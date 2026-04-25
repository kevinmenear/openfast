!KGEN-generated Fortran source file 
  
!Generated at : 2026-04-25 05:19:03 
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
    USE kgen_utils_mod
    USE tprof_mod, ONLY: tstart, tstop, tnull, tprnt 

    USE ISO_C_BINDING
    IMPLICIT NONE 

    PRIVATE 


    PUBLIC computeua360_updateseparationf 


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

CONTAINS


   !=============================================================================
   


   !=============================================================================
   !> This routine checks the init input values for AFI and makes sure they are valid
   !! before using them.
   


   !=============================================================================
  


!----------------------------------------------------------------------------------------------------------------------------------  


!----------------------------------------------------------------------------------------------------------------------------------

!----------------------------------------------------------------------------------------------------------------------------------


!----------------------------------------------------------------------------------------------------------------------------------


!----------------------------------------------------------------------------------------------------------------------------------  

!----------------------------------------------------------------------------------------------------------------------------------  


!----------------------------------------------------------------------------------------------------------------------------------  


!----------------------------------------------------------------------------------------------------------------------------------  
SUBROUTINE computeua360_updateseparationf(kgen_unit, kgen_measure, kgen_isverified, kgen_filepath, p, cn_cl, ilower) 
    USE kgen_utils_mod
    USE kgen_utils_mod
    USE kgen_utils_mod
    TYPE(afi_table_type), INTENT(INOUT) :: p 
    REAL(KIND=reki), INTENT(INOUT) :: cn_cl(:) 
    INTEGER(KIND=intki), INTENT(INOUT) :: ilower 
   
    REAL(KIND=reki) :: offset 

    INTEGER(KIND=intki) :: row 
      !------------------------------------------------
      ! set column numbers
      !------------------------------------------------
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
    REAL(KIND=reki) :: kgenref_offset 
      
    !parent block preprocessing 
    kgen_mpirank = 0 
      
    !local input variables 
    READ (UNIT = kgen_unit) offset 
    READ (UNIT = kgen_unit) row 
      
    !extern output variables 
      
    !local output variables 
    READ (UNIT = kgen_unit) kgenref_offset 
      
      
      ! compute f_st (separation function, f = p%Coefs(Row,ColUAf))
      
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
         offset = ComputeUA360_CnOffset(p, cn_cl, Row, iLower)
         IF (kgen_mainstage) THEN 
               
             !verify init 
             CALL kgen_init_verify(tolerance=1.D-14, minvalue=1.D-14, verboseLevel=100) 
             CALL kgen_init_check(check_status, rank=kgen_mpirank) 
               
             !extern verify variables 
               
             !local verify variables 
             CALL kv_kgen_computeua360_updateseparationf_subp0("offset", check_status, offset, kgenref_offset) 
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
         offset = ComputeUA360_CnOffset(p, cn_cl, Row, iLower)
             END DO   
             CALL SYSTEM_CLOCK(kgen_stop_clock, kgen_rate_clock) 
             kgen_measure = 1.0D6*(kgen_stop_clock - kgen_start_clock)/DBLE(kgen_rate_clock*KGEN_MAXITER) 
             IF (check_status%rank==0) THEN 
                 WRITE (*, *) "ComputeUA360_CnOffset : Time per call (usec): ", kgen_measure 
             END IF   
         END IF   
         IF (kgen_warmupstage) THEN 
         END IF   
         IF (kgen_evalstage) THEN 
         END IF   

         ! Where p%Coefs(Row,col_fa) == cn_cl(Row), set f = 1
      

      !-----------------------------------------------------------
      ! now fix issues if there is a second peak near 180 degrees:
      !-----------------------------------------------------------


      
      ! make sure this is monotonically decreasing from a single peak:


           
         CONTAINS 
           

      
         !verify state subroutine for kv_kgen_computeua360_updateseparationf_subp0 
         RECURSIVE SUBROUTINE kv_kgen_computeua360_updateseparationf_subp0(varname, check_status, var, kgenref_var) 
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
               
         END SUBROUTINE kv_kgen_computeua360_updateseparationf_subp0 
           
END SUBROUTINE computeua360_updateseparationf 
!----------------------------------------------------------------------------------------------------------------------------------  

!----------------------------------------------------------------------------------------------------------------------------------  
    FUNCTION ComputeUA360_CnOffset(p, cn_cl, Row, iLower) RESULT(offset)
        USE ISO_C_BINDING
        USE vit_afi_table_type_view, ONLY: afi_table_type_view_t, vit_populate_afi_table_type, vit_original_afi_table_type
        IMPLICIT NONE
        TYPE(AFI_TABLE_TYPE), INTENT(IN), TARGET :: p
        REAL(8), INTENT(IN) :: cn_cl(:)
        INTEGER(4), INTENT(IN) :: Row
        INTEGER(4), INTENT(IN) :: iLower
        REAL(8) :: offset
        TYPE(afi_table_type_view_t), TARGET :: p_view
        ! Populate view structs from Fortran types
        CALL vit_populate_afi_table_type(p, p_view)
        ! Stash original Fortran pointers for callee bridges
        vit_original_afi_table_type => p
        offset = REAL(computeua360_cnoffset_c(C_LOC(p_view), cn_cl, SIZE(cn_cl), Row, iLower), 8)
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