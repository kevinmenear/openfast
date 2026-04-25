!KGEN-generated Fortran source file 
  
!Generated at : 2026-04-25 19:27:48 
!KGEN version : 0.8.1 
  
!**********************************************************************************************************************************
! LICENSING
! Copyright (C) 2013-2016  National Renewable Energy Laboratory
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
!..................................................................................................................................  
!> This module stores constants to specify the KIND of variables.
!!
!! NOTE: When using preprocessor definition DOUBLE_PRECISION (which sets ReKi=R8Ki), you 
!!    may need to use a compile option to convert default reals to 8 bytes: \n
!!       - Intel:   /real_size:64
!!       - Gnu:     -fdefault-real-8


!
!
!
!
!

MODULE Precision
!..................................................................................................................................

    USE kgen_utils_mod
    USE, INTRINSIC :: ISO_FORTRAN_ENV
    USE tprof_mod, ONLY: tstart, tstop, tnull, tprnt 

    IMPLICIT NONE 


INTEGER, PARAMETER              :: B4Ki     = int32   !< Kind for four-byte whole numbers !!! UNRESOLVED !!! int32

INTEGER, PARAMETER              :: R4Ki     = real32  !< Kind for four-byte, floating-point numbers !!! UNRESOLVED !!! real32
INTEGER, PARAMETER              :: R8Ki     = real64  !< Kind for eight-byte floating-point numbers !!! UNRESOLVED !!! real64


      ! The default kinds for reals and integers, and the number of bytes they contain:


INTEGER, PARAMETER              :: IntKi          = B4Ki                        !< Default kind for integers

INTEGER, PARAMETER              :: SiKi           = R4Ki                        !< Default kind for single floating-point numbers


INTEGER, PARAMETER              :: ReKi           = R8Ki                        !< Default kind for floating-point numbers


END MODULE Precision