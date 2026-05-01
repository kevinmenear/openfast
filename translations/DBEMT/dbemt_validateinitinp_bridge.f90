! VIT: Test-validate bridge for DBEMT_ValidateInitInp
! Allows C++ test harness to call the original Fortran function.
! Handles C↔Fortran type conversions for derived types and CHARACTER.
    SUBROUTINE dbemt_validateinitinp_f90(interval, vit_InitInp_NumBlades, vit_InitInp_NumNodes, vit_InitInp_tau1_const, vit_InitInp_DBEMT_Mod, vit_InitInp_rLocal_ptr, vit_InitInp_rLocal_rows, vit_InitInp_rLocal_cols, errStat) &
        BIND(C, NAME='dbemt_validateinitinp_f90')
        USE ISO_C_BINDING
        USE DBEMT
        use NWTC_Library
        use DBEMT_Types
        IMPLICIT NONE
        REAL(C_DOUBLE), VALUE, INTENT(IN) :: interval
        INTEGER(C_INT), VALUE :: vit_InitInp_NumBlades
        INTEGER(C_INT), VALUE :: vit_InitInp_NumNodes
        REAL(C_DOUBLE), VALUE :: vit_InitInp_tau1_const
        INTEGER(C_INT), VALUE :: vit_InitInp_DBEMT_Mod
        TYPE(C_PTR), VALUE :: vit_InitInp_rLocal_ptr
        INTEGER(C_INT), VALUE :: vit_InitInp_rLocal_rows
        INTEGER(C_INT), VALUE :: vit_InitInp_rLocal_cols
        INTEGER(C_INT), INTENT(OUT) :: errStat
        TYPE(DBEMT_INITINPUTTYPE) :: vit_local_InitInp
        REAL(C_DOUBLE), POINTER :: vit_tmp_InitInp_rLocal(:)
        INTEGER :: vit_i_rLocal, vit_j_rLocal
        CHARACTER(8192) :: errMsg  ! Local buffer (not compared across language boundary)
        vit_local_InitInp%NumBlades = vit_InitInp_NumBlades
        vit_local_InitInp%NumNodes = vit_InitInp_NumNodes
        vit_local_InitInp%tau1_const = vit_InitInp_tau1_const
        vit_local_InitInp%DBEMT_Mod = vit_InitInp_DBEMT_Mod
        IF (C_ASSOCIATED(vit_InitInp_rLocal_ptr)) THEN
            ALLOCATE(vit_local_InitInp%rLocal(vit_InitInp_rLocal_rows, vit_InitInp_rLocal_cols))
            CALL C_F_POINTER(vit_InitInp_rLocal_ptr, vit_tmp_InitInp_rLocal, [vit_InitInp_rLocal_rows * vit_InitInp_rLocal_cols])
            DO vit_j_rLocal = 1, vit_InitInp_rLocal_cols
                DO vit_i_rLocal = 1, vit_InitInp_rLocal_rows
                    vit_local_InitInp%rLocal(vit_i_rLocal, vit_j_rLocal) = &
                        vit_tmp_InitInp_rLocal((vit_j_rLocal-1)*vit_InitInp_rLocal_rows + vit_i_rLocal)
                END DO
            END DO
        END IF
        CALL DBEMT_ValidateInitInp(interval, vit_local_InitInp, errStat, errMsg)
        IF (ALLOCATED(vit_local_InitInp%rLocal)) DEALLOCATE(vit_local_InitInp%rLocal)
    END SUBROUTINE dbemt_validateinitinp_f90