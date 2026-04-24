// VIT Translation Scaffold
// Function: Calculate_Cn
// Source: AirfoilInfo.f90
// Module: AirfoilInfo
// Fortran: FUNCTION Calculate_Cn(alpha, Cl, Cd, Cd0) RESULT(Cn)
// Source MD5: e870261d3759
// VIT: 0.1.0
// Status: unverified
// Generated: 2026-04-24T14:16:52Z

#include <cmath>

void Calculate_Cn(double* alpha, int n_alpha, double* Cl, int n_Cl, double* Cd, int n_Cd, double Cd0, double* Calculate_Cn_result) {
    for (int i = 0; i < n_alpha; ++i) {
        Calculate_Cn_result[i] = Cl[i] * std::cos(alpha[i]) + (Cd[i] - Cd0) * std::sin(alpha[i]);
    }
}
