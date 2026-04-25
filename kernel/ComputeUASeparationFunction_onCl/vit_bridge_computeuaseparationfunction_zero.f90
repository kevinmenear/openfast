! VIT: Kernel callee bridge for ComputeUASeparationFunction_zero
! Allows C++ translations to call the original Fortran function.
    SUBROUTINE computeuaseparationfunction_zero_bridge(p, ColUAf, cn_cl, n_cn_cl) &
        BIND(C, NAME='computeuaseparationfunction_zero_c')
        USE ISO_C_BINDING
        USE AirfoilInfo, ONLY: ComputeUASeparationFunction_zero
        USE vit_afi_table_type_view, ONLY: vit_original_afi_table_type, afi_table_type_view_t, vit_populate_afi_table_type
        IMPLICIT NONE
        TYPE(C_PTR), VALUE :: p
        INTEGER(C_INT), VALUE :: ColUAf
        REAL(C_DOUBLE), INTENT(IN) :: cn_cl(*)
        INTEGER(C_INT), VALUE :: n_cn_cl
        TYPE(afi_table_type_view_t), POINTER :: p_view
        CALL ComputeUASeparationFunction_zero(vit_original_afi_table_type, ColUAf, cn_cl(1:n_cn_cl))
        ! Re-sync view struct from Fortran type after callee modified it
        CALL C_F_POINTER(p, p_view)
        CALL vit_populate_afi_table_type(vit_original_afi_table_type, p_view)
    END SUBROUTINE computeuaseparationfunction_zero_bridge