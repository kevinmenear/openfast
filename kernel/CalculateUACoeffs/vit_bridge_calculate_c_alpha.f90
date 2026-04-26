! VIT: Kernel callee bridge for Calculate_C_alpha
! Allows C++ translations to call the original Fortran function.
    SUBROUTINE calculate_c_alpha_bridge(alpha, n_alpha, Cn, n_Cn, Cl, n_Cl, Default_Cn_alpha, Default_Cl_alpha, Default_alpha0, ErrStat, ErrMsg) &
        BIND(C, NAME='calculate_c_alpha_c')
        USE ISO_C_BINDING
        USE AirfoilInfo, ONLY: Calculate_C_alpha
        IMPLICIT NONE
        REAL(C_DOUBLE), INTENT(IN) :: alpha(*)
        INTEGER(C_INT), VALUE :: n_alpha
        REAL(C_DOUBLE), INTENT(IN) :: Cn(*)
        INTEGER(C_INT), VALUE :: n_Cn
        REAL(C_DOUBLE), INTENT(IN) :: Cl(*)
        INTEGER(C_INT), VALUE :: n_Cl
        REAL(C_DOUBLE), INTENT(OUT) :: Default_Cn_alpha
        REAL(C_DOUBLE), INTENT(OUT) :: Default_Cl_alpha
        REAL(C_DOUBLE), INTENT(OUT) :: Default_alpha0
        INTEGER(C_INT), INTENT(OUT) :: ErrStat
        CHARACTER(KIND=C_CHAR), INTENT(OUT) :: ErrMsg(*)
        CHARACTER(1024) :: local_ErrMsg
        CALL Calculate_C_alpha(alpha(1:n_alpha), Cn(1:n_Cn), Cl(1:n_Cl), Default_Cn_alpha, Default_Cl_alpha, Default_alpha0, ErrStat, local_ErrMsg)
    END SUBROUTINE calculate_c_alpha_bridge