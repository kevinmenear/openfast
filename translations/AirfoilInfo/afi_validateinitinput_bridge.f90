! VIT: Test-validate bridge for AFI_ValidateInitInput
! Allows C++ test harness to call the original Fortran function.
    SUBROUTINE afi_validateinitinput_f90(InitInput, ErrStat, ErrMsg) &
        BIND(C, NAME='afi_validateinitinput_f90')
        USE ISO_C_BINDING
        USE AirfoilInfo, ONLY: AFI_ValidateInitInput
        IMPLICIT NONE
        TYPE(AFI_InitInputType), INTENT(IN) :: InitInput
        INTEGER(C_INT), INTENT(OUT) :: ErrStat
        CHARACTER(C_CHAR), INTENT(OUT) :: ErrMsg(*)
        CALL AFI_ValidateInitInput(InitInput, ErrStat, ErrMsg)
    END SUBROUTINE afi_validateinitinput_f90