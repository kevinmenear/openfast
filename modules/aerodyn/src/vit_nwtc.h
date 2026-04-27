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

// Error message length (from NWTC_Base.f90:37)
static constexpr int ErrMsgLen = 8196;

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

// ---- MPi2Pi (NWTC_Num.f90:4475, MPi2Pi_R8) ----
// Normalize angle to [-Pi, Pi].

inline double MPi2Pi(double angle) {
    angle = std::fmod(angle, TwoPi);
    if (angle < 0.0) angle += TwoPi;  // fmod can be negative; MODULO is always non-negative
    if (angle > Pi) angle -= TwoPi;
    return angle;
}

// ---- AddOrSub2Pi (NWTC_Num.f90:328, AddOrSub2Pi_R8) ----
// Adjusts NewAngle to within Pi of OldAngle by adding/subtracting
// multiples of 2*Pi.

void AddOrSub2Pi(double OldAngle, double* NewAngle);

// ---- Angles_ExtrapInterp1 (NWTC_Num.f90:6746, Angles_ExtrapInterp1_R8) ----
// Angle-aware linear interpolation between two angles.
// Handles ±2Pi wrapping via AddOrSub2Pi before interpolating.
// tin[2]: times associated with the two angles (0-based)
// tin_out: time to interpolate to

void Angles_ExtrapInterp1(double Angle1, double Angle2,
                          const double tin[2], double* Angle_out,
                          double tin_out);

// ---- LocateBin (NWTC_Num.f90:4256) ----
// Binary search returning lower-bound 1-based index.
// XAry[0..AryLen-1]: 0-based sorted array.
// Returns: 1-based index ILo such that XAry[ILo-1] <= XVal < XAry[ILo].
//          Returns 0 if XVal < XAry[0], AryLen if XVal >= XAry[AryLen-1].

int LocateBin(double XVal, const double* XAry, int AryLen);

// ---- CubicSplineInterpM (NWTC_Num.f90:1021) ----
// Cubic spline interpolation for multiple columns.
// X: value to interpolate at
// XAry[0..NumPts-1]: x knots (0-based)
// YAry: 2D column-major [NumPts rows x nCols cols] (0-based)
// Coef: 3D column-major [nCoefRows x nCols x 4] with 0-based 3rd dim (coeff order 0..3)
//       Note: nCoefRows = NumPts-1 (one fewer than knot points)
// Res[0..nCols-1]: output interpolated values (0-based)
// NumPts: number of knot points
// nCols: number of output columns
// nCoefRows: first dimension of Coef array (typically NumPts-1)

void CubicSplineInterpM(double X, const double* XAry, const double* YAry,
                        const double* Coef, double* Res,
                        int NumPts, int nCols, int nCoefRows);

// ---- CubicSplineInitM (NWTC_Num.f90:742) ----
// Compute natural cubic spline coefficients for irregularly-spaced data.
// Handles multiple curves sharing the same X values.
// XAry[0..NumPts-1]: knot x-values (0-based, must be unique)
// YAry: 2D column-major [NumPts x NumCrvs] (0-based)
// Coef: 3D column-major output [nCoefRows x NumCrvs x 4], nCoefRows = NumPts-1
//       Coef(i,j,k) = Coef[k * nCoefRows * NumCrvs + j * nCoefRows + i]
// errStat/errMsg: error output (ErrID_Fatal if X not unique or system singular)

void CubicSplineInitM(const double* XAry, const double* YAry, double* Coef,
                      int NumPts, int NumCrvs, int* errStat, char* errMsg);

// ---- CubicLinSplineInitM (NWTC_Num.f90:907) ----
// Compute linear spline coefficients in cubic format (c2=c3=0).
// Same array layouts as CubicSplineInitM.

void CubicLinSplineInitM(const double* XAry, const double* YAry, double* Coef,
                         int NumPts, int NumCrvs, int* errStat, char* errMsg);

#endif // VIT_NWTC_H
