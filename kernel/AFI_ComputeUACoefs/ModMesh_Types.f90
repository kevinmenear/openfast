!KGEN-generated Fortran source file 
  
!Generated at : 2026-04-26 22:19:31 
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
!> This module contains the type definition of of ModMesh, the FAST spatial mesh structure.   


!
!
!
!
MODULE ModMesh_Types
    USE kgen_utils_mod
    USE tprof_mod, ONLY: tstart, tstop, tnull, tprnt 
    IMPLICIT NONE 

!WARNING... if you add fields here add them to the buffer size computation MeshPack too


   INTEGER, PUBLIC, PARAMETER :: MESH_NEWCOPY         = 1   !< parameter for type of mesh copy: new mesh instance


!   REAL(ReKi), PARAMETER            :: MIN_LINE2_ELEMENT_LENGTH = 0.001 ! 1 millimeter


      !> element record type: fields for a particular element
   

      !> table of all elements of a particular type


      !> table/list of all elements (may be different types, but not spatial dimensions)


      !> mesh data structure


!> This function returns the number of nodes in a given type of element.

!> This function determines if a mesh contains any motion field (translational/rotational positions, velocities, accelerations or scalars).


!> This function determines if a mesh contains any load field (force or motion).


!> This subroutine copies the element record data from one ElemRecType data structure to another. It calls the Fortran 2003 
!! intrinsic MOVE_ALLOC routine to move the address of the Src\%ElemNodes array to the Dest\%ElemNodes array without physically
!! copying any of the array. On exist Src\%ElemNodes will be deallocated. 


END MODULE ModMesh_Types