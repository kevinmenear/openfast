! VIT: Test-validate bridge for CheckValuesAreUniqueMonotonicIncreasing
! Allows C++ test harness to call the original Fortran function.
! Handles C↔Fortran type conversions for derived types and CHARACTER.
    SUBROUTINE checkvaluesareuniquemonotonicincreasing_f90(secondVals, n_secondVals, vit_result) &
        BIND(C, NAME='checkvaluesareuniquemonotonicincreasing_f90')
        USE ISO_C_BINDING
        USE AirfoilInfo
        IMPLICIT NONE
        REAL(C_DOUBLE), INTENT(IN) :: secondVals(*)
        INTEGER(C_INT), VALUE, INTENT(IN) :: n_secondVals
        LOGICAL(C_BOOL), INTENT(OUT) :: vit_result
        vit_result = LOGICAL(CheckValuesAreUniqueMonotonicIncreasing(secondVals(1:n_secondVals)), C_BOOL)
    END SUBROUTINE checkvaluesareuniquemonotonicincreasing_f90