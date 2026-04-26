!KGEN-generated Fortran source file 
  
!Generated at : 2026-04-24 12:51:06 
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


    PUBLIC calculateuacoeffs 


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

CONTAINS


   !=============================================================================
   


   !=============================================================================
   !> This routine checks the init input values for AFI and makes sure they are valid
   !! before using them.
   


   !=============================================================================
  


!----------------------------------------------------------------------------------------------------------------------------------  
SUBROUTINE calculateuacoeffs(kgen_unit, kgen_measure, kgen_isverified, kgen_filepath, p, colcl, colcd) 
    USE kgen_utils_mod
    USE kgen_utils_mod
    USE kgen_utils_mod
    TYPE(afi_table_type), INTENT(INOUT) :: p 
    INTEGER(KIND=intki), INTENT(INOUT) :: colcl 
    INTEGER(KIND=intki), INTENT(INOUT) :: colcd 
   
      
      
      ! note that we don't get here with constant data, so NumAlf>2

    REAL(KIND=reki) :: cn(p%numalf) 
      
      
      

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
    REAL(KIND=reki), dimension(p%numalf) :: kgenref_cn 
      
    !parent block preprocessing 
    kgen_mpirank = 0 
      
    !local input variables 
    READ (UNIT = kgen_unit) kgen_istrue 
    IF (kgen_istrue) THEN 
        READ (UNIT = kgen_unit) kgen_array_sum 
        READ (UNIT = kgen_unit) cn 
        CALL kgen_array_sumcheck("cn", kgen_array_sum, DBLE(SUM(cn, mask=(cn .eq. cn))), .TRUE.) 
    END IF   
      
    !extern output variables 
      
    !local output variables 
    READ (UNIT = kgen_unit) kgen_istrue 
    IF (kgen_istrue) THEN 
        READ (UNIT = kgen_unit) kgen_array_sum 
        READ (UNIT = kgen_unit) kgenref_cn 
        CALL kgen_array_sumcheck("kgenref_cn", kgen_array_sum, DBLE(SUM(kgenref_cn, mask=(kgenref_cn .eq. kgenref_cn))), .TRUE.) 
    END IF   


      


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
            cn = Calculate_Cn(alpha=p%alpha, cl=p%Coefs(:,ColCl), cd=p%Coefs(:,ColCd), cd0=p%UA_BL%Cd0)
            IF (kgen_mainstage) THEN 
                  
                !verify init 
                CALL kgen_init_verify(tolerance=1.D-14, minvalue=1.D-14, verboseLevel=100) 
                CALL kgen_init_check(check_status, rank=kgen_mpirank) 
                  
                !extern verify variables 
                  
                !local verify variables 
                CALL kv_calculateuacoeffs_real__reki_dim1("cn", check_status, cn, kgenref_cn) 
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
            cn = Calculate_Cn(alpha=p%alpha, cl=p%Coefs(:,ColCl), cd=p%Coefs(:,ColCd), cd0=p%UA_BL%Cd0)
                END DO   
                CALL SYSTEM_CLOCK(kgen_stop_clock, kgen_rate_clock) 
                kgen_measure = 1.0D6*(kgen_stop_clock - kgen_start_clock)/DBLE(kgen_rate_clock*KGEN_MAXITER) 
                IF (check_status%rank==0) THEN 
                    WRITE (*, *) "Calculate_Cn : Time per call (usec): ", kgen_measure 
                END IF   
            END IF   
            IF (kgen_warmupstage) THEN 
            END IF   
            IF (kgen_evalstage) THEN 
            END IF   


              
            CONTAINS 
              

            !verify state subroutine for kv_calculateuacoeffs_real__reki_dim1 
            RECURSIVE SUBROUTINE kv_calculateuacoeffs_real__reki_dim1(varname, check_status, var, kgenref_var) 
                CHARACTER(LEN=*), INTENT(IN) :: varname 
                TYPE(check_t), INTENT(INOUT) :: check_status 
                REAL(KIND=reki), INTENT(IN), DIMENSION(:) :: var, kgenref_var 
                INTEGER :: check_result 
                LOGICAL :: is_print = .FALSE. 
                  
                INTEGER :: idx1 
                INTEGER :: n 
                real(KIND=reki) :: nrmsdiff, rmsdiff 
                real(KIND=reki), ALLOCATABLE :: buf1(:), buf2(:) 
                  
                check_status%numTotal = check_status%numTotal + 1 
                  
                IF (ALL(var == kgenref_var)) THEN 
                    check_status%numIdentical = check_status%numIdentical + 1 
                    IF (kgen_verboseLevel > 1) THEN 
                        IF (check_status%rank == 0) THEN 
                            WRITE (*, *) trim(adjustl(varname)), " is IDENTICAL." 
                        END IF   
                    END IF   
                    check_result = CHECK_IDENTICAL 
                ELSE 
                    ALLOCATE (buf1(SIZE(var,dim=1))) 
                    ALLOCATE (buf2(SIZE(var,dim=1))) 
                    n = SIZE(var) 
                    WHERE ( ABS(kgenref_var) > kgen_minvalue ) 
                        buf1 = ((var-kgenref_var)/kgenref_var)**2 
                        buf2 = (var-kgenref_var)**2 
                    ELSEWHERE 
                        buf1 = (var-kgenref_var)**2 
                        buf2 = buf1 
                    END WHERE   
                    nrmsdiff = SQRT(SUM(buf1)/DBLE(n)) 
                    rmsdiff = SQRT(SUM(buf2)/DBLE(n)) 
                    IF (rmsdiff > kgen_tolerance) THEN 
                        check_status%numOutTol = check_status%numOutTol + 1 
                        IF (kgen_verboseLevel > 0) THEN 
                            IF (check_status%rank == 0) THEN 
                                WRITE (*, *) trim(adjustl(varname)), " is NOT IDENTICAL(out of tolerance)." 
                            END IF   
                        END IF   
                        check_result = CHECK_OUT_TOL 
                    ELSE 
                        check_status%numInTol = check_status%numInTol + 1 
                        IF (kgen_verboseLevel > 1) THEN 
                            IF (check_status%rank == 0) THEN 
                                WRITE (*, *) trim(adjustl(varname)), " is NOT IDENTICAL(within tolerance)." 
                            END IF   
                        END IF   
                        check_result = CHECK_IN_TOL 
                    END IF   
                END IF   
                IF (check_result == CHECK_IDENTICAL) THEN 
                    IF (kgen_verboseLevel > 2) THEN 
                        IF (check_status%rank == 0) THEN 
                            WRITE (*, *) count( var /= kgenref_var), " of ", size( var ), " elements are different." 
                            WRITE (*, *) "Average - kernel ", sum(var)/real(size(var)) 
                            WRITE (*, *) "Average - reference ", sum(kgenref_var)/real(size(kgenref_var)) 
                            WRITE (*, *) "RMS of difference is ", 0 
                            WRITE (*, *) "Normalized RMS of difference is ", 0 
                            WRITE (*, *) "" 
                        END IF   
                    END IF   
                ELSE IF (check_result == CHECK_OUT_TOL) THEN 
                    IF (kgen_verboseLevel > 0) THEN 
                        IF (check_status%rank == 0) THEN 
                            WRITE (*, *) count( var /= kgenref_var), " of ", size( var ), " elements are different." 
                            WRITE (*, *) "Average - kernel ", sum(var)/real(size(var)) 
                            WRITE (*, *) "Average - reference ", sum(kgenref_var)/real(size(kgenref_var)) 
                            WRITE (*, *) "RMS of difference is ", rmsdiff 
                            WRITE (*, *) "Normalized RMS of difference is ", nrmsdiff 
                            WRITE (*, *) "" 
                        END IF   
                    END IF   
                ELSE IF (check_result == CHECK_IN_TOL) THEN 
                    IF (kgen_verboseLevel > 1) THEN 
                        IF (check_status%rank == 0) THEN 
                            WRITE (*, *) count( var /= kgenref_var), " of ", size( var ), " elements are different." 
                            WRITE (*, *) "Average - kernel ", sum(var)/real(size(var)) 
                            WRITE (*, *) "Average - reference ", sum(kgenref_var)/real(size(kgenref_var)) 
                            WRITE (*, *) "RMS of difference is ", rmsdiff 
                            WRITE (*, *) "Normalized RMS of difference is ", nrmsdiff 
                            WRITE (*, *) "" 
                        END IF   
                    END IF   
                END IF   
                  
            END SUBROUTINE kv_calculateuacoeffs_real__reki_dim1 
              
END SUBROUTINE calculateuacoeffs 
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