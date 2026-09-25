// VIT Translation
// Function: AFI_Init
// Source: AirfoilInfo.f90
// Module: AirfoilInfo
// Fortran: SUBROUTINE AFI_Init(InitInput, p, ErrStat, ErrMsg, UnEcho)
// Integration: ONE call through the VIT-generated wrapper. p is INTENT(OUT):
// every ALLOCATABLE component arrives deallocated, and the ones the Fortran
// ALLOCATEs -- through ReadAFfile (Table, Alpha, Coefs, X/Y_Coord) and here
// (secondVals, SplineCoefs(NumAlf-1, nCoefs, 0:3)) -- are allocated with
// vit_adopt_alloc[_lb] and adopted by the wrapper (vit_adopt_afi_parametertype).
// There is no hand-written two-pass wrapper.
// Status: unverified

#include "vit_types.h"
#include "vit_nwtc.h"
#include "vit_aerodyn_constants.h"
#include "vit_translated.h"

#include <algorithm>
#include <cmath>
#include <cstring>
#include <string>

// Standalone translated unit (checkvaluesareuniquemonotonicincreasing.cpp).
bool CheckValuesAreUniqueMonotonicIncreasing(const double* secondVals, int n);

static const char* RoutineName = "AFI_Init";

static std::string trimFilename(const char* buf, int len) {
    int end = len;
    while (end > 0 && (buf[end - 1] == ' ' || buf[end - 1] == '\0')) end--;
    return std::string(buf, end);
}

// TRIM(ErrMsg2), as the Fortran SetErrStat applies it.
static std::string trimmed(const char* buf) {
    int end = ErrMsgLen;
    while (end > 0 && (buf[end - 1] == ' ' || buf[end - 1] == '\0')) end--;
    return std::string(buf, end);
}

static void finish(int es, const char* em, int* ErrStat, char* ErrMsg, int len_ErrMsg) {
    *ErrStat = es;
    int n = len_ErrMsg < ErrMsgLen ? len_ErrMsg : ErrMsgLen;
    std::memcpy(ErrMsg, em, n);
    if (len_ErrMsg > n) std::memset(ErrMsg + n, ' ', len_ErrMsg - n);
}

void AFI_Init(afi_initinputtype_t* InitInput, afi_parametertype_view_t* p,
              int* ErrStat, char* ErrMsg, int len_ErrMsg, int has_UnEcho, int UnEcho) {
    int es = ErrID_None;
    char em[ErrMsgLen];
    std::memset(em, ' ', ErrMsgLen);
    int es2;
    char em2[ErrMsgLen];

    // p%FileName = InitInput%FileName
    std::memcpy(p->FileName, InitInput->FileName, sizeof(p->FileName));
    const std::string filename = trimFilename(InitInput->FileName, sizeof(InitInput->FileName));

    // CALL AFI_ValidateInitInput(InitInput, ErrStat2, ErrMsg2)
    es2 = ErrID_None;
    std::memset(em2, ' ', ErrMsgLen);
    afi_validateinitinput_c(InitInput, &es2, em2);
    SetErrStat(es2, trimmed(em2), &es, em, RoutineName);
    if (es >= AbortErrLev) { finish(es, em, ErrStat, ErrMsg, len_ErrMsg); return; }

    // UnEc = UnEcho if present, else -1. The echo WRITE to a Fortran unit is
    // not reachable from C++ (the conformance matrix's c_unit_write); as in the
    // previous integration, ReadAFfile's echo is dropped too.
    int UnEc = has_UnEcho ? UnEcho : -1;

    p->AFTabMod = InitInput->AFTabMod;
    p->ColCl = 1;
    p->ColCd = 2;
    p->ColCm = 0;
    p->ColCpmin = 0;
    p->ColUAf = 0;
    if (InitInput->InCol_Cm > 0) {
        p->ColCm = 3;
        if (InitInput->InCol_Cpmin > 0) p->ColCpmin = 4;
    } else if (InitInput->InCol_Cpmin > 0) {
        p->ColCpmin = 3;
    }
    int NumCoefs = std::max(p->ColCd, std::max(p->ColCm, p->ColCpmin));

    // CALL ReadAFfile ( InitInput, NumCoefs, p, ErrStat2, ErrMsg2, UnEc )
    es2 = ErrID_None;
    readaffile_c(InitInput, NumCoefs, p, &es2, em2, ErrMsgLen, UnEc);
    SetErrStat(es2, trimmed(em2), &es, em, RoutineName);
    if (es >= AbortErrLev) { finish(es, em, ErrStat, ErrMsg, len_ErrMsg); return; }

    if (p->NumTabs > 1) {
        if (p->AFTabMod == AFITable_1) {
            p->NumTabs = 1;
            SetErrStat(ErrID_Warn,
                "DimModel = 1D, therefore using only the first airfoil table in the file: \"" + filename,
                &es, em, RoutineName);
        } else {
            // ALLOCATE(p%secondVals(p%NumTabs))
            p->secondVals = static_cast<double*>(vit_adopt_alloc(p->NumTabs * sizeof(double)));
            p->n_secondVals = p->NumTabs;

            if (p->AFTabMod == AFITable_2Re) {
                for (int i = 1; i < p->NumTabs; i++) {
                    if (p->Table[i].UserProp != p->Table[0].UserProp) {
                        SetErrStat(ErrID_Fatal, "Fatal Error: airfoil file \"" + filename
                            + "\", Table #" + std::to_string(i + 1)
                            + " does not have the same value for Ctrl Property (UserProp) as the first table.",
                            &es, em, RoutineName);
                        finish(es, em, ErrStat, ErrMsg, len_ErrMsg); return;
                    }
                }
                for (int i = 0; i < p->NumTabs; i++) {
                    if (p->Table[i].Re < 0.0) {
                        SetErrStat(ErrID_Fatal, "Fatal Error: airfoil file \"" + filename
                            + "\", Table #" + std::to_string(i + 1)
                            + " has a negative Reynolds Number.", &es, em, RoutineName);
                        finish(es, em, ErrStat, ErrMsg, len_ErrMsg); return;
                    }
                    p->Table[i].Re = std::max(p->Table[i].Re, 0.001);
                    p->secondVals[i] = std::log(p->Table[i].Re);
                }
            } else if (p->AFTabMod == AFITable_2User) {
                p->secondVals[0] = p->Table[0].UserProp;
                for (int i = 1; i < p->NumTabs; i++) {
                    if (p->Table[i].Re != p->Table[0].Re) {
                        SetErrStat(ErrID_Fatal, "Fatal Error: airfoil file \"" + filename
                            + "\", Table #" + std::to_string(i + 1)
                            + " does not have the same value for Re Property (Re) as the first table.",
                            &es, em, RoutineName);
                        finish(es, em, ErrStat, ErrMsg, len_ErrMsg); return;
                    }
                    p->secondVals[i] = p->Table[i].UserProp;
                }
            }

            if (!CheckValuesAreUniqueMonotonicIncreasing(p->secondVals, p->NumTabs)) {
                std::string msg = "Fatal Error: airfoil file \"" + filename
                    + "\", is not monotonic and increasing in the ";
                msg += (p->AFTabMod == AFITable_2Re) ? " Re Property (Re)." : " Ctrl Property (UserProp).";
                SetErrStat(ErrID_Fatal, msg, &es, em, RoutineName);
                finish(es, em, ErrStat, ErrMsg, len_ErrMsg); return;
            }
        }
    } else {
        p->AFTabMod = AFITable_1;
    }

    for (int i = 0; i < p->NumTabs; i++) {
        afi_table_type_view_t* tab = &p->Table[i];
        if (tab->ConstData) continue;
        int nr = tab->NumAlf - 1;
        int nc = tab->n_Coefs_cols;
        // allocate ( p%Table(iTable)%SplineCoefs( NumAlf-1, size(Coefs,2), 0:3 ) )
        tab->SplineCoefs = static_cast<double*>(
            vit_adopt_alloc_lb((size_t)nr * nc * 4 * sizeof(double), 3, 1, 1, 0));
        tab->n_SplineCoefs_dim1 = nr;
        tab->n_SplineCoefs_dim2 = nc;
        tab->n_SplineCoefs_dim3 = 4;

        es2 = ErrID_None;
        std::memset(em2, ' ', ErrMsgLen);
        if (p->InterpOrd == 3) {
            CubicSplineInitM(tab->Alpha, tab->Coefs, tab->SplineCoefs, tab->NumAlf, nc, &es2, em2);
            SetErrStat(es2, trimmed(em2), &es, em, RoutineName);
        } else if (p->InterpOrd == 1) {
            CubicLinSplineInitM(tab->Alpha, tab->Coefs, tab->SplineCoefs, tab->NumAlf, nc, &es2, em2);
            SetErrStat(es2, trimmed(em2), &es, em, RoutineName);
        } else {
            SetErrStat(ErrID_Fatal, "Airfoil file \"" + filename
                + "\": InterpOrd must be 1 (linear) or 3 (cubic spline).", &es, em, RoutineName);
            finish(es, em, ErrStat, ErrMsg, len_ErrMsg); return;
        }
    }

    finish(es, em, ErrStat, ErrMsg, len_ErrMsg);
}
