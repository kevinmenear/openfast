// VIT Translation Scaffold
// Function: DBEMT_ReInit
// Source: DBEMT.f90
// Module: DBEMT
// Fortran: SUBROUTINE DBEMT_ReInit(p, x, OtherState, m)
// Source MD5: cee0744ddb5d
// VIT: 0.1.0
// Status: unverified
// Generated: 2026-05-01T09:19:22Z

#include "vit_types.h"
#include "vit_aerodyn_constants.h"

void DBEMT_ReInit(dbemt_parametertype_view_t* p, dbemt_continuousstatetype_view_t* x, dbemt_otherstatetype_view_t* OtherState, dbemt_miscvartype_t* m) {
    int i, j, n;
    int nRows = x->n_element_rows;
    int nCols = x->n_element_cols;

    for (j = 1; j <= nCols; j++) {
        for (i = 1; i <= nRows; i++) {
            int idx = (j - 1) * nRows + (i - 1);
            x->element[idx].vind[0] = 0.0;
            x->element[idx].vind[1] = 0.0;
            x->element[idx].vind_1[0] = 0.0;
            x->element[idx].vind_1[1] = 0.0;
        }
    }

    int nInit = OtherState->n_areStatesInitialized_rows * OtherState->n_areStatesInitialized_cols;
    for (int k = 0; k < nInit; k++) {
        OtherState->areStatesInitialized[k] = 0;
    }

    if (p->DBEMT_Mod == DBEMT_tauConst || p->DBEMT_Mod == DBEMT_cont_tauConst) {
        OtherState->tau1 = p->tau1_const;
    } else {
        OtherState->tau1 = 0.0;
    }

    if (OtherState->n != nullptr) {
        int nN = OtherState->n_n_rows * OtherState->n_n_cols;
        for (int k = 0; k < nN; k++) {
            OtherState->n[k] = -1;
        }

        for (n = 0; n < 4; n++) {
            for (j = 1; j <= nCols; j++) {
                for (i = 1; i <= nRows; i++) {
                    int idx = (j - 1) * nRows + (i - 1);
                    OtherState->xdot[n].element[idx].vind[0] = x->element[idx].vind[0];
                    OtherState->xdot[n].element[idx].vind[1] = x->element[idx].vind[1];
                    OtherState->xdot[n].element[idx].vind_1[0] = x->element[idx].vind_1[0];
                    OtherState->xdot[n].element[idx].vind_1[1] = x->element[idx].vind_1[1];
                }
            }
        }
    }

    m->FirstWarn_tau1 = 1;
}

extern "C" {
    void dbemt_reinit_c(dbemt_parametertype_view_t* p, dbemt_continuousstatetype_view_t* x, dbemt_otherstatetype_view_t* OtherState, dbemt_miscvartype_t* m) {
        DBEMT_ReInit(p, x, OtherState, m);
    }
}
