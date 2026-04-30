// VIT Translation Scaffold
// Function: ComputeUA360_AttachedFlow
// Source: AirfoilInfo.f90
// Module: AirfoilInfo
// Fortran: SUBROUTINE ComputeUA360_AttachedFlow(p, ColUAf, cn_cl, iLower, iUpper)
// Source MD5: 83fec875aeef
// VIT: 0.1.0
// Status: unverified
// Generated: 2026-04-25T23:30:55Z

#include "vit_types.h"
#include "vit_nwtc.h"
#include "vit_fortran_intrinsics.h"
#include <vector>

// 2D column-major access: Coefs(Row, Col) in Fortran = Coefs[(Col-1)*nrows + (Row-1)] in C
#define COEFS(row1, col1) p->Coefs[((col1)-1) * p->n_Coefs_rows + ((row1)-1)]

void ComputeUA360_AttachedFlow(afi_table_type_view_t* p, int ColUAf, double* cn_cl, int n_cn_cl, int* iLower, int* iUpper) {
    int N = p->NumAlf;

    // Set column numbers
    int col_fa = ColUAf + 2;

    // Get bounds
    compute_iloweriupper_c(p, iLower, iUpper);

    p->UA_BL.alphaLower = p->Alpha[*iLower - 1];
    p->UA_BL.alphaUpper = p->Alpha[*iUpper - 1];

    p->UA_BL.c_alphaLower = cn_cl[*iLower - 1];
    p->UA_BL.c_alphaUpper = cn_cl[*iUpper - 1];

    // From dynamicStallLUT.m/updateCnAttached()
    // CnSlopeUpper = (cn_cl(iUpper-1) - cn_cl(iUpper)) / (alpha(iUpper-1) - alpha(iUpper))
    double CnSlopeUpper = (cn_cl[*iUpper - 2] - cn_cl[*iUpper - 1]) /
                           (p->Alpha[*iUpper - 2] - p->Alpha[*iUpper - 1]);
    double alpha0Upper;
    if (EqualRealNos(CnSlopeUpper, 0.0)) {
        alpha0Upper = p->Alpha[*iUpper - 1];
    } else {
        alpha0Upper = p->Alpha[*iUpper - 1] - cn_cl[*iUpper - 1] / CnSlopeUpper;
    }

    // CnSlopeLower = (cn_cl(iLower) - cn_cl(iLower+1)) / (alpha(iLower) - alpha(iLower+1))
    double CnSlopeLower = (cn_cl[*iLower - 1] - cn_cl[*iLower]) /
                           (p->Alpha[*iLower - 1] - p->Alpha[*iLower]);
    double alpha0Lower;
    if (EqualRealNos(CnSlopeLower, 0.0)) {
        alpha0Lower = p->Alpha[*iLower - 1];
    } else {
        alpha0Lower = p->Alpha[*iLower - 1] - cn_cl[*iLower - 1] / CnSlopeLower;
    }

    // Find reverse flow Cn = 0 near positive 180 deg (and not in the range (-45, 45) degrees)
    std::vector<double> roots(N);
    int nZeros;
    fZeros(p->Alpha, cn_cl, N, roots.data(), N, nZeros, true, TwoPi);

    p->UA_BL.alpha0ReverseFlow = p->Alpha[0];  // default value
    if (nZeros > 0) {
        int iRoot = fortran_maxloc(nZeros,
            [&](int i) { return std::abs(roots[i]); },
            [&](int i) { return std::abs(roots[i]) >= 45.0 * D2R; });
        if (std::abs(roots[iRoot - 1]) >= 45.0 * D2R) {
            p->UA_BL.alpha0ReverseFlow = roots[iRoot - 1];
            if (p->UA_BL.alpha0ReverseFlow < -PiBy2) {
                p->UA_BL.alpha0ReverseFlow = p->UA_BL.alpha0ReverseFlow + TwoPi;
            }
        }
    }
    double CnSlopeReverseFlow = -TwoPi;

    // Find intersections
    p->UA_BL.alphaBreakUpper = (CnSlopeReverseFlow * p->UA_BL.alpha0ReverseFlow -
                                 CnSlopeUpper * alpha0Upper) /
                                (CnSlopeReverseFlow - CnSlopeUpper);
    p->UA_BL.CnBreakUpper = CnSlopeUpper * (p->UA_BL.alphaBreakUpper - alpha0Upper);

    p->UA_BL.alphaBreakLower = (CnSlopeReverseFlow * (p->UA_BL.alpha0ReverseFlow - TwoPi) -
                                 CnSlopeLower * alpha0Lower) /
                                (CnSlopeReverseFlow - CnSlopeLower);
    p->UA_BL.CnBreakLower = CnSlopeLower * (p->UA_BL.alphaBreakLower - alpha0Lower);

    // Set fully attached values
    int Indx = 1;
    double x_[3] = {p->UA_BL.alpha0ReverseFlow - TwoPi, p->UA_BL.alphaBreakLower, p->Alpha[*iLower - 1]};
    double f_[3] = {0.0, p->UA_BL.CnBreakLower, cn_cl[*iLower - 1]};
    for (int Row = 1; Row <= *iLower - 1; Row++) {
        COEFS(Row, col_fa) = InterpExtrapStp(p->Alpha[Row - 1], x_, f_, Indx, 3);
    }

    for (int Row = *iLower; Row <= *iUpper; Row++) {
        COEFS(Row, col_fa) = cn_cl[Row - 1];
    }

    x_[0] = p->Alpha[*iUpper - 1];  x_[1] = p->UA_BL.alphaBreakUpper;  x_[2] = p->UA_BL.alpha0ReverseFlow;
    f_[0] = cn_cl[*iUpper - 1];     f_[1] = p->UA_BL.CnBreakUpper;     f_[2] = 0.0;
    for (int Row = *iUpper + 1; Row <= N; Row++) {
        COEFS(Row, col_fa) = InterpExtrapStp(p->Alpha[Row - 1], x_, f_, Indx, 3);
    }
}

#undef COEFS
