! VIT: File-output test bridge for AFI_WrHeader + AFI_WrData
! Calls the original Fortran implementations with mock data.

    SUBROUTINE afi_wrheaderdata_f90(filename, delim, NumAirfoils, &
        NumTabs_per_airfoil, InclUAdata, Re_vals, UserProp_vals, &
        alpha0_vals, Cn1_vals) &
        BIND(C, NAME='afi_wrheaderdata_f90')
        USE ISO_C_BINDING
        USE AirfoilInfo
        USE AirfoilInfo_Types
        USE NWTC_Library
        IMPLICIT NONE

        CHARACTER(KIND=C_CHAR), INTENT(IN) :: filename(*)
        CHARACTER(KIND=C_CHAR), INTENT(IN) :: delim(*)
        INTEGER(C_INT), VALUE, INTENT(IN) :: NumAirfoils
        INTEGER(C_INT), VALUE, INTENT(IN) :: NumTabs_per_airfoil
        INTEGER(C_INT), INTENT(IN) :: InclUAdata(*)
        REAL(C_DOUBLE), INTENT(IN) :: Re_vals(*)
        REAL(C_DOUBLE), INTENT(IN) :: UserProp_vals(*)
        REAL(C_DOUBLE), INTENT(IN) :: alpha0_vals(*)
        REAL(C_DOUBLE), INTENT(IN) :: Cn1_vals(*)

        ! Local
        TYPE(AFI_ParameterType), ALLOCATABLE :: AFInfo(:)
        INTEGER :: k, iTab, idx
        INTEGER(IntKi) :: unOutFile, ErrStat
        CHARACTER(ErrMsgLen) :: ErrMsg
        CHARACTER(1024) :: f_filename
        CHARACTER(1) :: f_delim
        INTEGER :: i

        ! Unpack filename
        i = 1
        DO WHILE (filename(i) /= C_NULL_CHAR .AND. i <= 1024)
            f_filename(i:i) = filename(i)
            i = i + 1
        END DO
        DO WHILE (i <= 1024)
            f_filename(i:i) = ' '
            i = i + 1
        END DO

        f_delim = delim(1)

        ! Build mock AFInfo array
        ALLOCATE(AFInfo(NumAirfoils))
        DO k = 1, NumAirfoils
            ALLOCATE(AFInfo(k)%Table(NumTabs_per_airfoil))
            DO iTab = 1, NumTabs_per_airfoil
                idx = (k - 1) * NumTabs_per_airfoil + iTab
                AFInfo(k)%Table(iTab)%InclUAdata = (InclUAdata(idx) /= 0)
                AFInfo(k)%Table(iTab)%Re = REAL(Re_vals(idx), ReKi)
                AFInfo(k)%Table(iTab)%UserProp = REAL(UserProp_vals(idx), ReKi)
                AFInfo(k)%Table(iTab)%UA_BL%alpha0 = REAL(alpha0_vals(idx), ReKi)
                AFInfo(k)%Table(iTab)%UA_BL%alpha1 = 0.2_ReKi
                AFInfo(k)%Table(iTab)%UA_BL%alpha2 = -0.2_ReKi
                AFInfo(k)%Table(iTab)%UA_BL%eta_e = 0.95_ReKi
                AFInfo(k)%Table(iTab)%UA_BL%C_nalpha = 6.28_ReKi
                AFInfo(k)%Table(iTab)%UA_BL%C_lalpha = 6.28_ReKi
                AFInfo(k)%Table(iTab)%UA_BL%T_f0 = 3.0_ReKi
                AFInfo(k)%Table(iTab)%UA_BL%T_V0 = 6.0_ReKi
                AFInfo(k)%Table(iTab)%UA_BL%T_p = 1.7_ReKi
                AFInfo(k)%Table(iTab)%UA_BL%T_VL = 11.0_ReKi
                AFInfo(k)%Table(iTab)%UA_BL%b1 = 0.14_ReKi
                AFInfo(k)%Table(iTab)%UA_BL%b2 = 0.53_ReKi
                AFInfo(k)%Table(iTab)%UA_BL%b5 = 5.0_ReKi
                AFInfo(k)%Table(iTab)%UA_BL%A1 = 0.3_ReKi
                AFInfo(k)%Table(iTab)%UA_BL%A2 = 0.7_ReKi
                AFInfo(k)%Table(iTab)%UA_BL%A5 = 1.0_ReKi
                AFInfo(k)%Table(iTab)%UA_BL%S1 = 0.0_ReKi
                AFInfo(k)%Table(iTab)%UA_BL%S2 = 0.0_ReKi
                AFInfo(k)%Table(iTab)%UA_BL%S3 = 0.0_ReKi
                AFInfo(k)%Table(iTab)%UA_BL%S4 = 0.0_ReKi
                AFInfo(k)%Table(iTab)%UA_BL%Cn1 = REAL(Cn1_vals(idx), ReKi)
                AFInfo(k)%Table(iTab)%UA_BL%Cn2 = -0.5_ReKi
                AFInfo(k)%Table(iTab)%UA_BL%St_sh = 0.19_ReKi
                AFInfo(k)%Table(iTab)%UA_BL%Cd0 = 0.01_ReKi
                AFInfo(k)%Table(iTab)%UA_BL%Cm0 = -0.05_ReKi
                AFInfo(k)%Table(iTab)%UA_BL%k0 = 0.0_ReKi
                AFInfo(k)%Table(iTab)%UA_BL%k1 = 0.0_ReKi
                AFInfo(k)%Table(iTab)%UA_BL%k2 = 0.0_ReKi
                AFInfo(k)%Table(iTab)%UA_BL%k3 = 0.0_ReKi
                AFInfo(k)%Table(iTab)%UA_BL%k1_hat = 0.0_ReKi
                AFInfo(k)%Table(iTab)%UA_BL%x_cp_bar = 0.25_ReKi
                AFInfo(k)%Table(iTab)%UA_BL%UACutout = 0.524_ReKi
                AFInfo(k)%Table(iTab)%UA_BL%UACutout_delta = 0.087_ReKi
                AFInfo(k)%Table(iTab)%UA_BL%UACutout_blend = 0.0_ReKi
                AFInfo(k)%Table(iTab)%UA_BL%filtCutOff = 0.5_ReKi
                AFInfo(k)%Table(iTab)%UA_BL%alphaLower = -0.1_ReKi
                AFInfo(k)%Table(iTab)%UA_BL%alphaUpper = 0.3_ReKi
                AFInfo(k)%Table(iTab)%UA_BL%c_alphaLower = 0.0_ReKi
                AFInfo(k)%Table(iTab)%UA_BL%c_alphaUpper = 0.0_ReKi
                AFInfo(k)%Table(iTab)%UA_BL%alpha0ReverseFlow = 0.0_ReKi
                AFInfo(k)%Table(iTab)%UA_BL%alphaBreakUpper = 0.25_ReKi
                AFInfo(k)%Table(iTab)%UA_BL%CnBreakUpper = 1.2_ReKi
                AFInfo(k)%Table(iTab)%UA_BL%alphaBreakLower = -0.15_ReKi
                AFInfo(k)%Table(iTab)%UA_BL%CnBreakLower = -0.8_ReKi
            END DO
        END DO

        ! Initialize NWTC Library constants (R2D, D2R, Pi, etc.)
        ! These are module variables set at runtime, not PARAMETER constants.
        CALL NWTC_Init()

        ! Call original Fortran WrHeader
        CALL AFI_WrHeader(f_delim, TRIM(f_filename), unOutFile, ErrStat, ErrMsg)
        IF (ErrStat >= AbortErrLev) RETURN

        ! Call original Fortran WrData for each airfoil
        DO k = 1, NumAirfoils
            CALL AFI_WrData(k, unOutFile, f_delim, AFInfo(k))
        END DO

        CLOSE(unOutFile)

    END SUBROUTINE afi_wrheaderdata_f90
