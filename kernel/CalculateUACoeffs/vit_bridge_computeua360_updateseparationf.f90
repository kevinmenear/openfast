! VIT: Kernel callee bridge for ComputeUA360_updateSeparationF
! Allows C++ translations to call the original Fortran function.
    SUBROUTINE computeua360_updateseparationf_bridge(p, ColUAf, cn_cl, n_cn_cl, iLower, iUpper) &
        BIND(C, NAME='computeua360_updateseparationf_c')
        USE ISO_C_BINDING
        USE AirfoilInfo, ONLY: ComputeUA360_updateSeparationF
        USE vit_afi_table_type_view, ONLY: vit_original_afi_table_type, afi_table_type_view_t, vit_populate_afi_table_type, vit_copy_scalars_to_afi_table_type
        IMPLICIT NONE
        TYPE(C_PTR), VALUE :: p
        INTEGER(C_INT), VALUE :: ColUAf
        REAL(C_DOUBLE), INTENT(IN) :: cn_cl(*)
        INTEGER(C_INT), VALUE :: n_cn_cl
        INTEGER(C_INT), VALUE :: iLower
        INTEGER(C_INT), VALUE :: iUpper
        TYPE(afi_table_type_view_t), POINTER :: p_view
        ! Flush C++ modifications to Fortran before callee call
        CALL C_F_POINTER(p, p_view)
        CALL vit_copy_scalars_to_afi_table_type(p_view, vit_original_afi_table_type)
        CALL ComputeUA360_updateSeparationF(vit_original_afi_table_type, ColUAf, cn_cl(1:n_cn_cl), iLower, iUpper)
        ! Re-sync view struct from Fortran type after callee modified it
        CALL C_F_POINTER(p, p_view)
        CALL vit_populate_afi_table_type(vit_original_afi_table_type, p_view)
    END SUBROUTINE computeua360_updateseparationf_bridge