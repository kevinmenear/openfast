!KGEN-generated Fortran source file 
  
!Generated at : 2026-04-26 22:19:30 
!KGEN version : 0.8.1 
  
!**********************************************************************************************************************************
! LICENSING
! Copyright (C) 2015-2016  National Renewable Energy Laboratory
! Copyright (C) 2016-2017  Envision Energy USA, LTD
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
! References:
!   [40] E. Branlard, B. Jonkman, G.R. Pirrung, K. Dixon, J. Jonkman (2022)
!        Dynamic inflow and unsteady aerodynamics models for modal and stability analyses in OpenFAST, 
!        Journal of Physics: Conference Series, doi:10.1088/1742-6596/2265/3/032044
!   [41] E. Branlard, J. Jonkman, B.Jonkman  (2020)
!        Development plan for the aerodynamic linearization in OpenFAST
!        Unpublished
!   [70] User Documentation / AeroDyn / Unsteady Aerodynamics / Boeing-Vertol model
!        https://openfast.readthedocs.io/
!   [other] R. Damiani and G. Hayman (2017)
!       The Unsteady Aerodynamics Module for FAST 8
!       NOTE: equations for this reference are labeled as x.y [n] where n is the number of the equation when several equations are given.


!
!
!
!
!
!
!
!
!

module UnsteadyAero
   ! This module uses equations defined in the document "The Unsteady Aerodynamics Module for FAST 8" by Rick Damiani and Greg Hayman, 28-Feb-2017


    USE unsteadyaero_types 
    USE airfoilinfo 
    USE kgen_utils_mod
    USE tprof_mod, ONLY: tstart, tstop, tnull, tprnt 
   
    IMPLICIT NONE 
    INTEGER :: errmsglen  ! VIT: dummy for sequential binary state read
    INTEGER :: kgenref_errmsg2  ! VIT: dummy for sequential binary state read
    INTEGER :: errmsg2  ! VIT: dummy for sequential binary state read

    PRIVATE 


    PUBLIC ua_calccontstatederiv 


   contains
! **************************************************
   

!==============================================================================
!> Compute the deficiency function:
!! \f$ Y_n = Y_{n-1} \exp \left(-\frac{\Delta t}{T}\right)+\left(x_n - x_{n-1}\right)\exp\left(-\frac{\Delta t}{2T}\right)\f$
   


!==============================================================================     
!==============================================================================
! TE Flow Separation Equations                                                !
!==============================================================================
!==============================================================================

   


!==============================================================================
!==============================================================================


!==============================================================================


!==============================================================================                              


!==============================================================================   
!==============================================================================
! Framework Routines                                                          !
!==============================================================================                               
!==============================================================================


      


!==============================================================================   
!==============================================================================


!==============================================================================   


!==============================================================================


!==============================================================================


!==============================================================================     


!==============================================================================     


!==============================================================================
!> This routine checks if the UA parameters indicate that UA should not be used. (i.e., if C_nalpha = 0)
!! This should be called at initialization.


!============================================================================== 
!> Update discrete states for Boeing Vertol model


!==============================================================================   
!> Calculate angle of attacks using Boeing-Vertol model, see [70]
!! Drag effective angle of attack needs extra computation


!==============================================================================   
!> Calculate gamma for lift and drag based rel thickness. See CACTUS BV_DynStall.f95

!==============================================================================   
!> Compute Transition region length
!! Note from CACTUS: 
!! Limit reference dalpha to a maximum to keep sign of CL the same for
!! alpha and lagged alpha (considered a reasonable lag...)
!! NOTE: magnitude increasing and decreasing effect ratios are maintained.

!==============================================================================   
!> Calculate deltas to negative and postivive stall angle, see [70]

!==============================================================================   
!> Calculate effective angle of attack for drag coefficient, based on lagged angle of attack, see [70]

!============================================================================== 
!> Activate dynamic stall for lift or drag, see [70]


!============================================================================== 
!> Routine for updating discrete states and other states for Beddoes-Leishman types models (note it breaks the framework)


!==============================================================================   
!============================================================================== 


!==============================================================================
!!----------------------------------------------------------------------------------------------------------------------------------
!> routine to initialize the states based on inputs at t=0
!! used to obtain initial values in linearization so that they don't change with each call to calcOutput (or other routines)

!==============================================================================


!----------------------------------------------------------------------------------------------------------------------------------
   SUBROUTINE ua_calccontstatederiv(kgen_unit, kgen_measure, kgen_isverified, kgen_filepath, afinfo) 
! Tight coupling routine for computing derivatives of continuous states
!..................................................................................................................................
       USE kgen_utils_mod
       USE kgen_utils_mod
       USE nwtc_num, ONLY: kr_externs_out_nwtc_num 
       USE kgen_utils_mod

       TYPE(afi_parametertype), INTENT(INOUT) :: afinfo 
      ! Local variables  

      
       TYPE(afi_ua_bl_type) :: bl_p 
       CHARACTER(LEN=8196) :: errmsg2 
       INTEGER(KIND=intki) :: errstat2 
   
       TYPE(ua_inputtype) :: u 
      ! Initialize ErrStat
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
       TYPE(afi_ua_bl_type) :: kgenref_bl_p 
       CHARACTER(LEN=8196) :: kgenref_errmsg2 
       INTEGER(KIND=intki) :: kgenref_errstat2 
         
       !parent block preprocessing 
       kgen_mpirank = 0 
         
       !local input variables 
       READ (UNIT = kgen_unit) errmsglen 
       CALL kr_airfoilinfo_types_afi_ua_bl_type(bl_p, kgen_unit, "bl_p", .FALSE.) 
       READ (UNIT = kgen_unit) errmsg2 
       READ (UNIT = kgen_unit) errstat2 
       CALL kr_unsteadyaero_types_ua_inputtype(u, kgen_unit, "u", .FALSE.) 
         
       !extern output variables 
       CALL kr_externs_out_nwtc_num(kgen_unit) 
         
       !local output variables 
       CALL kr_airfoilinfo_types_afi_ua_bl_type(kgenref_bl_p, kgen_unit, "kgenref_bl_p", .FALSE.) 
       READ (UNIT = kgen_unit) kgenref_errmsg2 
       READ (UNIT = kgen_unit) kgenref_errstat2 


   ! initialize for models that don't use all of the state terms:

      

      ! make sure that u%u is not zero (this previously turned off UA for the entire simulation. 
      ! Now, we keep it on, but we don't want the math to blow up when we divide by u%u)
   
   ! Lookup values using Airfoil Info module
   !$kgen begin_callsite AFI_ComputeUACoefs
   
   
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
   call AFI_ComputeUACoefs( AFInfo, u%Re, u%UserProp, BL_p, ErrMsg2, ErrStat2 )
   IF (kgen_mainstage) THEN 
         
       !verify init 
       CALL kgen_init_verify(tolerance=1.D-14, minvalue=1.D-14, verboseLevel=100) 
       CALL kgen_init_check(check_status, rank=kgen_mpirank) 
         
       !extern verify variables 
         
       !local verify variables 
       CALL kv_airfoilinfo_types_afi_ua_bl_type("bl_p", check_status, bl_p, kgenref_bl_p) 
       CALL kv_kgen_ua_calccontstatederiv_subp1("errmsg2", check_status, errmsg2, kgenref_errmsg2) 
       CALL kv_ua_calccontstatederiv_integer__intki("errstat2", check_status, errstat2, kgenref_errstat2) 
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
   call AFI_ComputeUACoefs( AFInfo, u%Re, u%UserProp, BL_p, ErrMsg2, ErrStat2 )
       END DO   
       CALL SYSTEM_CLOCK(kgen_stop_clock, kgen_rate_clock) 
       kgen_measure = 1.0D6*(kgen_stop_clock - kgen_start_clock)/DBLE(kgen_rate_clock*KGEN_MAXITER) 
       IF (check_status%rank==0) THEN 
           WRITE (*, *) "AFI_ComputeUACoefs : Time per call (usec): ", kgen_measure 
       END IF   
   END IF   
   IF (kgen_warmupstage) THEN 
   END IF   
   IF (kgen_evalstage) THEN 
   END IF   
   !$kgen end_callsite

   
      
      ! fix definitions of T_f0 and T_p (based on email from Emmanuel 12-28-20 regarding HAWC2 default values)
    

      ! calculate fs_aF (stored in AFI_interp%f_st):
    ! find alphaF where FullyAttached(alphaF) = x(3)

   

   ! States
   !x1: Downwash memory term 1 (rad)
   !x2: Downwash memory term 2 (rad)
   !x3: Clp', Lift coefficient with a time lag to the attached lift coeff
   !x4: f'' , Final separation point function
      ! Constraining x4 between 0 and 1 increases numerical stability (should be done elsewhere, but we'll double check here in case there were perturbations on the state value)
   
      
      
   


   


     
   CONTAINS 
     
   
   !verify state subroutine for kv_kgen_ua_calccontstatederiv_subp1 
   RECURSIVE SUBROUTINE kv_kgen_ua_calccontstatederiv_subp1(varname, check_status, var, kgenref_var) 
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
           WRITE(*, *) "[VIT_FIELD] ", trim(adjustl(varname)), " | IDENTICAL | ", var, " | ", kgenref_var
       ELSE 
           check_status%numOutTol = check_status%numOutTol + 1 
           IF (kgen_verboseLevel > 1) THEN 
               IF (check_status%rank == 0) THEN 
                   WRITE (*, *) trim(adjustl(varname)), " is NOT IDENTICAL." 
               END IF   
           END IF   
           check_result = CHECK_OUT_TOL 
           WRITE(*, *) "[VIT_FIELD] ", trim(adjustl(varname)), " | OUT_TOL | ", var, " | ", kgenref_var, " | ", diff
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
         
   END SUBROUTINE kv_kgen_ua_calccontstatederiv_subp1 
     
   !verify state subroutine for kv_ua_calccontstatederiv_integer__intki 
   RECURSIVE SUBROUTINE kv_ua_calccontstatederiv_integer__intki(varname, check_status, var, kgenref_var) 
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
           WRITE(*, *) "[VIT_FIELD] ", trim(adjustl(varname)), " | IDENTICAL | ", var, " | ", kgenref_var
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
               WRITE(*, *) "[VIT_FIELD] ", trim(adjustl(varname)), " | IN_TOL | ", var, " | ", kgenref_var, " | ", diff
           ELSE 
               check_status%numOutTol = check_status%numOutTol + 1 
               IF (kgen_verboseLevel > 0) THEN 
                   IF (check_status%rank == 0) THEN 
                       WRITE (*, *) trim(adjustl(varname)), " is NOT IDENTICAL(out of tolerance)." 
                   END IF   
               END IF   
               check_result = CHECK_OUT_TOL 
               WRITE(*, *) "[VIT_FIELD] ", trim(adjustl(varname)), " | OUT_TOL | ", var, " | ", kgenref_var, " | ", diff
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
         
   END SUBROUTINE kv_ua_calccontstatederiv_integer__intki 
     
   END SUBROUTINE ua_calccontstatederiv 
!----------------------------------------------------------------------------------------------------------------------------------

!---------------------------------------------------------------------------------

!---------------------------------------------------------------------------------
!> Compute angle of attack at 3/4 chord point based on values at Aerodynamic center

!> Compute angle of attack at 2/4 chord point based on values at Aerodynamic center


!> Compute time constant based on relative velocity u_rel


!----------------------------------------------------------------------------------------------------------------------------------
!> This subroutine implements the fourth-order Runge-Kutta Method (RK4) for numerically integrating ordinary differential equations:
!!
!!   Let f(t, x) = xdot denote the time (t) derivative of the continuous states (x). 
!!   Define constants k1, k2, k3, and k4 as 
!!        k1 = dt * f(t        , x_t        )
!!        k2 = dt * f(t + dt/2 , x_t + k1/2 )
!!        k3 = dt * f(t + dt/2 , x_t + k2/2 ), and
!!        k4 = dt * f(t + dt   , x_t + k3   ).
!!   Then the continuous states at t = t + dt are
!!        x_(t+dt) = x_t + k1/6 + k2/3 + k3/3 + k4/6 + O(dt^5)
!!
!! For details, see:
!! Press, W. H.; Flannery, B. P.; Teukolsky, S. A.; and Vetterling, W. T. "Runge-Kutta Method" and "Adaptive Step Size Control for 
!!   Runge-Kutta." Sections 16.1 and 16.2 in Numerical Recipes in FORTRAN: The Art of Scientific Computing, 2nd ed. Cambridge, England: 
!!   Cambridge University Press, pp. 704-716, 1992.


!----------------------------------------------------------------------------------------------------------------------------------
!> This subroutine implements the fourth-order Adams-Bashforth Method (AB4) for numerically integrating ordinary differential 
!! equations:
!!
!!   Let f(t, x) = xdot denote the time (t) derivative of the continuous states (x). 
!!
!!   x(t+dt) = x(t)  + (dt / 24.) * ( 55.*f(t,x) - 59.*f(t-dt,x) + 37.*f(t-2.*dt,x) - 9.*f(t-3.*dt,x) )
!!
!!  See, e.g.,
!!  http://en.wikipedia.org/wiki/Linear_multistep_method
!!
!!  or
!!
!!  K. E. Atkinson, "An Introduction to Numerical Analysis", 1989, John Wiley & Sons, Inc, Second Edition.


!----------------------------------------------------------------------------------------------------------------------------------
!> This subroutine implements the fourth-order Adams-Bashforth-Moulton Method (ABM4) for numerically integrating ordinary 
!! differential equations:
!!
!!   Let f(t, x) = xdot denote the time (t) derivative of the continuous states (x). 
!!
!!   Adams-Bashforth Predictor: \n
!!   x^p(t+dt) = x(t)  + (dt / 24.) * ( 55.*f(t,x) - 59.*f(t-dt,x) + 37.*f(t-2.*dt,x) - 9.*f(t-3.*dt,x) )
!!
!!   Adams-Moulton Corrector: \n
!!   x(t+dt) = x(t)  + (dt / 24.) * ( 9.*f(t+dt,x^p) + 19.*f(t,x) - 5.*f(t-dt,x) + 1.*f(t-2.*dt,x) )
!!
!!  See, e.g.,
!!  http://en.wikipedia.org/wiki/Linear_multistep_method
!!
!!  or
!!
!!  K. E. Atkinson, "An Introduction to Numerical Analysis", 1989, John Wiley & Sons, Inc, Second Edition.


!----------------------------------------------------------------------------------------------------------------------------------
!----------------------------------------------------------------------------------------------------------------------------------
!> This subroutine implements a Newton solve of the 2nd-order backward differentiation formula (BDF2) system for numerically integrating ordinary differential equations:


!----------------------------------------------------------------------------------------------------------------------------------


!----------------------------------------------------------------------------------------------------------------------------------
!============================================================================== 


!==============================================================================   


!==============================================================================   
! TODO Somehow merge this content with the unsteady aero driver summary file?


!==============================================================================

!==============================================================================   
!>This subroutine blends the steady outputs with the unsteady-outputs so that
!! UA can turn back on if the angle of attack goes back into a reasonable range.


!==============================================================================   
!>This subroutine blends the steady outputs with the unsteady-states so that
!! UA can turn back on if the angle of attack goes back into a reasonable range.


!==============================================================================   
!> This subroutine checks that the Mach number is valid. If M > 0.3, the theory 
!! is invalid. If M > 1, numerical issues result in the code.


   
   
end module UnsteadyAero