// VIT Translation Scaffold
// Function: DBEMT_ABM4
// Source: DBEMT.f90
// Module: DBEMT
// Fortran: SUBROUTINE DBEMT_ABM4(i, j, t, n, u, utimes, p, x, OtherState, m, ErrStat, ErrMsg)
// Source MD5: f2407982fc56
// VIT: 0.1.0
// Status: unverified
// Generated: 2026-04-30T03:41:47Z

#include "vit_types.h"
#include "vit_nwtc.h"
#include <cstring>

void DBEMT_ABM4(int i, int j, double t, int n, dbemt_elementinputtype_t* u, int n_u, double* utimes, int n_utimes, dbemt_parametertype_view_t* p, dbemt_continuousstatetype_view_t* x, dbemt_otherstatetype_view_t* OtherState, dbemt_miscvartype_t* m, int* ErrStat, char* ErrMsg) {
    *ErrStat = ErrID_None;
    std::memset(ErrMsg, ' ', ErrMsgLen);

    int x_idx = (j - 1) * x->n_element_rows + (i - 1);

    dbemt_elementcontinuousstatetype_t x_in = x->element[x_idx];

    int ErrStat2 = 0;
    char ErrMsg2[ErrMsgLen];
    std::memset(ErrMsg2, ' ', ErrMsgLen);

    dbemt_ab4_c(i, j, t, n, u, n_u, utimes, n_utimes, p, x, OtherState, m, &ErrStat2, ErrMsg2);
    SetErrStat(ErrStat2, ErrMsg2, ErrStat, ErrMsg, "DBEMT_ABM4");
    if (*ErrStat >= AbortErrLev) return;

    if (n > 2) {
        dbemt_elementinputtype_t u_interp;
        dbemt_elementinputtype_extrapinterp_c(u, n_u, utimes, n_utimes, &u_interp, t + p->DT, &ErrStat2, ErrMsg2);
        SetErrStat(ErrStat2, ErrMsg2, ErrStat, ErrMsg, "DBEMT_ABM4");
        if (*ErrStat >= AbortErrLev) return;

        dbemt_elementcontinuousstatetype_t xdot_pred;
        dbemt_calccontstatederiv_c(i, j, t + p->DT, &u_interp, p, &x->element[x_idx], OtherState, m, &xdot_pred, &ErrStat2, ErrMsg2);
        SetErrStat(ErrStat2, ErrMsg2, ErrStat, ErrMsg, "DBEMT_ABM4");
        if (*ErrStat >= AbortErrLev) return;

        double coeff = p->DT / 24.0;
        for (int k = 0; k < 2; k++) {
            x->element[x_idx].vind[k] = x_in.vind[k] + coeff * (
                 9.0 * xdot_pred.vind[k]
              + 19.0 * OtherState->xdot[0].element[x_idx].vind[k]
              -  5.0 * OtherState->xdot[1].element[x_idx].vind[k]
              +  1.0 * OtherState->xdot[2].element[x_idx].vind[k]);

            x->element[x_idx].vind_1[k] = x_in.vind_1[k] + coeff * (
                 9.0 * xdot_pred.vind_1[k]
              + 19.0 * OtherState->xdot[0].element[x_idx].vind_1[k]
              -  5.0 * OtherState->xdot[1].element[x_idx].vind_1[k]
              +  1.0 * OtherState->xdot[2].element[x_idx].vind_1[k]);
        }
    }
}
