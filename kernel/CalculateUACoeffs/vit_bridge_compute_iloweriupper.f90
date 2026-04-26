! VIT: Kernel callee bridge for Compute_iLoweriUpper
! Allows C++ translations to call the original Fortran function.
    SUBROUTINE compute_iloweriupper_bridge(p, iLower, iUpper) &
        BIND(C, NAME='compute_iloweriupper_c')
        USE ISO_C_BINDING
        USE AirfoilInfo, ONLY: Compute_iLoweriUpper
        USE vit_afi_table_type_view, ONLY: vit_original_afi_table_type
        IMPLICIT NONE
        TYPE(C_PTR), VALUE :: p
        INTEGER(C_INT), INTENT(OUT) :: iLower
        INTEGER(C_INT), INTENT(OUT) :: iUpper
        CALL Compute_iLoweriUpper(vit_original_afi_table_type, iLower, iUpper)
    END SUBROUTINE compute_iloweriupper_bridge