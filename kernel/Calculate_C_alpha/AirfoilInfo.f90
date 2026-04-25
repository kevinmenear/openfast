!KGEN-generated Fortran source file 
  
!Generated at : 2026-04-25 11:14:48 
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
    INTEGER :: errmsglen  ! VIT: dummy for sequential binary state read
    INTEGER :: kgenref_errmsg2  ! VIT: dummy for sequential binary state read
    INTEGER :: errmsg2  ! VIT: dummy for sequential binary state read

    PRIVATE 


    PUBLIC calculateuacoeffs 


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

CONTAINS


   !=============================================================================
   


   !=============================================================================
   !> This routine checks the init input values for AFI and makes sure they are valid
   !! before using them.
   


   !=============================================================================
  


!----------------------------------------------------------------------------------------------------------------------------------  
SUBROUTINE calculateuacoeffs(kgen_unit, kgen_measure, kgen_isverified, kgen_filepath, p, colcl) 
    USE kgen_utils_mod
    USE kgen_utils_mod
    USE kgen_utils_mod
    TYPE(afi_table_type), INTENT(INOUT) :: p 
    INTEGER(KIND=intki), INTENT(INOUT) :: colcl 
   
      
    INTEGER(KIND=intki) :: ihigh2, ilow2 
      
      ! note that we don't get here with constant data, so NumAlf>2

    REAL(KIND=reki) :: cn(p%numalf) 
      
      
    REAL(KIND=reki) :: default_cn_alpha 
    REAL(KIND=reki) :: default_cl_alpha 
    REAL(KIND=reki) :: default_alpha0 
      

    INTEGER(KIND=intki) :: errstat2 
    CHARACTER(LEN=8196) :: errmsg2 
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
    REAL(KIND=reki) :: kgenref_default_cn_alpha 
    REAL(KIND=reki) :: kgenref_default_cl_alpha 
    REAL(KIND=reki) :: kgenref_default_alpha0 
    INTEGER(KIND=intki) :: kgenref_errstat2 
    CHARACTER(LEN=8196) :: kgenref_errmsg2 
      
    !parent block preprocessing 
    kgen_mpirank = 0 
      
    !local input variables 
    READ (UNIT = kgen_unit) errmsglen 
    READ (UNIT = kgen_unit) ilow2 
    READ (UNIT = kgen_unit) ihigh2 
    READ (UNIT = kgen_unit) kgen_istrue 
    IF (kgen_istrue) THEN 
        READ (UNIT = kgen_unit) kgen_array_sum 
        READ (UNIT = kgen_unit) cn 
        CALL kgen_array_sumcheck("cn", kgen_array_sum, DBLE(SUM(cn, mask=(cn .eq. cn))), .TRUE.) 
    END IF   
    READ (UNIT = kgen_unit) default_cn_alpha 
    READ (UNIT = kgen_unit) default_cl_alpha 
    READ (UNIT = kgen_unit) default_alpha0 
    READ (UNIT = kgen_unit) errstat2 
    READ (UNIT = kgen_unit) errmsg2 
      
    !extern output variables 
      
    !local output variables 
    READ (UNIT = kgen_unit) kgenref_default_cn_alpha 
    READ (UNIT = kgen_unit) kgenref_default_cl_alpha 
    READ (UNIT = kgen_unit) kgenref_default_alpha0 
    READ (UNIT = kgen_unit) kgenref_errstat2 
    READ (UNIT = kgen_unit) kgenref_errmsg2 


      


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
               call Calculate_C_alpha(p%alpha(iLow2:iHigh2), Cn(iLow2:iHigh2), p%Coefs(iLow2:iHigh2,ColCl), Default_Cn_alpha, Default_Cl_alpha, Default_alpha0, ErrStat2, ErrMsg2)
               IF (kgen_mainstage) THEN 
                     
                   !verify init 
                   CALL kgen_init_verify(tolerance=1.D-14, minvalue=1.D-14, verboseLevel=100) 
                   CALL kgen_init_check(check_status, rank=kgen_mpirank) 
                     
                   !extern verify variables 
                     
                   !local verify variables 
                   CALL kv_calculateuacoeffs_real__reki("default_cn_alpha", check_status, default_cn_alpha, &
                   &kgenref_default_cn_alpha) 
                   CALL kv_calculateuacoeffs_real__reki("default_cl_alpha", check_status, default_cl_alpha, &
                   &kgenref_default_cl_alpha) 
                   CALL kv_calculateuacoeffs_real__reki("default_alpha0", check_status, default_alpha0, kgenref_default_alpha0) 
                   CALL kv_calculateuacoeffs_integer__intki("errstat2", check_status, errstat2, kgenref_errstat2) 
                   CALL kv_calculateuacoeffs_character_errmsglen_("errmsg2", check_status, errmsg2, kgenref_errmsg2) 
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
               call Calculate_C_alpha(p%alpha(iLow2:iHigh2), Cn(iLow2:iHigh2), p%Coefs(iLow2:iHigh2,ColCl), Default_Cn_alpha, Default_Cl_alpha, Default_alpha0, ErrStat2, ErrMsg2)
                   END DO   
                   CALL SYSTEM_CLOCK(kgen_stop_clock, kgen_rate_clock) 
                   kgen_measure = 1.0D6*(kgen_stop_clock - kgen_start_clock)/DBLE(kgen_rate_clock*KGEN_MAXITER) 
                   IF (check_status%rank==0) THEN 
                       WRITE (*, *) "Calculate_C_alpha : Time per call (usec): ", kgen_measure 
                   END IF   
               END IF   
               IF (kgen_warmupstage) THEN 
               END IF   
               IF (kgen_evalstage) THEN 
               END IF   


                 
               CONTAINS 
                 

               !verify state subroutine for kv_calculateuacoeffs_real__reki 
               RECURSIVE SUBROUTINE kv_calculateuacoeffs_real__reki(varname, check_status, var, kgenref_var) 
                   CHARACTER(LEN=*), INTENT(IN) :: varname 
                   TYPE(check_t), INTENT(INOUT) :: check_status 
                   REAL(KIND=reki), INTENT(IN) :: var, kgenref_var 
                   INTEGER :: check_result 
                   LOGICAL :: is_print = .FALSE. 
                     
                   real(KIND=reki) :: diff 
                     
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
                     
               END SUBROUTINE kv_calculateuacoeffs_real__reki 
                 
               !verify state subroutine for kv_calculateuacoeffs_integer__intki 
               RECURSIVE SUBROUTINE kv_calculateuacoeffs_integer__intki(varname, check_status, var, kgenref_var) 
                   CHARACTER(LEN=*), INTENT(IN) :: varname 
                   TYPE(check_t), INTENT(INOUT) :: check_status 
                   INTEGER(KIND=intki), INTENT(IN) :: var, kgenref_var 
                   INTEGER :: check_result 
                   LOGICAL :: is_print = .FALSE. 
                     
                   integer(KIND=intki) :: diff 
                     
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
                     
               END SUBROUTINE kv_calculateuacoeffs_integer__intki 
                 
               !verify state subroutine for kv_calculateuacoeffs_character_errmsglen_ 
               RECURSIVE SUBROUTINE kv_calculateuacoeffs_character_errmsglen_(varname, check_status, var, kgenref_var) 
                   CHARACTER(LEN=*), INTENT(IN) :: varname 
                   TYPE(check_t), INTENT(INOUT) :: check_status 
                   CHARACTER(LEN=8196), INTENT(IN) :: var, kgenref_var 
                   INTEGER :: check_result 
                   LOGICAL :: is_print = .FALSE. 
                     
                   CHARACTER(LEN=8196) :: diff 
                     
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
                       check_status%numOutTol = check_status%numOutTol + 1 
                       IF (kgen_verboseLevel > 1) THEN 
                           IF (check_status%rank == 0) THEN 
                               WRITE (*, *) trim(adjustl(varname)), " is NOT IDENTICAL." 
                           END IF   
                       END IF   
                       check_result = CHECK_OUT_TOL 
                   END IF   
                   IF (check_result == CHECK_IDENTICAL) THEN 
                       IF (kgen_verboseLevel > 2) THEN 
                           IF (check_status%rank == 0) THEN 
                               WRITE (*, *) "NOT IMPLEMENTED" 
                               WRITE (*, *) "" 
                           END IF   
                       END IF   
                   ELSE IF (check_result == CHECK_OUT_TOL) THEN 
                       IF (kgen_verboseLevel > 0) THEN 
                           IF (check_status%rank == 0) THEN 
                               WRITE (*, *) "NOT IMPLEMENTED" 
                               WRITE (*, *) "" 
                           END IF   
                       END IF   
                   ELSE IF (check_result == CHECK_IN_TOL) THEN 
                       IF (kgen_verboseLevel > 1) THEN 
                           IF (check_status%rank == 0) THEN 
                               WRITE (*, *) "NOT IMPLEMENTED" 
                               WRITE (*, *) "" 
                           END IF   
                       END IF   
                   END IF   
                     
               END SUBROUTINE kv_calculateuacoeffs_character_errmsglen_ 
                 
END SUBROUTINE calculateuacoeffs 
!----------------------------------------------------------------------------------------------------------------------------------

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


!----------------------------------------------------------------------------------------------------------------------------------  

!----------------------------------------------------------------------------------------------------------------------------------  


!----------------------------------------------------------------------------------------------------------------------------------  


!----------------------------------------------------------------------------------------------------------------------------------  


!----------------------------------------------------------------------------------------------------------------------------------  

!----------------------------------------------------------------------------------------------------------------------------------  

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