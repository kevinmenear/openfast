// VIT: Kernel callee bridge declarations
// Auto-generated — allows C++ translations to call
// original Fortran functions via BIND(C) bridges.

#ifndef VIT_KERNEL_CALLEES_H
#define VIT_KERNEL_CALLEES_H

#ifdef __cplusplus
extern "C" {
#endif

void compute_iloweriupper_c(afi_table_type_view_t* p, int* iLower, int* iUpper);
double interpextrapstp_c(double XVal, double* XAry, double* YAry, int* Ind, int AryLen);

#ifdef __cplusplus
}
#endif

#endif // VIT_KERNEL_CALLEES_H
