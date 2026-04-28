// VIT Translation
// Function: AFI_Init
// Source: AirfoilInfo.f90
// Module: AirfoilInfo
// Fortran: SUBROUTINE AFI_Init(InitInput, p, ErrStat, ErrMsg, UnEcho)
// Status: unverified
// Verification: simulation (17/17 baselines)

#include "vit_types.h"
#include "vit_nwtc.h"
#include "vit_aerodyn_constants.h"

#include <algorithm>
#include <cmath>
#include <cstring>
#include <string>

static void setErrStat(int errStatIn, const std::string& errMsgIn,
                       int* errStat, char* errMsg) {
    if (errStatIn > *errStat) {
        *errStat = errStatIn;
        setErrMsg(errMsg, errMsgIn);
    }
}

static std::string trimFilename(const char* buf, int len) {
    int end = len;
    while (end > 0 && (buf[end - 1] == ' ' || buf[end - 1] == '\0')) end--;
    return std::string(buf, end);
}

static bool CheckValuesAreUniqueMonotonicIncreasing(const double* vals, int n) {
    for (int i = 1; i < n; i++) {
        if (EqualRealNos(vals[i], vals[i - 1]) || vals[i] < vals[i - 1])
            return false;
    }
    return true;
}

extern "C" {

// Pass 1: Column setup + multi-table validation.
// Called AFTER ReadAFfile has populated Table/Alpha/Coefs arrays.
// Returns allocation sizes for secondVals and SplineCoefs.
void afi_init_pass1_c(
    const afi_initinputtype_t* InitInput,
    afi_parametertype_view_t* p,
    int* n_secondVals_out,
    double* secondVals_buf,
    int* spline_dim1_out,
    int* spline_dim2_out,
    int* errStat,
    char* errMsg)
{
    *errStat = ErrID_None;
    std::memset(errMsg, ' ', ErrMsgLen);
    *n_secondVals_out = 0;

    std::string filename = trimFilename(p->FileName, 1024);

    // Column indices (ColCl, ColCd, ColCm, ColCpmin, ColUAf) are already set
    // by the Fortran wrapper before ReadAFfile runs. ReadAFfile further updates
    // ColUAf. Do NOT reset them here — that would overwrite ColUAf.

    // Multi-table validation (lines 175-267)
    if (p->NumTabs > 1) {
        if (p->AFTabMod == AFITable_1) {
            p->NumTabs = 1;
            setErrStat(ErrID_Warn,
                "DimModel = 1D, therefore using only the first airfoil table in the file: \""
                + filename + "\"", errStat, errMsg);
        } else {
            *n_secondVals_out = p->NumTabs;

            if (p->AFTabMod == AFITable_2Re) {
                // Validate UserProp consistency
                for (int i = 1; i < p->NumTabs; i++) {
                    if (p->Table[i].UserProp != p->Table[0].UserProp) {
                        setErrStat(ErrID_Fatal,
                            "Fatal Error: airfoil file \"" + filename
                            + "\", Table #" + std::to_string(i + 1)
                            + " does not have the same value for Ctrl Property (UserProp) as the first table.",
                            errStat, errMsg);
                        return;
                    }
                }
                // Validate Re >= 0, clamp, compute log(Re)
                for (int i = 0; i < p->NumTabs; i++) {
                    if (p->Table[i].Re < 0.0) {
                        setErrStat(ErrID_Fatal,
                            "Fatal Error: airfoil file \"" + filename
                            + "\", Table #" + std::to_string(i + 1)
                            + " has a negative Reynolds Number.",
                            errStat, errMsg);
                        return;
                    }
                    p->Table[i].Re = std::max(p->Table[i].Re, 0.001);
                    secondVals_buf[i] = std::log(p->Table[i].Re);
                }
            } else if (p->AFTabMod == AFITable_2User) {
                secondVals_buf[0] = p->Table[0].UserProp;
                for (int i = 1; i < p->NumTabs; i++) {
                    if (p->Table[i].Re != p->Table[0].Re) {
                        setErrStat(ErrID_Fatal,
                            "Fatal Error: airfoil file \"" + filename
                            + "\", Table #" + std::to_string(i + 1)
                            + " does not have the same value for Re Property (Re) as the first table.",
                            errStat, errMsg);
                        return;
                    }
                    secondVals_buf[i] = p->Table[i].UserProp;
                }
            }

            if (!CheckValuesAreUniqueMonotonicIncreasing(secondVals_buf, p->NumTabs)) {
                std::string msg = "Fatal Error: airfoil file \"" + filename
                    + "\", is not monotonic and increasing in the ";
                if (p->AFTabMod == AFITable_2Re)
                    msg += "Re Property (Re).";
                else
                    msg += "Ctrl Property (UserProp).";
                setErrStat(ErrID_Fatal, msg, errStat, errMsg);
                return;
            }
        }
    } else {
        p->AFTabMod = AFITable_1;
    }

    // Compute per-table SplineCoefs dimensions
    for (int i = 0; i < p->n_Table; i++) {
        if (p->Table[i].ConstData) {
            spline_dim1_out[i] = 0;
            spline_dim2_out[i] = 0;
        } else {
            spline_dim1_out[i] = p->Table[i].NumAlf - 1;
            spline_dim2_out[i] = p->Table[i].n_Coefs_cols;
        }
    }
}

// Pass 2: Fill secondVals + compute spline coefficients.
// Called AFTER Fortran allocates secondVals and SplineCoefs arrays.
void afi_init_pass2_c(
    afi_parametertype_view_t* p,
    const double* secondVals_buf,
    int n_secondVals,
    int* errStat,
    char* errMsg)
{
    *errStat = ErrID_None;
    std::memset(errMsg, ' ', ErrMsgLen);

    std::string filename = trimFilename(p->FileName, 1024);

    // Copy secondVals from temp buffer to allocated array
    if (n_secondVals > 0 && p->secondVals != nullptr) {
        for (int i = 0; i < n_secondVals; i++) {
            p->secondVals[i] = secondVals_buf[i];
        }
    }

    // Per-table spline initialization (lines 270-322)
    int numTabsToProcess = (p->NumTabs < p->n_Table) ? p->NumTabs : p->n_Table;
    for (int i = 0; i < numTabsToProcess; i++) {
        afi_table_type_view_t* tab = &p->Table[i];
        if (tab->ConstData) continue;

        int errStat2 = ErrID_None;
        char errMsg2[ErrMsgLen];
        std::memset(errMsg2, ' ', ErrMsgLen);

        if (p->InterpOrd == 3) {
            CubicSplineInitM(tab->Alpha, tab->Coefs, tab->SplineCoefs,
                             tab->NumAlf, tab->n_Coefs_cols,
                             &errStat2, errMsg2);
            if (errStat2 > *errStat) {
                *errStat = errStat2;
                std::memcpy(errMsg, errMsg2, ErrMsgLen);
            }
        } else if (p->InterpOrd == 1) {
            CubicLinSplineInitM(tab->Alpha, tab->Coefs, tab->SplineCoefs,
                                tab->NumAlf, tab->n_Coefs_cols,
                                &errStat2, errMsg2);
            if (errStat2 > *errStat) {
                *errStat = errStat2;
                std::memcpy(errMsg, errMsg2, ErrMsgLen);
            }
        } else {
            setErrStat(ErrID_Fatal,
                "Airfoil file \"" + filename
                + "\": InterpOrd must be 1 (linear) or 3 (cubic spline).",
                errStat, errMsg);
            return;
        }
    }
}

} // extern "C"
