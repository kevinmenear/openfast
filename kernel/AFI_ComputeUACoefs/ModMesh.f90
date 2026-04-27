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
!> The modules ModMesh and ModMesh_Types provide data structures and subroutines for representing and manipulating meshes
!! and meshed data in the FAST modular framework. 
!!
!! A mesh is comprised of a set of "nodes" (simple points in space) together with information specifying how they are connected 
!! to form "elements"  representing spatial boundaries between components. ModMesh and ModMesh_Types define point, line, surface, 
!! and volume elements in a standard isoparametric mapping from finite element analysis. Currently only points and straight line 
!! (line2) elements are implemented.
!!   
!! Associated with a mesh are one or more "fields" that represent the values of variables or "degrees of freedom" at each node. 
!! A mesh always has a named "Position" that specifies the location in three-dimensional space as an Xi,Yi,Zi triplet of each node 
!! and a field named "RefOrientation" that specifies the orientation (as a direction cosine matrix) of the node. 
!! The ModMesh_Types module predefines a number of other fields of triples representing velocities, forces, and moments as well as
!! a field of nine values representing a direction cosine matrix. 
!!   
!! The operations on meshes defined in the ModMesh module are creation, spatio-location of nodes, construction, committing the 
!! mesh definition, initialization of fields, accessing field data, updating field data, copying, deallocating, and destroying meshes. 
!! See https://nwtc.nrel.gov/FAST-Developers and https://nwtc.nrel.gov/system/files/ProgrammingHandbook_Mod20130717.pdf


!
!
!
!
MODULE ModMesh
    USE modmesh_types 
    USE kgen_utils_mod
    USE tprof_mod, ONLY: tstart, tstop, tnull, tprnt 
    IMPLICIT NONE 
!   INTEGER :: DEBUG_UNIT = 74


!----------------------------------------------------------------------------------------------------------------------------------
!> This routine writes mesh information in binary form. If UnIn is < 0, it gets a new unit number and opens the file,
!! otherwise the file is appended. It is up to the caller of this routine to close the file when it's finished.


!----------------------------------------------------------------------------------------------------------------------------------
!> This routine writes the reference position and orientations of a mesh in VTK format.
!! see VTK file information format for XML, here: http://www.vtk.org/wp-content/uploads/2015/04/file-formats.pdf


!----------------------------------------------------------------------------------------------------------------------------------
!> This routine writes mesh information in VTK format.
!! see VTK file information format for XML, here: http://www.vtk.org/wp-content/uploads/2015/04/file-formats.pdf


!----------------------------------------------------------------------------------------------------------------------------------
!> This routine writes mesh field information in VTK format.
!! see VTK file information format for XML, here: http://www.vtk.org/wp-content/uploads/2015/04/file-formats.pdf


!----------------------------------------------------------------------------------------------------------------------------------
!> This routine writes line2 mesh surface information in VTK format.
!! see VTK file information format for XML, here: http://www.vtk.org/wp-content/uploads/2015/04/file-formats.pdf


!----------------------------------------------------------------------------------------------------------------------------------
!> This routine writes point mesh surfaces information in VTK format.
!! see VTK file information format for XML, here: http://www.vtk.org/wp-content/uploads/2015/04/file-formats.pdf


!-------------------------------------------------------------------------------------------------------------------------------
!> This routine writes mesh information in text form. It is used for debugging.
   


!----------------------------------------------------------------------------------------------------------------------------------
   ! operations to create a mesh
!> Takes a blank, uninitialized instance of Type(MeshType) and defines the number of nodes in the mesh. Optional 
!! arguments indicate the fields that will be allocated and associated with the nodes of the mesh. The fields that may 
!! be associated with the mesh nodes are Force, Moment, Orientation, Rotation, TranslationDisp, RotationVel, TranslationVel, 
!! RotationAcc, TranslationAcc, and an arbitrary number of Scalars. See the definition of ModMeshType for descriptions of these fields.  
! After the first 5 arguments, the others are optional that say whether to allocate fields in the mesh.
! These are always dimensioned npoints 


!> Destroy the given mesh and deallocate all of its data. If the optional IgnoreSibling argument 
!! is set to TRUE, destroying a sibling in a set has no effect on the other siblings other than 
!! to remove the victim from the list of siblings. If IgnoreSibling is omitted or is set to FALSE, 
!! all of the other siblings in the set will be destroyed as well.


!----------------------------------------------------------------------------------------------------------------------------------
! Format of the Int buffer
!   word
!     1        Total size of Int buffer in bytes
!     2        Total size of Real buffer in bytes
!     3        Total size of Db  buffer in bytes
!     4        IOS
!     5        Number of Nodes
!     6        Number of element records
!     7        FieldMask                           FIELDMASK_SIZE
!     7+$7     Table Entries                       $5 * SIZE(ElemRecType)
!> Given a mesh and allocatable buffers of type INTEGER(IntKi), REAL(ReKi), and REAL(DbKi), 
!! return the mesh information compacted into consecutive elements of the corresponding buffers. 
!! This would be done to allow subsequent writing of the buffers to a file for restarting later. 
!! The sense of the name is "pack the data from the mesh into buffers". IMPORTANT: MeshPack 
!! allocates the three buffers. It is incumbent upon the calling program to deallocate the 
!! buffers when they are no longer needed. For sibling meshes, MeshPack should be called 
!! separately for each sibling, because the fields allocated with the siblings are separate 
!! and unique to each sibling.

!


!----------------------------------------------------------------------------------------------------------------------------------
!> Given a blank, uncreated mesh and buffers of type INTEGER(IntKi), REAL(ReKi), and 
!! REAL(DbKi), unpack the mesh information from the buffers. This would be done to 
!! recreate a mesh after reading in the buffers on a restart of the program. The sense 
!! of the name is "unpack the mesh from buffers." The resulting mesh will be returned 
!! in the exact state as when the data in the buffers was packed using MeshPack. 


!----------------------------------------------------------------------------------------------------------------------------------
!> Given an existing mesh and a destination mesh, create a completely new copy, a sibling, or 
!!   update the fields of a second existing mesh from the first mesh. When CtrlCode is 
!!   MESH_NEWCOPY or MESH_SIBLING, the destination mesh must be a blank, uncreated mesh.
!! 
!! If CtrlCode is MESH_NEWCOPY, an entirely new copy of the mesh is created, including all fields, 
!!   with the same data values as the original, but as an entirely separate copy in memory. The new 
!!   copy is in the same state as the original--if the original has not been committed, neither is 
!!   the copy; in this case, an all-new copy of the mesh must be committed separately.
!!
!! If CtrlCode is MESH_SIBLING, the destination mesh is created with the same mesh and position/reference 
!!   orientation information of the source mesh, and this new sibling is added to the end of the list for 
!!   the set of siblings. Siblings may have different fields (other than Position and RefOrientation). 
!!   Therefore, for a sibling, it is necessary, as with MeshCreate, to indicate the fields the sibling 
!!   will have using optional arguments. Sibling meshes should not be created unless the original mesh 
!!   has been committed first.
!!
!! If CtrlCode is MESH_UPDATECOPY, all of the allocatable fields of the destination mesh are updated 
!!   with the values of the fields in the source. (The underlying mesh is untouched.) The mesh and field 
!!   definitions of the source and destination meshes must match and both must have been already committed. 
!!   The destination mesh may be an entirely different copy or it may be a sibling of the source mesh.


!----------------------------------------------------------------------------------------------------------------------------------
!> For a given node in a mesh, assign the coordinates of the node in the global coordinate space. 
!! If an Orient argument is included, the node will also be assigned the specified orientation 
!! (orientation is assumed to be the identity matrix if omitted). Returns a non-zero value in  
!! ErrStat if Inode is outside the range 1..Nnodes.     


!----------------------------------------------------------------------------------------------------------------------------------
!> Given a mesh that has been created, spatio-located, and constructed, 
!! commit the definition of the mesh, making it ready for initialization 
!! and use. Explicitly committing a mesh provides the opportunity to precompute 
!! traversal information, neighbor lists and other information about the mesh. 
!! Returns non-zero in value of ErrStat on error.     


!----------------------------------------------------------------------------------------------------------------------------------
!> Given a mesh and an element name, construct a point element whose vertex is the 
!! node index listed as the remaining argument of the call to MeshConstructElement.
!! Returns a non-zero ErrStat value on error.     


!----------------------------------------------------------------------------------------------------------------------------------


!----------------------------------------------------------------------------------------------------------------------------------
!> This subroutine increases the allocated space for Mesh%ElemTable(Xelement)%Elements
!! if adding a new element will exceed the pre-allocated space.
   


!----------------------------------------------------------------------------------------------------------------------------------
!> Given a mesh and an element name, construct 2-point line (line2) element whose 
!! vertices are the node indices listed as the remaining arguments of the call to 
!! MeshConstructElement. The adjacency of elements is implied when elements are 
!! created that share some of the same nodes. Returns a non-zero value on error.     
      


!----------------------------------------------------------------------------------------------------------------------------------
!> added 20130102 as stub for AeroDyn work


!----------------------------------------------------------------------------------------------------------------------------------
!> added 20130102 as stub for AeroDyn work


!----------------------------------------------------------------------------------------------------------------------------------
!> added 20130102 as stub for AeroDyn work


!----------------------------------------------------------------------------------------------------------------------------------
!> added 20130102 as stub for AeroDyn work


!----------------------------------------------------------------------------------------------------------------------------------
!> added 20130102 as stub for AeroDyn work


!----------------------------------------------------------------------------------------------------------------------------------
!> added 20130102 as stub for AeroDyn work


!----------------------------------------------------------------------------------------------------------------------------------
!> added 20130102 as stub for AeroDyn work


!................................................................                                                                                                                                                      
!> This routine splits a line2 element into two separate elements, using p1 as
!! the new node connecting the two new elements formed from E1.


!................................................................                                                                           
!----------------------------------------------------------------------------------------------------------------------------------
!> Given a control code and a mesh that has been committed, retrieve the next element in the mesh. 
!!   Used to traverse mesh element by element. On entry, the CtrlCode argument contains a control code: 
!!   zero indicates start from the beginning, an integer between 1 and Mesh%Nelemlist returns that element,
!!   and MESH_NEXT means return the next element in traversal. On exit, CtrlCode contains the status of the 
!!   traversal in (zero or MESH_NOMOREELEMS). The routine optionally outputs the index of the element in the
!!   mesh's element list, the name of the element (see "Element Names"), and a pointer to the element.    
                                                                           


!...............................................................................................................................
!> This subroutine returns the names of the output rows/columns in the Jacobian matrices. It assumes both force and moment
!! fields are allocated.


!...............................................................................................................................
!> This subroutine returns the operating point values of the mesh fields. It assumes both force and moment
!! fields are allocated.


!...............................................................................................................................
!> This subroutine computes the differences of two meshes and packs that value into appropriate locations in the dY array.
!! Do not change this packing without making sure subroutine aerodyn::init_jacobian is consistant with this routine!


!...............................................................................................................................
!> This subroutine returns the names of rows/columns of motion meshes in the Jacobian matrices. It assumes all fields marked
!! by FieldMask are allocated; Some fields may be allocated by the ModMesh module and not used in
!! the linearization procedure, thus I am not using the check if they are allocated to determine if they should be included.
!...............................................................................................................................


!...............................................................................................................................
!> This subroutine returns the operating point values of the mesh fields. It assumes all fields marked
!! by FieldMask are allocated; Some fields may be allocated by the ModMesh module and not used in
!! the linearization procedure, thus I am not using the check if they are allocated to determine if they should be included.


!...............................................................................................................................
!> This subroutine computes the differences of two meshes and packs that value into appropriate locations in the dY array.


!...............................................................................................................................
!> This subroutine calculates a extrapolated (or interpolated) input u_out at time t_out, from previous/future time
!! values of u (which has values associated with times in t).  Order of the interpolation is 1.


!...............................................................................................................................
!> This subroutine calculates a extrapolated (or interpolated) input u_out at time t_out, from previous/future time
!! values of u (which has values associated with times in t).  Order of the interpolation is 2.


!...............................................................................................................................
!> High level function to easily create an input point mesh with one node and one element


!----------------------------------------------------------------------------------------------------------------------------------
END MODULE ModMesh

