!**********************************************************************************************************************************
! LICENSING
! Copyright (C) 2015-2018  National Renewable Energy Laboratory
!
!    This file is part of AeroDyn.
!
! Licensed under the Apache License, Version 2.0 (the "License");
! you may not use this file except in compliance with the License.
! You may obtain a copy of the License at
!
!     http://www.apache.org/licenses/LICENSE-2.0
!
! Unless required by applicable law or agreed to in writing, software
! distributed under the License is distributed on an "AS IS" BASIS,
! WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
! See the License for the specific language governing permissions and
! limitations under the License.
!
!**********************************************************************************************************************************
MODULE AirfoilInfo


   ! This module contains airfoil-related routines with non-system-specific logic and references.

! Redo this routing to get rid of some of the phases.  For instance, AFI_Init should be calle directly.

   USE                                             AirfoilInfo_Types
   USE                                          :: ISO_FORTRAN_ENV , ONLY : IOSTAT_EOR
   USE                                          :: NWTC_LAPACK

   USE ISO_C_BINDING
   IMPLICIT NONE

   PRIVATE

   PUBLIC                                       :: AFI_Init ! routine to initialize AirfoilInfo parameters
   PUBLIC                                       :: AFI_ComputeUACoefs        ! routine to calculate Airfoil BL parameters for UA
   PUBLIC                                       :: AFI_ComputeAirfoilCoefs   ! routine to perform 1D (AOA) or 2D (AOA, Re) or (AOA, UserProp) lookup of the airfoil coefs
   PUBLIC                                       :: AFI_WrHeader
   PUBLIC                                       :: AFI_WrData
   PUBLIC                                       :: AFI_WrTables

   TYPE(ProgDesc), PARAMETER                    :: AFI_Ver = ProgDesc( 'AirfoilInfo', '', '')    ! The name, version, and date of AirfoilInfo.

   integer, parameter                           :: MaxNumAFCoeffs = 7 !cl,cd,cm,cpMin, UA:f_st, FullySeparate, FullyAttached

   ! Stashed filename for WrHeader→WrData file passing (C++ manages the file, Fortran passes the path)
   CHARACTER(1024), SAVE                        :: vit_wr_stashed_filename = ' '

    ! Auto-generated interface for C++ implementation of AFI_ComputeUACoefs
    INTERFACE
        SUBROUTINE afi_computeuacoefs_c(p, Re, UserProp, UA_BL, errMsg, errStat) BIND(C, NAME='afi_computeuacoefs_c')
            USE ISO_C_BINDING
            TYPE(C_PTR), VALUE :: p
            REAL(C_DOUBLE), VALUE :: Re
            REAL(C_DOUBLE), VALUE :: UserProp
            TYPE(C_PTR), VALUE :: UA_BL
            CHARACTER(KIND=C_CHAR), INTENT(OUT) :: errMsg(*)
            INTEGER(C_INT), INTENT(OUT) :: errStat
        END SUBROUTINE afi_computeuacoefs_c
    END INTERFACE


    ! Auto-generated interface for C++ implementation of Calculate_Cn
    INTERFACE
        SUBROUTINE calculate_cn_c(alpha, n_alpha, Cl, n_Cl, Cd, n_Cd, Cd0, Calculate_Cn_result) BIND(C, NAME='calculate_cn_c')
            USE ISO_C_BINDING
            REAL(C_DOUBLE), INTENT(IN) :: alpha(*)
            INTEGER(C_INT), VALUE :: n_alpha
            REAL(C_DOUBLE), INTENT(IN) :: Cl(*)
            INTEGER(C_INT), VALUE :: n_Cl
            REAL(C_DOUBLE), INTENT(IN) :: Cd(*)
            INTEGER(C_INT), VALUE :: n_Cd
            REAL(C_DOUBLE), VALUE :: Cd0
            REAL(C_DOUBLE), INTENT(OUT) :: Calculate_Cn_result(*)
        END SUBROUTINE calculate_cn_c
    END INTERFACE


    ! Auto-generated interface for C++ implementation of FindBoundingTables
    INTERFACE
        SUBROUTINE findboundingtables_c(p, secondaryDepVal, lowerTable, upperTable, xVals) BIND(C, NAME='findboundingtables_c')
            USE ISO_C_BINDING
            TYPE(C_PTR), VALUE :: p
            REAL(C_DOUBLE), VALUE :: secondaryDepVal
            INTEGER(C_INT), INTENT(OUT) :: lowerTable
            INTEGER(C_INT), INTENT(OUT) :: upperTable
            REAL(C_DOUBLE), INTENT(OUT) :: xVals(*)
        END SUBROUTINE findboundingtables_c
    END INTERFACE


    ! Auto-generated interface for C++ implementation of Compute_iLoweriUpper
    INTERFACE
        SUBROUTINE compute_iloweriupper_c(p, iLower, iUpper) BIND(C, NAME='compute_iloweriupper_c')
            USE ISO_C_BINDING
            TYPE(C_PTR), VALUE :: p
            INTEGER(C_INT), INTENT(OUT) :: iLower
            INTEGER(C_INT), INTENT(OUT) :: iUpper
        END SUBROUTINE compute_iloweriupper_c
    END INTERFACE


    ! Auto-generated interface for C++ implementation of ComputeUA360_CnOffset
    INTERFACE
        FUNCTION computeua360_cnoffset_c(p, cn_cl, n_cn_cl, Row, iLower) BIND(C, NAME='computeua360_cnoffset_c')
            USE ISO_C_BINDING
            TYPE(C_PTR), VALUE :: p
            REAL(C_DOUBLE), INTENT(IN) :: cn_cl(*)
            INTEGER(C_INT), VALUE :: n_cn_cl
            INTEGER(C_INT), VALUE :: Row
            INTEGER(C_INT), VALUE :: iLower
            REAL(C_DOUBLE) :: computeua360_cnoffset_c
        END FUNCTION computeua360_cnoffset_c
    END INTERFACE


    ! Auto-generated interface for C++ implementation of Calculate_C_alpha
    INTERFACE
        SUBROUTINE calculate_c_alpha_c(alpha, n_alpha, Cn, n_Cn, Cl, n_Cl, Default_Cn_alpha, Default_Cl_alpha, Default_alpha0, ErrStat, ErrMsg) BIND(C, NAME='calculate_c_alpha_c')
            USE ISO_C_BINDING
            REAL(C_DOUBLE), INTENT(IN) :: alpha(*)
            INTEGER(C_INT), VALUE :: n_alpha
            REAL(C_DOUBLE), INTENT(IN) :: Cn(*)
            INTEGER(C_INT), VALUE :: n_Cn
            REAL(C_DOUBLE), INTENT(IN) :: Cl(*)
            INTEGER(C_INT), VALUE :: n_Cl
            REAL(C_DOUBLE), INTENT(OUT) :: Default_Cn_alpha
            REAL(C_DOUBLE), INTENT(OUT) :: Default_Cl_alpha
            REAL(C_DOUBLE), INTENT(OUT) :: Default_alpha0
            INTEGER(C_INT), INTENT(OUT) :: ErrStat
            CHARACTER(KIND=C_CHAR), INTENT(OUT) :: ErrMsg(*)
        END SUBROUTINE calculate_c_alpha_c
    END INTERFACE


    ! Auto-generated interface for C++ implementation of ComputeUASeparationFunction_zero
    INTERFACE
        SUBROUTINE computeuaseparationfunction_zero_c(p, ColUAf, cn_cl, n_cn_cl) BIND(C, NAME='computeuaseparationfunction_zero_c')
            USE ISO_C_BINDING
            TYPE(C_PTR), VALUE :: p
            INTEGER(C_INT), VALUE :: ColUAf
            REAL(C_DOUBLE), INTENT(IN) :: cn_cl(*)
            INTEGER(C_INT), VALUE :: n_cn_cl
        END SUBROUTINE computeuaseparationfunction_zero_c
    END INTERFACE


    ! Auto-generated interface for C++ implementation of ComputeUA360_updateCnSeparated
    INTERFACE
        SUBROUTINE computeua360_updatecnseparated_c(p, ColUAf, cn_cl, n_cn_cl, iLower) BIND(C, NAME='computeua360_updatecnseparated_c')
            USE ISO_C_BINDING
            TYPE(C_PTR), VALUE :: p
            INTEGER(C_INT), VALUE :: ColUAf
            REAL(C_DOUBLE), INTENT(IN) :: cn_cl(*)
            INTEGER(C_INT), VALUE :: n_cn_cl
            INTEGER(C_INT), VALUE :: iLower
        END SUBROUTINE computeua360_updatecnseparated_c
    END INTERFACE


    ! Auto-generated interface for C++ implementation of ComputeUA360_updateSeparationF
    INTERFACE
        SUBROUTINE computeua360_updateseparationf_c(p, ColUAf, cn_cl, n_cn_cl, iLower, iUpper) BIND(C, NAME='computeua360_updateseparationf_c')
            USE ISO_C_BINDING
            TYPE(C_PTR), VALUE :: p
            INTEGER(C_INT), VALUE :: ColUAf
            REAL(C_DOUBLE), INTENT(IN) :: cn_cl(*)
            INTEGER(C_INT), VALUE :: n_cn_cl
            INTEGER(C_INT), VALUE :: iLower
            INTEGER(C_INT), VALUE :: iUpper
        END SUBROUTINE computeua360_updateseparationf_c
    END INTERFACE


    ! Auto-generated interface for C++ implementation of ComputeUASeparationFunction_onCl
    INTERFACE
        SUBROUTINE computeuaseparationfunction_oncl_c(p, ColCl, ColUAf, col_fs, col_fa) BIND(C, NAME='computeuaseparationfunction_oncl_c')
            USE ISO_C_BINDING
            TYPE(C_PTR), VALUE :: p
            INTEGER(C_INT), VALUE :: ColCl
            INTEGER(C_INT), VALUE :: ColUAf
            INTEGER(C_INT), VALUE :: col_fs
            INTEGER(C_INT), VALUE :: col_fa
        END SUBROUTINE computeuaseparationfunction_oncl_c
    END INTERFACE


    ! Auto-generated interface for C++ implementation of ComputeUA360_AttachedFlow
    INTERFACE
        SUBROUTINE computeua360_attachedflow_c(p, ColUAf, cn_cl, n_cn_cl, iLower, iUpper) BIND(C, NAME='computeua360_attachedflow_c')
            USE ISO_C_BINDING
            TYPE(C_PTR), VALUE :: p
            INTEGER(C_INT), VALUE :: ColUAf
            REAL(C_DOUBLE), INTENT(IN) :: cn_cl(*)
            INTEGER(C_INT), VALUE :: n_cn_cl
            INTEGER(C_INT), INTENT(OUT) :: iLower
            INTEGER(C_INT), INTENT(OUT) :: iUpper
        END SUBROUTINE computeua360_attachedflow_c
    END INTERFACE


    ! Auto-generated interface for C++ implementation of CalculateUACoeffs
    INTERFACE
        SUBROUTINE calculateuacoeffs_c(CalcDefaults, p, ColCl, ColCd, ColCm, ColUAf, UAMod) BIND(C, NAME='calculateuacoeffs_c')
            USE ISO_C_BINDING
            TYPE(C_PTR), VALUE :: CalcDefaults
            TYPE(C_PTR), VALUE :: p
            INTEGER(C_INT), VALUE :: ColCl
            INTEGER(C_INT), VALUE :: ColCd
            INTEGER(C_INT), VALUE :: ColCm
            INTEGER(C_INT), VALUE :: ColUAf
            INTEGER(C_INT), VALUE :: UAMod
        END SUBROUTINE calculateuacoeffs_c
    END INTERFACE


    ! Auto-generated interface for C++ implementation of AFI_ValidateInitInput
    INTERFACE
        SUBROUTINE afi_validateinitinput_c(InitInput, ErrStat, ErrMsg) BIND(C, NAME='afi_validateinitinput_c')
            USE ISO_C_BINDING
            TYPE(C_PTR), VALUE :: InitInput
            INTEGER(C_INT), INTENT(OUT) :: ErrStat
            CHARACTER(KIND=C_CHAR), INTENT(OUT) :: ErrMsg(*)
        END SUBROUTINE afi_validateinitinput_c
    END INTERFACE


    ! Auto-generated interface for C++ implementation of AFI_ComputeAirfoilCoefs
    INTERFACE
        SUBROUTINE afi_computeairfoilcoefs_c(AOA, Re, UserProp, p, AFI_interp, errStat, errMsg) BIND(C, NAME='afi_computeairfoilcoefs_c')
            USE ISO_C_BINDING
            REAL(C_DOUBLE), VALUE :: AOA
            REAL(C_DOUBLE), VALUE :: Re
            REAL(C_DOUBLE), VALUE :: UserProp
            TYPE(C_PTR), VALUE :: p
            TYPE(C_PTR), VALUE :: AFI_interp
            INTEGER(C_INT), INTENT(OUT) :: errStat
            CHARACTER(KIND=C_CHAR), INTENT(OUT) :: errMsg(*)
        END SUBROUTINE afi_computeairfoilcoefs_c
    END INTERFACE

CONTAINS


   function CheckValuesAreUniqueMonotonicIncreasing(secondVals)
     
      real(ReKi),  intent(in   )  :: secondVals(:)
      logical CheckValuesAreUniqueMonotonicIncreasing
      
      
      integer(IntKi) :: i
      
      CheckValuesAreUniqueMonotonicIncreasing = .true.
      
      do i = 2, size(secondVals)
         if ( EqualRealNos(secondVals(i), secondVals(i-1)) .or. (secondVals(i) < secondVals(i-1))) then
            CheckValuesAreUniqueMonotonicIncreasing = .false.
            exit
         end if
      end do
      
       
   end function CheckValuesAreUniqueMonotonicIncreasing
   
   !=============================================================================
   SUBROUTINE AFI_Init ( InitInput, p, ErrStat, ErrMsg, UnEcho )
      ! C++ wrapper: two-pass multi-table validation + spline initialization
      USE ISO_C_BINDING
      USE vit_afi_parametertype_view, ONLY: afi_parametertype_view_t, &
          vit_populate_afi_parametertype, vit_copy_scalars_to_afi_parametertype
      USE vit_afi_table_type_view, ONLY: afi_table_type_view_t, vit_copy_scalars_to_afi_table_type
      IMPLICIT NONE

      ! --- Arguments (unchanged from original) ---
      INTEGER(IntKi), INTENT(OUT)               :: ErrStat
      INTEGER, INTENT(IN), OPTIONAL             :: UnEcho
      CHARACTER(*), INTENT(OUT)                 :: ErrMsg
      TYPE (AFI_InitInputType), INTENT(IN   )   :: InitInput
      TYPE (AFI_ParameterType), INTENT(  OUT)   :: p

      ! --- BIND(C) mirror of AFI_InitInputType ---
      TYPE, BIND(C) :: afi_initinput_c_t
          CHARACTER(KIND=C_CHAR) :: FileName(1024)
          INTEGER(C_INT) :: AFTabMod
          INTEGER(C_INT) :: InCol_Alfa
          INTEGER(C_INT) :: InCol_Cl
          INTEGER(C_INT) :: InCol_Cd
          INTEGER(C_INT) :: InCol_Cm
          INTEGER(C_INT) :: InCol_Cpmin
          INTEGER(C_INT) :: UAMod
      END TYPE afi_initinput_c_t

      ! --- C function interfaces ---
      INTERFACE
          SUBROUTINE afi_init_pass1_c(InitInp, p, n_secondVals_out, secondVals_buf, &
                                       spline_dim1_out, spline_dim2_out, errStat, errMsg) BIND(C)
              USE ISO_C_BINDING
              TYPE(C_PTR), VALUE :: InitInp
              TYPE(C_PTR), VALUE :: p
              TYPE(C_PTR), VALUE :: n_secondVals_out
              TYPE(C_PTR), VALUE :: secondVals_buf
              TYPE(C_PTR), VALUE :: spline_dim1_out
              TYPE(C_PTR), VALUE :: spline_dim2_out
              TYPE(C_PTR), VALUE :: errStat
              TYPE(C_PTR), VALUE :: errMsg
          END SUBROUTINE afi_init_pass1_c
          SUBROUTINE afi_init_pass2_c(p, secondVals_buf, n_secondVals, errStat, errMsg) BIND(C)
              USE ISO_C_BINDING
              TYPE(C_PTR), VALUE :: p
              TYPE(C_PTR), VALUE :: secondVals_buf
              INTEGER(C_INT), VALUE :: n_secondVals
              TYPE(C_PTR), VALUE :: errStat
              TYPE(C_PTR), VALUE :: errMsg
          END SUBROUTINE afi_init_pass2_c
      END INTERFACE

      ! --- Local variables ---
      TYPE(afi_parametertype_view_t), TARGET :: p_view
      TYPE(afi_initinput_c_t), TARGET :: initinp_c
      INTEGER(C_INT), TARGET :: c_errStat
      CHARACTER(KIND=C_CHAR), TARGET :: c_errMsg(ErrMsgLen)
      INTEGER(C_INT), TARGET :: n_secondVals
      REAL(C_DOUBLE), TARGET :: secondVals_buf(100)
      INTEGER(C_INT), TARGET :: spline_dim1(100)
      INTEGER(C_INT), TARGET :: spline_dim2(100)
      INTEGER :: iTable, i, UnEc, NumCoefs
      INTEGER :: ErrStat2
      CHARACTER(ErrMsgLen) :: ErrMsg2
      CHARACTER(*), PARAMETER :: RoutineName = 'AFI_Init'
      TYPE(afi_table_type_view_t), POINTER :: table_views(:)

      ErrStat = ErrID_None
      ErrMsg  = ""

      p%FileName = InitInput%FileName

      ! --- Validate inputs ---
      CALL AFI_ValidateInitInput(InitInput, ErrStat2, ErrMsg2)
         CALL SetErrStat(ErrStat2, ErrMsg2, ErrStat, ErrMsg, RoutineName)
         IF (ErrStat >= AbortErrLev) RETURN

      ! --- Handle OPTIONAL UnEcho ---
      IF (PRESENT(UnEcho)) THEN
         UnEc = UnEcho
      ELSE
         UnEc = -1
      END IF

      ! --- Set AFTabMod before ReadAFfile ---
      p%AFTabMod = InitInput%AFTabMod

      ! --- Compute NumCoefs for ReadAFfile ---
      ! (Column index logic replicated here since ReadAFfile needs NumCoefs)
      p%ColCl    = 1
      p%ColCd    = 2
      p%ColCm    = 0
      p%ColCpmin = 0
      p%ColUAf   = 0
      IF (InitInput%InCol_Cm > 0) THEN
         p%ColCm = 3
         IF (InitInput%InCol_Cpmin > 0) THEN
            p%ColCpmin = 4
         END IF
      ELSE IF (InitInput%InCol_Cpmin > 0) THEN
         p%ColCpmin = 3
      END IF
      NumCoefs = MAX(p%ColCd, p%ColCm, p%ColCpmin)

      ! --- Echo header ---
      IF (UnEc > 0) THEN
         WRITE (UnEc,'("--",/,A)') 'Contents of "'//TRIM(InitInput%FileName)//'":'
      END IF

      ! --- Read airfoil file (existing two-pass wrapper) ---
      CALL ReadAFfile(InitInput, NumCoefs, p, ErrStat2, ErrMsg2, UnEc)
         CALL SetErrStat(ErrStat2, ErrMsg2, ErrStat, ErrMsg, RoutineName)
         IF (ErrStat >= AbortErrLev) RETURN

      ! --- Pack InitInput for C++ ---
      DO i = 1, 1024
          initinp_c%FileName(i) = InitInput%FileName(i:i)
      END DO
      initinp_c%AFTabMod   = INT(InitInput%AFTabMod, C_INT)
      initinp_c%InCol_Alfa = INT(InitInput%InCol_Alfa, C_INT)
      initinp_c%InCol_Cl   = INT(InitInput%InCol_Cl, C_INT)
      initinp_c%InCol_Cd   = INT(InitInput%InCol_Cd, C_INT)
      initinp_c%InCol_Cm   = INT(InitInput%InCol_Cm, C_INT)
      initinp_c%InCol_Cpmin = INT(InitInput%InCol_Cpmin, C_INT)
      initinp_c%UAMod      = 0

      ! --- Populate view with ReadAFfile results ---
      CALL vit_populate_afi_parametertype(p, p_view)

      ! --- Pass 1: Column setup + multi-table validation ---
      CALL afi_init_pass1_c(C_LOC(initinp_c), C_LOC(p_view), &
                            C_LOC(n_secondVals), C_LOC(secondVals_buf), &
                            C_LOC(spline_dim1), C_LOC(spline_dim2), &
                            C_LOC(c_errStat), C_LOC(c_errMsg))

      ErrStat2 = INT(c_errStat, IntKi)
      DO i = 1, MIN(LEN(ErrMsg2), ErrMsgLen)
          ErrMsg2(i:i) = c_errMsg(i)
      END DO
      CALL SetErrStat(ErrStat2, ErrMsg2, ErrStat, ErrMsg, RoutineName)
      IF (ErrStat >= AbortErrLev) RETURN

      ! --- Copy modified scalars back from view ---
      CALL vit_copy_scalars_to_afi_parametertype(p_view, p)
      CALL C_F_POINTER(p_view%Table, table_views, [p%NumTabs])
      DO iTable = 1, p%NumTabs
          CALL vit_copy_scalars_to_afi_table_type(table_views(iTable), p%Table(iTable))
      END DO

      ! --- Allocate secondVals if needed ---
      IF (n_secondVals > 0) THEN
          ALLOCATE(p%secondVals(n_secondVals), STAT=ErrStat2)
          IF (ErrStat2 /= 0) THEN
              CALL SetErrStat(ErrID_Fatal, 'Error allocating memory for the secondVals array.', &
                              ErrStat, ErrMsg, RoutineName)
              RETURN
          END IF
      END IF

      ! --- Allocate SplineCoefs per table ---
      DO iTable = 1, p%NumTabs
          IF (spline_dim1(iTable) > 0) THEN
              ALLOCATE(p%Table(iTable)%SplineCoefs(spline_dim1(iTable), &
                       spline_dim2(iTable), 0:3), STAT=ErrStat2)
              IF (ErrStat2 /= 0) THEN
                  CALL SetErrStat(ErrStat2, 'Error allocating memory for the SplineCoefs array.', &
                                  ErrStat, ErrMsg, RoutineName)
                  RETURN
              END IF
          END IF
      END DO

      ! --- Re-populate view with newly allocated arrays ---
      CALL vit_populate_afi_parametertype(p, p_view)

      ! --- Pass 2: Fill secondVals + compute spline coefficients ---
      CALL afi_init_pass2_c(C_LOC(p_view), C_LOC(secondVals_buf), &
                            INT(n_secondVals, C_INT), &
                            C_LOC(c_errStat), C_LOC(c_errMsg))

      ErrStat2 = INT(c_errStat, IntKi)
      DO i = 1, MIN(LEN(ErrMsg2), ErrMsgLen)
          ErrMsg2(i:i) = c_errMsg(i)
      END DO
      CALL SetErrStat(ErrStat2, ErrMsg2, ErrStat, ErrMsg, RoutineName)

   END SUBROUTINE AFI_Init

   !=============================================================================
   !> This routine checks the init input values for AFI and makes sure they are valid
   !! before using them.
    SUBROUTINE AFI_ValidateInitInput(InitInput, ErrStat, ErrMsg)
        USE ISO_C_BINDING
        IMPLICIT NONE
        TYPE(AFI_INITINPUTTYPE), INTENT(IN), TARGET :: InitInput
        INTEGER(4), INTENT(OUT) :: ErrStat
        CHARACTER(*), INTENT(OUT) :: ErrMsg
        CHARACTER(KIND=C_CHAR) :: ErrMsg_c(LEN(ErrMsg))
        INTEGER :: vit_i_ErrMsg
        ! Convert CHARACTER args to C_CHAR arrays
        DO vit_i_ErrMsg = 1, LEN(ErrMsg)
            ErrMsg_c(vit_i_ErrMsg) = ErrMsg(vit_i_ErrMsg:vit_i_ErrMsg)
        END DO
        CALL afi_validateinitinput_c(C_LOC(InitInput), ErrStat, ErrMsg_c)
        ! Copy C_CHAR arrays back to CHARACTER args (INTENT OUT/INOUT)
        DO vit_i_ErrMsg = 1, LEN(ErrMsg)
            ErrMsg(vit_i_ErrMsg:vit_i_ErrMsg) = ErrMsg_c(vit_i_ErrMsg)
        END DO
    END SUBROUTINE AFI_ValidateInitInput
  
   !=============================================================================
   SUBROUTINE ReadAFfile ( InitInp, NumCoefsIn, p, ErrStat, ErrMsg, UnEc )
      ! C++ wrapper: two-pass idiomatic file parser
      USE ISO_C_BINDING
      USE vit_afi_parametertype_view, ONLY: afi_parametertype_view_t, &
          vit_populate_afi_parametertype, vit_copy_scalars_to_afi_parametertype
      USE vit_afi_table_type_view, ONLY: afi_table_type_view_t, vit_copy_scalars_to_afi_table_type
      IMPLICIT NONE

      ! --- Arguments (unchanged from original) ---
      TYPE (AFI_InitInputType), INTENT(IN)    :: InitInp
      INTEGER(IntKi),    INTENT(  OUT)        :: ErrStat
      INTEGER(IntKi),    INTENT(IN   )        :: NumCoefsIn
      INTEGER,           INTENT(IN)           :: UnEc
      CHARACTER(*),      INTENT(  OUT)        :: ErrMsg
      TYPE (AFI_ParameterType), INTENT(INOUT) :: p
      
      ! --- BIND(C) mirror of AFI_InitInputType ---
      TYPE, BIND(C) :: afi_initinput_c_t
          CHARACTER(KIND=C_CHAR) :: FileName(1024)
          INTEGER(C_INT) :: AFTabMod
          INTEGER(C_INT) :: InCol_Alfa
          INTEGER(C_INT) :: InCol_Cl
          INTEGER(C_INT) :: InCol_Cd
          INTEGER(C_INT) :: InCol_Cm
          INTEGER(C_INT) :: InCol_Cpmin
          INTEGER(C_INT) :: UAMod
      END TYPE afi_initinput_c_t

      ! --- C function interfaces ---
      INTERFACE
          SUBROUTINE readaffile_pass1_c(InitInp, NumCoefsIn, p, numalf_out, &
                                         ncoefstab_out, errStat, errMsg) BIND(C)
              USE ISO_C_BINDING
              TYPE(C_PTR), VALUE :: InitInp
              INTEGER(C_INT), VALUE :: NumCoefsIn
              TYPE(C_PTR), VALUE :: p
              TYPE(C_PTR), VALUE :: numalf_out
              TYPE(C_PTR), VALUE :: ncoefstab_out
              TYPE(C_PTR), VALUE :: errStat
              TYPE(C_PTR), VALUE :: errMsg
          END SUBROUTINE readaffile_pass1_c
          SUBROUTINE readaffile_fill_c(p, InitInp, NumCoefsIn, errStat, errMsg) BIND(C)
              USE ISO_C_BINDING
              TYPE(C_PTR), VALUE :: p
              TYPE(C_PTR), VALUE :: InitInp
              INTEGER(C_INT), VALUE :: NumCoefsIn
              TYPE(C_PTR), VALUE :: errStat
              TYPE(C_PTR), VALUE :: errMsg
          END SUBROUTINE readaffile_fill_c
      END INTERFACE

      ! --- Local variables ---
      TYPE(afi_parametertype_view_t), TARGET :: p_view
      TYPE(afi_initinput_c_t), TARGET :: initinp_c
      INTEGER(C_INT), TARGET :: numalf_out(100)
      INTEGER(C_INT), TARGET :: ncoefstab_out(100)
      INTEGER(C_INT), TARGET :: c_errStat
      CHARACTER(KIND=C_CHAR), TARGET :: c_errMsg(ErrMsgLen)
      INTEGER :: iTable, i
      TYPE(afi_table_type_view_t), POINTER :: table_views(:)

      ErrStat = ErrID_None
      ErrMsg  = ""

      ! --- Populate InitInp C struct ---
      DO i = 1, 1024
          initinp_c%FileName(i) = InitInp%FileName(i:i)
      END DO
      initinp_c%AFTabMod   = INT(InitInp%AFTabMod, C_INT)
      initinp_c%InCol_Alfa = INT(InitInp%InCol_Alfa, C_INT)
      initinp_c%InCol_Cl   = INT(InitInp%InCol_Cl, C_INT)
      initinp_c%InCol_Cd   = INT(InitInp%InCol_Cd, C_INT)
      initinp_c%InCol_Cm   = INT(InitInp%InCol_Cm, C_INT)
      initinp_c%InCol_Cpmin = INT(InitInp%InCol_Cpmin, C_INT)
      initinp_c%UAMod      = INT(InitInp%UAMod, C_INT)

      ! --- Pass 1: Parse file, determine sizes ---
      CALL readaffile_pass1_c(C_LOC(initinp_c), INT(NumCoefsIn, C_INT), &
                              C_LOC(p_view), C_LOC(numalf_out), C_LOC(ncoefstab_out), &
                              C_LOC(c_errStat), C_LOC(c_errMsg))

      ErrStat = INT(c_errStat, IntKi)
      ! Copy C error message back to Fortran
      DO i = 1, MIN(LEN(ErrMsg), ErrMsgLen)
          ErrMsg(i:i) = c_errMsg(i)
      END DO
      IF (ErrStat >= AbortErrLev) RETURN

      ! --- Copy parsed scalars from view to Fortran p ---
      p%InterpOrd    = INT(p_view%InterpOrd, IntKi)
      p%RelThickness = REAL(p_view%RelThickness, ReKi)
      p%NonDimArea   = REAL(p_view%NonDimArea, ReKi)
      p%NumCoords    = INT(p_view%NumCoords, IntKi)
      p%NumTabs      = INT(p_view%NumTabs, IntKi)
      p%ColUAf       = INT(p_view%ColUAf, IntKi)
      DO i = 1, 1024
          p%BL_file(i:i) = p_view%BL_file(i)
      END DO

      ! --- Allocate Fortran arrays based on parsed sizes ---
      ALLOCATE(p%Table(p%NumTabs))

      IF (p%NumCoords > 0) THEN
          ALLOCATE(p%X_Coord(p%NumCoords))
          ALLOCATE(p%Y_Coord(p%NumCoords))
      END IF

      DO iTable = 1, p%NumTabs
          ALLOCATE(p%Table(iTable)%Alpha(numalf_out(iTable)))
          ALLOCATE(p%Table(iTable)%Coefs(numalf_out(iTable), ncoefstab_out(iTable)))
          p%Table(iTable)%Coefs = 0.0_ReKi
      END DO

      ! --- Re-populate view with pointers to allocated arrays ---
      CALL vit_populate_afi_parametertype(p, p_view)

      ! --- Pass 2: Fill arrays from cache ---
      CALL readaffile_fill_c(C_LOC(p_view), C_LOC(initinp_c), &
                             INT(NumCoefsIn, C_INT), C_LOC(c_errStat), C_LOC(c_errMsg))

      IF (INT(c_errStat, IntKi) > ErrStat) THEN
          ErrStat = INT(c_errStat, IntKi)
          DO i = 1, MIN(LEN(ErrMsg), ErrMsgLen)
              ErrMsg(i:i) = c_errMsg(i)
          END DO
      END IF

      ! --- Copy scalars back from views to Fortran types ---
      ! Top-level scalar (ColUAf may have been modified by pass 2)
      p%ColUAf = INT(p_view%ColUAf, IntKi)

      ! Per-table scalars (Re, UserProp, NumAlf, ConstData, InclUAdata, UA_BL)
      CALL C_F_POINTER(p_view%Table, table_views, [p%NumTabs])
      DO iTable = 1, p%NumTabs
          CALL vit_copy_scalars_to_afi_table_type(table_views(iTable), p%Table(iTable))
      END DO

   END SUBROUTINE ReadAFfile
!----------------------------------------------------------------------------------------------------------------------------------  
    SUBROUTINE CalculateUACoeffs(CalcDefaults, p, ColCl, ColCd, ColCm, ColUAf, UAMod)
        USE ISO_C_BINDING
        USE vit_afi_table_type_view, ONLY: afi_table_type_view_t, vit_populate_afi_table_type, vit_copy_scalars_to_afi_table_type
        IMPLICIT NONE
        TYPE(AFI_UA_BL_DEFAULT_TYPE), INTENT(IN), TARGET :: CalcDefaults
        TYPE(AFI_TABLE_TYPE), INTENT(INOUT), TARGET :: p
        INTEGER(4), INTENT(IN) :: ColCl
        INTEGER(4), INTENT(IN) :: ColCd
        INTEGER(4), INTENT(IN) :: ColCm
        INTEGER(4), INTENT(IN) :: ColUAf
        INTEGER(4), INTENT(IN) :: UAMod
        TYPE(afi_table_type_view_t), TARGET :: p_view
        ! Populate view structs from Fortran types
        CALL vit_populate_afi_table_type(p, p_view)
        CALL calculateuacoeffs_c(C_LOC(CalcDefaults), C_LOC(p_view), ColCl, ColCd, ColCm, ColUAf, UAMod)
        ! Copy modified scalars back from view to Fortran type
        CALL vit_copy_scalars_to_afi_table_type(p_view, p)
    END SUBROUTINE CalculateUACoeffs
!----------------------------------------------------------------------------------------------------------------------------------
    FUNCTION Calculate_Cn(alpha, Cl, Cd, Cd0) RESULT(Cn)
        USE ISO_C_BINDING
        IMPLICIT NONE
        REAL(8), INTENT(IN) :: alpha(:)
        REAL(8), INTENT(IN) :: Cl(:)
        REAL(8), INTENT(IN) :: Cd(:)
        REAL(8), INTENT(IN) :: Cd0
        REAL(8), DIMENSION(SIZE(ALPHA)) :: Cn
        CALL calculate_cn_c(alpha, SIZE(alpha), Cl, SIZE(Cl), Cd, SIZE(Cd), Cd0, Cn)
    END FUNCTION Calculate_Cn
!----------------------------------------------------------------------------------------------------------------------------------
    SUBROUTINE Calculate_C_alpha(alpha, Cn, Cl, Default_Cn_alpha, Default_Cl_alpha, Default_alpha0, ErrStat, ErrMsg)
        USE ISO_C_BINDING
        IMPLICIT NONE
        REAL(8), INTENT(IN) :: alpha(:)
        REAL(8), INTENT(IN) :: Cn(:)
        REAL(8), INTENT(IN) :: Cl(:)
        REAL(8), INTENT(OUT) :: Default_Cn_alpha
        REAL(8), INTENT(OUT) :: Default_Cl_alpha
        REAL(8), INTENT(OUT) :: Default_alpha0
        INTEGER(4), INTENT(OUT) :: ErrStat
        CHARACTER(*), INTENT(OUT) :: ErrMsg
        CHARACTER(KIND=C_CHAR) :: ErrMsg_c(LEN(ErrMsg))
        INTEGER :: vit_i_ErrMsg
        ! Convert CHARACTER args to C_CHAR arrays
        DO vit_i_ErrMsg = 1, LEN(ErrMsg)
            ErrMsg_c(vit_i_ErrMsg) = ErrMsg(vit_i_ErrMsg:vit_i_ErrMsg)
        END DO
        CALL calculate_c_alpha_c(alpha, SIZE(alpha), Cn, SIZE(Cn), Cl, SIZE(Cl), Default_Cn_alpha, Default_Cl_alpha, Default_alpha0, ErrStat, ErrMsg_c)
        ! Copy C_CHAR arrays back to CHARACTER args (INTENT OUT/INOUT)
        DO vit_i_ErrMsg = 1, LEN(ErrMsg)
            ErrMsg(vit_i_ErrMsg:vit_i_ErrMsg) = ErrMsg_c(vit_i_ErrMsg)
        END DO
    END SUBROUTINE Calculate_C_alpha
!----------------------------------------------------------------------------------------------------------------------------------
    SUBROUTINE ComputeUASeparationFunction_onCl(p, ColCl, ColUAf, col_fs, col_fa)
        USE ISO_C_BINDING
        USE vit_afi_table_type_view, ONLY: afi_table_type_view_t, vit_populate_afi_table_type
        IMPLICIT NONE
        TYPE(AFI_TABLE_TYPE), INTENT(INOUT), TARGET :: p
        INTEGER(4), INTENT(IN) :: ColCl
        INTEGER(4), INTENT(IN) :: ColUAf
        INTEGER(4), INTENT(IN) :: col_fs
        INTEGER(4), INTENT(IN) :: col_fa
        TYPE(afi_table_type_view_t), TARGET :: p_view
        ! Populate view structs from Fortran types
        CALL vit_populate_afi_table_type(p, p_view)
        CALL computeuaseparationfunction_oncl_c(C_LOC(p_view), ColCl, ColUAf, col_fs, col_fa)
    END SUBROUTINE ComputeUASeparationFunction_onCl
!----------------------------------------------------------------------------------------------------------------------------------  
    SUBROUTINE Compute_iLoweriUpper(p, iLower, iUpper)
        USE ISO_C_BINDING
        USE vit_afi_table_type_view, ONLY: afi_table_type_view_t, vit_populate_afi_table_type
        IMPLICIT NONE
        TYPE(AFI_TABLE_TYPE), INTENT(IN), TARGET :: p
        INTEGER(4), INTENT(OUT) :: iLower
        INTEGER(4), INTENT(OUT) :: iUpper
        TYPE(afi_table_type_view_t), TARGET :: p_view
        ! Populate view structs from Fortran types
        CALL vit_populate_afi_table_type(p, p_view)
        CALL compute_iloweriupper_c(C_LOC(p_view), iLower, iUpper)
    END SUBROUTINE Compute_iLoweriUpper
!----------------------------------------------------------------------------------------------------------------------------------  
    SUBROUTINE ComputeUASeparationFunction_zero(p, ColUAf, cn_cl)
        USE ISO_C_BINDING
        USE vit_afi_table_type_view, ONLY: afi_table_type_view_t, vit_populate_afi_table_type
        IMPLICIT NONE
        TYPE(AFI_TABLE_TYPE), INTENT(INOUT), TARGET :: p
        INTEGER(4), INTENT(IN) :: ColUAf
        REAL(8), INTENT(IN) :: cn_cl(:)
        TYPE(afi_table_type_view_t), TARGET :: p_view
        ! Populate view structs from Fortran types
        CALL vit_populate_afi_table_type(p, p_view)
        CALL computeuaseparationfunction_zero_c(C_LOC(p_view), ColUAf, cn_cl, SIZE(cn_cl))
    END SUBROUTINE ComputeUASeparationFunction_zero
!----------------------------------------------------------------------------------------------------------------------------------  
    SUBROUTINE ComputeUA360_AttachedFlow(p, ColUAf, cn_cl, iLower, iUpper)
        USE ISO_C_BINDING
        USE vit_afi_table_type_view, ONLY: afi_table_type_view_t, vit_populate_afi_table_type, vit_copy_scalars_to_afi_table_type
        IMPLICIT NONE
        TYPE(AFI_TABLE_TYPE), INTENT(INOUT), TARGET :: p
        INTEGER(4), INTENT(IN) :: ColUAf
        REAL(8), INTENT(IN) :: cn_cl(:)
        INTEGER(4), INTENT(OUT) :: iLower
        INTEGER(4), INTENT(OUT) :: iUpper
        TYPE(afi_table_type_view_t), TARGET :: p_view
        ! Populate view structs from Fortran types
        CALL vit_populate_afi_table_type(p, p_view)
        CALL computeua360_attachedflow_c(C_LOC(p_view), ColUAf, cn_cl, SIZE(cn_cl), iLower, iUpper)
        ! Copy modified scalars back from view to Fortran type
        CALL vit_copy_scalars_to_afi_table_type(p_view, p)
    END SUBROUTINE ComputeUA360_AttachedFlow
!----------------------------------------------------------------------------------------------------------------------------------  
    SUBROUTINE ComputeUA360_updateSeparationF(p, ColUAf, cn_cl, iLower, iUpper)
        USE ISO_C_BINDING
        USE vit_afi_table_type_view, ONLY: afi_table_type_view_t, vit_populate_afi_table_type
        IMPLICIT NONE
        TYPE(AFI_TABLE_TYPE), INTENT(INOUT), TARGET :: p
        INTEGER(4), INTENT(IN) :: ColUAf
        REAL(8), INTENT(IN) :: cn_cl(:)
        INTEGER(4), INTENT(IN) :: iLower
        INTEGER(4), INTENT(IN) :: iUpper
        TYPE(afi_table_type_view_t), TARGET :: p_view
        ! Populate view structs from Fortran types
        CALL vit_populate_afi_table_type(p, p_view)
        CALL computeua360_updateseparationf_c(C_LOC(p_view), ColUAf, cn_cl, SIZE(cn_cl), iLower, iUpper)
    END SUBROUTINE ComputeUA360_updateSeparationF
!----------------------------------------------------------------------------------------------------------------------------------  
    SUBROUTINE ComputeUA360_updateCnSeparated(p, ColUAf, cn_cl, iLower)
        USE ISO_C_BINDING
        USE vit_afi_table_type_view, ONLY: afi_table_type_view_t, vit_populate_afi_table_type
        IMPLICIT NONE
        TYPE(AFI_TABLE_TYPE), INTENT(INOUT), TARGET :: p
        INTEGER(4), INTENT(IN) :: ColUAf
        REAL(8), INTENT(IN) :: cn_cl(:)
        INTEGER(4), INTENT(IN) :: iLower
        TYPE(afi_table_type_view_t), TARGET :: p_view
        ! Populate view structs from Fortran types
        CALL vit_populate_afi_table_type(p, p_view)
        CALL computeua360_updatecnseparated_c(C_LOC(p_view), ColUAf, cn_cl, SIZE(cn_cl), iLower)
    END SUBROUTINE ComputeUA360_updateCnSeparated
!----------------------------------------------------------------------------------------------------------------------------------  
    FUNCTION ComputeUA360_CnOffset(p, cn_cl, Row, iLower) RESULT(offset)
        USE ISO_C_BINDING
        USE vit_afi_table_type_view, ONLY: afi_table_type_view_t, vit_populate_afi_table_type
        IMPLICIT NONE
        TYPE(AFI_TABLE_TYPE), INTENT(IN), TARGET :: p
        REAL(8), INTENT(IN) :: cn_cl(:)
        INTEGER(4), INTENT(IN) :: Row
        INTEGER(4), INTENT(IN) :: iLower
        REAL(8) :: offset
        TYPE(afi_table_type_view_t), TARGET :: p_view
        ! Populate view structs from Fortran types
        CALL vit_populate_afi_table_type(p, p_view)
        offset = REAL(computeua360_cnoffset_c(C_LOC(p_view), cn_cl, SIZE(cn_cl), Row, iLower), 8)
    END FUNCTION ComputeUA360_CnOffset
!----------------------------------------------------------------------------------------------------------------------------------  
    SUBROUTINE FindBoundingTables(p, secondaryDepVal, lowerTable, upperTable, xVals)
        USE ISO_C_BINDING
        USE vit_afi_parametertype_view, ONLY: afi_parametertype_view_t, vit_populate_afi_parametertype
        IMPLICIT NONE
        TYPE(AFI_PARAMETERTYPE), INTENT(IN), TARGET :: p
        REAL(8), INTENT(IN) :: secondaryDepVal
        INTEGER(4), INTENT(OUT) :: lowerTable
        INTEGER(4), INTENT(OUT) :: upperTable
        REAL(8), INTENT(OUT) :: xVals(2)
        TYPE(afi_parametertype_view_t), TARGET :: p_view
        ! Populate view structs from Fortran types
        CALL vit_populate_afi_parametertype(p, p_view)
        CALL findboundingtables_c(C_LOC(p_view), secondaryDepVal, lowerTable, upperTable, xVals)
    END SUBROUTINE FindBoundingTables
!----------------------------------------------------------------------------------------------------------------------------------  
subroutine AFI_ComputeUACoefs2D( secondaryDepVal, p, UA_BL, errStat, errMsg )
! This routine is calculates the UA parameters for a set of tables which are dependent a 2nd user-defined varible, could be Re or Cntrl, etc.
! If the requested yVar is not associated with a given table, then the two tables which contain yVar are found and, a cubic spline interpolation is performed at the requested AOA.
! for each of those two tables. Then a linear intepolation is performed on the 2nd dimension to find the final Cl,Cd,Cm, and Cpmin values.
! If the requested yVar corresponds to a table, then only a single cubic interpolation based on the requested AOA is performed.
!..................................................................................................................................
   real(ReKi),               intent(in   ) :: secondaryDepVal            ! Interpolate based on this value
   TYPE (AFI_ParameterType), intent(in   ) :: p                          ! This structure stores all the module parameters that are set by AirfoilInfo during the initialization phase.
   type(AFI_UA_BL_Type),     intent(  out) :: UA_BL
   integer(IntKi),           intent(  out) :: errStat                    ! Error status of the operation
   character(*),             intent(  out) :: errMsg                     ! Error message if ErrStat /= ErrID_None 
   
   real(ReKi)                              :: xVals(2)                   ! secondary interpolation values associated with the tables (this takes the place of time in the extrapInterp routines generated by the Registry)
   
   integer                                 :: lowerTable, upperTable
   character(*), parameter                 :: RoutineName = 'AFI_ComputeUACoefs2D'

   
   ErrStat = ErrID_None
   ErrMsg  = ''
   
      ! find boundaries for 
   
         ! Let's check the limits first.

   IF ( secondaryDepVal <= p%secondVals( 1 ) )  THEN
   ! was call SetErrStat (ErrID_Fatal, "Specified Reynold's number, "//trim(num2lstr(secondaryDepVal))//" , is outside the range of Re specified in the airfoil input file tables.", ErrStat, ErrMsg, RoutineName )
   ! or  call SetErrStat (ErrID_Fatal, "Specified User Property's value, "//trim(num2lstr(secondaryDepVal))//" , is outside the range of User Property values specified in the airfoil input file tables.", ErrStat, ErrMsg, RoutineName )
      call AFI_CopyUA_BL_Type( p%Table(1)%UA_BL, UA_BL, MESH_NEWCOPY, errStat, errMsg )  ! this doesn't have a mesh, so the control code is irrelevant
      return
   ELSE IF ( secondaryDepVal >= p%secondVals( p%NumTabs ) ) THEN
   ! was call SetErrStat (ErrID_Fatal, "Specified Reynold's number, "//trim(num2lstr(secondaryDepVal))//" , is outside the range of Re specified in the airfoil input file tables.", ErrStat, ErrMsg, RoutineName )
   ! or  call SetErrStat (ErrID_Fatal, "Specified User Property's value, "//trim(num2lstr(secondaryDepVal))//" , is outside the range of User Property values specified in the airfoil input file tables.", ErrStat, ErrMsg, RoutineName )
      call AFI_CopyUA_BL_Type( p%Table(p%NumTabs)%UA_BL, UA_BL, MESH_NEWCOPY, errStat, errMsg )  ! this doesn't have a mesh, so the control code is irrelevant
      return
   END IF

   call FindBoundingTables(p, secondaryDepVal, lowerTable, upperTable, xVals)

      ! linearly interpolate
   call AFI_UA_BL_Type_ExtrapInterp1(p%Table(lowerTable)%UA_BL, p%Table(upperTable)%UA_BL, xVals, UA_BL, secondaryDepVal, ErrStat, ErrMsg )

   
end subroutine AFI_ComputeUACoefs2D  
!----------------------------------------------------------------------------------------------------------------------------------  
subroutine AFI_ComputeAirfoilCoefs2D( AOA, secondaryDepVal, p, AFI_interp, errStat, errMsg )
! This routine is calculates Cl, Cd, Cm, (and Cpmin) for a set of tables which are dependent on AOA as well as a 2nd user-defined varible, could be Re or Cntrl, etc.
! If the requested yVar is not associated with a given table, then the two tables which contain yVar are found and, a cubic spline interpolation is performed at the requested AOA.
! for each of those two tables. Then a linear intepolation is performed on the 2nd dimension to find the final Cl,Cd,Cm, and Cpmin values.
! If the requested yVar corresponds to a table, then only a single cubic interpolation based on the requested AOA is performed.
!..................................................................................................................................
   real(ReKi),               intent(in   ) :: AOA
   real(ReKi),               intent(in   ) :: secondaryDepVal           ! Unused in the current version!     
   TYPE (AFI_ParameterType), intent(in   ) :: p                          ! This structure stores all the module parameters that are set by AirfoilInfo during the initialization phase.
   type(AFI_OutputType),     intent(  out) :: AFI_interp                 ! contains    real(ReKi),               intent(  out) :: Cl, Cd, Cm, Cpmin
   integer(IntKi),           intent(  out) :: errStat                    ! Error status of the operation
   character(*),             intent(  out) :: errMsg                     ! Error message if ErrStat /= ErrID_None 
   
   
   integer                                 :: lowerTable, upperTable
   real(ReKi)                              :: xVals(2)
   type(AFI_OutputType)                    :: AFI_lower
   type(AFI_OutputType)                    :: AFI_upper
      
   ErrStat = ErrID_None
   ErrMsg  = ''
   
   IF ( secondaryDepVal <= p%secondVals( 1 ) )  THEN
   ! was call SetErrStat (ErrID_Fatal, "Specified Reynold's number, "//trim(num2lstr(secondaryDepVal))//" , is outside the range of Re specified in the airfoil input file tables.", ErrStat, ErrMsg, RoutineName )
   ! or  call SetErrStat (ErrID_Fatal, "Specified User Property's value, "//trim(num2lstr(secondaryDepVal))//" , is outside the range of User Property values specified in the airfoil input file tables.", ErrStat, ErrMsg, RoutineName )
      call AFI_ComputeAirfoilCoefs1D( AOA, p, AFI_interp, errStat, errMsg, 1 )
      return
   ELSE IF ( secondaryDepVal >= p%secondVals( p%NumTabs ) ) THEN
   ! was call SetErrStat (ErrID_Fatal, "Specified Reynold's number, "//trim(num2lstr(secondaryDepVal))//" , is outside the range of Re specified in the airfoil input file tables.", ErrStat, ErrMsg, RoutineName )
   ! or  call SetErrStat (ErrID_Fatal, "Specified User Property's value, "//trim(num2lstr(secondaryDepVal))//" , is outside the range of User Property values specified in the airfoil input file tables.", ErrStat, ErrMsg, RoutineName )
      call AFI_ComputeAirfoilCoefs1D( AOA, p, AFI_interp, errStat, errMsg, p%NumTabs )
      return
   END IF
   
   call FindBoundingTables(p, secondaryDepVal, lowerTable, upperTable, xVals)
   
!fixme ERROR HANDLING!   
   call AFI_ComputeAirfoilCoefs1D( AOA, p, AFI_lower, errStat, errMsg, lowerTable )
      if (ErrStat >= AbortErrLev) return
   call AFI_ComputeAirfoilCoefs1D( AOA, p, AFI_upper, errStat, errMsg, upperTable )
      if (ErrStat >= AbortErrLev) return

       ! linearly interpolate these values
   call AFI_Output_ExtrapInterp1(AFI_lower, AFI_upper, xVals, AFI_interp, secondaryDepVal, ErrStat, ErrMsg )
   
   
end subroutine AFI_ComputeAirfoilCoefs2D  
         
!----------------------------------------------------------------------------------------------------------------------------------  
subroutine AFI_ComputeAirfoilCoefs1D( AOA, p, AFI_interp, errStat, errMsg, TableNum )
! If the requested yVar is not associated with a given table, then the two tables which contain yVar are found and, a cubic spline interpolation is performed at the requested AOA.
! for each of those two tables. Then a linear intepolation is performed on the 2nd dimension to find the final Cl,Cd,Cm, and Cpmin values.
! If the requested yVar corresponds to a table, then only a single cubic interpolation based on the requested AOA is performed.
!..................................................................................................................................
   real(ReKi),               intent(in   ) :: AOA 
   TYPE (AFI_ParameterType), intent(in   ) :: p                          ! This structure stores all the module parameters that are set by AirfoilInfo during the initialization phase.
   type(AFI_OutputType)                    :: AFI_interp                 !  Cl, Cd, Cm, Cpmin
   integer(IntKi),           intent(  out) :: errStat                    ! Error status of the operation
   character(*),             intent(  out) :: errMsg                     ! Error message if ErrStat /= ErrID_None
   integer(IntKi), optional, intent(in   ) :: TableNum
   
   
   real                                    :: IntAFCoefs(MaxNumAFCoeffs)                ! The interpolated airfoil coefficients.
   real(reki)                              :: Alpha
   integer                                 :: s1
   integer                                 :: iTab

      
   ErrStat = ErrID_None
   ErrMsg  = ''

   if (present(TableNum)) then
      iTab = TableNum
   else
      iTab = 1
   end if
   
   IntAFCoefs = 0.0_ReKi ! initialize in case we only don't have MaxNumAFCoeffs columns in the airfoil data (e.g., so cm is zero if not in the file)
 
   s1 = size(p%Table(iTab)%Coefs,2)
   
   if (p%Table(iTab)%ConstData) then
      IntAFCoefs(1:s1) = p%Table(iTab)%Coefs(1,:)   ! all the rows are constant, so we can just return the values at any alpha (e.g., row 1)
   else
      Alpha = AOA
      call MPi2Pi ( Alpha ) ! change AOA into range of -pi to pi
   
   
         ! Spline interpolation of lower table based on requested AOA
       CALL CubicSplineInterpM( Alpha, p%Table(iTab)%Alpha, p%Table(iTab)%Coefs, p%Table(iTab)%SplineCoefs, IntAFCoefs(1:s1) )
   end if
  
   AFI_interp%Cl    = IntAFCoefs(p%ColCl)
   AFI_interp%Cd    = IntAFCoefs(p%ColCd)
     
   if ( p%ColCm > 0 ) then
      AFI_interp%Cm = IntAFCoefs(p%ColCm)
   else
      AFI_interp%Cm    = 0.0_Reki  !Set these to zero unless there is data to be read in
   end if
   
   if ( p%ColCpmin > 0 ) then
      AFI_interp%Cpmin = IntAFCoefs(p%ColCpmin)
   else
      AFI_interp%Cpmin = 0.0_Reki
   end if

   if ( p%ColUAf > 0 ) then
      AFI_interp%f_st          = IntAFCoefs(p%ColUAf)   ! separation function
      AFI_interp%fullySeparate = IntAFCoefs(p%ColUAf+1) ! fully separated cn or cl
      AFI_interp%fullyAttached = IntAFCoefs(p%ColUAf+2) ! fully attached cn or cl
   else
      AFI_interp%f_st          = 0.0_ReKi
      AFI_interp%fullySeparate = 0.0_ReKi
      AFI_interp%fullyAttached = 0.0_ReKi
   end if
   
      ! needed if using UnsteadyAero:
   if (p%Table(iTab)%InclUAdata) then
      AFI_interp%Cd0 = p%Table(iTab)%UA_BL%Cd0
      AFI_interp%Cm0 = p%Table(iTab)%UA_BL%Cm0
   else
      AFI_interp%Cd0 = 0.0_ReKi
      AFI_interp%Cm0 = 0.0_ReKi
   end if
   
   
end subroutine AFI_ComputeAirfoilCoefs1D

!----------------------------------------------------------------------------------------------------------------------------------  
!> This routine calculates Cl, Cd, Cm, (and Cpmin) for a set of tables which are dependent on AOA as well as a 2nd user-defined varible, could be Re or Cntrl, etc.
    SUBROUTINE AFI_ComputeAirfoilCoefs(AOA, Re, UserProp, p, AFI_interp, errStat, errMsg)
        USE ISO_C_BINDING
        USE vit_afi_parametertype_view, ONLY: afi_parametertype_view_t, vit_populate_afi_parametertype
        IMPLICIT NONE
        REAL(8), INTENT(IN) :: AOA
        REAL(8), INTENT(IN) :: Re
        REAL(8), INTENT(IN) :: UserProp
        TYPE(AFI_PARAMETERTYPE), INTENT(IN), TARGET :: p
        TYPE(AFI_OUTPUTTYPE), INTENT(OUT), TARGET :: AFI_interp
        INTEGER(4), INTENT(OUT) :: errStat
        CHARACTER(*), INTENT(OUT) :: errMsg
        CHARACTER(KIND=C_CHAR) :: errMsg_c(LEN(errMsg))
        INTEGER :: vit_i_errMsg
        TYPE(afi_parametertype_view_t), TARGET :: p_view
        ! Populate view structs from Fortran types
        CALL vit_populate_afi_parametertype(p, p_view)
        ! Convert CHARACTER args to C_CHAR arrays
        DO vit_i_errMsg = 1, LEN(errMsg)
            errMsg_c(vit_i_errMsg) = errMsg(vit_i_errMsg:vit_i_errMsg)
        END DO
        CALL afi_computeairfoilcoefs_c(AOA, Re, UserProp, C_LOC(p_view), C_LOC(AFI_interp), errStat, errMsg_c)
        ! Copy C_CHAR arrays back to CHARACTER args (INTENT OUT/INOUT)
        DO vit_i_errMsg = 1, LEN(errMsg)
            errMsg(vit_i_errMsg:vit_i_errMsg) = errMsg_c(vit_i_errMsg)
        END DO
    END SUBROUTINE AFI_ComputeAirfoilCoefs

!----------------------------------------------------------------------------------------------------------------------------------  
!> This routine calculates Cl, Cd, Cm, (and Cpmin) for a set of tables which are dependent on AOA as well as a 2nd user-defined varible, could be Re or Cntrl, etc.
    SUBROUTINE AFI_ComputeUACoefs(p, Re, UserProp, UA_BL, errMsg, errStat)
        USE ISO_C_BINDING
        USE vit_afi_parametertype_view, ONLY: afi_parametertype_view_t, vit_populate_afi_parametertype
        IMPLICIT NONE
        TYPE(AFI_PARAMETERTYPE), INTENT(IN), TARGET :: p
        REAL(8), INTENT(IN) :: Re
        REAL(8), INTENT(IN) :: UserProp
        TYPE(AFI_UA_BL_TYPE), INTENT(OUT), TARGET :: UA_BL
        INTEGER(4), INTENT(OUT) :: errStat
        CHARACTER(*), INTENT(OUT) :: errMsg
        CHARACTER(KIND=C_CHAR) :: errMsg_c(LEN(errMsg))
        INTEGER :: vit_i_errMsg
        TYPE(afi_parametertype_view_t), TARGET :: p_view
        ! Populate view structs from Fortran types
        CALL vit_populate_afi_parametertype(p, p_view)
        ! Convert CHARACTER args to C_CHAR arrays
        DO vit_i_errMsg = 1, LEN(errMsg)
            errMsg_c(vit_i_errMsg) = errMsg(vit_i_errMsg:vit_i_errMsg)
        END DO
        CALL afi_computeuacoefs_c(C_LOC(p_view), Re, UserProp, C_LOC(UA_BL), errMsg_c, errStat)
        ! Copy C_CHAR arrays back to CHARACTER args (INTENT OUT/INOUT)
        DO vit_i_errMsg = 1, LEN(errMsg)
            errMsg(vit_i_errMsg:vit_i_errMsg) = errMsg_c(vit_i_errMsg)
        END DO
    END SUBROUTINE AFI_ComputeUACoefs

!=============================================================================
subroutine AFI_WrHeader(delim, FileName, unOutFile, ErrStat, ErrMsg)
   ! C++ wrapper: opens file and writes header with 46 channel names/units
   USE ISO_C_BINDING
   IMPLICIT NONE

   character(*),                 intent(in   )  :: delim
   character(*),                 intent(in   )  :: FileName
   integer(IntKi),               intent(  out)  :: unOutFile
   integer(IntKi),               intent(  out)  :: ErrStat
   character(*),                 intent(  out)  :: ErrMsg

   INTERFACE
       SUBROUTINE afi_wrheader_c(delim, filename, errStat, errMsg) BIND(C)
           USE ISO_C_BINDING
           TYPE(C_PTR), VALUE :: delim
           TYPE(C_PTR), VALUE :: filename
           TYPE(C_PTR), VALUE :: errStat
           TYPE(C_PTR), VALUE :: errMsg
       END SUBROUTINE afi_wrheader_c
   END INTERFACE

   CHARACTER(KIND=C_CHAR), TARGET :: c_delim(2)
   CHARACTER(KIND=C_CHAR), TARGET :: c_filename(1024)
   INTEGER(C_INT), TARGET :: c_errStat
   CHARACTER(KIND=C_CHAR), TARGET :: c_errMsg(ErrMsgLen)
   INTEGER :: i

   ErrStat = ErrID_None
   ErrMsg  = ""

   ! Pack delimiter (null-terminated)
   c_delim(1) = delim(1:1)
   c_delim(2) = C_NULL_CHAR

   ! Pack filename (null-terminated)
   DO i = 1, MIN(LEN_TRIM(FileName), 1023)
       c_filename(i) = FileName(i:i)
   END DO
   c_filename(MIN(LEN_TRIM(FileName), 1023) + 1) = C_NULL_CHAR

   ! Stash filename for WrData to use
   vit_wr_stashed_filename = FileName

   ! C++ opens file, writes header, closes
   CALL afi_wrheader_c(C_LOC(c_delim), C_LOC(c_filename), C_LOC(c_errStat), C_LOC(c_errMsg))

   ErrStat = INT(c_errStat, IntKi)
   DO i = 1, MIN(LEN(ErrMsg), ErrMsgLen)
       ErrMsg(i:i) = c_errMsg(i)
   END DO
   IF (ErrStat >= AbortErrLev) RETURN

   ! Open Fortran unit to same file (APPEND mode) so caller's close() works
   CALL GetNewUnit(unOutFile, ErrStat, ErrMsg)
   IF (ErrStat >= AbortErrLev) RETURN
   OPEN(UNIT=unOutFile, FILE=TRIM(FileName), POSITION='APPEND', STATUS='OLD', FORM='FORMATTED')

end subroutine AFI_WrHeader
!=============================================================================
subroutine AFI_WrData(k, unOutFile, delim, AFInfo)
   ! C++ wrapper: writes UA_BL parameter rows to file
   USE ISO_C_BINDING
   USE vit_afi_parametertype_view, ONLY: afi_parametertype_view_t, vit_populate_afi_parametertype
   IMPLICIT NONE

   type(AFI_ParameterType),      intent(in   )  :: AFInfo
   integer,                      intent(in   )  :: k
   integer(IntKi),               intent(in   )  :: unOutFile
   character(*),                 intent(in   )  :: delim

   INTERFACE
       SUBROUTINE afi_wrdata_c(k, filename, delim, p) BIND(C)
           USE ISO_C_BINDING
           INTEGER(C_INT), VALUE :: k
           TYPE(C_PTR), VALUE :: filename
           TYPE(C_PTR), VALUE :: delim
           TYPE(C_PTR), VALUE :: p
       END SUBROUTINE afi_wrdata_c
   END INTERFACE

   TYPE(afi_parametertype_view_t), TARGET :: p_view
   CHARACTER(KIND=C_CHAR), TARGET :: c_delim(2)
   CHARACTER(KIND=C_CHAR), TARGET :: c_filename(1024)
   INTEGER :: i

   ! Pack delimiter
   c_delim(1) = delim(1:1)
   c_delim(2) = C_NULL_CHAR

   ! Pack stashed filename
   DO i = 1, MIN(LEN_TRIM(vit_wr_stashed_filename), 1023)
       c_filename(i) = vit_wr_stashed_filename(i:i)
   END DO
   c_filename(MIN(LEN_TRIM(vit_wr_stashed_filename), 1023) + 1) = C_NULL_CHAR

   ! Populate view struct
   CALL vit_populate_afi_parametertype(AFInfo, p_view)

   ! C++ reopens file in append mode, writes data, closes
   CALL afi_wrdata_c(INT(k, C_INT), C_LOC(c_filename), C_LOC(c_delim), C_LOC(p_view))

end subroutine AFI_WrData
!=============================================================================
subroutine AFI_WrTables(AFI_Params,UAMod,OutRootName)
   ! C++ wrapper: writes per-table coefficient files with derived quantities
   USE ISO_C_BINDING
   USE vit_afi_parametertype_view, ONLY: afi_parametertype_view_t, vit_populate_afi_parametertype
   IMPLICIT NONE

   type(AFI_ParameterType), intent(in), target  :: AFI_Params
   integer(IntKi),          intent(in)          :: UAMod
   character(*),            intent(in)          :: OutRootName

   INTERFACE
       SUBROUTINE afi_wrtables_c(p, UAMod, OutRootName) BIND(C)
           USE ISO_C_BINDING
           TYPE(C_PTR), VALUE :: p
           INTEGER(C_INT), VALUE :: UAMod
           TYPE(C_PTR), VALUE :: OutRootName
       END SUBROUTINE afi_wrtables_c
   END INTERFACE

   TYPE(afi_parametertype_view_t), TARGET :: p_view
   CHARACTER(KIND=C_CHAR), TARGET :: c_rootname(1024)
   INTEGER :: i

   ! Pack root name (space-padded to 1024 for C++ trimming)
   DO i = 1, 1024
       IF (i <= LEN_TRIM(OutRootName)) THEN
           c_rootname(i) = OutRootName(i:i)
       ELSE
           c_rootname(i) = ' '
       END IF
   END DO

   ! Populate view struct
   CALL vit_populate_afi_parametertype(AFI_Params, p_view)

   ! C++ handles all file I/O
   CALL afi_wrtables_c(C_LOC(p_view), INT(UAMod, C_INT), C_LOC(c_rootname))

end subroutine AFI_WrTables
!=============================================================================
   
END MODULE AirfoilInfo
