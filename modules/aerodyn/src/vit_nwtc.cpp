// C++ translations of NWTC_Library utility functions.
// Compiled once, linked into all AeroDyn translation units.
// See vit_nwtc.h for declarations and documentation.

#include "vit_nwtc.h"
#include <algorithm>
#include <cstring>
#include <limits>
#include <string>
#include <vector>

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
// Extrapolates at boundaries using linear slope from nearest interval.

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

// ---- InterpStp (NWTC_Num.f90:3455, InterpStpReal8) ----
// Clamps at boundaries instead of extrapolating.

double InterpStp(double XVal, const double* XAry,
                 const double* YAry, int& Ind, int AryLen) {
    auto GetLinearVal = [&]() -> double {
        return (YAry[Ind] - YAry[Ind-1]) * (XVal - XAry[Ind-1])
             / (XAry[Ind] - XAry[Ind-1]) + YAry[Ind-1];
    };

    if (XVal <= XAry[0]) {
        Ind = 1;
        return YAry[0];
    } else if (XVal >= XAry[AryLen-1]) {
        Ind = std::max(AryLen - 1, 1);
        return YAry[AryLen-1];
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

// ---- kernelSmoothing (NWTC_Num.f90:4157) ----

void kernelSmoothing(const double* x, const double* f, int n,
                     int kernelType, double radius, double* fNew) {
    double RadiusFix = std::max(std::abs(radius), std::numeric_limits<double>::epsilon());

    if (kernelType != kernelType_GAUSSIAN) {
        // Non-Gaussian kernels: K(u) = w * (1 - |u|^Exp1)^Exp2 for |u| <= 1
        double w;
        int Exp1, Exp2;
        switch (kernelType) {
            case kernelType_EPANECHINIKOV: w = 3.0/4.0;   Exp1 = 2; Exp2 = 1; break;
            case kernelType_QUARTIC:
            case kernelType_BIWEIGHT:      w = 15.0/16.0;  Exp1 = 2; Exp2 = 2; break;
            case kernelType_TRIWEIGHT:     w = 35.0/32.0;  Exp1 = 2; Exp2 = 3; break;
            case kernelType_TRICUBE:       w = 70.0/81.0;  Exp1 = 3; Exp2 = 3; break;
            default:                       w = 35.0/32.0;  Exp1 = 2; Exp2 = 3; break;
        }

        for (int j = 0; j < n; j++) {
            double k_sum = 0.0;
            fNew[j] = 0.0;
            for (int i = 0; i < n; i++) {
                double u = (x[i] - x[j]) / RadiusFix;
                u = std::min(1.0, std::max(-1.0, u));
                // Use explicit integer exponentiation to match gfortran's
                // compilation of abs(u)**Exp1 and (...)^Exp2 (repeated
                // multiplication, not pow() library call — avoids 1-ULP diffs)
                double abs_u = std::abs(u);
                double u_pow = (Exp1 == 2) ? abs_u * abs_u : abs_u * abs_u * abs_u;
                double base = 1.0 - u_pow;
                double k;
                if      (Exp2 == 1) k = w * base;
                else if (Exp2 == 2) k = w * base * base;
                else                k = w * base * base * base;
                k_sum += k;
                fNew[j] += k * f[i];
            }
            if (k_sum > 0.0) {
                fNew[j] /= k_sum;
            }
        }
    } else {
        // Gaussian kernel: K(u) = (1/sqrt(2*pi)) * exp(-0.5*u^2)
        double w = 1.0 / std::sqrt(TwoPi);

        for (int j = 0; j < n; j++) {
            double k_sum = 0.0;
            fNew[j] = 0.0;
            for (int i = 0; i < n; i++) {
                double u = (x[i] - x[j]) / RadiusFix;
                double k = w * std::exp(-0.5 * u * u);
                k_sum += k;
                fNew[j] += k * f[i];
            }
            if (k_sum > 0.0) {
                fNew[j] /= k_sum;
            }
        }
    }
}

// ---- AddOrSub2Pi (NWTC_Num.f90:328, AddOrSub2Pi_R8) ----

void AddOrSub2Pi(double OldAngle, double* NewAngle) {
    double DelAngle = OldAngle - *NewAngle;

    // Coarse adjustment: jump by integer multiples of 2*Pi
    int n = static_cast<int>(DelAngle / TwoPi);
    *NewAngle += n * TwoPi;
    DelAngle = OldAngle - *NewAngle;

    // Fine adjustment: iterate ±2*Pi until within Pi (max 10 steps)
    int i = 0;
    while (std::abs(DelAngle) > Pi && !EqualRealNos(OldAngle, *NewAngle) && i < 10) {
        *NewAngle += std::copysign(TwoPi, DelAngle);
        DelAngle = OldAngle - *NewAngle;
        i++;
    }
}

// ---- Angles_ExtrapInterp1 (NWTC_Num.f90:6746, Angles_ExtrapInterp1_R8) ----

void Angles_ExtrapInterp1(double Angle1, double Angle2,
                          const double tin[2], double* Angle_out,
                          double tin_out) {
    // Short-circuit if both inputs are the same
    if (Angle1 == Angle2) {
        *Angle_out = Angle1;
        return;
    }

    // Normalize time (subtract tin[0] to simplify equations)
    double t1 = tin[1] - tin[0];
    double t_out = tin_out - tin[0];

    // Adjust Angle2 to be within Pi of Angle1
    double Angle2_mod = Angle2;
    AddOrSub2Pi(Angle1, &Angle2_mod);

    // Standard linear interpolation on adjusted angles
    *Angle_out = Angle1 + (Angle2_mod - Angle1) * t_out / t1;
}

// ---- LocateBin (NWTC_Num.f90:4256) ----
// Binary search: returns 1-based index ILo.
// 0 if below range, AryLen if above range.
// XAry is 0-based in C++ but the algorithm mirrors Fortran's 1-based logic.

int LocateBin(double XVal, const double* XAry, int AryLen) {
    if (XVal < XAry[0]) return 0;
    if (XVal >= XAry[AryLen - 1]) return AryLen;

    // Binary search (1-based logic mapped to 0-based arrays)
    int ILo = 1;
    int IHi = AryLen;
    while (IHi - ILo > 1) {
        int IMid = (IHi + ILo) / 2;
        if (XVal >= XAry[IMid - 1]) {  // 0-based access
            ILo = IMid;
        } else {
            IHi = IMid;
        }
    }
    return ILo;  // 1-based index
}

// ---- CubicSplineInitM (NWTC_Num.f90:742) ----

void CubicSplineInitM(const double* XAry, const double* YAry, double* Coef,
                      int NumPts, int NumCrvs, int* errStat, char* errMsg) {
    *errStat = ErrID_None;
    std::memset(errMsg, ' ', ErrMsgLen);

    int nSeg = NumPts - 1;
    int slice = nSeg * NumCrvs;  // stride for 3rd dimension of Coef

    std::vector<double> DelX(nSeg);
    std::vector<double> Slope(nSeg * NumCrvs);
    std::vector<double> U(nSeg);
    std::vector<double> V(nSeg * NumCrvs);
    std::vector<double> ZHi(NumCrvs);
    std::vector<double> ZLo(NumCrvs);

    // Compute spacing and slopes
    for (int i = 0; i < nSeg; i++) {
        DelX[i] = XAry[i + 1] - XAry[i];
        if (EqualRealNos(DelX[i], 0.0)) {
            *errStat = ErrID_Fatal;
            setErrMsg(errMsg, "CubicSplineInitM:XAry must have unique values.");
            return;
        }
        for (int j = 0; j < NumCrvs; j++) {
            Slope[j * nSeg + i] = (YAry[j * NumPts + (i + 1)] - YAry[j * NumPts + i]) / DelX[i];
        }
    }

    // Forward Gaussian elimination on tridiagonal system
    U[0] = 2.0 * (DelX[1] + DelX[0]);
    for (int j = 0; j < NumCrvs; j++) {
        V[j * nSeg + 0] = 6.0 * (Slope[j * nSeg + 1] - Slope[j * nSeg + 0]);
    }

    for (int i = 1; i < nSeg; i++) {
        if (EqualRealNos(U[i - 1], 0.0)) {
            *errStat = ErrID_Fatal;
            setErrMsg(errMsg, "CubicSplineInitM:XAry must be monotonic.");
            return;
        }
        U[i] = 2.0 * (DelX[i - 1] + DelX[i]) - DelX[i - 1] * DelX[i - 1] / U[i - 1];
        for (int j = 0; j < NumCrvs; j++) {
            V[j * nSeg + i] = 6.0 * (Slope[j * nSeg + i] - Slope[j * nSeg + (i - 1)])
                             - DelX[i - 1] * V[j * nSeg + (i - 1)] / U[i - 1];
        }
    }

    // Coef(:,:,0) = YAry(1:NumPts-1,:)
    for (int j = 0; j < NumCrvs; j++) {
        for (int i = 0; i < nSeg; i++) {
            Coef[0 * slice + j * nSeg + i] = YAry[j * NumPts + i];
        }
    }

    // Back-substitution
    for (int j = 0; j < NumCrvs; j++) ZHi[j] = 0.0;

    for (int i = nSeg - 1; i >= 0; i--) {
        for (int j = 0; j < NumCrvs; j++) {
            ZLo[j] = (V[j * nSeg + i] - DelX[i] * ZHi[j]) / U[i];
            Coef[1 * slice + j * nSeg + i] = Slope[j * nSeg + i]
                - DelX[i] * (ZHi[j] / 6.0 + ZLo[j] / 3.0);
            Coef[2 * slice + j * nSeg + i] = 0.5 * ZLo[j];
            Coef[3 * slice + j * nSeg + i] = (ZHi[j] - ZLo[j]) / (6.0 * DelX[i]);
            ZHi[j] = ZLo[j];
        }
    }
}

// ---- CubicLinSplineInitM (NWTC_Num.f90:907) ----

void CubicLinSplineInitM(const double* XAry, const double* YAry, double* Coef,
                         int NumPts, int NumCrvs, int* errStat, char* errMsg) {
    *errStat = ErrID_None;
    std::memset(errMsg, ' ', ErrMsgLen);

    int nSeg = NumPts - 1;
    int slice = nSeg * NumCrvs;

    for (int i = nSeg - 1; i >= 0; i--) {
        double DelX = XAry[i + 1] - XAry[i];
        if (EqualRealNos(DelX, 0.0)) {
            *errStat = ErrID_Fatal;
            setErrMsg(errMsg, "CubicLinSplineInitM:XAry must have unique values.");
            return;
        }
        for (int j = 0; j < NumCrvs; j++) {
            Coef[0 * slice + j * nSeg + i] = YAry[j * NumPts + i];
            Coef[1 * slice + j * nSeg + i] = (YAry[j * NumPts + (i + 1)] - YAry[j * NumPts + i]) / DelX;
            Coef[2 * slice + j * nSeg + i] = 0.0;
            Coef[3 * slice + j * nSeg + i] = 0.0;
        }
    }
}

// ---- CubicSplineInterpM (NWTC_Num.f90:1021) ----
// Cubic spline interpolation with multiple output columns.
// All arrays are 0-based. Coef layout: [NumPts x nCols x 4] column-major,
// matching Fortran's (NumPts, nCols, 0:3).

void CubicSplineInterpM(double X, const double* XAry, const double* YAry,
                        const double* Coef, double* Res,
                        int NumPts, int nCols, int nCoefRows) {
    // Boundary: return first/last row if out of range
    if (X <= XAry[0]) {
        for (int c = 0; c < nCols; c++) {
            Res[c] = YAry[c * NumPts];  // YAry(1, col) in Fortran = YAry[col * NumPts + 0]
        }
        return;
    }
    if (X >= XAry[NumPts - 1]) {
        for (int c = 0; c < nCols; c++) {
            Res[c] = YAry[c * NumPts + (NumPts - 1)];  // YAry(NumPts, col)
        }
        return;
    }

    // Binary search for the bounding segment
    int ILo = LocateBin(X, XAry, NumPts);  // 1-based
    int iLo0 = ILo - 1;  // 0-based index into arrays

    double XOff  = X - XAry[iLo0];
    double XOff2 = XOff * XOff;
    double XOff3 = XOff2 * XOff;

    // Evaluate cubic polynomial for each column:
    // Fortran: Res(col) = Coef(ILo, col, 0) + Coef(ILo, col, 1)*XOff + ...
    // Coef is (nCoefRows, nCols, 0:3) — nCoefRows = NumPts-1 (one fewer than knots).
    // Column-major: Coef(i, j, k) = Coef[k * nCoefRows * nCols + j * nCoefRows + (i-1)]
    int slice = nCoefRows * nCols;  // stride for 3rd dimension
    for (int c = 0; c < nCols; c++) {
        int base = c * nCoefRows + iLo0;
        Res[c] = Coef[0 * slice + base]
               + Coef[1 * slice + base] * XOff
               + Coef[2 * slice + base] * XOff2
               + Coef[3 * slice + base] * XOff3;
    }
}
