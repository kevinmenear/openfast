!KGEN-generated Fortran source file 
  
!Generated at : 2026-04-25 13:48:16 
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
    PUBLIC ComputeUASeparationFunction_zero


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

CONTAINS


   !=============================================================================
   


   !=============================================================================
   !> This routine checks the init input values for AFI and makes sure they are valid
   !! before using them.
   


   !=============================================================================
  


!----------------------------------------------------------------------------------------------------------------------------------  
SUBROUTINE calculateuacoeffs(kgen_unit, kgen_measure, kgen_isverified, kgen_filepath, p, colcl, coluaf) 
    USE kgen_utils_mod
    USE kgen_utils_mod
    USE nwtc_num, ONLY: kr_externs_out_nwtc_num 
    TYPE(afi_table_type), INTENT(INOUT) :: p 
    INTEGER(KIND=intki), INTENT(INOUT) :: colcl 
    INTEGER(KIND=intki), INTENT(INOUT) :: coluaf 
   
    INTEGER(KIND=intki) :: col_fs 
    INTEGER(KIND=intki) :: col_fa 
      
      
      ! note that we don't get here with constant data, so NumAlf>2

      
      
      

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
    TYPE(afi_table_type) :: kgenref_p 
      
    !parent block preprocessing 
    kgen_mpirank = 0 
      
    !local input variables 
    READ (UNIT = kgen_unit) col_fs 
    READ (UNIT = kgen_unit) col_fa 
      
    !extern output variables 
    CALL kr_externs_out_nwtc_num(kgen_unit) 
      
    !local output variables 
    CALL kr_airfoilinfo_types_afi_table_type(kgenref_p, kgen_unit, "kgenref_p", .FALSE.) 


      


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
               call ComputeUASeparationFunction_onCl(p, ColCl, ColUAf, col_fs, col_fa)
               IF (kgen_mainstage) THEN 
                     
                   !verify init 
                   CALL kgen_init_verify(tolerance=1.D-14, minvalue=1.D-14, verboseLevel=100) 
                   CALL kgen_init_check(check_status, rank=kgen_mpirank) 
                     
                   !extern verify variables 
                     
                   !local verify variables 
                   CALL kv_airfoilinfo_types_afi_table_type("p", check_status, p, kgenref_p) 
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
               call ComputeUASeparationFunction_onCl(p, ColCl, ColUAf, col_fs, col_fa)
                   END DO   
                   CALL SYSTEM_CLOCK(kgen_stop_clock, kgen_rate_clock) 
                   kgen_measure = 1.0D6*(kgen_stop_clock - kgen_start_clock)/DBLE(kgen_rate_clock*KGEN_MAXITER) 
                   IF (check_status%rank==0) THEN 
                       WRITE (*, *) "ComputeUASeparationFunction_onCl : Time per call (usec): ", kgen_measure 
                   END IF   
               END IF   
               IF (kgen_warmupstage) THEN 
               END IF   
               IF (kgen_evalstage) THEN 
               END IF   


END SUBROUTINE calculateuacoeffs 
!----------------------------------------------------------------------------------------------------------------------------------

!----------------------------------------------------------------------------------------------------------------------------------


!----------------------------------------------------------------------------------------------------------------------------------
    SUBROUTINE ComputeUASeparationFunction_onCl(p, ColCl, ColUAf, col_fs, col_fa)
        USE ISO_C_BINDING
        USE vit_afi_table_type_view, ONLY: afi_table_type_view_t, vit_populate_afi_table_type, vit_original_afi_table_type, vit_copy_scalars_to_afi_table_type
        IMPLICIT NONE
        TYPE(AFI_TABLE_TYPE), INTENT(INOUT), TARGET :: p
        INTEGER(4), INTENT(IN) :: ColCl
        INTEGER(4), INTENT(IN) :: ColUAf
        INTEGER(4), INTENT(IN) :: col_fs
        INTEGER(4), INTENT(IN) :: col_fa
        TYPE(afi_table_type_view_t), TARGET :: p_view
        ! Populate view structs from Fortran types
        CALL vit_populate_afi_table_type(p, p_view)
        ! Stash original Fortran pointers for callee bridges
        vit_original_afi_table_type => p
        CALL computeuaseparationfunction_oncl_c(C_LOC(p_view), ColCl, ColUAf, col_fs, col_fa)
        ! Copy modified scalars back from view to Fortran type
        CALL vit_copy_scalars_to_afi_table_type(p_view, p)
    END SUBROUTINE ComputeUASeparationFunction_onCl
!----------------------------------------------------------------------------------------------------------------------------------  

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