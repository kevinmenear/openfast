#include "vit_translated.h"
// VIT Translation Scaffold
// Function: DBEMT_AB4
// Source: DBEMT.f90
// Module: DBEMT
// Fortran: SUBROUTINE DBEMT_AB4(i, j, t, n, u, utimes, p, x, OtherState, m, ErrStat, ErrMsg)
// Source MD5: 5cfa3e025419
// VIT: 0.1.0
// Status: unverified
// Generated: 2026-04-30T03:21:53Z

#include "vit_types.h"
#include "vit_nwtc.h"
#include <cstring>

void DBEMT_AB4(int i, int j, double t, int n, dbemt_elementinputtype_t* u, int n_u, double* utimes, int n_utimes, dbemt_parametertype_view_t* p, dbemt_continuousstatetype_view_t* x, dbemt_otherstatetype_view_t* OtherState, dbemt_miscvartype_t* m, int* ErrStat, char* ErrMsg) {
    *ErrStat = ErrID_None;
    std::memset(ErrMsg, ' ', ErrMsgLen);

    int x_idx = (j - 1) * x->n_element_rows + (i - 1);
    int n_idx = (j - 1) * OtherState->n_n_rows + (i - 1);

    if (OtherState->n[n_idx] < n) {
        OtherState->n[n_idx] = n;
        OtherState->xdot[3].element[x_idx] = OtherState->xdot[2].element[x_idx];
        OtherState->xdot[2].element[x_idx] = OtherState->xdot[1].element[x_idx];
        OtherState->xdot[1].element[x_idx] = OtherState->xdot[0].element[x_idx];
    } else if (OtherState->n[n_idx] > n) {
        SetErrStat(ErrID_Fatal, "Backing up in time is not supported with a multistep method.", ErrStat, ErrMsg, "DBEMT_AB4");
        return;
    }

    int ErrStat2 = 0;
    char ErrMsg2[ErrMsgLen];
    std::memset(ErrMsg2, ' ', ErrMsgLen);

    dbemt_elementinputtype_t u_interp;
    dbemt_elementinputtype_extrapinterp_c(u, n_u, utimes, n_utimes, &u_interp, t, &ErrStat2, ErrMsg2);
    SetErrStat(ErrStat2, ErrMsg2, ErrStat, ErrMsg, "DBEMT_AB4");
    if (*ErrStat >= AbortErrLev) return;

    dbemt_elementcontinuousstatetype_t x_tmp = x->element[x_idx];

    dbemt_calccontstatederiv_c(i, j, t, &u_interp, p, &x_tmp, OtherState, m,
        &OtherState->xdot[0].element[x_idx], &ErrStat2, ErrMsg2);
    SetErrStat(ErrStat2, ErrMsg2, ErrStat, ErrMsg, "DBEMT_AB4");
    if (*ErrStat >= AbortErrLev) return;

    if (n <= 2) {
        dbemt_rk4_c(i, j, t, n, u, n_u, utimes, n_utimes, p, x, OtherState, m, &ErrStat2, ErrMsg2);
        SetErrStat(ErrStat2, ErrMsg2, ErrStat, ErrMsg, "DBEMT_AB4");
        if (*ErrStat >= AbortErrLev) return;
    } else {
        double coeff = p->DT / 24.0;
        for (int k = 0; k < 2; k++) {
            x->element[x_idx].vind[k] += coeff * (
                55.0 * OtherState->xdot[0].element[x_idx].vind[k]
              - 59.0 * OtherState->xdot[1].element[x_idx].vind[k]
              + 37.0 * OtherState->xdot[2].element[x_idx].vind[k]
              -  9.0 * OtherState->xdot[3].element[x_idx].vind[k]);

            x->element[x_idx].vind_1[k] += coeff * (
                55.0 * OtherState->xdot[0].element[x_idx].vind_1[k]
              - 59.0 * OtherState->xdot[1].element[x_idx].vind_1[k]
              + 37.0 * OtherState->xdot[2].element[x_idx].vind_1[k]
              -  9.0 * OtherState->xdot[3].element[x_idx].vind_1[k]);
        }
    }
}

extern "C" {
    void dbemt_ab4_c(int i, int j, double t, int n, dbemt_elementinputtype_t* u, int n_u, double* utimes, int n_utimes, dbemt_parametertype_view_t* p, dbemt_continuousstatetype_view_t* x, dbemt_otherstatetype_view_t* OtherState, dbemt_miscvartype_t* m, int* ErrStat, char* ErrMsg) {
        DBEMT_AB4(i, j, t, n, u, n_u, utimes, n_utimes, p, x, OtherState, m, ErrStat, ErrMsg);
    }
}
