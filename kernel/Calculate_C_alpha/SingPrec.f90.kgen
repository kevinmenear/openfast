!KGEN-generated Fortran source file 
  
!Generated at : 2026-04-25 11:14:49 
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

    USE kgen_utils_mod, ONLY: kgen_dp, kgen_array_sumcheck 
    USE tprof_mod, ONLY: tstart, tstop, tnull, tprnt 

    IMPLICIT NONE 


INTEGER, PARAMETER              :: B1Ki     = int8    !< Kind for one-byte whole numbers !!! UNRESOLVED !!! int8
INTEGER, PARAMETER              :: B2Ki     = int16   !< Kind for two-byte whole numbers !!! UNRESOLVED !!! int16
INTEGER, PARAMETER              :: B4Ki     = int32   !< Kind for four-byte whole numbers !!! UNRESOLVED !!! int32
INTEGER, PARAMETER              :: B8Ki     = int64   !< Kind for eight-byte whole numbers !!! UNRESOLVED !!! int64

INTEGER, PARAMETER              :: R4Ki     = real32  !< Kind for four-byte, floating-point numbers !!! UNRESOLVED !!! real32
INTEGER, PARAMETER              :: R8Ki     = real64  !< Kind for eight-byte floating-point numbers !!! UNRESOLVED !!! real64


INTEGER, PARAMETER              :: BYTES_IN_B4Ki =  4                           !< Number of bytes per B4Ki number

INTEGER, PARAMETER              :: BYTES_IN_R4Ki =  4                           !< Number of bytes per R4Ki number
INTEGER, PARAMETER              :: BYTES_IN_R8Ki =  8                           !< Number of bytes per R8Ki number 
      ! The default kinds for reals and integers, and the number of bytes they contain:


INTEGER, PARAMETER              :: IntKi          = B4Ki                        !< Default kind for integers
INTEGER, PARAMETER              :: BYTES_IN_INT   = BYTES_IN_B4Ki               !< Number of bytes per IntKi number    - use SIZEOF()

INTEGER, PARAMETER              :: SiKi           = R4Ki                        !< Default kind for single floating-point numbers


INTEGER, PARAMETER              :: ReKi           = R8Ki                        !< Default kind for floating-point numbers


END MODULE Precision