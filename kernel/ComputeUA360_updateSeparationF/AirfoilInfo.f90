!KGEN-generated Fortran source file 
  
!Generated at : 2026-04-25 14:30:50 
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
    PUBLIC ComputeUA360_CnOffset


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

CONTAINS


   !=============================================================================
   


   !=============================================================================
   !> This routine checks the init input values for AFI and makes sure they are valid
   !! before using them.
   


   !=============================================================================
  


!----------------------------------------------------------------------------------------------------------------------------------  
SUBROUTINE calculateuacoeffs(kgen_unit, kgen_measure, kgen_isverified, kgen_filepath, p, coluaf) 
    USE kgen_utils_mod
    USE kgen_utils_mod
    USE nwtc_num, ONLY: kr_externs_out_nwtc_num 
    TYPE(afi_table_type), INTENT(INOUT) :: p 
    INTEGER(KIND=intki), INTENT(INOUT) :: coluaf 
   
      
    INTEGER(KIND=intki) :: iupper, ilower 
      
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
    TYPE(afi_table_type) :: kgenref_p 
      
    !parent block preprocessing 
    kgen_mpirank = 0 
      
    !local input variables 
    READ (UNIT = kgen_unit) ilower 
    READ (UNIT = kgen_unit) iupper 
    READ (UNIT = kgen_unit) kgen_istrue 
    IF (kgen_istrue) THEN 
        READ (UNIT = kgen_unit) kgen_array_sum 
        READ (UNIT = kgen_unit) cn 
        CALL kgen_array_sumcheck("cn", kgen_array_sum, DBLE(SUM(cn, mask=(cn .eq. cn))), .TRUE.) 
    END IF   
      
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
               call ComputeUA360_updateSeparationF( p, ColUAf, Cn, iLower, iUpper )
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
               call ComputeUA360_updateSeparationF( p, ColUAf, Cn, iLower, iUpper )
                   END DO   
                   CALL SYSTEM_CLOCK(kgen_stop_clock, kgen_rate_clock) 
                   kgen_measure = 1.0D6*(kgen_stop_clock - kgen_start_clock)/DBLE(kgen_rate_clock*KGEN_MAXITER) 
                   IF (check_status%rank==0) THEN 
                       WRITE (*, *) "ComputeUA360_updateSeparationF : Time per call (usec): ", kgen_measure 
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


!----------------------------------------------------------------------------------------------------------------------------------  

!----------------------------------------------------------------------------------------------------------------------------------  


!----------------------------------------------------------------------------------------------------------------------------------  


!----------------------------------------------------------------------------------------------------------------------------------  
    SUBROUTINE ComputeUA360_updateSeparationF(p, ColUAf, cn_cl, iLower, iUpper)
        USE ISO_C_BINDING
        USE vit_afi_table_type_view, ONLY: afi_table_type_view_t, vit_populate_afi_table_type, vit_original_afi_table_type, vit_copy_scalars_to_afi_table_type
        IMPLICIT NONE
        TYPE(AFI_TABLE_TYPE), INTENT(INOUT), TARGET :: p
        INTEGER(4), INTENT(IN) :: ColUAf
        REAL(8), INTENT(IN) :: cn_cl(:)
        INTEGER(4), INTENT(IN) :: iLower
        INTEGER(4), INTENT(IN) :: iUpper
        TYPE(afi_table_type_view_t), TARGET :: p_view
        ! Populate view structs from Fortran types
        CALL vit_populate_afi_table_type(p, p_view)
        ! Stash original Fortran pointers for callee bridges
        vit_original_afi_table_type => p
        CALL computeua360_updateseparationf_c(C_LOC(p_view), ColUAf, cn_cl, SIZE(cn_cl), iLower, iUpper)
        ! Copy modified scalars back from view to Fortran type
        CALL vit_copy_scalars_to_afi_table_type(p_view, p)
    END SUBROUTINE ComputeUA360_updateSeparationF
!----------------------------------------------------------------------------------------------------------------------------------  

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