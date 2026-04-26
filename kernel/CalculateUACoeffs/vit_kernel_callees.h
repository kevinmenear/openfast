// VIT: Kernel callee bridge declarations
// Auto-generated — allows C++ translations to call
// original Fortran functions via BIND(C) bridges.

#ifndef VIT_KERNEL_CALLEES_H
#define VIT_KERNEL_CALLEES_H

#ifdef __cplusplus
extern "C" {
#endif

void calculate_cn_c(double* alpha, int n_alpha, double* Cl, int n_Cl, double* Cd, int n_Cd, double Cd0, double* Calculate_Cn_result);
void calculate_c_alpha_c(double* alpha, int n_alpha, double* Cn, int n_Cn, double* Cl, int n_Cl, double* Default_Cn_alpha, double* Default_Cl_alpha, double* Default_alpha0, int* ErrStat, char* ErrMsg);
void computeua360_attachedflow_c(afi_table_type_view_t* p, int ColUAf, double* cn_cl, int n_cn_cl, int* iLower, int* iUpper);
void computeua360_updatecnseparated_c(afi_table_type_view_t* p, int ColUAf, double* cn_cl, int n_cn_cl, int iLower);
void computeua360_updateseparationf_c(afi_table_type_view_t* p, int ColUAf, double* cn_cl, int n_cn_cl, int iLower, int iUpper);
void computeuaseparationfunction_oncl_c(afi_table_type_view_t* p, int ColCl, int ColUAf, int col_fs, int col_fa);
void compute_iloweriupper_c(afi_table_type_view_t* p, int* iLower, int* iUpper);
void kernelsmoothing_c(double* x, int n_x, double* f, int n_f, int kernelType, double radius, double* fNew, int n_fNew);

#ifdef __cplusplus
}
#endif

#endif // VIT_KERNEL_CALLEES_H
