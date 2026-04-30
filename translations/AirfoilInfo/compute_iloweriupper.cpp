// VIT Translation Scaffold
// Function: Compute_iLoweriUpper
// Source: AirfoilInfo.f90
// Module: AirfoilInfo
// Fortran: SUBROUTINE Compute_iLoweriUpper(p, iLower, iUpper)
// Source MD5: 8fd66298e8f3
// VIT: 0.1.0
// Status: unverified
// Generated: 2026-04-24T22:30:43Z

#include "vit_types.h"
#include "vit_fortran_intrinsics.h"

void Compute_iLoweriUpper(afi_table_type_view_t* p, int* iLower, int* iUpper) {
    *iLower = fortran_minloc(p->n_Alpha,
        [&](int i) { return p->Alpha[i]; },
        [&](int i) { return p->Alpha[i] >= p->UA_BL.alphaLower; });

    *iUpper = fortran_maxloc(p->n_Alpha,
        [&](int i) { return p->Alpha[i]; },
        [&](int i) { return p->Alpha[i] <= p->UA_BL.alphaUpper; });

    // Clamp to valid ranges (1-based)
    int numAlf = p->NumAlf;
    *iLower = *iLower < 1 ? 1 : (*iLower > numAlf - 1 ? numAlf - 1 : *iLower);
    *iUpper = *iUpper < 2 ? 2 : (*iUpper > numAlf ? numAlf : *iUpper);
}
