// C++ translations of NWTC_Library utility functions and constants.
// Used by VIT-translated AeroDyn functions.
//
// Source: modules/nwtc-library/src/NWTC_Num.f90
//         modules/nwtc-library/src/SysGnuLinux.f90
//
// These are header-only inline implementations. Verification of every
// AeroDyn function that calls them provides transitive verification
// against the Fortran originals via KGen kernel comparison.

#ifndef VIT_NWTC_H
#define VIT_NWTC_H

#include <cmath>
#include <algorithm>
#include <limits>

// ---- Constants (from NWTC_Library precision/system modules) ----

static constexpr double Pi    = M_PI;
static constexpr double TwoPi = 2.0 * M_PI;
static constexpr double PiBy2 = M_PI / 2.0;
static constexpr double D2R   = M_PI / 180.0;
static constexpr double R2D   = 180.0 / M_PI;

// ---- EqualRealNos (NWTC_Num.f90:1647, EqualRealNos8) ----
// Returns true if two doubles are approximately equal,
// ignoring the last 2 significant digits of machine precision.

static inline bool EqualRealNos(double a, double b) {
    static constexpr double Eps = std::numeric_limits<double>::epsilon();
    static constexpr double Tol = 100.0 * Eps / 2.0;
    double Fraction = std::max(std::abs(a + b), 1.0);
    return std::abs(a - b) <= Fraction * Tol;
}

// ---- fZeros (NWTC_Num.f90:7205, fZero_R8) ----
// Finds zero-crossings in tabulated data via linear interpolation.
// x[0..n-1]: monotonic increasing x values (0-based)
// f[0..n-1]: corresponding f(x) values (0-based)
// roots[0..roots_size-1]: output array for found roots (0-based)
// nZeros: output count of zeros found
// has_period/period: if true, also checks periodic wraparound

static inline void fZeros(const double* x, const double* f, int n,
                           double* roots, int roots_size, int& nZeros,
                           bool has_period = false, double period = 0.0) {
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
// Linear interpolation/extrapolation with stepping index search.
// XAry[0..AryLen-1], YAry[0..AryLen-1]: 0-based arrays
// Ind: 1-based tracking index (matches Fortran convention).
//      Caller initializes to 1; function updates it for efficient
//      sequential lookups.

static inline double InterpExtrapStp(double XVal, const double* XAry,
                                      const double* YAry, int& Ind, int AryLen) {
    // GetLinearVal: linear interpolation using the interval [Ind-1, Ind] (0-based)
    // Fortran Ind is 1-based, so XAry(Ind) = XAry[Ind-1], XAry(Ind+1) = XAry[Ind]
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

#endif // VIT_NWTC_H
