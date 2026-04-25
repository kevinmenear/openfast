// VIT Translation Scaffold
// Function: ComputeUA360_updateCnSeparated
// Source: AirfoilInfo.f90
// Module: AirfoilInfo
// Fortran: SUBROUTINE ComputeUA360_updateCnSeparated(p, ColUAf, cn_cl, iLower)
// Source MD5: 61932bfb94fc
// VIT: 0.1.0
// Status: unverified
// Generated: 2026-04-25T18:40:23Z

#include "vit_types.h"
#include <cmath>
#include <limits>

// 2D column-major access: Coefs(Row, Col) in Fortran = Coefs[(Col-1)*nrows + (Row-1)] in C
#define COEFS(row1, col1) p->Coefs[((col1)-1) * p->n_Coefs_rows + ((row1)-1)]

// EqualRealNos: returns true if two doubles are approximately equal (within machine precision)
static inline bool EqualRealNos(double a, double b) {
    const double Eps = std::numeric_limits<double>::epsilon();
    const double Tol = 100.0 * Eps / 2.0;
    double Fraction = std::max(std::abs(a + b), 1.0);
    return std::abs(a - b) <= Fraction * Tol;
}

void ComputeUA360_updateCnSeparated(afi_table_type_view_t* p, int ColUAf, double* cn_cl, int n_cn_cl, int iLower) {
    // Column numbers (1-based, matching Fortran)
    int col_fa = ColUAf + 2;  // fully attached
    int col_fs = ColUAf + 1;  // fully separated

    for (int Row = 1; Row <= p->NumAlf; Row++) {
        if (EqualRealNos(COEFS(Row, ColUAf), 1.0)) {
            double offset = computeua360_cnoffset_c(p, cn_cl, n_cn_cl, Row, iLower);
            COEFS(Row, col_fs) = 0.5 * (cn_cl[Row - 1] + offset);
        } else {
            COEFS(Row, col_fs) = (cn_cl[Row - 1] - COEFS(Row, col_fa) * COEFS(Row, ColUAf)) /
                                 (1.0 - COEFS(Row, ColUAf));
        }
    }
}

#undef COEFS
