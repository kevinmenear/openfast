!KGEN-generated Fortran source file 
  
!Generated at : 2026-04-25 21:22:06 
!KGEN version : 0.8.1 
  
!**********************************************************************************************************************************
! LICENSING
! Copyright (C) 2015-2018  National Renewable Energy Laboratory
!    This file is part of AeroDyn.
! Licensed under the Apache License, Version 2.0 (the "License");
! you may not use this file except in compliance with the License.
! You may obtain a copy of the License at
!     http://www.apache.org/licenses/LICENSE-2.0
! Unless required by applicable law or agreed to in writing, software
! distributed under the License is distributed on an "AS IS" BASIS,
! WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
! See the License for the specific language governing permissions and
! limitations under the License.
!**********************************************************************************************************************************


!
!
!
!
!
MODULE AirfoilInfo
   ! This module contains airfoil-related routines with non-system-specific logic and references.
! Redo this routing to get rid of some of the phases.  For instance, AFI_Init should be calle directly.


    USE airfoilinfo_types 
    USE nwtc_lapack 
    USE kgen_utils_mod
    USE tprof_mod, ONLY: tstart, tstop, tnull, tprnt 

    USE ISO_C_BINDING
    IMPLICIT NONE 

    PRIVATE 


    PUBLIC readaffile 
    PUBLIC Calculate_Cn
    PUBLIC Calculate_C_alpha
    PUBLIC ComputeUASeparationFunction_onCl
    PUBLIC Compute_iLoweriUpper
    PUBLIC ComputeUA360_AttachedFlow
    PUBLIC ComputeUA360_updateSeparationF
    PUBLIC ComputeUA360_updateCnSeparated


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

CONTAINS


   !=============================================================================
   


   !=============================================================================
   !> This routine checks the init input values for AFI and makes sure they are valid
   !! before using them.
   


   !=============================================================================
  
SUBROUTINE readaffile(kgen_unit, kgen_measure, kgen_isverified, kgen_filepath, initinp, p) 
         ! This routine reads an airfoil file.
         ! Argument declarations.
    USE kgen_utils_mod
    USE kgen_utils_mod
    USE nwtc_num, ONLY: kr_externs_out_nwtc_num 
    USE kgen_utils_mod


    TYPE(afi_initinputtype), INTENT(INOUT) :: initinp 
      


    TYPE(afi_parametertype), INTENT(INOUT) :: p 
         ! Local declarations.


                                              
    INTEGER :: itable 
                                              


      
    TYPE(afi_ua_bl_default_type), allocatable :: calcdefaults(:) 
    INTEGER, INTENT(IN) :: kgen_unit 
    REAL(KIND=kgen_dp), INTENT(OUT) :: kgen_measure 
    LOGICAL, INTENT(OUT) :: kgen_isverified 
    CHARACTER(LEN=*), INTENT(IN) :: kgen_filepath 
    LOGICAL :: kgen_istrue 
    REAL(KIND=8) :: kgen_array_sum 
    INTEGER :: kgen_intvar, kgen_ierr 
    INTEGER :: kgen_mpirank, kgen_openmptid, kgen_kernelinvoke 
    LOGICAL :: kgen_evalstage, kgen_warmupstage, kgen_mainstage 
    COMMON / state / kgen_mpirank, kgen_openmptid, kgen_kernelinvoke, kgen_evalstage, kgen_warmupstage, kgen_mainstage 
    INTEGER, PARAMETER :: KGEN_MAXITER = 1 
      
    TYPE(check_t) :: check_status 
    INTEGER*8 :: kgen_start_clock, kgen_stop_clock, kgen_rate_clock 
    REAL(KIND=kgen_dp) :: gkgen_measure 
    TYPE(afi_parametertype) :: kgenref_p 
    INTEGER :: kgenref_itable 
      
    !parent block preprocessing 
    kgen_mpirank = 0 
      
    !local input variables 
    READ (UNIT = kgen_unit) itable 
    CALL kr_kgen_readaffile_subp2(calcdefaults, kgen_unit, "calcdefaults", .FALSE.) 
      
    !extern output variables 
    CALL kr_externs_out_nwtc_num(kgen_unit) 
      
    !local output variables 
    CALL kr_airfoilinfo_types_afi_parametertype(kgenref_p, kgen_unit, "kgenref_p", .FALSE.) 
    READ (UNIT = kgen_unit) kgenref_itable 
      
      ! Getting parent folder of airfoils data (e.g. "Arifoils/")
      
         ! Process the (possibly) nested set of files.  This copies the decommented contents of
         ! AFI_FileInfo%FileName and the files it includes (both directly and indirectly) into
         ! the FileInfo structure that we can then parse.


         ! Process the airfoil shape information if it is included.
         


      

         ! RelThickness, default is 0.2 if user doesn't know it, only used for Boeing-Vertol UA model = 7
         

         ! NonDimArea is currently unused by AirfoilInfo or codes using AirfoilInfo.  GJH 9/13/2017
         
         
         ! NumCoords, with the Coords data, is used for determining the blade shape (currently used 
         !   for visualization only).  This data (blade coordinates) is passed to the caller via 
         !   the InitOut%BladeShape data structure, and stored in p%XCoord, etc.,
         !   but is currently unused by AFI module.  GJH 9/13/2017
         


      ! Reading Boundary layer file for aeroacoustics
      

         !CALL SetErrStat( ErrStat2, ErrMsg2, ErrStat, ErrMsg, RoutineName )

         ! How many columns do we need to read in the input and how many total coefficients will be used?


         ! Work through the multiple tables.


    IF (kgen_evalstage) THEN 
    END IF   
    IF (kgen_warmupstage) THEN 
    END IF   
    IF (kgen_mainstage) THEN 
    END IF   
      
    !Uncomment following call statement to turn on perturbation experiment. 
    !Adjust perturbation value and/or kind parameter if required. 
    !CALL kgen_perturb_real( your_variable, 1.0E-15_8 ) 
      
      
    !call to kgen kernel 
            call CalculateUACoeffs(CalcDefaults(iTable), p%Table(iTable), p%ColCl, p%ColCd, p%ColCm, p%ColUAf, InitInp%UAMod)
            IF (kgen_mainstage) THEN 
                  
                !verify init 
                CALL kgen_init_verify(tolerance=1.D-14, minvalue=1.D-14, verboseLevel=100) 
                CALL kgen_init_check(check_status, rank=kgen_mpirank) 
                  
                !extern verify variables 
                  
                !local verify variables 
                CALL kv_airfoilinfo_types_afi_parametertype("p", check_status, p, kgenref_p) 
                CALL kv_readaffile_integer__("itable", check_status, itable, kgenref_itable) 
                IF (check_status%rank == 0) THEN 
                    WRITE (*, *) "" 
                END IF   
                IF (kgen_verboseLevel > 0) THEN 
                    IF (check_status%rank == 0) THEN 
                        WRITE (*, *) "Number of output variables: ", check_status%numTotal 
                        WRITE (*, *) "Number of identical variables: ", check_status%numIdentical 
                        WRITE (*, *) "Number of non-identical variables within tolerance: ", check_status%numInTol 
                        WRITE (*, *) "Number of non-identical variables out of tolerance: ", check_status%numOutTol 
                        WRITE (*, *) "Tolerance: ", kgen_tolerance 
                    END IF   
                END IF   
                IF (check_status%rank == 0) THEN 
                    WRITE (*, *) "" 
                END IF   
                IF (check_status%numOutTol > 0) THEN 
                    IF (check_status%rank == 0) THEN 
                        WRITE (*, *) "Verification FAILED with" // TRIM(ADJUSTL(kgen_filepath)) 
                    END IF   
                    check_status%Passed = .FALSE. 
                    kgen_isverified = .FALSE. 
                ELSE 
                    IF (check_status%rank == 0) THEN 
                        WRITE (*, *) "Verification PASSED with " // TRIM(ADJUSTL(kgen_filepath)) 
                    END IF   
                    check_status%Passed = .TRUE. 
                    kgen_isverified = .TRUE. 
                END IF   
                IF (check_status%rank == 0) THEN 
                    WRITE (*, *) "" 
                END IF   
                CALL SYSTEM_CLOCK(kgen_start_clock, kgen_rate_clock) 
                DO kgen_intvar = 1, KGEN_MAXITER 
            call CalculateUACoeffs(CalcDefaults(iTable), p%Table(iTable), p%ColCl, p%ColCd, p%ColCm, p%ColUAf, InitInp%UAMod)
                END DO   
                CALL SYSTEM_CLOCK(kgen_stop_clock, kgen_rate_clock) 
                kgen_measure = 1.0D6*(kgen_stop_clock - kgen_start_clock)/DBLE(kgen_rate_clock*KGEN_MAXITER) 
                IF (check_status%rank==0) THEN 
                    WRITE (*, *) "CalculateUACoeffs : Time per call (usec): ", kgen_measure 
                END IF   
            END IF   
            IF (kgen_warmupstage) THEN 
            END IF   
            IF (kgen_evalstage) THEN 
            END IF   


      !=======================================================================

      !=======================================================================
              
            CONTAINS 
              
                  


            !read state subroutine for kr_kgen_readaffile_subp2 
            SUBROUTINE kr_kgen_readaffile_subp2(var, kgen_unit, printname, printvar) 
                TYPE(afi_ua_bl_default_type), INTENT(INOUT), ALLOCATABLE, DIMENSION(:) :: var 
                INTEGER, INTENT(IN) :: kgen_unit 
                CHARACTER(LEN=*), INTENT(IN) :: printname 
                LOGICAL, INTENT(IN), OPTIONAL :: printvar 
                LOGICAL :: kgen_istrue 
                REAL(KIND=8) :: kgen_array_sum 
                INTEGER :: idx1 
                INTEGER, DIMENSION(2,1) :: kgen_bound 
                  
                READ (UNIT = kgen_unit) kgen_istrue 
                IF (kgen_istrue) THEN 
                    IF (ALLOCATED( var )) THEN 
                        DEALLOCATE (var) 
                    END IF   
                    READ (UNIT = kgen_unit) kgen_bound(1, 1) 
                    READ (UNIT = kgen_unit) kgen_bound(2, 1) 
                    ALLOCATE (var(kgen_bound(1,1):kgen_bound(2,1))) 
                    DO idx1=kgen_bound(1,1), kgen_bound(2,1) 
                        IF (PRESENT( printvar ) .AND. printvar) THEN 
                            CALL kr_kgen_airfoilinfo_types_typesubp0(var(idx1), kgen_unit, printname // "(idx1)", .TRUE.) 
                        ELSE 
                            CALL kr_kgen_airfoilinfo_types_typesubp0(var(idx1), kgen_unit, printname // "(idx1)", .FALSE.) 
                        END IF   
                    END DO   
                END IF   
            END SUBROUTINE kr_kgen_readaffile_subp2 
              
            !verify state subroutine for kv_readaffile_integer__ 
            RECURSIVE SUBROUTINE kv_readaffile_integer__(varname, check_status, var, kgenref_var) 
                CHARACTER(LEN=*), INTENT(IN) :: varname 
                TYPE(check_t), INTENT(INOUT) :: check_status 
                INTEGER, INTENT(IN) :: var, kgenref_var 
                INTEGER :: check_result 
                LOGICAL :: is_print = .FALSE. 
                  
                integer :: diff 
                  
                check_status%numTotal = check_status%numTotal + 1 
                  
                IF ((var == kgenref_var) .OR. ((var /= var) .AND. (kgenref_var /= kgenref_var))) THEN
        IF (var /= var) WRITE(*, *) trim(adjustl(varname))," is IDENTICAL (both NaN, uninitialized)." 
                    check_status%numIdentical = check_status%numIdentical + 1 
                    IF (kgen_verboseLevel > 1) THEN 
                        IF (check_status%rank == 0) THEN 
                            WRITE (*, *) trim(adjustl(varname)), " is IDENTICAL." 
                        END IF   
                    END IF   
                    check_result = CHECK_IDENTICAL 
                ELSE 
                    diff = ABS(var - kgenref_var) 
                    IF (diff <= kgen_tolerance) THEN 
                        check_status%numInTol = check_status%numInTol + 1 
                        IF (kgen_verboseLevel > 1) THEN 
                            IF (check_status%rank == 0) THEN 
                                WRITE (*, *) trim(adjustl(varname)), " is NOT IDENTICAL(within tolerance)." 
                            END IF   
                        END IF   
                        check_result = CHECK_IN_TOL 
                    ELSE 
                        check_status%numOutTol = check_status%numOutTol + 1 
                        IF (kgen_verboseLevel > 0) THEN 
                            IF (check_status%rank == 0) THEN 
                                WRITE (*, *) trim(adjustl(varname)), " is NOT IDENTICAL(out of tolerance)." 
                            END IF   
                        END IF   
                        check_result = CHECK_OUT_TOL 
                    END IF   
                END IF   
                IF (check_result == CHECK_IDENTICAL) THEN 
                    IF (kgen_verboseLevel > 2) THEN 
                        IF (check_status%rank == 0) THEN 
                            WRITE (*, *) "Difference is ", 0 
                            WRITE (*, *) "" 
                        END IF   
                    END IF   
                ELSE IF (check_result == CHECK_OUT_TOL) THEN 
                    IF (kgen_verboseLevel > 0) THEN 
                        IF (check_status%rank == 0) THEN 
                            WRITE (*, *) "Difference is ", diff 
                            WRITE (*, *) "" 
                        END IF   
                    END IF   
                ELSE IF (check_result == CHECK_IN_TOL) THEN 
                    IF (kgen_verboseLevel > 1) THEN 
                        IF (check_status%rank == 0) THEN 
                            WRITE (*, *) "Difference is ", diff 
                            WRITE (*, *) "" 
                        END IF   
                    END IF   
                END IF   
                  
            END SUBROUTINE kv_readaffile_integer__ 
              
END SUBROUTINE readaffile 
!----------------------------------------------------------------------------------------------------------------------------------  
    SUBROUTINE CalculateUACoeffs(CalcDefaults, p, ColCl, ColCd, ColCm, ColUAf, UAMod)
        USE ISO_C_BINDING
        USE vit_afi_table_type_view, ONLY: afi_table_type_view_t, vit_populate_afi_table_type, vit_original_afi_table_type, vit_copy_scalars_to_afi_table_type
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
        ! Stash original Fortran pointers for callee bridges
        vit_original_afi_table_type => p
        CALL calculateuacoeffs_c(C_LOC(CalcDefaults), C_LOC(p_view), ColCl, ColCd, ColCm, ColUAf, UAMod)
        ! Copy modified scalars back from view to Fortran type
        CALL vit_copy_scalars_to_afi_table_type(p_view, p)
    END SUBROUTINE CalculateUACoeffs
!----------------------------------------------------------------------------------------------------------------------------------
   FUNCTION Calculate_Cn (alpha, Cl, Cd, Cd0) RESULT(Cn)
      REAL(ReKi),               intent(in   ) :: alpha(:)                   ! alpha
      REAL(ReKi),               intent(in   ) :: Cl(:)                      ! cl
      REAL(ReKi),               intent(in   ) :: Cd(:)                      ! cd
      REAL(ReKi),               intent(in   ) :: Cd0
      REAL(ReKi)                              :: Cn(size(alpha))            ! cn (result of this function)
      
      integer(IntKi)                          :: NumAlf
      integer(IntKi)                          :: Row
   
      NumAlf = size(alpha)
      
      do Row=1,NumAlf
         cn(Row) = Cl(Row)*cos(alpha(Row)) + (Cd(Row) - Cd0)*sin(alpha(Row))
      end do
      
   END FUNCTION Calculate_Cn
!----------------------------------------------------------------------------------------------------------------------------------
   SUBROUTINE Calculate_C_alpha(alpha, Cn, Cl, Default_Cn_alpha, Default_Cl_alpha, Default_alpha0, ErrStat, ErrMsg)
      REAL(ReKi),               intent(in   ) :: alpha(:)                   ! alpha
      REAL(ReKi),               intent(in   ) :: Cn(:)                      ! cn
      REAL(ReKi),               intent(in   ) :: Cl(:)                      ! cl
   
      REAL(ReKi),               intent(  out) :: Default_Cn_alpha
      REAL(ReKi),               intent(  out) :: Default_Cl_alpha
      REAL(ReKi),               intent(  out) :: Default_alpha0
      integer(IntKi),           intent(  out) :: errStat                    ! Error status of the operation
      character(*),             intent(  out) :: errMsg                     ! Error message if ErrStat /= ErrID_None 
      
      REAL(ReKi)                              :: A(      size(alpha), 2)
      REAL(ReKi)                              :: B(max(2,size(alpha)),2)

      if (SIZE(Cn) < 2 .OR. SIZE(Cl) < 2) then
         ErrMsg='Calculate_C_alpha: Not enough data points to compute Cn and Cl slopes.'
         ErrStat=ErrID_Fatal
         Default_Cn_alpha = EPSILON(Default_Cn_alpha)
         Default_Cl_alpha = EPSILON(Default_Cl_alpha)
         Default_alpha0 = 0.0_ReKi
         return
      end if

      A(:,1) = alpha
      A(:,2) = 1.0_ReKi
      
      if (size(Cn) == 1) then
         B(:,1) = Cn(1)
         B(:,2) = Cl(1)
      else
         B(:,1) = Cn
         B(:,2) = Cl
      end if
      
      CALL LAPACK_gels('N', A, B, ErrStat, ErrMsg)
   
      Default_Cn_alpha = B(1,1)
      Default_Cl_alpha = B(1,2)
      
      if (.not. EqualRealNos(B(1,1),0.0_ReKi)) then
         Default_alpha0  = -B(2,1)/B(1,1) ! using the values from Cn_alpha
      else
         Default_alpha0 = 0.0_ReKi
      end if
         
   END SUBROUTINE Calculate_C_alpha
!----------------------------------------------------------------------------------------------------------------------------------
   SUBROUTINE ComputeUASeparationFunction_onCl(p, ColCl, ColUAf, col_fs, col_fa)
      TYPE (AFI_Table_Type),    intent(inout) :: p                             ! This structure stores all the module parameters that are set by AirfoilInfo during the initialization phase.
      integer(IntKi),           intent(in   ) :: ColUAf                        ! column for UA f_st (based on Cl or cn)
      integer(IntKi),           intent(in   ) :: ColCl                         ! column for cl
      INTEGER(IntKi),           intent(in   ) :: col_fs                        ! column for UA cn/cl_fs (fully separated cn or cl)
      INTEGER(IntKi),           intent(in   ) :: col_fa                        ! column for UA cn/cl_fa (fully attached cn or cl); NOT USED IN THE MODELS ! note that col_fa is not used in this model, but we set the values to ensure files get written properly

      
      integer                                 :: Row
      REAL(ReKi)                              :: cl_ratio
      REAL(ReKi)                              :: cl_inv
      REAL(ReKi)                              :: f_st
      REAL(ReKi)                              :: fullySeparate
         !------------------------------------------------
         ! calculate f_st, cl_fs, and cl_fa for HGM model
         !------------------------------------------------
      
         if (EqualRealNos(p%UA_BL%c_lalpha,0.0_ReKi)) then
            p%Coefs(:,ColUAf) = 0.0_ReKi                           ! Eq. 59
            p%Coefs(:,col_fs) = p%Coefs(:,ColCl)                   ! Eq. 61
            p%Coefs(:,col_fa) = 0.0_ReKi
            call ComputeUASeparationFunction_zero(p, ColUAf, p%Coefs(:,ColCl)) ! just to initialize these values... UA will turn off without using them
         else
            
               do Row=1,p%NumAlf
            
                  if (EqualRealNos( p%alpha(Row), p%UA_BL%alpha0)) then
                     f_st  = 1.0_ReKi                                         ! Eq. 59
                     fullySeparate = p%Coefs(Row,ColCl) / 2.0_ReKi            ! Eq. 61 (which should be very close to 0 because definition of alpha0 says cl(alpha0) = 0 )
                  else
            
                     cl_ratio = p%Coefs(Row,ColCl) / ( p%UA_BL%c_lalpha*(p%alpha(Row) - p%UA_BL%alpha0))
                     cl_ratio = max(0.0_ReKi, cl_ratio)
            
                     f_st = ( 2.0_ReKi * sqrt(cl_ratio) - 1.0_ReKi )**2
                  
                     if (f_st < 1.0_ReKi) then 
                        ! Region where f_st<1, merge
                        f_st  = max(0.0_ReKi, f_st) ! make sure it is not negative
                        fullySeparate = (p%Coefs(Row,ColCl) - p%UA_BL%c_lalpha* (p%alpha(Row) - p%UA_BL%alpha0)*f_st) / (1.0_ReKi - f_st) ! Eq 61
                     else
                        ! Initialize to linear region (in fact only at singularity, where f_st=1)
                        f_st = 1.0_ReKi
                        fullySeparate = p%Coefs(Row,ColCl) / 2.0_ReKi                      ! Eq. 61
                     end if
                     
                  end if
               
                  p%Coefs(Row,ColUAf) = f_st
                  p%Coefs(Row,col_fs) = fullySeparate
                  p%Coefs(Row,col_fa) = p%UA_BL%c_lalpha * (p%alpha(Row) - p%UA_BL%alpha0) ! not used in the UA model (it's specified directly), but computed here for completeness

               end do
               ! These variables aren't used with the models that use Cl instead of Cn, but it's a way to initialize the values.
               ! They make sure that the separation function is monotonic before p%UA_BL%alphaLower and after p%UA_BL%alphaUpper:

               call ComputeUASeparationFunction_zero(p, ColUAf, p%Coefs(:,ColCl)) ! this was comparing with alpha0, but now we compare with alphaUpper and alphaLower
               ! Ensuring everything is in harmony 

            
               do Row=1,p%NumAlf
                  fullySeparate = p%Coefs(Row,col_fs)
               
                  cl_inv = p%UA_BL%c_lalpha*(p%alpha(Row) - p%UA_BL%alpha0)     ! Eq. 64
                  if (.not. EqualRealNos(cl_inv, fullySeparate)) then
                     f_st=(p%Coefs(Row,ColCl) - fullySeparate) / (cl_inv - fullySeparate);        ! Eq. 60
                     f_st = max(0.0_ReKi, f_st)
                     f_st = min(1.0_ReKi, f_st)
                  
                     p%Coefs(Row,ColUAf) = f_st
                  else 
                     p%Coefs(Row,ColUAf) = 1.0_ReKi
                  end if
               end do
               
               
            end if ! c_lalpha == 0

   END SUBROUTINE ComputeUASeparationFunction_onCl
!----------------------------------------------------------------------------------------------------------------------------------  
   SUBROUTINE Compute_iLoweriUpper(p, iLower, iUpper)
      TYPE (AFI_Table_Type),    intent(in   ) :: p                             ! This structure stores all the module parameters that are set by AirfoilInfo during the initialization phase.
      INTEGER(IntKi)          , intent(  out) :: iLower                        ! The lower index separating the region around 0
      INTEGER(IntKi)          , intent(  out) :: iUpper                        ! The upper index separating the region around 0
      !------------------------------------------------
      ! get bounds
      !------------------------------------------------
      
      iLower = minloc( p%alpha , DIM=1, MASK=p%alpha >= p%UA_BL%alphaLower)
      iUpper = maxloc( p%alpha , DIM=1, MASK=p%alpha <= p%UA_BL%alphaUpper)
      
      iLower = max(1, min(p%NumAlf-1,iLower)) ! 1 <= iLower <= NumAlf-1
      iUpper = max(2, min(p%NumAlf  ,iUpper)) ! 2 <= iUpper <= NumAlf

   END SUBROUTINE Compute_iLoweriUpper
!----------------------------------------------------------------------------------------------------------------------------------  
   SUBROUTINE ComputeUASeparationFunction_zero(p, ColUAf, cn_cl)
      TYPE (AFI_Table_Type),    intent(inout) :: p                             ! This structure stores all the module parameters that are set by AirfoilInfo during the initialization phase.
      integer(IntKi),           intent(in   ) :: ColUAf                        ! column for UA f_st (based on Cl or cn)
      REAL(ReKi),               intent(in   ) :: cn_cl(:)                      ! cn or cl, whichever variable we are computing this on
   
      REAL(ReKi)                              :: c_RateBreak                   ! the slope of the wrap-around region
      INTEGER(IntKi)                          :: Row                           ! The row of a table to be parsed in the FileInfo structure.
      INTEGER(IntKi)                          :: col_fs                        ! column for UA cn/cl_fs (fully separated cn or cl)
      INTEGER(IntKi)                          :: col_fa                        ! column for UA cn/cl_fa (fully attached cn or cl)
      INTEGER(IntKi)                          :: iHigh, iLow
      INTEGER(IntKi)                          :: iTemp
      !------------------------------------------------
      ! set column numbers
      !------------------------------------------------
      
      col_fs = ColUAf + 1
      col_fa = col_fs + 1
         ! initialize so that we can find the minimum f on each side of the attached region
     !iLow  = minloc(p%Coefs(:,ColUAf), DIM=1, MASK=p%alpha < p%UA_BL%alphaLower, BACK=.TRUE.) ! because not all compilers allow keyword "BACK" from the F2008 standard, we implement this way:
      
      iTemp  = minloc(p%Coefs(:,ColUAf), DIM=1, MASK=p%alpha < p%UA_BL%alphaLower) ! because not all compilers (gcc) allow keyword "BACK" from the F2008 standard, we implement this way
      iLow  = maxloc( p%alpha, DIM=1, MASK=p%alpha < p%UA_BL%alphaLower .and. p%Coefs(:,ColUAf) == p%Coefs(iTemp,ColUAf) )

      iHigh = minloc(p%Coefs(:,ColUAf), DIM=1, MASK=p%alpha > p%UA_BL%alphaUpper)
      ! Compute variables to help x3 state with +/-180-degree wrap-around issues

      p%UA_BL%alphaBreakUpper  = p%alpha(iHigh)
      p%UA_BL%alphaBreakLower  = p%alpha(iLow)
      p%UA_BL%CnBreakUpper     = p%Coefs(iHigh,col_fa)
      p%UA_BL%CnBreakLower     = p%Coefs(iLow,col_fa)
      
      c_RateBreak       = (p%UA_BL%CnBreakUpper - p%UA_BL%CnBreakLower) / ( (p%UA_BL%alphaBreakUpper-TwoPi) - p%UA_BL%alphaBreakLower)
         ! make sure that the separation function is monotonic before iLow and after iHigh:
      
      do Row=1,iLow
         p%Coefs(Row,col_fa) = (p%alpha(Row) - p%UA_BL%alphaBreakLower) * c_RateBreak + p%UA_BL%CnBreakLower
         p%Coefs(Row,col_fs) = cn_cl(Row)
         p%Coefs(Row,ColUAf) = 0.0_ReKi
      end do
      do Row=iHigh,p%NumAlf
         p%Coefs(Row,col_fa) = (p%alpha(Row) - p%UA_BL%alphaBreakUpper) * c_RateBreak + p%UA_BL%CnBreakUpper
         p%Coefs(Row,col_fs) = cn_cl(Row)
         p%Coefs(Row,ColUAf) = 0.0_ReKi
      end do
      
   END SUBROUTINE ComputeUASeparationFunction_zero
!----------------------------------------------------------------------------------------------------------------------------------  
   SUBROUTINE ComputeUA360_AttachedFlow(p, ColUAf, cn_cl, iLower, iUpper)
      TYPE (AFI_Table_Type),    intent(inout) :: p                             ! This structure stores all the module parameters that are set by AirfoilInfo during the initialization phase.
      integer(IntKi),           intent(in   ) :: ColUAf                        ! column for UA f_st (based on Cl or cn)
      REAL(ReKi),               intent(in   ) :: cn_cl(:)                      ! cn or cl, whichever variable we are computing this on
      INTEGER(IntKi)          , intent(  out) :: iLower                        ! The lower index separating the region around 0
      INTEGER(IntKi)          , intent(  out) :: iUpper                        ! The upper index separating the region around 0
   
      REAL(ReKi)                              :: roots(p%NumAlf)
      REAL(ReKi)                              :: x_(3), f_(3)
      
      REAL(ReKi)                              :: CnSlopeUpper, alpha0Upper
      REAL(ReKi)                              :: CnSlopeLower, alpha0Lower
      REAL(ReKi)                              :: CnSlopeReverseFlow           ! Cn slope versus angle of attack for reverse flow, 1/rad

      
      INTEGER(IntKi)                          :: Row                           ! The row of a table to be parsed in the FileInfo structure.
      INTEGER(IntKi)                          :: iRoot
      INTEGER(IntKi)                          :: col_fa                        ! column for UA cn/cl_fa (fully attached cn or cl)
      INTEGER(IntKi)                          :: Indx
      INTEGER(IntKi)                          :: nZeros
      !------------------------------------------------
      ! set column numbers
      !------------------------------------------------
      
      
      col_fa = ColUAf + 2
      !------------------------------------------------
      ! get bounds
      !------------------------------------------------

      call Compute_iLoweriUpper(p, iLower, iUpper)

      p%UA_BL%alphaLower = p%alpha(iLower) ! note we are overwriting values here to make them consistent in the linear equation
      p%UA_BL%alphaUpper = p%alpha(iUpper) ! note we are overwriting values here to make them consistent in the linear equation
      
      p%UA_BL%c_alphaLower = cn_cl(iLower) ! for vortex calculations (x5, HGMV model)
      p%UA_BL%c_alphaUpper = cn_cl(iUpper) ! for vortex calculations (x5, HGMV model)
      !------------------------------------------------
      ! From dynamicStallLUT.m/updateCnAttached()
      !------------------------------------------------
      CnSlopeUpper = ( cn_cl(iUpper-1) - cn_cl(iUpper) ) / ( p%alpha(iUpper-1) - p%alpha(iUpper) )
      if (EqualRealNos(CnSlopeUpper, 0.0_ReKi)) then
         alpha0Upper = p%alpha(iUpper)
      else
         alpha0Upper  = p%alpha(iUpper) - cn_cl(iUpper)/CnSlopeUpper;
      end if
      
      CnSlopeLower = ( cn_cl(iLower) - cn_cl(iLower+1) ) / ( p%alpha(iLower) - p%alpha(iLower+1) )
      if (EqualRealNos(CnSlopeLower, 0.0_ReKi)) then
         alpha0Lower = p%alpha(iLower)
      else
         alpha0Lower  = p%alpha(iLower) - cn_cl(iLower)/CnSlopeLower;
      end if
      ! Find reverse flow Cn = 0 near positive 180 deg (and not in the range (- 45, 45) degrees)
      
      call fZeros(p%alpha, cn_cl, roots, nZeros, Period=TwoPi)
      p%UA_BL%alpha0ReverseFlow = p%alpha(1) !  default value, in case there aren't any roots. Maybe this should be an error?
      if (nZeros > 0) then
         iRoot = maxloc( abs(roots(1:nZeros)), DIM=1, MASK=abs(roots(1:nZeros)) >= 45.0_ReKi*D2R )
         if (iRoot > 0) then
            p%UA_BL%alpha0ReverseFlow = roots(iRoot)
            if (p%UA_BL%alpha0ReverseFlow < -PiBy2) p%UA_BL%alpha0ReverseFlow = p%UA_BL%alpha0ReverseFlow + TwoPi !bjj check this value along with alphaBreakLower subtracting the TwoPi
         end if
      end if
      CnSlopeReverseFlow = -TwoPi;
      ! Find intersections

      
      p%UA_BL%alphaBreakUpper = ( CnSlopeReverseFlow *  p%UA_BL%alpha0ReverseFlow          - CnSlopeUpper*alpha0Upper ) / ( CnSlopeReverseFlow - CnSlopeUpper );
      p%UA_BL%CnBreakUpper    = CnSlopeUpper*( p%UA_BL%alphaBreakUpper - alpha0Upper );
            
      p%UA_BL%alphaBreakLower = ( CnSlopeReverseFlow * (p%UA_BL%alpha0ReverseFlow - TwoPi) - CnSlopeLower*alpha0Lower ) / ( CnSlopeReverseFlow - CnSlopeLower );
      p%UA_BL%CnBreakLower    = CnSlopeLower*( p%UA_BL%alphaBreakLower - alpha0Lower );
      ! set fully attached values:

      Indx = 1
      x_ = (/ p%UA_BL%alpha0ReverseFlow-TwoPi, p%UA_BL%alphaBreakLower, p%alpha(iLower) /)
      f_ = (/ 0.0_ReKi,                        p%UA_BL%CnBreakLower,    cn_cl(iLower) /)
      do Row=1,iLower-1
         p%Coefs(Row,col_fa) = InterpExtrapStp(p%alpha(Row), x_, f_, Indx, size(x_))
      end do
      
      do Row=iLower,iUpper
         p%Coefs(Row,col_fa) = cn_cl(Row)
      end do
      
      x_ = (/ p%alpha(iUpper), p%UA_BL%alphaBreakUpper, p%UA_BL%alpha0ReverseFlow /)
      f_ = (/ cn_cl(iUpper)  , p%UA_BL%CnBreakUpper,    0.0_ReKi /)
      do Row=iUpper+1,p%NumAlf
         p%Coefs(Row,col_fa) = InterpExtrapStp(p%alpha(Row), x_, f_, Indx, size(x_))
      end do
      
   END SUBROUTINE ComputeUA360_AttachedFlow
!----------------------------------------------------------------------------------------------------------------------------------  
   SUBROUTINE ComputeUA360_updateSeparationF( p, ColUAf, cn_cl, iLower, iUpper )
      TYPE (AFI_Table_Type),    intent(inout) :: p                             ! This structure stores all the module parameters that are set by AirfoilInfo during the initialization phase.
      integer(IntKi),           intent(in   ) :: ColUAf                        ! column for UA f_st (based on Cl or cn)
      REAL(ReKi),               intent(in   ) :: cn_cl(:)                      ! cn or cl, whichever variable we are computing this on
      INTEGER(IntKi)          , intent(in   ) :: iLower                        ! The lower index separating the region around 0
      INTEGER(IntKi)          , intent(in   ) :: iUpper                        ! The upper index separating the region around 0
   
      REAL(ReKi)                              :: Offset
      REAL(ReKi)                              :: CnRatio
      REAL(ReKi)                              :: alpha_(p%NumAlf)              ! temporary for calculating periodic f_st
      REAL(ReKi)                              :: f_st(  p%NumAlf)              ! temporary for calculating periodic f_st

      INTEGER(IntKi)                          :: Row                           ! The row of a table to be parsed in the FileInfo structure.
      INTEGER(IntKi)                          :: col_fa                        ! column for UA cn/cl_fa (fully attached cn or cl)
      INTEGER(IntKi)                          :: iReverseFlow                  ! The index where f_st is at a local max near +/-180
      INTEGER(IntKi)                          :: iUpperBreak                   ! The upper index separating the region around +/-180
      INTEGER(IntKi)                          :: iLowerBreak                   ! The lower index separating the region around +/-180
      !------------------------------------------------
      ! set column numbers
      !------------------------------------------------
      
      
      col_fa = ColUAf + 2 ! fully attached (column values computed in ComputeUA360_AttachedFlow())
      ! compute f_st (separation function, f = p%Coefs(Row,ColUAf))
      
      do Row=1,p%NumAlf
         offset = ComputeUA360_CnOffset(p, cn_cl, Row, iLower)
         if (EqualRealNos(p%Coefs(Row,col_fa),offset)) then
            CnRatio = 1.0_ReKi
         else
            CnRatio = (cn_cl(Row)-offset) / (p%Coefs(Row,col_fa)-offset);  ! offset needed to ensure numerator and denomonator have same sign since sqrt is used next
         end if
         CnRatio = max( 0.25_ReKi, CnRatio ); ! below 1/4 we assume full separation and f = 0

         p%Coefs(Row,ColUAf) = ( 2.0_ReKi * sqrt( CnRatio ) - 1.0_ReKi )**2
            
         p%Coefs(Row,ColUAf) = min( p%Coefs(Row,ColUAf), 1.0_ReKi )  ! f <= 1
         p%Coefs(Row,ColUAf) = max( 0.0_ReKi, p%Coefs(Row,ColUAf) )  ! f >= 0
         !if (EqualRealNos( p%Coefs(Row,col_fa), cn_cl(Row)) p%Coefs(Row,ColUAf) = 1.0_ReKi ! Set this below without EqualRealNos()

      end do
         ! Where p%Coefs(Row,col_fa) == cn_cl(Row), set f = 1
      
      do Row=iLower,iUpper
         p%Coefs(Row,ColUAf) = 1.0_ReKi 
      end do
      !-----------------------------------------------------------
      ! now fix issues if there is a second peak near 180 degrees:
      !-----------------------------------------------------------

      iLowerBreak = maxloc( p%alpha , DIM=1, MASK=p%alpha <= p%UA_BL%alphaBreakLower)
      alpha_ = cshift(p%alpha,iLowerBreak)
      f_st   = cshift(p%Coefs(:,ColUAf),iLowerBreak)
      do Row = 2,p%NumAlf
         if (alpha_(Row) < alpha_(Row-1)) alpha_(Row) = alpha_(Row)+TwoPi
      end do
      
      iReverseFlow = maxloc( f_st, DIM=1, MASK= alpha_ > p%UA_BL%alphaBreakUpper )
      iUpperBreak = minloc( alpha_ , DIM=1, MASK=alpha_ >= p%UA_BL%alphaBreakUpper)
      ! make sure this is monotonically decreasing from a single peak:

      do Row=iReverseFlow-1,iUpperBreak+1,-1
!        if ( f_st(Row-1) > f_st(Row) )    f_st(Row-1) = max(0.0_ReKi, f_st(Row) - ABS( (f_st(Row+1) - f_st(Row) )/(alpha_(Row+1) - alpha_(Row)) * (alpha_(Row)-alpha_(Row-1))))
         if (EqualRealNos(f_st(Row),0.0_ReKi)) f_st(Row-1) = 0.0_ReKi
         if ( f_st(Row-1) > f_st(Row) )    f_st(Row) = 0.5_ReKi * (f_st(Row+1) + f_st(Row-1))
      end do
      do Row=iReverseFlow+1,p%NumAlf-1
!        if ( f_st(Row+1) > f_st(Row) )    f_st(Row+1) = max(0.0_ReKi, f_st(Row) - ABS( (f_st(Row-1) - f_st(Row) )/(alpha_(Row-1) - alpha_(Row)) * (alpha_(Row+1) - alpha_(Row))))
         if (EqualRealNos(f_st(Row),0.0_ReKi)) f_st(Row+1) = 0.0_ReKi
         if ( f_st(Row+1) > f_st(Row) )    f_st(Row) = 0.5_ReKi * (f_st(Row+1) + f_st(Row-1))
      end do

      p%Coefs(:,ColUAf)   = cshift(f_st,-iLowerBreak)

      
   END SUBROUTINE ComputeUA360_updateSeparationF
!----------------------------------------------------------------------------------------------------------------------------------  
   SUBROUTINE ComputeUA360_updateCnSeparated( p, ColUAf, cn_cl, iLower )
      TYPE (AFI_Table_Type),    intent(inout) :: p                             ! This structure stores all the module parameters that are set by AirfoilInfo during the initialization phase.
      integer(IntKi),           intent(in   ) :: ColUAf                        ! column for UA f_st (based on Cl or cn)
      REAL(ReKi),               intent(in   ) :: cn_cl(:)                      ! cn or cl, whichever variable we are computing this on
      INTEGER(IntKi)          , intent(in   ) :: iLower                        ! The lower index separating the region around 0
   
      REAL(ReKi)                              :: Offset                       
      INTEGER(IntKi)                          :: Row                           ! The row of a table to be parsed in the FileInfo structure.
      INTEGER(IntKi)                          :: col_fa                        ! column for UA cn/cl_fa (fully attached cn or cl)
      INTEGER(IntKi)                          :: col_fs                        ! column for UA cn/cl_fa (fully separated cn or cl)
      !------------------------------------------------
      ! set column numbers
      !------------------------------------------------
      
      col_fa = ColUAf + 2 ! fully attached
      col_fs = ColUAf + 1 ! fully separate

      do Row=1,p%NumAlf
         if (EqualRealNos( p%Coefs(Row,ColUAf), 1.0_ReKi )) then
            offset = ComputeUA360_CnOffset(p, cn_cl, Row, iLower)
            p%Coefs(Row,col_fs) = 0.5_ReKi * (cn_cl(Row) + offset)
         else
            p%Coefs(Row,col_fs) = ( cn_cl(Row) - p%Coefs(Row,col_fa) * p%Coefs(Row,ColUAf) ) / ( 1.0_ReKi - p%Coefs(Row,ColUAf) )
         end if
      end do

   END SUBROUTINE ComputeUA360_updateCnSeparated
!----------------------------------------------------------------------------------------------------------------------------------  
   REAL(ReKi) FUNCTION ComputeUA360_CnOffset(p, cn_cl, Row, iLower) RESULT(offset)
      TYPE (AFI_Table_Type),    intent(in   ) :: p                             ! This structure stores all the module parameters that are set by AirfoilInfo during the initialization phase.
      REAL(ReKi),               intent(in   ) :: cn_cl(:)                      ! cn or cl, whichever variable we are computing this on
      INTEGER(IntKi)          , intent(in   ) :: Row                           ! The row of a table to be parsed in the FileInfo structure.
      INTEGER(IntKi)          , intent(in   ) :: iLower                        ! The lower index separating the region around 0
   
      REAL(ReKi)                              :: CnOffset                     ! Mathematical trick: offset to Cn making formulation of f-separation behave for strange polars with negative stall at positive Cn values (usually soiled polars for thick airfoils)
      REAL(ReKi)                              :: SlopeScale
      ! compute cnOffset
         
   
      if (cn_cl(iLower) > -0.05) then
         CnOffset = cn_cl(iLower) + 0.05
      else
         CnOffset = 0.0_ReKi
      end if
      
      SlopeScale = 0.1_ReKi*R2D
      offset = CnOffset * ( tanh(SlopeScale*(p%alpha(Row)+PiBy2)) - tanh(SlopeScale*(p%alpha(Row)-PiBy2)) ) / 2.0_ReKi; !Only apply Cn offset in vicinity of AoA 0 deg
   END FUNCTION ComputeUA360_CnOffset
!----------------------------------------------------------------------------------------------------------------------------------  

!----------------------------------------------------------------------------------------------------------------------------------  

!----------------------------------------------------------------------------------------------------------------------------------  


!----------------------------------------------------------------------------------------------------------------------------------  
         


!----------------------------------------------------------------------------------------------------------------------------------  
!> This routine calculates Cl, Cd, Cm, (and Cpmin) for a set of tables which are dependent on AOA as well as a 2nd user-defined varible, could be Re or Cntrl, etc.


!----------------------------------------------------------------------------------------------------------------------------------  
!> This routine calculates Cl, Cd, Cm, (and Cpmin) for a set of tables which are dependent on AOA as well as a 2nd user-defined varible, could be Re or Cntrl, etc.


!=============================================================================


!=============================================================================

!=============================================================================


!=============================================================================
   
END MODULE AirfoilInfo