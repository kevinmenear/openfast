// C++ translations of NWTC_Library utility functions.
// Compiled once, linked into all AeroDyn translation units.
// See vit_nwtc.h for declarations and documentation.

#include "vit_nwtc.h"
#include <algorithm>
#include <limits>

// ---- EqualRealNos (NWTC_Num.f90:1647, EqualRealNos8) ----

bool EqualRealNos(double a, double b) {
    static constexpr double Eps = std::numeric_limits<double>::epsilon();
    static constexpr double Tol = 100.0 * Eps / 2.0;
    double Fraction = std::max(std::abs(a + b), 1.0);
    return std::abs(a - b) <= Fraction * Tol;
}

// ---- fZeros (NWTC_Num.f90:7205, fZero_R8) ----

void fZeros(const double* x, const double* f, int n,
            double* roots, int roots_size, int& nZeros,
            bool has_period, double period) {
    nZeros = 0;

    for (int j = 1; j < n; j++) {
        if ((f[j-1] < 0.0 && f[j] >= 0.0) || (f[j-1] >= 0.0 && f[j] < 0.0)) {
            nZeros++;
            double df = f[j] - f[j-1];
            double dx = x[j] - x[j-1];
            roots[std::min(nZeros, roots_size) - 1] = x[j] - f[j] * dx / df;
        }
    }

    if (has_period) {
        if ((f[n-1] < 0.0 && f[0] >= 0.0) || (f[n-1] >= 0.0 && f[0] < 0.0)) {
            nZeros++;
            double df = f[0] - f[n-1];
            double dx = x[0] - x[n-1] + period;
            roots[std::min(nZeros, roots_size) - 1] = x[0] - f[0] * dx / df;
        }
    }
}

// ---- InterpExtrapStp (NWTC_Num.f90:3268) ----

double InterpExtrapStp(double XVal, const double* XAry,
                       const double* YAry, int& Ind, int AryLen) {
    auto GetLinearVal = [&]() -> double {
        return (YAry[Ind] - YAry[Ind-1]) * (XVal - XAry[Ind-1])
             / (XAry[Ind] - XAry[Ind-1]) + YAry[Ind-1];
    };

    if (AryLen < 2) {
        Ind = 1;
        return YAry[0];
    }

    if (XVal <= XAry[0]) {
        Ind = 1;
        return GetLinearVal();
    } else if (XVal >= XAry[AryLen-1]) {
        Ind = std::max(AryLen - 1, 1);
        return GetLinearVal();
    }

    Ind = std::max(std::min(Ind, AryLen - 1), 1);

    while (true) {
        if (XVal < XAry[Ind-1]) {
            Ind--;
        } else if (XVal >= XAry[Ind]) {
            Ind++;
        } else {
            return GetLinearVal();
        }
    }
}
