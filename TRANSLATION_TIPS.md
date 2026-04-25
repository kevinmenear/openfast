# AeroDyn Translation Tips

Lessons learned from AirfoilInfo function translations. `vit translate` includes this file in the translation prompt automatically.

## Column-Major 2D Array Access (Coefs)

AirfoilInfo functions frequently access `p%Coefs(Row, Col)` — a 2D ALLOCATABLE column-major array. Use a macro:

```cpp
#define COEFS(row1, col1) p->Coefs[((col1)-1) * p->n_Coefs_rows + ((row1)-1)]
```

All indices are 1-based in Fortran. The macro preserves 1-based indexing to match the Fortran exactly.

## EqualRealNos (Machine-Precision Comparison)

Several functions call `EqualRealNos(a, b)` from the NWTC Library. This is NOT a callee bridge — it's a pure function that should be inlined:

```cpp
static inline bool EqualRealNos(double a, double b) {
    const double Eps = std::numeric_limits<double>::epsilon();
    const double Tol = 100.0 * Eps / 2.0;
    double Fraction = std::max(std::abs(a + b), 1.0);
    return std::abs(a - b) <= Fraction * Tol;
}
```

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
