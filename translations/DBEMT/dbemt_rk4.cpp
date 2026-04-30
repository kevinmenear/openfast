// VIT Translation Scaffold
// Function: DBEMT_RK4
// Source: DBEMT.f90
// Module: DBEMT
// Fortran: SUBROUTINE DBEMT_RK4(i, j, t, n, u, utimes, p, x, OtherState, m, ErrStat, ErrMsg)
// Source MD5: 7627a1644504
// VIT: 0.1.0
// Status: unverified
// Generated: 2026-04-30T00:54:19Z

#include "vit_types.h"
#include "vit_nwtc.h"
#include <cstring>

void DBEMT_RK4(int i, int j, double t, int n, dbemt_elementinputtype_t* u, int n_u, double* utimes, int n_utimes, dbemt_parametertype_view_t* p, dbemt_continuousstatetype_view_t* x, dbemt_otherstatetype_view_t* OtherState, dbemt_miscvartype_t* m, int* ErrStat, char* ErrMsg) {
    *ErrStat = ErrID_None;
    std::memset(ErrMsg, ' ', ErrMsgLen);

    dbemt_elementcontinuousstatetype_t k1, k2, k3, k4, x_tmp;
    dbemt_elementinputtype_t u_interp;
    int ErrStat2 = 0;
    char ErrMsg2[ErrMsgLen];
    std::memset(ErrMsg2, ' ', ErrMsgLen);

    int x_idx = (j - 1) * x->n_element_rows + (i - 1);

    // Interpolate u at time t
    dbemt_elementinputtype_extrapinterp_c(u, n_u, utimes, n_utimes, &u_interp, t, &ErrStat2, ErrMsg2);
    SetErrStat(ErrStat2, ErrMsg2, ErrStat, ErrMsg, "DBEMT_RK4");
    if (*ErrStat >= AbortErrLev) return;

    x_tmp = x->element[x_idx];

    // k1 = f(t, x_t)
    dbemt_calccontstatederiv_c(i, j, t, &u_interp, p, &x_tmp, OtherState, m, &k1, &ErrStat2, ErrMsg2);
    SetErrStat(ErrStat2, ErrMsg2, ErrStat, ErrMsg, "DBEMT_RK4");
    if (*ErrStat >= AbortErrLev) return;

    for (int k = 0; k < 2; k++) {
        k1.vind[k]   = p->DT * k1.vind[k];
        k1.vind_1[k] = p->DT * k1.vind_1[k];
    }

    for (int k = 0; k < 2; k++) {
        x_tmp.vind[k]   = x->element[x_idx].vind[k]   + 0.5 * k1.vind[k];
        x_tmp.vind_1[k] = x->element[x_idx].vind_1[k] + 0.5 * k1.vind_1[k];
    }

    // Interpolate u at t + dt/2
    double TPlusHalfDt = t + 0.5 * p->DT;
    dbemt_elementinputtype_extrapinterp_c(u, n_u, utimes, n_utimes, &u_interp, TPlusHalfDt, &ErrStat2, ErrMsg2);
    SetErrStat(ErrStat2, ErrMsg2, ErrStat, ErrMsg, "DBEMT_RK4");
    if (*ErrStat >= AbortErrLev) return;

    // k2 = f(t + dt/2, x_t + k1/2)
    dbemt_calccontstatederiv_c(i, j, TPlusHalfDt, &u_interp, p, &x_tmp, OtherState, m, &k2, &ErrStat2, ErrMsg2);

    for (int k = 0; k < 2; k++) {
        k2.vind[k]   = p->DT * k2.vind[k];
        k2.vind_1[k] = p->DT * k2.vind_1[k];
    }

    for (int k = 0; k < 2; k++) {
        x_tmp.vind[k]   = x->element[x_idx].vind[k]   + 0.5 * k2.vind[k];
        x_tmp.vind_1[k] = x->element[x_idx].vind_1[k] + 0.5 * k2.vind_1[k];
    }

    // k3 = f(t + dt/2, x_t + k2/2)
    dbemt_calccontstatederiv_c(i, j, TPlusHalfDt, &u_interp, p, &x_tmp, OtherState, m, &k3, &ErrStat2, ErrMsg2);

    for (int k = 0; k < 2; k++) {
        k3.vind[k]   = p->DT * k3.vind[k];
        k3.vind_1[k] = p->DT * k3.vind_1[k];
    }

    for (int k = 0; k < 2; k++) {
        x_tmp.vind[k]   = x->element[x_idx].vind[k]   + k3.vind[k];
        x_tmp.vind_1[k] = x->element[x_idx].vind_1[k] + k3.vind_1[k];
    }

    // Interpolate u at t + dt
    double TPlusDt = t + p->DT;
    dbemt_elementinputtype_extrapinterp_c(u, n_u, utimes, n_utimes, &u_interp, TPlusDt, &ErrStat2, ErrMsg2);
    SetErrStat(ErrStat2, ErrMsg2, ErrStat, ErrMsg, "DBEMT_RK4");
    if (*ErrStat >= AbortErrLev) return;

    // k4 = f(t + dt, x_t + k3)
    dbemt_calccontstatederiv_c(i, j, TPlusDt, &u_interp, p, &x_tmp, OtherState, m, &k4, &ErrStat2, ErrMsg2);

    for (int k = 0; k < 2; k++) {
        k4.vind[k]   = p->DT * k4.vind[k];
        k4.vind_1[k] = p->DT * k4.vind_1[k];
    }

    // RK4 combination: x = x + (k1 + 2*k2 + 2*k3 + k4) / 6
    for (int k = 0; k < 2; k++) {
        x->element[x_idx].vind[k]   += (k1.vind[k]   + 2.0 * k2.vind[k]   + 2.0 * k3.vind[k]   + k4.vind[k])   / 6.0;
        x->element[x_idx].vind_1[k] += (k1.vind_1[k] + 2.0 * k2.vind_1[k] + 2.0 * k3.vind_1[k] + k4.vind_1[k]) / 6.0;
    }
}
