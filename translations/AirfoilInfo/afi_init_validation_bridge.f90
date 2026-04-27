! VIT: Test-validate bridge for AFI_Init multi-table validation logic.
! Replicates the original AFI_Init lines 175-267 on mock data.
! Allows C++ test harness to call the original Fortran validation.

    SUBROUTINE afi_init_validate_multitable_f90(NumTabs, AFTabMod, &
        Re_array, UserProp_array, filename, ErrStat) &
        BIND(C, NAME='afi_init_validate_multitable_f90')
        USE ISO_C_BINDING
        USE AirfoilInfo
        USE AirfoilInfo_Types
        USE NWTC_Library
        IMPLICIT NONE

        INTEGER(C_INT), VALUE, INTENT(IN) :: NumTabs
        INTEGER(C_INT), VALUE, INTENT(IN) :: AFTabMod
        REAL(C_DOUBLE), INTENT(IN) :: Re_array(*)
        REAL(C_DOUBLE), INTENT(IN) :: UserProp_array(*)
        CHARACTER(KIND=C_CHAR), INTENT(IN) :: filename(1024)
        INTEGER(C_INT), INTENT(OUT) :: ErrStat

        ! Local
        TYPE(AFI_ParameterType) :: p
        TYPE(AFI_InitInputType) :: InitInput
        INTEGER :: iTable, i
        INTEGER :: ErrStat2
        CHARACTER(ErrMsgLen) :: ErrMsg, ErrMsg2
        CHARACTER(*), PARAMETER :: RoutineName = 'AFI_Init'

        ErrStat = ErrID_None
        ErrMsg  = ""

        ! Build mock AFI_ParameterType
        p%NumTabs  = INT(NumTabs, IntKi)
        p%AFTabMod = INT(AFTabMod, IntKi)
        DO i = 1, 1024
            p%FileName(i:i) = filename(i)
        END DO
        DO i = 1, 1024
            InitInput%FileName(i:i) = filename(i)
        END DO

        ! Allocate and populate Table array
        ALLOCATE(p%Table(NumTabs))
        DO iTable = 1, NumTabs
            p%Table(iTable)%Re       = REAL(Re_array(iTable), ReKi)
            p%Table(iTable)%UserProp = REAL(UserProp_array(iTable), ReKi)
        END DO

        ! --- Original AFI_Init validation logic (lines 175-267) ---
        IF ( p%NumTabs > 1 )  THEN

            IF ( p%AFTabMod == AFITable_1 ) THEN
                p%NumTabs = 1
                CALL SetErrStat ( ErrID_Warn, 'DimModel = 1D, therefore using only the first airfoil table in the file: "'//TRIM( InitInput%FileName ), ErrStat, ErrMsg, RoutineName )

            ELSE

                ALLOCATE(p%secondVals(p%NumTabs), STAT=ErrStat2 )
                IF ( ErrStat2 /= 0 )  THEN
                    CALL SetErrStat ( ErrID_Fatal, 'Error allocating memory for the secondVals array.', ErrStat, ErrMsg, RoutineName )
                    RETURN
                ENDIF

                IF (p%AFTabMod == AFITable_2Re) THEN
                    DO iTable=2,p%NumTabs
                        IF ( p%Table(iTable)%UserProp /= p%Table(1)%UserProp )  THEN
                            CALL SetErrStat ( ErrID_Fatal, 'Fatal Error: airfoil file "'//TRIM( InitInput%FileName ) &
                                           //'", Table #'//TRIM( Num2LStr( iTable ) ) &
                                           //' does not have the same value for Ctrl Property (UserProp) as the first table.', ErrStat, ErrMsg, RoutineName )
                            RETURN
                        ENDIF
                    END DO

                    DO iTable=1,p%NumTabs
                        if (p%Table(iTable)%Re < 0.0_ReKi) then
                            CALL SetErrStat ( ErrID_Fatal, 'Fatal Error: airfoil file "'//TRIM( InitInput%FileName ) &
                                           //'", Table #'//TRIM( Num2LStr( iTable ) ) &
                                           //' has a negative Reynolds Number.', ErrStat, ErrMsg, RoutineName )
                            RETURN
                        end if

                        p%Table(iTable)%Re = max( p%Table(iTable)%Re, 0.001_ReKi )

#ifndef AFI_USE_LINEAR_RE
                        p%secondVals(iTable) = log( p%Table(iTable)%Re )
#else
                        p%secondVals(iTable) =      p%Table(iTable)%Re
#endif
                    END DO

                ELSE IF (p%AFTabMod == AFITable_2User) THEN
                    p%secondVals(1) = p%Table(1)%UserProp

                    DO iTable=2,p%NumTabs
                        IF ( p%Table(iTable)%Re /= p%Table(1)%Re )  THEN
                            CALL SetErrStat ( ErrID_Fatal, 'Fatal Error: airfoil file "'//TRIM( InitInput%FileName ) &
                                           //'", Table #'//TRIM( Num2LStr( iTable ) ) &
                                           //' does not have the same value for Re Property (Re) as the first table.', ErrStat, ErrMsg, RoutineName )
                            RETURN
                        ENDIF
                        p%secondVals(iTable) = p%Table(iTable)%UserProp
                    END DO

                END IF

                IF (.NOT. CheckValuesAreUniqueMonotonicIncreasing(p%secondVals)) THEN
                    ErrMsg2 = 'Fatal Error: airfoil file "'//TRIM( InitInput%FileName ) &
                                //'", is not monotonic and increasing in the '
                    IF (p%AFTabMod == AFITable_2Re) THEN
                        ErrMsg2 = trim(ErrMsg2)//' Re Property (Re).'
                    ELSE
                        ErrMsg2 = trim(ErrMsg2)//' Ctrl Property (UserProp).'
                    END IF

                    CALL SetErrStat ( ErrID_Fatal, ErrMsg2, ErrStat, ErrMsg, RoutineName )
                    RETURN
                END IF

            END IF
        ELSE
            p%AFTabMod = AFITable_1
        ENDIF

    END SUBROUTINE afi_init_validate_multitable_f90
