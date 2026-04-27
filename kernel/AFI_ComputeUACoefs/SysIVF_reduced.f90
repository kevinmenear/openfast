!KGEN-generated Fortran source file 
  
!Generated at : 2026-04-26 22:19:31 
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
! URL: $HeadURL: http://sel1004.verit.dnv.com:8080/svn/LoadSimCtl_SurfaceIce/trunk/IceDyn_IntelFortran/IceDyn/source/NWTC_Lib/SysIVF.f90 $
!**********************************************************************************************************************************


!
!
!
!
!
MODULE SysSubs
   ! This module contains routines with system-specific logic and references, including all references to the console unit, CU.
   ! It also contains standard (but not system-specific) routines it uses.
   ! SysIVF.f90 is specifically for the Intel Visual Fortran for Windows compiler.
   ! It contains the following routines:
   !     FUNCTION    FileSize( Unit )                                         ! Returns the size (in bytes) of an open file.
   !     SUBROUTINE  FlushOut ( Unit )
   !     SUBROUTINE  GET_CWD( DirName, Status )
   !     FUNCTION    Is_NaN( DblNum )                                                        ! Please use IEEE_IS_NAN() instead
   ! per MLB, this can be removed, but only if CU is OUTPUT_UNIT:
   !     SUBROUTINE  OpenCon     ! Actually, it can't be removed until we get Intel's FLUSH working. (mlb)
   !     SUBROUTINE  OpenUnfInpBEFile ( Un, InFile, RecLen, Error )
   !     SUBROUTINE  ProgExit ( StatCode )
   !     SUBROUTINE  UsrAlarm
   !     SUBROUTINE  WrNR ( Str )
   !     SUBROUTINE  WrOver ( Str )
   !     SUBROUTINE  WriteScr ( Str, Frm )


    USE nwtc_base 
    USE kgen_utils_mod
    USE tprof_mod, ONLY: tstart, tstop, tnull, tprnt 

    IMPLICIT NONE 
!=======================================================================


!=======================================================================


!=======================================================================

!=======================================================================

!=======================================================================

!=======================================================================

!=======================================================================

!=======================================================================

!=======================================================================

!=======================================================================

!=======================================================================

!=======================================================================

!=======================================================================
!==================================================================================================================================


END MODULE SysSubs