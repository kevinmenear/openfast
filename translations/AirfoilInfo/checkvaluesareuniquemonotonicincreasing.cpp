// VIT Translation
// Function: CheckValuesAreUniqueMonotonicIncreasing
// Source: AirfoilInfo.f90
// Module: AirfoilInfo
// Fortran: FUNCTION CheckValuesAreUniqueMonotonicIncreasing(secondVals)
// Status: unverified

#include "vit_nwtc.h"

// Returns true if the array is strictly monotonically increasing and unique.
// Uses EqualRealNos for floating-point tolerance comparison.
bool CheckValuesAreUniqueMonotonicIncreasing(const double* secondVals, int n) {
    for (int i = 1; i < n; i++) {
        if (EqualRealNos(secondVals[i], secondVals[i - 1]) || secondVals[i] < secondVals[i - 1]) {
            return false;
        }
    }
    return true;
}
