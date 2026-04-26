! VIT: Kernel callee bridge for ComputeUASeparationFunction_onCl
! Allows C++ translations to call the original Fortran function.
    SUBROUTINE computeuaseparationfunction_oncl_bridge(p, ColCl, ColUAf, col_fs, col_fa) &
        BIND(C, NAME='computeuaseparationfunction_oncl_c')
        USE ISO_C_BINDING
        USE AirfoilInfo, ONLY: ComputeUASeparationFunction_onCl
        USE vit_afi_table_type_view, ONLY: vit_original_afi_table_type, afi_table_type_view_t, vit_populate_afi_table_type, vit_copy_scalars_to_afi_table_type
        IMPLICIT NONE
        TYPE(C_PTR), VALUE :: p
        INTEGER(C_INT), VALUE :: ColCl
        INTEGER(C_INT), VALUE :: ColUAf
        INTEGER(C_INT), VALUE :: col_fs
        INTEGER(C_INT), VALUE :: col_fa
        TYPE(afi_table_type_view_t), POINTER :: p_view
        ! Flush C++ modifications to Fortran before callee call
        CALL C_F_POINTER(p, p_view)
        CALL vit_copy_scalars_to_afi_table_type(p_view, vit_original_afi_table_type)
        CALL ComputeUASeparationFunction_onCl(vit_original_afi_table_type, ColCl, ColUAf, col_fs, col_fa)
        ! Re-sync view struct from Fortran type after callee modified it
        CALL C_F_POINTER(p, p_view)
        CALL vit_populate_afi_table_type(vit_original_afi_table_type, p_view)
    END SUBROUTINE computeuaseparationfunction_oncl_bridge