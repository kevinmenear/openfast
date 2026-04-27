! VIT: Kernel callee bridge for FindBoundingTables
! Allows C++ translations to call the original Fortran function.
    SUBROUTINE findboundingtables_bridge(p, secondaryDepVal, lowerTable, upperTable, xVals) &
        BIND(C, NAME='findboundingtables_c')
        USE ISO_C_BINDING
        USE AirfoilInfo, ONLY: FindBoundingTables
        USE vit_afi_parametertype_view, ONLY: vit_original_afi_parametertype
        IMPLICIT NONE
        TYPE(C_PTR), VALUE :: p
        REAL(C_DOUBLE), VALUE :: secondaryDepVal
        INTEGER(C_INT), INTENT(OUT) :: lowerTable
        INTEGER(C_INT), INTENT(OUT) :: upperTable
        REAL(C_DOUBLE), INTENT(OUT) :: xVals(*)
        CALL FindBoundingTables(vit_original_afi_parametertype, secondaryDepVal, lowerTable, upperTable, xVals)
    END SUBROUTINE findboundingtables_bridge