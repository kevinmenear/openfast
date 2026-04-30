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

**Constants:** `Pi`, `TwoPi`, `PiBy2`, `D2R`, `R2D`, `ErrMsgLen`, `ErrID_None`, `ErrID_Warn`, `ErrID_Severe`, `ErrID_Fatal`, `AbortErrLev`

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

## Fortran Array Intrinsics (MINLOC, MAXLOC, CSHIFT)

Use the shared implementations in `vit_fortran_intrinsics.h` — do not write inline loops:

```cpp
#include "vit_fortran_intrinsics.h"

// MINLOC(array, DIM=1, MASK=condition) — returns 1-based index
int idx = fortran_minloc(N,
    [&](int i) { return array[i]; },        // value at 0-based index
    [&](int i) { return array[i] >= threshold; }); // mask predicate

// MAXLOC — same pattern
int idx = fortran_maxloc(N, value_fn, mask_fn);

// CSHIFT(array, shift) — circular shift, positive = left
fortran_cshift(src, dst, n, shift);
```

Use `std::vector<double>` for temporary arrays (Fortran's stack-allocated variable-length arrays).

## Callee Declarations

If the function calls other already-translated functions, `vit translate` will show their `_c` signatures in the "Already-Translated Callees" section of the prompt. **Do NOT add your own `extern "C"` declarations or `#include "vit_translated.h"`.** VIT handles callee declarations automatically in both kernel verification (`vit_kernel_callees.h`) and production integration (`vit_translated.h`).

## Fortran `**2` vs C++ `x * x` — Parenthesize When Multiplied

Fortran `a*x**2` means `a * (x*x)` — exponentiation binds tighter than multiplication. C++ `a * x * x` means `(a*x) * x` — left-to-right associativity. The different intermediate rounding produces 1-3 ULP differences for certain values. Always parenthesize:

```cpp
// WRONG: (0.26 * spanRatio) * spanRatio — different from Fortran
double k_tau = 0.39 - 0.26 * spanRatio * spanRatio;

// CORRECT: 0.26 * (spanRatio * spanRatio) — matches Fortran a*x**2
double k_tau = 0.39 - 0.26 * (spanRatio * spanRatio);
```

This applies to any `coeff * var**N` pattern. The parentheses ensure the exponentiation happens first, matching Fortran semantics.

## ErrMsg Blank-Padding

Fortran `ErrMsg = ""` fills the entire CHARACTER variable with spaces (ASCII 32). C++ `errMsg[0] = '\0'` only sets the first byte — the rest is garbage. KGen compares the full buffer byte-by-byte, so this fails verification.

Always initialize ErrMsg with `memset` to match Fortran:

```cpp
#include <cstring>
#include "vit_nwtc.h"  // for ErrMsgLen

*errStat = 0;
std::memset(errMsg, ' ', ErrMsgLen);
```

Do NOT use `errMsg[0] = '\0'` — it will pass baselines (Fortran callers only read up to the first space-trim) but fail KGen kernel verification.

## SetErrStat Error Accumulation

Fortran functions that call multiple subroutines use `SetErrStat` to accumulate errors. `vit_nwtc.h` provides a C++ `SetErrStat()` that matches the Fortran semantics (keeps highest severity, concatenates messages with routine name prefix):

```cpp
int ErrStat2 = 0;
char ErrMsg2[ErrMsgLen];
std::memset(ErrMsg2, ' ', ErrMsgLen);

some_callee_c(..., &ErrStat2, ErrMsg2);
SetErrStat(ErrStat2, ErrMsg2, ErrStat, ErrMsg, "DBEMT_RK4");
if (*ErrStat >= AbortErrLev) return;
```

Match the Fortran source exactly for which calls get error checks — some functions skip checks on later calls (e.g., RK4 only checks the first CalcContStateDeriv call).

## View-Type INOUT Arguments

Functions that modify scalar fields in view-type INOUT arguments (e.g., `p%UA_BL.alphaBreakUpper`) need `--reverse-copy` during integration. VIT auto-generates the reverse-copy in kernel verification. ALLOCATABLE array modifications (e.g., `p%Coefs(Row,Col) = value`) work through `C_LOC` pointers and don't need reverse-copy.
