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

// ---- InterpStp (NWTC_Num.f90:3455, InterpStpReal8) ----
// Like InterpExtrapStp but clamps at boundaries instead of extrapolating.
// At XVal <= XAry[0]: returns YAry[0] directly.
// At XVal >= XAry[AryLen-1]: returns YAry[AryLen-1] directly.
// Ind: 1-based tracking index (same convention as InterpExtrapStp).

double InterpStp(double XVal, const double* XAry,
                 const double* YAry, int& Ind, int AryLen);

// ---- kernelSmoothing (NWTC_Num.f90:4157) ----
// Weighted kernel density smoothing.
// x[0..n-1]: independent axis (0-based)
// f[0..n-1]: function values to smooth (0-based)
// kernelType: kernel function selector (use kernelType_TRIWEIGHT etc.)
// radius: window width in units of x
// fNew[0..n-1]: smoothed output (0-based)

void kernelSmoothing(const double* x, const double* f, int n,
                     int kernelType, double radius, double* fNew);

// Kernel type constants (from NWTC_Num.f90:77-82)
static constexpr int kernelType_EPANECHINIKOV = 1;
static constexpr int kernelType_QUARTIC       = 2;
static constexpr int kernelType_BIWEIGHT      = 3;
static constexpr int kernelType_TRIWEIGHT     = 4;
static constexpr int kernelType_TRICUBE       = 5;
static constexpr int kernelType_GAUSSIAN      = 6;

#endif // VIT_NWTC_H
