// C++ equivalents of Fortran array intrinsics (MINLOC, MAXLOC, CSHIFT).
// Header-only — templates inline at -O2 with no runtime cost.

#ifndef VIT_FORTRAN_INTRINSICS_H
#define VIT_FORTRAN_INTRINSICS_H

#include <limits>

// MINLOC(array, DIM=1, MASK=condition)
// Returns 1-based index of minimum value where mask is true.
// value(i) returns the value at 0-based index i.
// mask(i) returns true if index i should be considered.
template<typename ValueFn, typename MaskFn>
inline int fortran_minloc(int n, ValueFn value, MaskFn mask) {
    int idx = 1;
    double min_val = std::numeric_limits<double>::max();
    for (int i = 0; i < n; i++) {
        if (mask(i) && value(i) < min_val) {
            min_val = value(i);
            idx = i + 1;
        }
    }
    return idx;
}

// MAXLOC(array, DIM=1, MASK=condition)
// Returns 1-based index of maximum value where mask is true.
template<typename ValueFn, typename MaskFn>
inline int fortran_maxloc(int n, ValueFn value, MaskFn mask) {
    int idx = 1;
    double max_val = -std::numeric_limits<double>::max();
    for (int i = 0; i < n; i++) {
        if (mask(i) && value(i) > max_val) {
            max_val = value(i);
            idx = i + 1;
        }
    }
    return idx;
}

// CSHIFT(array, shift)
// Circular shift: positive shift moves elements left.
inline void fortran_cshift(const double* src, double* dst, int n, int shift) {
    shift = ((shift % n) + n) % n;
    for (int i = 0; i < n; i++) {
        dst[i] = src[(i + shift) % n];
    }
}

#endif // VIT_FORTRAN_INTRINSICS_H
