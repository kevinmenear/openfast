! VIT: Kernel callee bridge for kernelSmoothing
! Allows C++ translations to call the original Fortran function.
    SUBROUTINE kernelsmoothing_bridge(x, n_x, f, n_f, kernelType, radius, fNew, n_fNew) &
        BIND(C, NAME='kernelsmoothing_c')
        USE ISO_C_BINDING
        USE NWTC_Num, ONLY: kernelSmoothing
        IMPLICIT NONE
        REAL(C_DOUBLE), INTENT(IN) :: x(*)
        INTEGER(C_INT), VALUE :: n_x
        REAL(C_DOUBLE), INTENT(IN) :: f(*)
        INTEGER(C_INT), VALUE :: n_f
        INTEGER(C_INT), VALUE :: kernelType
        REAL(C_DOUBLE), VALUE :: radius
        REAL(C_DOUBLE), INTENT(OUT) :: fNew(*)
        INTEGER(C_INT), VALUE :: n_fNew
        CALL kernelSmoothing(x(1:n_x), f(1:n_f), kernelType, radius, fNew(1:n_fNew))
    END SUBROUTINE kernelsmoothing_bridge