! VIT: File-output test bridge for AFI_WrTables
! Builds a fully populated AFI_ParameterType and calls original Fortran.

    SUBROUTINE afi_wrtables_f90(NumAlf, NumCoefCols, ColCl, ColCd, ColCm, ColUAf, &
        UAMod, Alpha_array, Coefs_array, OutRootName) &
        BIND(C, NAME='afi_wrtables_f90')
        USE ISO_C_BINDING
        USE AirfoilInfo
        USE AirfoilInfo_Types
        USE NWTC_Library
        IMPLICIT NONE

        INTEGER(C_INT), VALUE, INTENT(IN) :: NumAlf
        INTEGER(C_INT), VALUE, INTENT(IN) :: NumCoefCols
        INTEGER(C_INT), VALUE, INTENT(IN) :: ColCl, ColCd, ColCm, ColUAf
        INTEGER(C_INT), VALUE, INTENT(IN) :: UAMod
        REAL(C_DOUBLE), INTENT(IN) :: Alpha_array(*)
        REAL(C_DOUBLE), INTENT(IN) :: Coefs_array(*)
        CHARACTER(KIND=C_CHAR), INTENT(IN) :: OutRootName(*)

        ! Local
        TYPE(AFI_ParameterType), TARGET :: p
        INTEGER :: i, j, idx
        CHARACTER(1024) :: f_rootname

        ! Initialize NWTC Library constants (R2D, D2R, Pi, etc.)
        CALL NWTC_Init()

        ! Unpack root name
        i = 1
        DO WHILE (OutRootName(i) /= C_NULL_CHAR .AND. i <= 1024)
            f_rootname(i:i) = OutRootName(i)
            i = i + 1
        END DO
        DO WHILE (i <= 1024)
            f_rootname(i:i) = ' '
            i = i + 1
        END DO

        ! Build mock AFI_ParameterType with 1 table
        p%ColCl = INT(ColCl, IntKi)
        p%ColCd = INT(ColCd, IntKi)
        p%ColCm = INT(ColCm, IntKi)
        p%ColUAf = INT(ColUAf, IntKi)
        p%NumTabs = 1

        ALLOCATE(p%Table(1))
        p%Table(1)%NumAlf = INT(NumAlf, IntKi)
        p%Table(1)%InclUAdata = .TRUE.

        ALLOCATE(p%Table(1)%Alpha(NumAlf))
        DO i = 1, NumAlf
            p%Table(1)%Alpha(i) = REAL(Alpha_array(i), ReKi)
        END DO

        ! Coefs is column-major: Coefs(row, col) stored as Coefs_array((col-1)*NumAlf + row)
        ALLOCATE(p%Table(1)%Coefs(NumAlf, NumCoefCols))
        idx = 1
        DO j = 1, NumCoefCols
            DO i = 1, NumAlf
                p%Table(1)%Coefs(i, j) = REAL(Coefs_array(idx), ReKi)
                idx = idx + 1
            END DO
        END DO

        ! Set UA_BL parameters
        p%Table(1)%UA_BL%alpha0 = 0.0_ReKi
        p%Table(1)%UA_BL%alpha1 = 0.2_ReKi
        p%Table(1)%UA_BL%alpha2 = -0.2_ReKi
        p%Table(1)%UA_BL%C_nalpha = 6.28_ReKi
        p%Table(1)%UA_BL%C_lalpha = 6.28_ReKi
        p%Table(1)%UA_BL%Cd0 = 0.01_ReKi
        p%Table(1)%UA_BL%alphaBreakLower = -0.15_ReKi
        p%Table(1)%UA_BL%alphaBreakUpper = 0.15_ReKi
        p%Table(1)%UA_BL%Cn1 = 1.5_ReKi
        p%Table(1)%UA_BL%Cn2 = -0.5_ReKi

        ! Call original Fortran WrTables
        CALL AFI_WrTables(p, INT(UAMod, IntKi), TRIM(f_rootname))

    END SUBROUTINE afi_wrtables_f90
