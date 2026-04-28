// VIT Translation
// Function: ComputeTau2
// Source: DBEMT.f90
// Module: DBEMT
// Fortran: SUBROUTINE ComputeTau2(i, j, u, p, tau1, tau2, k_tau_out)

#include "vit_types.h"
#include "vit_aerodyn_constants.h"

void ComputeTau2(int i, int j,
    const dbemt_elementinputtype_t* u,
    const dbemt_parametertype_view_t* p,
    double tau1, double* tau2,
    int has_k_tau_out, double* k_tau_out)
{
    double spanRatio;

    if (p->DBEMT_Mod == DBEMT_tauConst || p->DBEMT_Mod == DBEMT_cont_tauConst) {
        spanRatio = p->spanRatio[(j - 1) * p->n_spanRatio_rows + (i - 1)];
    } else {
        spanRatio = u->spanRatio;
    }

    double k_tau = 0.39 - 0.26 * spanRatio * spanRatio;
    *tau2 = k_tau * tau1;

    if (has_k_tau_out) {
        *k_tau_out = k_tau;
    }
}
