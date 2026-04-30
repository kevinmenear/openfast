// VIT Translation
// Function: ComputeTau1
// Source: DBEMT.f90
// Module: DBEMT
// Fortran: SUBROUTINE ComputeTau1(u, p, m, tau1, errStat, errMsg)

#include "vit_types.h"
#include "vit_translated.h"
#include "vit_nwtc.h"
#include "vit_aerodyn_constants.h"
#include <algorithm>
#include <cstring>

void ComputeTau1(const dbemt_inputtype_view_t* u,
                 const dbemt_parametertype_view_t* p,
                 dbemt_miscvartype_t* m,
                 double* tau1,
                 int* errStat, char* errMsg)
{
    constexpr double max_AxInd = 0.5;
    constexpr double min_Un = 0.1;

    *errStat = ErrID_None;
    std::memset(errMsg, ' ', ErrMsgLen);

    if (p->DBEMT_Mod == DBEMT_tauConst || p->DBEMT_Mod == DBEMT_cont_tauConst) {
        *tau1 = p->tau1_const;
    } else {
        double AxInd_disk;
        if (u->AxInd_disk > max_AxInd) {
            AxInd_disk = max_AxInd;
            if (m->FirstWarn_tau1) {
                SetErrStat(ErrID_Severe,
                    ("Rotor-averaged axial induction factor is greater than "
                    + num2lstr(max_AxInd)
                    + "; limiting time-varying tau1. This message will not be repeated though the condition may persist."),
                    errStat, errMsg, "ComputeTau");
                m->FirstWarn_tau1 = 0;
            }
        } else {
            AxInd_disk = u->AxInd_disk;
        }

        double Un_disk;
        if (u->Un_disk < min_Un) {
            Un_disk = min_Un;
            if (m->FirstWarn_tau1) {
                SetErrStat(ErrID_Severe,
                    ("Uninduced axial relative air speed, Un, is less than "
                    + num2lstr(min_Un)
                    + " m/s; limiting time-varying tau1. This message will not be repeated though the condition may persist."),
                    errStat, errMsg, "ComputeTau");
                m->FirstWarn_tau1 = 0;
            }
        } else {
            Un_disk = u->Un_disk;
        }

        double temp = (1.0 - 1.3 * AxInd_disk) * Un_disk;
        *tau1 = 1.1 * u->R_disk / temp;
        *tau1 = std::min(*tau1, 100.0);
    }
}

extern "C" {
    void computetau1_c(dbemt_inputtype_view_t* u, dbemt_parametertype_view_t* p, dbemt_miscvartype_t* m, double* tau1, int* errStat, char* errMsg) {
        ComputeTau1(u, p, m, tau1, errStat, errMsg);
    }
}
