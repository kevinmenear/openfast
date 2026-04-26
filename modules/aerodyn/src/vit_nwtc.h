// C++ translations of NWTC_Library utility functions and constants.
// Used by VIT-translated AeroDyn functions.
//
// Source: modules/nwtc-library/src/NWTC_Num.f90
//         modules/nwtc-library/src/SysGnuLinux.f90
//
// Declarations only — implementations are in vit_nwtc.cpp (compiled once,
// linked into all translation units). Verification of every AeroDyn function
// that calls these provides transitive verification against the Fortran
// originals via KGen kernel comparison.

#ifndef VIT_NWTC_H
#define VIT_NWTC_H

#include <cmath>

// ---- Constants (from NWTC_Library precision/system modules) ----

static constexpr double Pi    = M_PI;
static constexpr double TwoPi = 2.0 * M_PI;
static constexpr double PiBy2 = M_PI / 2.0;
static constexpr double D2R   = M_PI / 180.0;
static constexpr double R2D   = 180.0 / M_PI;

// ---- EqualRealNos (NWTC_Num.f90:1647, EqualRealNos8) ----
// Returns true if two doubles are approximately equal,
// ignoring the last 2 significant digits of machine precision.

bool EqualRealNos(double a, double b);

// ---- fZeros (NWTC_Num.f90:7205, fZero_R8) ----
// Finds zero-crossings in tabulated data via linear interpolation.
// x[0..n-1]: monotonic increasing x values (0-based)
// f[0..n-1]: corresponding f(x) values (0-based)
// roots[0..roots_size-1]: output array for found roots (0-based)
// nZeros: output count of zeros found
// has_period/period: if true, also checks periodic wraparound

void fZeros(const double* x, const double* f, int n,
            double* roots, int roots_size, int& nZeros,
            bool has_period = false, double period = 0.0);

// ---- InterpExtrapStp (NWTC_Num.f90:3268) ----
// Linear interpolation/extrapolation with stepping index search.
// XAry[0..AryLen-1], YAry[0..AryLen-1]: 0-based arrays
// Ind: 1-based tracking index (matches Fortran convention).
//      Caller initializes to 1; function updates it for efficient
//      sequential lookups.

double InterpExtrapStp(double XVal, const double* XAry,
                       const double* YAry, int& Ind, int AryLen);

#endif // VIT_NWTC_H
