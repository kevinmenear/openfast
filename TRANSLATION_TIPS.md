# AeroDyn Translation Tips

Lessons learned from AirfoilInfo function translations. `vit translate` includes this file in the translation prompt automatically.

## Column-Major 2D Array Access (Coefs)

AirfoilInfo functions frequently access `p%Coefs(Row, Col)` — a 2D ALLOCATABLE column-major array. Use a macro:

```cpp
#define COEFS(row1, col1) p->Coefs[((col1)-1) * p->n_Coefs_rows + ((row1)-1)]
```

All indices are 1-based in Fortran. The macro preserves 1-based indexing to match the Fortran exactly.

## Shared NWTC Utility Library (`vit_nwtc.h` / `vit_nwtc.cpp`)

All translations should `#include "vit_nwtc.h"` for NWTC Library functions and constants. Do NOT inline these — the implementations are compiled once in `vit_nwtc.cpp` and linked into all translations. VIT automatically copies both files to kernel directories during verification.

**Constants:** `Pi`, `TwoPi`, `PiBy2`, `D2R`, `R2D`, `ErrMsgLen`

**Functions (12 total):**
- `EqualRealNos(a, b)` — epsilon-based floating-point comparison
- `fZeros(x, f, n, roots, roots_size, nZeros, ...)` — zero-crossing finder
- `InterpExtrapStp(XVal, XAry, YAry, Ind, AryLen)` — linear interpolation with stepping (Ind is 1-based)
- `InterpStp(XVal, XAry, YAry, Ind, AryLen)` — same but clamps at boundaries
- `kernelSmoothing(x, f, n, kernelType, radius, fNew)` — kernel density smoothing
- `MPi2Pi(angle)` — normalize angle to [-Pi, Pi] (inline)
- `LocateBin(XVal, XAry, AryLen)` — binary search, returns 1-based index
- `CubicSplineInterpM(X, XAry, YAry, Coef, Res, NumPts, nCols, nCoefRows)` — multi-column cubic spline evaluation
- `CubicSplineInitM(XAry, YAry, Coef, NumPts, NumCrvs, errStat, errMsg)` — cubic spline coefficient computation (tridiagonal Gaussian elimination)
- `CubicLinSplineInitM(XAry, YAry, Coef, NumPts, NumCrvs, errStat, errMsg)` — linear spline coefficients in cubic format
- `AddOrSub2Pi(OldAngle, NewAngle*)` — adjust angle to within Pi of reference
- `Angles_ExtrapInterp1(Angle1, Angle2, tin, Angle_out, tin_out)` — angle-aware linear interpolation

All arrays are 0-based in C++. Index-tracking parameters (Ind in InterpStp/InterpExtrapStp, return from LocateBin) are 1-based to match Fortran convention. See `vit_nwtc.h` for full signatures and documentation.

## MINLOC / MAXLOC with Masks

Fortran `MINLOC(array, DIM=1, MASK=condition)` returns the index of the minimum value where the mask is true. Translate as a manual loop:

```cpp
int idx = 1;  // 1-based default
double minVal = std::numeric_limits<double>::max();
for (int i = 0; i < N; i++) {
    if (mask_condition(i) && array[i] < minVal) {
        minVal = array[i];
        idx = i + 1;  // 1-based
    }
}
```

## CSHIFT (Circular Array Shift)

Fortran `CSHIFT(array, shift)` performs a circular shift. Positive shift moves elements left:

```cpp
static void cshift(const double* src, double* dst, int n, int shift) {
    shift = ((shift % n) + n) % n;
    for (int i = 0; i < n; i++) {
        dst[i] = src[(i + shift) % n];
    }
}
```

Use `std::vector<double>` for the temporary arrays (Fortran's stack-allocated variable-length arrays).

## Callee Declarations

If the function calls other already-translated functions, `vit translate` will show their `_c` signatures in the "Already-Translated Callees" section of the prompt. **Do NOT add your own `extern "C"` declarations or `#include "vit_translated.h"`.** VIT handles callee declarations automatically in both kernel verification (`vit_kernel_callees.h`) and production integration (`vit_translated.h`).

## View-Type INOUT Arguments

Functions that modify scalar fields in view-type INOUT arguments (e.g., `p%UA_BL.alphaBreakUpper`) need `--reverse-copy` during integration. VIT auto-generates the reverse-copy in kernel verification. ALLOCATABLE array modifications (e.g., `p%Coefs(Row,Col) = value`) work through `C_LOC` pointers and don't need reverse-copy.
