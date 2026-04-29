// VIT Translation Scaffold
// Function: DBEMT_InitStates
// Source: DBEMT.f90
// Module: DBEMT
// Fortran: SUBROUTINE DBEMT_InitStates(i, j, u, p, x, OtherState)
// Source MD5: 573844d0b606
// VIT: 0.1.0
// Status: unverified
// Generated: 2026-04-29T13:44:57Z

#include "vit_types.h"
#include "vit_aerodyn_constants.h"

void DBEMT_InitStates(int i, int j, dbemt_inputtype_view_t* u, dbemt_parametertype_view_t* p, dbemt_continuousstatetype_view_t* x, dbemt_otherstatetype_view_t* OtherState) {
    int os_idx = (j - 1) * OtherState->n_areStatesInitialized_rows + (i - 1);

    if (!OtherState->areStatesInitialized[os_idx]) {
        int x_idx = (j - 1) * x->n_element_rows + (i - 1);
        int u_idx = (j - 1) * u->n_element_rows + (i - 1);

        x->element[x_idx].vind[0] = u->element[u_idx].vind_s[0];
        x->element[x_idx].vind[1] = u->element[u_idx].vind_s[1];

        if (p->DBEMT_Mod == DBEMT_cont_tauConst) {
            x->element[x_idx].vind_1[0] = (1.0 - p->k_0ye) * u->element[u_idx].vind_s[0];
            x->element[x_idx].vind_1[1] = (1.0 - p->k_0ye) * u->element[u_idx].vind_s[1];
        } else {
            x->element[x_idx].vind_1[0] = u->element[u_idx].vind_s[0];
            x->element[x_idx].vind_1[1] = u->element[u_idx].vind_s[1];
        }

        OtherState->areStatesInitialized[os_idx] = 1;
        return;
    }
}
