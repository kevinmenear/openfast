// VIT Translation Scaffold
// Function: ComputeUASeparationFunction_zero
// Source: AirfoilInfo.f90
// Module: AirfoilInfo
// Fortran: SUBROUTINE ComputeUASeparationFunction_zero(p, ColUAf, cn_cl)
// Source MD5: 6b46a1891169
// VIT: 0.1.0
// Status: unverified
// Generated: 2026-04-25T18:02:05Z

#include "vit_types.h"
#include <cmath>
#include <limits>

// 2D column-major access: Coefs(Row, Col) in Fortran = Coefs[(Col-1)*nrows + (Row-1)] in C
#define COEFS(row1, col1) p->Coefs[((col1)-1) * p->n_Coefs_rows + ((row1)-1)]

void ComputeUASeparationFunction_zero(afi_table_type_view_t* p, int ColUAf, double* cn_cl, int n_cn_cl) {
    const double TwoPi = 2.0 * M_PI;

    // Column numbers (1-based, matching Fortran)
    int col_fs = ColUAf + 1;
    int col_fa = col_fs + 1;

    // Find iLow: last row where alpha < alphaLower AND Coefs(:,ColUAf) is at its minimum
    // Fortran: iTemp = minloc(Coefs(:,ColUAf), DIM=1, MASK=alpha < alphaLower)
    //          iLow  = maxloc(alpha, DIM=1, MASK=alpha < alphaLower AND Coefs(:,ColUAf) == Coefs(iTemp,ColUAf))
    int iTemp = -1;
    double minVal = std::numeric_limits<double>::max();
    for (int i = 0; i < p->NumAlf; i++) {
        if (p->Alpha[i] < p->UA_BL.alphaLower) {
            if (COEFS(i + 1, ColUAf) < minVal) {
                minVal = COEFS(i + 1, ColUAf);
                iTemp = i + 1;  // 1-based
            }
        }
    }

    int iLow = 1;
    if (iTemp > 0) {
        double maxAlpha = -std::numeric_limits<double>::max();
        for (int i = 0; i < p->NumAlf; i++) {
            if (p->Alpha[i] < p->UA_BL.alphaLower && COEFS(i + 1, ColUAf) == COEFS(iTemp, ColUAf)) {
                if (p->Alpha[i] > maxAlpha) {
                    maxAlpha = p->Alpha[i];
                    iLow = i + 1;  // 1-based
                }
            }
        }
    }

    // Find iHigh: first row where alpha > alphaUpper AND Coefs(:,ColUAf) is at its minimum
    // Fortran: iHigh = minloc(Coefs(:,ColUAf), DIM=1, MASK=alpha > alphaUpper)
    int iHigh = p->NumAlf;
    minVal = std::numeric_limits<double>::max();
    for (int i = 0; i < p->NumAlf; i++) {
        if (p->Alpha[i] > p->UA_BL.alphaUpper) {
            if (COEFS(i + 1, ColUAf) < minVal) {
                minVal = COEFS(i + 1, ColUAf);
                iHigh = i + 1;  // 1-based
            }
        }
    }

    // Compute break-point variables for wrap-around
    p->UA_BL.alphaBreakUpper = p->Alpha[iHigh - 1];
    p->UA_BL.alphaBreakLower = p->Alpha[iLow - 1];
    p->UA_BL.CnBreakUpper = COEFS(iHigh, col_fa);
    p->UA_BL.CnBreakLower = COEFS(iLow, col_fa);

    double c_RateBreak = (p->UA_BL.CnBreakUpper - p->UA_BL.CnBreakLower) /
                         ((p->UA_BL.alphaBreakUpper - TwoPi) - p->UA_BL.alphaBreakLower);

    // Make separation function monotonic before iLow
    for (int Row = 1; Row <= iLow; Row++) {
        COEFS(Row, col_fa) = (p->Alpha[Row - 1] - p->UA_BL.alphaBreakLower) * c_RateBreak + p->UA_BL.CnBreakLower;
        COEFS(Row, col_fs) = cn_cl[Row - 1];
        COEFS(Row, ColUAf) = 0.0;
    }

    // Make separation function monotonic after iHigh
    for (int Row = iHigh; Row <= p->NumAlf; Row++) {
        COEFS(Row, col_fa) = (p->Alpha[Row - 1] - p->UA_BL.alphaBreakUpper) * c_RateBreak + p->UA_BL.CnBreakUpper;
        COEFS(Row, col_fs) = cn_cl[Row - 1];
        COEFS(Row, ColUAf) = 0.0;
    }
}

#undef COEFS
