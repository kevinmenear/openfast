!KGEN-generated Fortran source file 
  
!Generated at : 2026-04-25 21:22:06 
!KGEN version : 0.8.1 
  
!**********************************************************************************************************************************
! LICENSING
! Copyright (C) 2013  National Renewable Energy Laboratory
!    This file is part of the NWTC Subroutine Library.
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
! File last committed: $Date: 2013-12-23 14:04:45 -0800 (Mon, 23 Dec 2013) $
! (File) Revision #: $Rev: 117 $
! URL: $HeadURL: http://sel1004.verit.dnv.com:8080/svn/LoadSimCtl_SurfaceIce/trunk/IceDyn_IntelFortran/IceDyn/source/NWTC_Lib/NWTC_Base.f90 $
!**********************************************************************************************************************************


!
!
!
!
!
MODULE NWTC_Base
      ! This module stores basic constants and routines that are not system-specific, but may be used in the system-specific routines.
!   USE, INTRINSIC               :: ISO_C_Binding


    USE precision 
    USE kgen_utils_mod
    USE tprof_mod, ONLY: tstart, tstop, tnull, tprnt 

    IMPLICIT NONE 
!=======================================================================
      ! General constants:
!   INTEGER, PARAMETER            :: BITS_IN_ADDR  = C_INTPTR_T*8                  ! The number of bits in an address (32-bit or 64-bit).


      ! Global Error-level variables:


   INTEGER(IntKi), PARAMETER     :: ErrID_None   = 0
   INTEGER(IntKi), PARAMETER     :: ErrID_Fatal  = 4

   INTEGER(IntKi)                :: AbortErrLev  = ErrID_Fatal                     ! Note that this is not a PARAMETER
      ! Type definition for dynamically loaded libraries:
      !  Note that changes here may need to be reflected in DLLTypePack() DLLTypeUnPack(), and the FAST Registry.exe
!   TYPE DLL_Type
!      INTEGER(C_INTPTR_T)       :: FileAddr                                        ! The address of file FileName.         (RETURN value from LoadLibrary ) [Windows]
!      TYPE(C_PTR)               :: FileAddrX                                       ! The address of file FileName.         (RETURN value dlopen ) [Linux]
!      TYPE(C_FUNPTR)            :: ProcAddr                                        ! The address of procedure ProcName.    (RETURN value from GetProcAddress or dlsym)
!      CHARACTER(1024)           :: FileName                                        ! The name of the DLL file including the full path to the current working directory.
!      CHARACTER(1024)           :: ProcName                                        ! The name of the procedure in the DLL that will be called.
!   END TYPE DLL_Type
   PUBLIC kr_externs_in_nwtc_base 
     
   CONTAINS 
     


!
!
!


   !read state subroutine for kr_externs_in_nwtc_base 
   SUBROUTINE kr_externs_in_nwtc_base(kgen_unit) 
       INTEGER, INTENT(IN) :: kgen_unit 
       LOGICAL :: kgen_istrue 
       REAL(KIND=8) :: kgen_array_sum 
         
       READ (UNIT = kgen_unit) aborterrlev 
   END SUBROUTINE kr_externs_in_nwtc_base 
     

   pure subroutine SetErrStat (ErrStatLcl, ErrMessLcl, ErrStat, ErrMess, RoutineName)
      
      INTEGER(IntKi), INTENT(IN   )  :: ErrStatLcl   ! Error status of the operation
      CHARACTER(*),   INTENT(IN   )  :: ErrMessLcl   ! Error message if ErrStat /= ErrID_None
                                                                        
      INTEGER(IntKi), INTENT(INOUT)  :: ErrStat      ! Error status of the operation
      CHARACTER(*),   INTENT(INOUT)  :: ErrMess      ! Error message if ErrStat /= ErrID_None
   
      CHARACTER(*),   INTENT(IN   )  :: RoutineName  ! Name of the routine error occurred in
      
      IF ( ErrStatLcl /= ErrID_None ) THEN
         IF (ErrStat /= ErrID_None) then
            ErrMess = TRIM(ErrMess)//new_line('a')//TRIM(RoutineName)//':'//TRIM(ErrMessLcl)
         else
            ErrMess = TRIM(RoutineName)//':'//TRIM(ErrMessLcl)
         END IF
         ErrStat = MAX(ErrStat, ErrStatLcl)
      END IF
         
   end subroutine    



END MODULE NWTC_Base