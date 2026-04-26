! VIT: Kernel callee bridge for Calculate_Cn
! Allows C++ translations to call the original Fortran function.
    SUBROUTINE calculate_cn_bridge(alpha, n_alpha, Cl, n_Cl, Cd, n_Cd, Cd0, Calculate_Cn_result) &
        BIND(C, NAME='calculate_cn_c')
        USE ISO_C_BINDING
        USE AirfoilInfo, ONLY: Calculate_Cn
        IMPLICIT NONE
        REAL(C_DOUBLE), INTENT(IN) :: alpha(*)
        INTEGER(C_INT), VALUE :: n_alpha
        REAL(C_DOUBLE), INTENT(IN) :: Cl(*)
        INTEGER(C_INT), VALUE :: n_Cl
        REAL(C_DOUBLE), INTENT(IN) :: Cd(*)
        INTEGER(C_INT), VALUE :: n_Cd
        REAL(C_DOUBLE), VALUE :: Cd0
        REAL(C_DOUBLE), INTENT(OUT) :: Calculate_Cn_result(*)
        Calculate_Cn_result(1:n_alpha) = Calculate_Cn(alpha(1:n_alpha), Cl(1:n_Cl), Cd(1:n_Cd), Cd0)
    END SUBROUTINE calculate_cn_bridge