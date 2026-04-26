! VIT: Test-validate bridge for AFI_ValidateInitInput
! Allows C++ test harness to call the original Fortran function.
! Handles C↔Fortran type conversions for derived types and CHARACTER.
    SUBROUTINE afi_validateinitinput_f90(InitInput_ptr, ErrStat) &
        BIND(C, NAME='afi_validateinitinput_f90')
        USE ISO_C_BINDING
        USE AirfoilInfo
        USE                                             AirfoilInfo_Types
        USE                                          :: NWTC_LAPACK
        IMPLICIT NONE
        TYPE(C_PTR), VALUE :: InitInput_ptr
        INTEGER(C_INT), INTENT(OUT) :: ErrStat
        TYPE(AFI_InitInputType), POINTER :: InitInput
        CHARACTER(8192) :: ErrMsg  ! Local buffer (not compared across language boundary)
        CALL C_F_POINTER(InitInput_ptr, InitInput)
        CALL AFI_ValidateInitInput(InitInput, ErrStat, ErrMsg)
    END SUBROUTINE afi_validateinitinput_f90