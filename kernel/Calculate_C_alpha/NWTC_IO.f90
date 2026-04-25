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
!> This module contains I/O-related variables and routines with non-system-specific logic.


!
!
!
!

MODULE NWTC_IO

    USE nwtc_library_types 
    USE kgen_utils_mod, ONLY: kgen_dp, kgen_array_sumcheck 
    USE tprof_mod, ONLY: tstart, tstop, tnull, tprnt 

    IMPLICIT NONE 
!=======================================================================


      !> This type stores a linked list of file names, used in MLB-style input file parsing (currently used in AirfoilInfo)


      ! Global coupling scheme variables.


   !bjj: will add more of these as we work our way
      ! Global I/O-related variables.


      ! Parameters for writing to echo files (in this module only)


   ! >>> Note that the following array formats use 100, the value of NWTC_MaxAryLen above. Please keep the two numbers consistant!
   ! <<< End of arrays that use number defined in NWTC_MaxAryLen
!=======================================================================


      !> \copydoc nwtc_io::allcary1

   INTERFACE AllocAry
      MODULE PROCEDURE AllCAry1
      MODULE PROCEDURE AllCAry2
      MODULE PROCEDURE AllCAry3
   !   MODULE PROCEDURE AllCAry4                               Not yet coded.
      MODULE PROCEDURE AllI1BAry1      ! 1-dimensional array of B1Ki integers
      MODULE PROCEDURE AllI2BAry1      ! 1-dimensional array of B2Ki integers
      MODULE PROCEDURE AllI4BAry1      ! 1-dimensional array of B4Ki integers
      MODULE PROCEDURE AllIAry2
      MODULE PROCEDURE AllIAry3
   !   MODULE PROCEDURE AllIAry4                               Not yet coded.
      MODULE PROCEDURE AllLAry1
      MODULE PROCEDURE AllLAry2
      MODULE PROCEDURE AllLAry3
   !   MODULE PROCEDURE AllLAry4                               Not yet coded.
      MODULE PROCEDURE AllR4Ary1       ! 1-dimensional array of SiKi reals
      MODULE PROCEDURE AllR4Ary2       ! 2-dimensional array of SiKi reals
      MODULE PROCEDURE AllR4Ary3       ! 3-dimensional array of SiKi reals
      MODULE PROCEDURE AllR4Ary4       ! 4-dimensional array of SiKi reals
      MODULE PROCEDURE AllR4Ary5       ! 5-dimensional array of SiKi reals
      MODULE PROCEDURE AllR8Ary1       ! 1-dimensional array of R8Ki reals      
      MODULE PROCEDURE AllR8Ary2       ! 2-dimensional array of R8Ki reals
      MODULE PROCEDURE AllR8Ary3       ! 3-dimensional array of R8Ki reals
      MODULE PROCEDURE AllR8Ary4       ! 4-dimensional array of R8Ki reals
      MODULE PROCEDURE AllR8Ary5       ! 5-dimensional array of R8Ki reals
   END INTERFACE
      !> \copydoc nwtc_io::allipary1


      !> \copydoc nwtc_io::parsechvar


      !> \copydoc nwtc_io::parsechvarwdefault


      !> \copydoc nwtc_io::parsedbary


      !> \copydoc nwtc_io::checkr4var


      !> \copydoc nwtc_io::readcvar
   

      !> \copydoc nwtc_io::readivarwdefault


      !> \copydoc nwtc_io::readcary
   

      !> \copydoc nwtc_io::readr4arywdefault


      !> \copydoc nwtc_io::readcarylines   


      !> \copydoc nwtc_io::int2lstr

   INTERFACE Num2LStr
      MODULE PROCEDURE Int2LStr        ! default integers
      MODULE PROCEDURE B8Ki2LStr       ! 8 byte integers
      MODULE PROCEDURE R2LStr4         ! 4-byte  reals
      MODULE PROCEDURE R2LStr8         ! 8-byte  reals
   END INTERFACE
      !> \copydoc nwtc_io::dispnvd0


      !> \copydoc nwtc_io::wrmatrix1r4


      !> \copydoc nwtc_io::wrpartialmatrix1r8


      !> \copydoc nwtc_io::wrr4aryfilenr
   


CONTAINS
!> This routine adjusts strings created from real numbers (4, 8, or 16-byte)
! It removes leading spaces and trailing zeros. It is intended to be called
! from routines R2LStr4, R2LStr8, and R2LStr16 (nwtc_io::r2lstr).
!=======================================================================

   SUBROUTINE AdjRealStr( NumStr )


   CHARACTER(*), INTENT(INOUT) :: NumStr       !< String representing a real number (e.g., from R2LStr4)
         ! Local declarations.


   INTEGER                      :: IC          ! Character index.


   NumStr = ADJUSTL( NumStr )
      ! Replace trailing zeros and possibly the decimal point with blanks.
      ! Stop trimming once we find the decimal point or a nonzero.
      ! Don't remove (important!) trailing zeros if they are in the exponent:


   IF (INDEX( NumStr, "E" ) > 0 ) RETURN
   IF (INDEX( NumStr, "e" ) > 0 ) RETURN
      ! These are not in the exponent


   DO IC=LEN_TRIM( NumStr ),1,-1

      IF ( NumStr(IC:IC) == '.' )  THEN
         NumStr(IC:IC) = ' '
         RETURN
      ELSE IF ( NumStr(IC:IC) /= '0' )  THEN
         RETURN
      END IF

      NumStr(IC:IC) = ' '

   END DO ! IC


   END SUBROUTINE AdjRealStr
!=======================================================================
!> This routine allocates an array to the size specified in the AryDim input arguement(s).
!! Arrays are of type ALLOCATABLE.   
!! If the array is already allocated on entry to this routine, an error will be generated. \n
!! Use AllocAry (nwtc_io::allocary) instead of directly calling a specific routine in the generic interface.   
   SUBROUTINE AllCAry1 ( Ary, AryDim1, Descr, ErrStat, ErrMsg )
   ! This routine allocates a 1-D CHARACTER array.
   ! Argument declarations.

   CHARACTER(*), ALLOCATABLE         :: Ary    (:)                                 !< Array to be allocated
   INTEGER,      INTENT(IN)          :: AryDim1                                    !< The size of the first dimension of the array.
   CHARACTER(*), INTENT(IN)          :: Descr                                      !< Brief array description (for error message).
   INTEGER,      INTENT(OUT)         :: ErrStat                                    !< Error status
   CHARACTER(*), INTENT(OUT)         :: ErrMsg                                     !< Error message corresponding to ErrStat
   
   ALLOCATE ( Ary(AryDim1) , STAT=ErrStat )

   IF ( ErrStat /= 0 ) THEN
      ErrStat = ErrID_Fatal
      IF ( ALLOCATED(Ary) ) THEN ! or Sttus=151 on IVF
         ErrMsg = 'Error allocating memory for the '//TRIM( Descr )//' array; array was already allocated.'
      ELSE
         ErrMsg = 'Error allocating memory for '//TRIM(Num2LStr(AryDim1))//' characters in the '//TRIM( Descr )//' array.'
      END IF
   ELSE
      ErrStat = ErrID_None
      ErrMsg  = ''
      Ary = ''
   END IF

   RETURN
   END SUBROUTINE AllCAry1 
!=======================================================================
!> \copydoc nwtc_io::allcary1
   SUBROUTINE AllCAry2 ( Ary, AryDim1, AryDim2, Descr, ErrStat, ErrMsg )
   ! This routine allocates a 2-D CHARACTER array.
   ! Argument declarations.

   CHARACTER(*), ALLOCATABLE         :: Ary    (:,:)                               !  Array to be allocated
   INTEGER,      INTENT(IN)          :: AryDim1                                    !  The size of the first dimension of the array.
   INTEGER,      INTENT(IN)          :: AryDim2                                    !< The size of the second dimension of the array.
   INTEGER,      INTENT(OUT)         :: ErrStat                                    !  Error status
   CHARACTER(*), INTENT(OUT)         :: ErrMsg                                     !  Error message corresponding to ErrStat
   CHARACTER(*), INTENT(IN)          :: Descr                                      !  Brief array description.

   ALLOCATE ( Ary(AryDim1,AryDim2) , STAT=ErrStat )

   IF ( ErrStat /= 0 ) THEN
      ErrStat = ErrID_Fatal
      IF ( ALLOCATED(Ary) ) THEN ! or Sttus=151 on IVF
         ErrMsg = 'Error allocating memory for the '//TRIM( Descr )//' array; array was already allocated.'
      ELSE
         ErrMsg = 'Error allocating memory for '//TRIM(Num2LStr(AryDim1*AryDim2))//' characters in the '//TRIM( Descr )//' array.'
      END IF
   ELSE
      ErrStat = ErrID_None
      ErrMsg  = ''
      Ary = ''
   END IF

   RETURN
   END SUBROUTINE AllCAry2
!=======================================================================
!> \copydoc nwtc_io::allcary1
   SUBROUTINE AllCAry3 (  Ary, AryDim1, AryDim2, AryDim3, Descr, ErrStat, ErrMsg )
   ! This routine allocates a 3-D CHARACTER array.
   ! Argument declarations.

   CHARACTER(*), ALLOCATABLE         :: Ary    (:,:,:)                             !  Array to be allocated
   INTEGER,      INTENT(IN)          :: AryDim1                                    !  The size of the first dimension of the array.
   INTEGER,      INTENT(IN)          :: AryDim2                                    !< The size of the second dimension of the array.
   INTEGER,      INTENT(IN)          :: AryDim3                                    !< The size of the third dimension of the array.
   CHARACTER(*), INTENT(IN)          :: Descr                                      !  Brief array description.
   INTEGER,      INTENT(OUT)         :: ErrStat                                    !  Error status
   CHARACTER(*), INTENT(OUT)         :: ErrMsg                                     !  Error message corresponding to ErrStat

   ALLOCATE ( Ary(AryDim1,AryDim2,AryDim3) , STAT=ErrStat )

   IF ( ErrStat /= 0 ) THEN
      ErrStat = ErrID_Fatal
      IF ( ALLOCATED(Ary) ) THEN ! or Sttus=151 on IVF
         ErrMsg = 'Error allocating memory for the '//TRIM( Descr )//' array; array was already allocated.'
      ELSE
         ErrMsg = 'Error allocating memory for '//TRIM(Num2LStr(AryDim1*AryDim2*AryDim3))//' characters in the '//TRIM( Descr )//' array.'
      END IF
   ELSE
      ErrStat = ErrID_None
      ErrMsg  = ''
      Ary = ''
   END IF

   RETURN
   END SUBROUTINE AllCAry3
!=======================================================================
!> \copydoc nwtc_io::allcary1
   SUBROUTINE AllI1BAry1 ( Ary, AryDim1, Descr, ErrStat, ErrMsg )
   ! This routine allocates a 1-D INTEGER B1Ki array.
   ! Argument declarations.

   INTEGER(B1Ki),  ALLOCATABLE :: Ary    (:)                                 ! Array to be allocated
   INTEGER(IntKi), INTENT(IN)  :: AryDim1                                    ! The size of the array
   CHARACTER(*),   INTENT(IN)  :: Descr                                      ! Brief array description
   INTEGER(IntKi), INTENT(OUT) :: ErrStat                                    ! Error status
   CHARACTER(*),   INTENT(OUT) :: ErrMsg                                     ! Error message corresponding to ErrStat

   ALLOCATE ( Ary(AryDim1) , STAT=ErrStat )

   IF ( ErrStat /= 0 ) THEN
      ErrStat = ErrID_Fatal
      IF ( ALLOCATED(Ary) ) THEN ! or Sttus=151 on IVF
         ErrMsg = 'Error allocating memory for the '//TRIM( Descr )//' array; array was already allocated.'
      ELSE
         ErrMsg = 'Error allocating '//TRIM(Num2LStr(AryDim1*1))//' bytes of memory for the '//TRIM( Descr )//' array.'
      END IF
   ELSE
      ErrStat = ErrID_None
      ErrMsg = ' '
      Ary = 0_B1Ki
   END IF

   RETURN
   END SUBROUTINE AllI1BAry1
!=======================================================================
!> \copydoc nwtc_io::allcary1
   SUBROUTINE AllI2BAry1 ( Ary, AryDim1, Descr, ErrStat, ErrMsg )
   ! This routine allocates a 1-D INTEGER B2Ki array.
   ! Argument declarations.

   INTEGER(B2Ki),  ALLOCATABLE :: Ary    (:)                                 ! Array to be allocated
   INTEGER(IntKi), INTENT(IN)  :: AryDim1                                     ! The size of the array
   CHARACTER(*),   INTENT(IN)  :: Descr                                      ! Brief array description
   INTEGER(IntKi), INTENT(OUT) :: ErrStat                                    ! Error status
   CHARACTER(*),   INTENT(OUT) :: ErrMsg                                     ! Error message corresponding to ErrStat

   ALLOCATE ( Ary(AryDim1) , STAT=ErrStat )

   IF ( ErrStat /= 0 ) THEN
      ErrStat = ErrID_Fatal
      IF ( ALLOCATED(Ary) ) THEN ! or Sttus=151 on IVF
         ErrMsg = 'Error allocating memory for the '//TRIM( Descr )//' array; array was already allocated.'
      ELSE
         ErrMsg = 'Error allocating '//TRIM(Num2LStr(AryDim1*2))//' bytes of memory for the '//TRIM( Descr )//' array.'
      END IF
   ELSE
      ErrStat = ErrID_None
      ErrMsg = ' '
      Ary = 0_B2Ki
   END IF

   RETURN
   END SUBROUTINE AllI2BAry1
!=======================================================================
!> \copydoc nwtc_io::allcary1
   SUBROUTINE AllI4BAry1 ( Ary, AryDim1, Descr, ErrStat, ErrMsg )
   ! This routine allocates a 1-D INTEGER B1Ki array.
   ! Argument declarations.

   INTEGER(B4Ki),  ALLOCATABLE :: Ary    (:)                                 !  Array to be allocated
   INTEGER(IntKi), INTENT(IN)  :: AryDim1                                     !  The size of the array
   CHARACTER(*),   INTENT(IN)  :: Descr                                      !  Brief array description
   INTEGER(IntKi), INTENT(OUT) :: ErrStat                                    !  Error status
   CHARACTER(*),   INTENT(OUT) :: ErrMsg                                     !  Error message corresponding to ErrStat

   ALLOCATE ( Ary(AryDim1) , STAT=ErrStat )

   IF ( ErrStat /= 0 ) THEN
      ErrStat = ErrID_Fatal
      IF ( ALLOCATED(Ary) ) THEN ! or Sttus=151 on IVF
         ErrMsg = 'Error allocating memory for the '//TRIM( Descr )//' array; array was already allocated.'
      ELSE
         ErrMsg = 'Error allocating '//TRIM(Num2LStr(AryDim1*4))//' bytes of memory for the '//TRIM( Descr )//' array.'
      END IF
   ELSE
      ErrStat = ErrID_None
      ErrMsg = ' '
      Ary = 0_B4Ki
   END IF

   RETURN
   END SUBROUTINE AllI4BAry1
!=======================================================================
!> \copydoc nwtc_io::allcary1
   SUBROUTINE AllIAry2 (  Ary, AryDim1, AryDim2, Descr, ErrStat, ErrMsg )
   ! This routine allocates a 2-D INTEGER array.
   ! Argument declarations.

   INTEGER(IntKi), ALLOCATABLE       :: Ary    (:,:)                               ! Array to be allocated
   INTEGER,      INTENT(IN)          :: AryDim1                                    ! The size of the first dimension of the array.
   INTEGER,      INTENT(IN)          :: AryDim2                                    !< The size of the second dimension of the array.
   CHARACTER(*), INTENT(IN)          :: Descr                                      ! Brief array description.
   INTEGER,      INTENT(OUT)         :: ErrStat                                    ! Error status
   CHARACTER(*), INTENT(OUT)         :: ErrMsg                                     ! Error message corresponding to ErrStat

   ALLOCATE ( Ary(AryDim1,AryDim2) , STAT=ErrStat )

   IF ( ErrStat /= 0 ) THEN
      ErrStat = ErrID_Fatal
      IF ( ALLOCATED(Ary) ) THEN ! or Sttus=151 on IVF
         ErrMsg = 'Error allocating memory for the '//TRIM( Descr )//' array; array was already allocated.'
      ELSE
         ErrMsg = 'Error allocating '//TRIM(Num2LStr(AryDim1*AryDim2*BYTES_IN_INT))//' bytes of memory for the '//TRIM( Descr )//' array.'
      END IF
   ELSE
      ErrStat = ErrID_None
      ErrMsg  = ''
      Ary = 0_IntKi
   END IF

   RETURN
   END SUBROUTINE AllIAry2
!=======================================================================
!> \copydoc nwtc_io::allcary1
   SUBROUTINE AllIAry3 (  Ary, AryDim1, AryDim2, AryDim3, Descr, ErrStat, ErrMsg )
   ! This routine allocates a 3-D INTEGER array.
   ! Argument declarations.

   INTEGER(IntKi),  ALLOCATABLE      :: Ary    (:,:,:)                             !  Array to be allocated
   INTEGER,      INTENT(IN)          :: AryDim1                                    !  The size of the first dimension of the array.
   INTEGER,      INTENT(IN)          :: AryDim2                                    !< The size of the second dimension of the array.
   INTEGER,      INTENT(IN)          :: AryDim3                                    !< The size of the third dimension of the array.
   CHARACTER(*), INTENT(IN)          :: Descr                                      !  Brief array description.
   INTEGER,      INTENT(OUT)         :: ErrStat                                    !  Error status; if present, program does not abort on error
   CHARACTER(*), INTENT(OUT)         :: ErrMsg                                     !  Error message corresponding to ErrStat

   ALLOCATE ( Ary(AryDim1,AryDim2,AryDim3) , STAT=ErrStat )

   IF ( ErrStat /= 0 ) THEN
      ErrStat = ErrID_Fatal
      IF ( ALLOCATED(Ary) ) THEN ! or Sttus=151 on IVF
         ErrMsg = 'Error allocating memory for the '//TRIM( Descr )//' array; array was already allocated.'
      ELSE
         ErrMsg = 'Error allocating '//TRIM(Num2LStr(AryDim1*AryDim2*AryDim3*BYTES_IN_INT))//' bytes of memory for the '//TRIM( Descr )//' array.'
      END IF
   ELSE
      ErrStat = ErrID_None
      ErrMsg  = ''
      Ary = 0_IntKi
   END IF

   RETURN
   END SUBROUTINE AllIAry3
!=======================================================================
!> This routine allocates an array to the size specified in the AryDim input arguement(s).
!! Arrays are of type POINTER.   
!! If the array pointer is already associated on entry to this routine, the array it points to 
!! will be deallocated first. \n
!! Use AllocPAry (nwtc_io::allocpary) instead of directly calling a specific routine in the generic interface.   


!=======================================================================
!> \copydoc nwtc_io::allipary1


!=======================================================================
!> \copydoc nwtc_io::allipary1


!=======================================================================
!> \copydoc nwtc_io::allipary1


!=======================================================================
!> \copydoc nwtc_io::allipary1


!=======================================================================
!> \copydoc nwtc_io::allipary1


!=======================================================================
!> \copydoc nwtc_io::allipary1


!=======================================================================
!> \copydoc nwtc_io::allcary1
   SUBROUTINE AllLAry1 ( Ary, AryDim1, Descr, ErrStat, ErrMsg )
   ! This routine allocates a 1-D LOGICAL array.
   ! Argument declarations.

   LOGICAL,      ALLOCATABLE         :: Ary    (:)                                 !  Array to be allocated
   INTEGER,      INTENT(IN)          :: AryDim1                                    !  The size of the array.
   CHARACTER(*), INTENT(IN)          :: Descr                                      !  Brief array description.
   INTEGER,      INTENT(OUT)         :: ErrStat                                    !  Error status; if present, program does not abort on error
   CHARACTER(*), INTENT(OUT)         :: ErrMsg                                     !  Error message corresponding to ErrStat

   ALLOCATE ( Ary(AryDim1) , STAT=ErrStat )

   IF ( ErrStat /= 0 ) THEN
      ErrStat = ErrID_Fatal
      IF ( ALLOCATED(Ary) ) THEN ! or Sttus=151 on IVF
         ErrMsg = 'Error allocating memory for the '//TRIM( Descr )//' array; array was already allocated.'
      ELSE
         ErrMsg = 'Error allocating memory for '//TRIM(Num2LStr(AryDim1))//&
                  ' logical values in the '//TRIM( Descr )//' array.'
      END IF      
   ELSE
      ErrStat = ErrID_None
      ErrMsg  = ''
      Ary = .FALSE.
   END IF

   RETURN
   END SUBROUTINE AllLAry1
!=======================================================================
!> \copydoc nwtc_io::allcary1
   SUBROUTINE AllLAry2 (  Ary, AryDim1, AryDim2, Descr, ErrStat, ErrMsg )
   ! This routine allocates a 2-D LOGICAL array.
   ! Argument declarations.

   LOGICAL,      ALLOCATABLE         :: Ary    (:,:)                               !  Array to be allocated
   INTEGER,      INTENT(IN)          :: AryDim1                                    !  The size of the first dimension of the array.
   INTEGER,      INTENT(IN)          :: AryDim2                                    !< The size of the second dimension of the array.
   CHARACTER(*), INTENT(IN)          :: Descr                                      !  Brief array description.
   INTEGER,      INTENT(OUT)         :: ErrStat                                    !  Error status; if present, program does not abort on error
   CHARACTER(*), INTENT(OUT)         :: ErrMsg                                     !  Error message corresponding to ErrStat

   ALLOCATE ( Ary(AryDim1,AryDim2) , STAT=ErrStat )

   IF ( ErrStat /= 0 ) THEN
      ErrStat = ErrID_Fatal
      IF ( ALLOCATED(Ary) ) THEN ! or Sttus=151 on IVF
         ErrMsg = 'Error allocating memory for the '//TRIM( Descr )//' array; array was already allocated.'
      ELSE
         ErrMsg = 'Error allocating memory for '//TRIM(Num2LStr(AryDim1*AryDim2))//&
                  ' logical values in the '//TRIM( Descr )//' array.'
      END IF      
   ELSE
      ErrStat = ErrID_None
      ErrMsg  = ''
      Ary = .FALSE.
   END IF

   RETURN
   END SUBROUTINE AllLAry2
!=======================================================================
!> \copydoc nwtc_io::allcary1
   SUBROUTINE AllLAry3 (  Ary, AryDim1, AryDim2, AryDim3, Descr, ErrStat, ErrMsg )
   ! Argument declarations.

   LOGICAL,      ALLOCATABLE         :: Ary    (:,:,:)                             !  Array to be allocated
   INTEGER,      INTENT(IN)          :: AryDim1                                    !  The size of the first dimension of the array.
   INTEGER,      INTENT(IN)          :: AryDim2                                    !< The size of the second dimension of the array.
   INTEGER,      INTENT(IN)          :: AryDim3                                    !< The size of the third dimension of the array.
   CHARACTER(*), INTENT(IN)          :: Descr                                      !  Brief array description.
   INTEGER,      INTENT(OUT)         :: ErrStat                                    !  Error status; if present, program does not abort on error
   CHARACTER(*), INTENT(OUT)         :: ErrMsg                                     !  Error message corresponding to ErrStat

   ALLOCATE ( Ary(AryDim1,AryDim2,AryDim3) , STAT=ErrStat )

   IF ( ErrStat /= 0 ) THEN
      ErrStat = ErrID_Fatal
      IF ( ALLOCATED(Ary) ) THEN ! or Sttus=151 on IVF
         ErrMsg = 'Error allocating memory for the '//TRIM( Descr )//' array; array was already allocated.'
      ELSE
         ErrMsg = 'Error allocating memory for '//TRIM(Num2LStr(AryDim1*AryDim2*AryDim3))//&
                  ' logical values in the '//TRIM( Descr )//' array.'
      END IF      
   ELSE
      ErrStat = ErrID_None
      ErrMsg  = ''
      Ary = .FALSE.
   END IF

   RETURN
   END SUBROUTINE AllLAry3
!=======================================================================
!> \copydoc nwtc_io::allcary1
   SUBROUTINE AllR4Ary1 ( Ary, AryDim1, Descr, ErrStat, ErrMsg )
   ! Argument declarations.

   REAL(SiKi),      ALLOCATABLE      :: Ary    (:)                                 !  Array to be allocated
   INTEGER,      INTENT(IN)          :: AryDim1                                    !  The size of the array.
   CHARACTER(*), INTENT(IN)          :: Descr                                      !  Brief array description.
   INTEGER,      INTENT(OUT)         :: ErrStat                                    !  Error status
   CHARACTER(*), INTENT(OUT)         :: ErrMsg                                     !  Error message corresponding to ErrStat

   ALLOCATE ( Ary(AryDim1) , STAT=ErrStat )

   IF ( ErrStat /= 0 ) THEN
      ErrStat = ErrID_Fatal
      IF ( ALLOCATED(Ary) ) THEN ! or Sttus=151 on IVF
         ErrMsg = 'Error allocating memory for the '//TRIM( Descr )//' array; array was already allocated.'
      ELSE
         ErrMsg = 'Error allocating '//TRIM(Num2LStr(AryDim1*BYTES_IN_R4Ki))//' bytes of memory for the '//TRIM( Descr )//' array.'
      END IF
   ELSE
      ErrStat = ErrID_None
      ErrMsg  = ''
      Ary = 0.0_SiKi
   END IF
 
   RETURN
   END SUBROUTINE AllR4Ary1
!=======================================================================
!> \copydoc nwtc_io::allcary1
   SUBROUTINE AllR8Ary1 ( Ary, AryDim1, Descr, ErrStat, ErrMsg )
   ! This routine allocates a 1-D 8-byte REAL array.
   ! Argument declarations.

   REAL(R8Ki),      ALLOCATABLE      :: Ary    (:)                                 !  Array to be allocated
   INTEGER,      INTENT(IN)          :: AryDim1                                    !  The size of the array.
   CHARACTER(*), INTENT(IN)          :: Descr                                      !  Brief array description.
   INTEGER,      INTENT(OUT)         :: ErrStat                                    !  Error status
   CHARACTER(*), INTENT(OUT)         :: ErrMsg                                     !  Error message corresponding to ErrStat
   
   ALLOCATE ( Ary(AryDim1) , STAT=ErrStat )

   IF ( ErrStat /= 0 ) THEN
      ErrStat = ErrID_Fatal
      IF ( ALLOCATED(Ary) ) THEN ! or Sttus=151 on IVF
         ErrMsg = 'Error allocating memory for the '//TRIM( Descr )//' array; array was already allocated.'
      ELSE
         ErrMsg = 'Error allocating '//TRIM(Num2LStr(AryDim1*BYTES_IN_R8Ki))//' bytes of memory for the '//TRIM( Descr )//' array.'
      END IF
   ELSE
      ErrStat = ErrID_None
      ErrMsg  = ''
      Ary = 0.0_R8Ki
   END IF
 
   RETURN
   END SUBROUTINE AllR8Ary1
!=======================================================================
!> \copydoc nwtc_io::allcary1
   SUBROUTINE AllR4Ary2 (  Ary, AryDim1, AryDim2, Descr, ErrStat, ErrMsg )
   ! This routine allocates a 2-D 4-Byte REAL array.
   ! Argument declarations.

   REAL(SiKi), ALLOCATABLE           :: Ary    (:,:)                               !  Array to be allocated
   INTEGER,      INTENT(IN)          :: AryDim1                                    !  The size of the first dimension of the array.
   INTEGER,      INTENT(IN)          :: AryDim2                                    !< The size of the second dimension of the array.
   CHARACTER(*), INTENT(IN)          :: Descr                                      !  Brief array description.
   INTEGER,      INTENT(OUT)         :: ErrStat                                    !  Error status
   CHARACTER(*), INTENT(OUT)         :: ErrMsg                                     !  Error message corresponding to ErrStat

   ALLOCATE ( Ary(AryDim1,AryDim2) , STAT=ErrStat )
   
   IF ( ErrStat /= 0 ) THEN
      ErrStat = ErrID_Fatal
      IF ( ALLOCATED(Ary) ) THEN
         ErrMsg = 'Error allocating memory for the '//TRIM( Descr )//' array; array was already allocated.'
      ELSE
         ErrMsg = 'Error allocating '//TRIM(Num2LStr(AryDim1*AryDim2*BYTES_IN_R4Ki))//&
                  ' bytes of memory for the '//TRIM( Descr )//' array.'
      END IF
   ELSE
      ErrStat = ErrID_None
      ErrMsg  = ''
      Ary = 0.0_SiKi
   END IF

   RETURN
   END SUBROUTINE AllR4Ary2
!=======================================================================
!> \copydoc nwtc_io::allcary1
   SUBROUTINE AllR8Ary2 (  Ary, AryDim1, AryDim2, Descr, ErrStat, ErrMsg )
   ! This routine allocates a 2-D 8-Byte REAL array.
   ! Argument declarations.

   REAL(R8Ki), ALLOCATABLE           :: Ary    (:,:)                               !  Array to be allocated
   INTEGER,      INTENT(IN)          :: AryDim1                                    !  The size of the first dimension of the array.
   INTEGER,      INTENT(IN)          :: AryDim2                                    !< The size of the second dimension of the array.
   CHARACTER(*), INTENT(IN)          :: Descr                                      !  Brief array description.
   INTEGER,      INTENT(OUT)         :: ErrStat                                    !  Error status
   CHARACTER(*), INTENT(OUT)         :: ErrMsg                                     !  Error message corresponding to ErrStat

   ALLOCATE ( Ary(AryDim1,AryDim2) , STAT=ErrStat )

   IF ( ErrStat /= 0 ) THEN
      ErrStat = ErrID_Fatal
      IF ( ALLOCATED(Ary) ) THEN
         ErrMsg = 'Error allocating memory for the '//TRIM( Descr )//' array; array was already allocated.'
      ELSE
         ErrMsg = 'Error allocating '//TRIM(Num2LStr(AryDim1*AryDim2*BYTES_IN_R8Ki))//&
                  ' bytes of memory for the '//TRIM( Descr )//' array.'
      END IF
   ELSE
      ErrStat = ErrID_None
      ErrMsg  = ''
      Ary = 0.0_R8Ki
   END IF

   RETURN
   END SUBROUTINE AllR8Ary2
!=======================================================================
!> \copydoc nwtc_io::allcary1
   SUBROUTINE AllR4Ary3 (  Ary, AryDim1, AryDim2, AryDim3, Descr, ErrStat, ErrMsg )
   ! This routine allocates a 3-D 4-byte REAL array.
   ! Argument declarations.

   REAL(SiKi), ALLOCATABLE           :: Ary    (:,:,:)                             !  Array to be allocated
   INTEGER,      INTENT(IN)          :: AryDim1                                    !  The size of the first dimension of the array.
   INTEGER,      INTENT(IN)          :: AryDim2                                    !< The size of the second dimension of the array.
   INTEGER,      INTENT(IN)          :: AryDim3                                    !< The size of the third dimension of the array.
   CHARACTER(*), INTENT(IN)          :: Descr                                      !  Brief array description.
   INTEGER,      INTENT(OUT)         :: ErrStat                                    !  Error status; if present, program does not abort on error
   CHARACTER(*), INTENT(OUT)         :: ErrMsg                                     !  Error message corresponding to ErrStat

   ALLOCATE ( Ary(AryDim1,AryDim2,AryDim3) , STAT=ErrStat )

   IF ( ErrStat /= 0 ) THEN
      ErrStat = ErrID_Fatal
      IF ( ALLOCATED(Ary) ) THEN ! or Sttus=151 on IVF
         ErrMsg = 'Error allocating memory for the '//TRIM( Descr )//' array; array was already allocated.'
      ELSE
         ErrMsg = 'Error allocating '//TRIM(Num2LStr(AryDim1*AryDim2*AryDim3*BYTES_IN_R4Ki))//&
                  ' bytes of memory for the '//TRIM( Descr )//' array.'
      END IF
   ELSE
      ErrStat = ErrID_None
      ErrMsg  = ''
      Ary = 0.0_SiKi
   END IF

   RETURN
   END SUBROUTINE AllR4Ary3
!=======================================================================
!> \copydoc nwtc_io::allcary1
   SUBROUTINE AllR8Ary3 (  Ary, AryDim1, AryDim2, AryDim3, Descr, ErrStat, ErrMsg )
   ! This routine allocates a 3-D 8-byte REAL array.
   ! Argument declarations.

   REAL(R8Ki), ALLOCATABLE           :: Ary    (:,:,:)                             !  Array to be allocated
   INTEGER,      INTENT(IN)          :: AryDim1                                    !  The size of the first dimension of the array.
   INTEGER,      INTENT(IN)          :: AryDim2                                    !< The size of the second dimension of the array.
   INTEGER,      INTENT(IN)          :: AryDim3                                    !< The size of the third dimension of the array.
   CHARACTER(*), INTENT(IN)          :: Descr                                      !  Brief array description.
   INTEGER,      INTENT(OUT)         :: ErrStat                                    !  Error status; if present, program does not abort on error
   CHARACTER(*), INTENT(OUT)         :: ErrMsg                                     !  Error message corresponding to ErrStat

   ALLOCATE ( Ary(AryDim1,AryDim2,AryDim3) , STAT=ErrStat )

   IF ( ErrStat /= 0 ) THEN
      ErrStat = ErrID_Fatal
      IF ( ALLOCATED(Ary) ) THEN ! or Sttus=151 on IVF
         ErrMsg = 'Error allocating memory for the '//TRIM( Descr )//' array; array was already allocated.'
      ELSE
         ErrMsg = 'Error allocating '//TRIM(Num2LStr(AryDim1*AryDim2*AryDim3*BYTES_IN_R8Ki))//&
                  ' bytes of memory for the '//TRIM( Descr )//' array.'
      END IF
   ELSE
      ErrStat = ErrID_None
      ErrMsg  = ''
      Ary = 0.0_R8Ki
   END IF

   RETURN
   END SUBROUTINE AllR8Ary3
!=======================================================================
!> \copydoc nwtc_io::allcary1
   SUBROUTINE AllR4Ary4 (  Ary, AryDim1, AryDim2, AryDim3, AryDim4, Descr, ErrStat, ErrMsg )
   ! This routine allocates a 4-D 4-byte REAL array.
   ! Argument declarations.

   REAL(SiKi),      ALLOCATABLE      :: Ary    (:,:,:,:)                           !  Array to be allocated
   INTEGER,      INTENT(IN)          :: AryDim1                                    !  The size of the first dimension of the array.
   INTEGER,      INTENT(IN)          :: AryDim2                                    !< The size of the second dimension of the array.
   INTEGER,      INTENT(IN)          :: AryDim3                                    !< The size of the third dimension of the array.
   INTEGER,      INTENT(IN)          :: AryDim4                                    !< The size of the fourth dimension of the array.
   CHARACTER(*), INTENT(IN)          :: Descr                                      !  Brief array description.
   INTEGER,      INTENT(OUT)         :: ErrStat                                    !  Error status; if present, program does not abort on error
   CHARACTER(*), INTENT(OUT)         :: ErrMsg                                     !  Error message corresponding to ErrStat

   ALLOCATE ( Ary(AryDim1,AryDim2,AryDim3,AryDim4) , STAT=ErrStat )

   IF ( ErrStat /= 0 ) THEN
      ErrStat = ErrID_Fatal
      IF ( ALLOCATED(Ary) ) THEN ! or Sttus=151 on IVF
         ErrMsg = 'Error allocating memory for the '//TRIM( Descr )//' array; array was already allocated.'
      ELSE
         ErrMsg = 'Error allocating '//TRIM(Num2LStr(AryDim1*AryDim2*AryDim3*AryDim4*BYTES_IN_R4Ki))//&
                  ' bytes of memory for the '//TRIM( Descr )//' array.'
      END IF
   ELSE
      ErrStat = ErrID_None
      ErrMsg  = ''
      Ary = 0.0_SiKi
   END IF

   RETURN
   END SUBROUTINE AllR4Ary4
!=======================================================================
!> \copydoc nwtc_io::allcary1
   SUBROUTINE AllR8Ary4 (  Ary, AryDim1, AryDim2, AryDim3, AryDim4, Descr, ErrStat, ErrMsg )
   ! This routine allocates a 4-D 8-byte REAL array.
   ! Argument declarations.

   REAL(R8Ki),      ALLOCATABLE      :: Ary    (:,:,:,:)                           !  Array to be allocated
   INTEGER,      INTENT(IN)          :: AryDim1                                    !  The size of the first dimension of the array.
   INTEGER,      INTENT(IN)          :: AryDim2                                    !< The size of the second dimension of the array.
   INTEGER,      INTENT(IN)          :: AryDim3                                    !< The size of the third dimension of the array.
   INTEGER,      INTENT(IN)          :: AryDim4                                    !< The size of the fourth dimension of the array.
   CHARACTER(*), INTENT(IN)          :: Descr                                      !  Brief array description.
   INTEGER,      INTENT(OUT)         :: ErrStat                                    !  Error status; if present, program does not abort on error
   CHARACTER(*), INTENT(OUT)         :: ErrMsg                                     !  Error message corresponding to ErrStat

   ALLOCATE ( Ary(AryDim1,AryDim2,AryDim3,AryDim4) , STAT=ErrStat )

   IF ( ErrStat /= 0 ) THEN
      ErrStat = ErrID_Fatal
      IF ( ALLOCATED(Ary) ) THEN ! or Sttus=151 on IVF
         ErrMsg = 'Error allocating memory for the '//TRIM( Descr )//' array; array was already allocated.'
      ELSE
         ErrMsg = 'Error allocating '//TRIM(Num2LStr(AryDim1*AryDim2*AryDim3*AryDim4*BYTES_IN_R8Ki))//&
                  ' bytes of memory for the '//TRIM( Descr )//' array.'
      END IF
   ELSE
      ErrStat = ErrID_None
      ErrMsg  = ''
      Ary = 0.0_R8Ki
   END IF

   RETURN
   END SUBROUTINE AllR8Ary4
!=======================================================================
!> \copydoc nwtc_io::allcary1
   SUBROUTINE AllR4Ary5 (  Ary, AryDim1, AryDim2, AryDim3, AryDim4, AryDim5, Descr, ErrStat, ErrMsg )
   ! This routine allocates a 5-D 4-byte REAL array.
   ! Argument declarations.

   REAL(SiKi),      ALLOCATABLE      :: Ary    (:,:,:,:,:)                         !  Array to be allocated
   INTEGER,      INTENT(IN)          :: AryDim1                                    !  The size of the first dimension of the array.
   INTEGER,      INTENT(IN)          :: AryDim2                                    !< The size of the second dimension of the array.
   INTEGER,      INTENT(IN)          :: AryDim3                                    !< The size of the third dimension of the array.
   INTEGER,      INTENT(IN)          :: AryDim4                                    !< The size of the fourth dimension of the array.
   INTEGER,      INTENT(IN)          :: AryDim5                                    !< The size of the fourth dimension of the array.
   CHARACTER(*), INTENT(IN)          :: Descr                                      !  Brief array description.
   INTEGER,      INTENT(OUT)         :: ErrStat                                    !  Error status; if present, program does not abort on error
   CHARACTER(*), INTENT(OUT)         :: ErrMsg                                     !  Error message corresponding to ErrStat

   ALLOCATE ( Ary(AryDim1,AryDim2,AryDim3,AryDim4,AryDim5) , STAT=ErrStat )

   IF ( ErrStat /= 0 ) THEN
      ErrStat = ErrID_Fatal
      IF ( ALLOCATED(Ary) ) THEN ! or Sttus=151 on IVF
         ErrMsg = 'Error allocating memory for the '//TRIM( Descr )//' array; array was already allocated.'
      ELSE
         ErrMsg = 'Error allocating '//TRIM(Num2LStr(AryDim1*AryDim2*AryDim3*AryDim4*AryDim5*BYTES_IN_R4Ki))//&
                  ' bytes of memory for the '//TRIM( Descr )//' array.'
      END IF
   ELSE
      ErrStat = ErrID_None
      ErrMsg  = ''
      Ary = 0.0_SiKi
   END IF

   RETURN
   END SUBROUTINE AllR4Ary5
!=======================================================================
!> \copydoc nwtc_io::allcary1
   SUBROUTINE AllR8Ary5 (  Ary, AryDim1, AryDim2, AryDim3, AryDim4, AryDim5, Descr, ErrStat, ErrMsg )
   ! This routine allocates a 5-D 8-byte REAL array.
   ! Argument declarations.

   REAL(R8Ki),      ALLOCATABLE      :: Ary    (:,:,:,:,:)                         !  Array to be allocated
   INTEGER,      INTENT(IN)          :: AryDim1                                    !  The size of the first dimension of the array.
   INTEGER,      INTENT(IN)          :: AryDim2                                    !< The size of the second dimension of the array.
   INTEGER,      INTENT(IN)          :: AryDim3                                    !< The size of the third dimension of the array.
   INTEGER,      INTENT(IN)          :: AryDim4                                    !< The size of the fourth dimension of the array.
   INTEGER,      INTENT(IN)          :: AryDim5                                    !< The size of the fourth dimension of the array.
   CHARACTER(*), INTENT(IN)          :: Descr                                      !  Brief array description.
   INTEGER,      INTENT(OUT)         :: ErrStat                                    !  Error status; if present, program does not abort on error
   CHARACTER(*), INTENT(OUT)         :: ErrMsg                                     !  Error message corresponding to ErrStat

   ALLOCATE ( Ary(AryDim1,AryDim2,AryDim3,AryDim4,AryDim5) , STAT=ErrStat )

   IF ( ErrStat /= 0 ) THEN
      ErrStat = ErrID_Fatal
      IF ( ALLOCATED(Ary) ) THEN ! or Sttus=151 on IVF
         ErrMsg = 'Error allocating memory for the '//TRIM( Descr )//' array; array was already allocated.'
      ELSE
         ErrMsg = 'Error allocating '//TRIM(Num2LStr(AryDim1*AryDim2*AryDim3*AryDim4*AryDim5*BYTES_IN_R8Ki))//&
                  ' bytes of memory for the '//TRIM( Descr )//' array.'
      END IF
   ELSE
      ErrStat = ErrID_None
      ErrMsg  = ''
      Ary = 0.0_R8Ki
   END IF

   RETURN
   END SUBROUTINE AllR8Ary5
!=======================================================================
!> This subroutine checks the data to be parsed to make sure it finds
!! the expected variable name and an associated value.


!=======================================================================
!> This routine tests to make sure we have a valid format string for real numbers (i.e., it doesn't produce "****").

!=======================================================================
!> This routine checks the I/O status and prints either an end-of-file or
!! an invalid-input message, and then aborts the program or returns an appropriate error level and message.


!=======================================================================
!> This routine checks that real values are finite and not NaNs

!=======================================================================
!> \copydoc nwtc_io::checkr4var

!=======================================================================
!> This routine converts all the text in a string to upper case.

!=======================================================================
!> This subroutine is used to count the number of "words" in a line of text.
!! It uses spaces, tabs, commas, semicolons, single quotes, and double quotes ("whitespace")
!!  as word separators. Use GetWords (nwtc_io::getwords) to return the words from the line.


!=======================================================================
!> This function returns a character string encoded with today's date in the form dd-mmm-ccyy.

!=======================================================================
!> This function returns a character string encoded with the time in the form "hh:mm:ss".

!=======================================================================
!> This routine displays some text about copyright and license.


!=======================================================================
!> This routine packs the DLL_Type (nwtc_base::dll_type) data into an integer buffer.
!! It is required for the FAST Registry. It is the inverse of DLLTypeUnPack (nwtc_io::dlltypeunpack).


!=======================================================================
!> This routine unpacks the DLL_Type data from an integer buffer.
!! It is required for the FAST Registry. It is the inverse of DLLTypePack (nwtc_io::dlltypepack).


!=======================================================================
!> This routine displays the name of the program, its version, and its release date.
!! Use DispNVD (nwtc_io::dispnvd) instead of directly calling a specific routine in the generic interface.

!=======================================================================
!> \copydoc nwtc_io::dispnvd0


!=======================================================================
!> This routine displays the name of the program, its version, and its release date passed in as strings
!! This routine is depricated and for legacy purposes only. Please don't use for any new code (Dec-2012).


!=======================================================================
!> This routine finds one line of text with a maximum length of MaxLen from the Str.
!! It tries to break the line at a blank.
   

!=======================================================================
!> This routine returns the next unit number greater than 9 that is not currently in use.
!! If it cannot find any unit between 10 and 2^16-1 that is available, it either aborts or returns an appropriate error status/message.   


!=======================================================================
!> This function returns a text description of the ErrID (ErrStat) code.

!=======================================================================
!> This function extracts the Name field from the ProgDesc data type
!  and return it.

!=======================================================================
!> Let's parse the path name from the name of the given file.
!! We'll count everything before (and including) the last "\" or "/".


!=======================================================================
!> Let's parse the root file name from the name of the given file.
!! We'll count everything after the last period as the extension.


!=======================================================================
!> This routine will parse Line for NumTok "tokens" and return them in the Tokens array.
!! This routine differs from GetWords() (nwtc_io::getwords) in that it uses only spaces as token separators.

!=======================================================================
!> This subroutine is used to get the NumWords "words" from a line of text.
!! It uses spaces, tabs, commas, semicolons, single quotes, and double quotes ("whitespace")
!! as word separators. If there aren't NumWords in the line, the remaining array elements will remain empty.
!! Use CountWords (nwtc_io::countwords) to count the number of words in a line.


!=======================================================================
!> This subroutine is used to compare a header line (`HeaderLine`) with a list of column names.
!! It searches for each possible column name (AvailableChanName) and returns an index array indicating which
!! order the columns are listed in the file (this allows columns to be entered in different orders or for 
!! some columns to be missing. It returns an error if any of the required channels are missing.


!=======================================================================
!> This routine converts an ASCII array of integers into an equivalent string
!! (character array). This routine is the inverse of the Str2IntAry() (nwtc_io::str2intary) routine.


!=======================================================================
!> This function returns a left-adjusted string representing the passed numeric value. 
!! It eliminates trailing zeroes and even the decimal point if it is not a fraction. \n
!! Use Num2LStr (nwtc_io::num2lstr) instead of directly calling a specific routine in the generic interface.   
   FUNCTION Int2LStr ( Num )
      CHARACTER(11)                :: Int2LStr                                  !< string representing input number.
      ! Argument declarations.
      INTEGER(IntKi), INTENT(IN)   :: Num                                       !< The number to convert to a left-justified string.
      WRITE (Int2LStr,'(I11)')  Num
      Int2Lstr = ADJUSTL( Int2LStr )
      RETURN
   END FUNCTION Int2LStr
!=======================================================================
!> This function returns a left-adjusted string representing the passed numeric value. 
!! It eliminates trailing zeroes and even the decimal point if it is not a fraction. \n
!! Use Num2LStr (nwtc_io::num2lstr) instead of directly calling a specific routine in the generic interface.   
   FUNCTION B8Ki2LStr ( Num )
      CHARACTER(20)                :: B8Ki2LStr                                 !< string representing input number.
      ! Argument declarations.
      INTEGER(B8Ki), INTENT(IN)    :: Num                                       !< The number to convert to a left-justified string.
      WRITE (B8Ki2LStr,'(I20)')  Num
      B8Ki2Lstr = ADJUSTL( B8Ki2LStr )
      RETURN
   END FUNCTION B8Ki2LStr
!=======================================================================
!> This function returns true if and only if the first character of the input StringToCheck matches on the of comment characters
!! nwtc_io::commchars.

!=======================================================================
!> This routine gets the name of the input file from the InArgth command-line argument, 
!! removes the extension if there is one, and appends OutExten to the end.

!=======================================================================
!> This routine performs a normal termination of the program.

!=======================================================================
!> This routine displays the expected command-line syntax for 
!!  most software developed at the NWTC.

!=======================================================================
!> This routine opens a binary input file.


!=======================================================================
!> This routine opens a binary output file with stream access,
!! implemented in standrad Fortran 2003.
!! Valid in gfortran 4.6.1 and IVF 10.1 and later

!=======================================================================
!> This routine opens a formatted output file for the echo file.


!=======================================================================
!> This routine opens a formatted input file.

!=======================================================================
!> This routine opens a formatted output file.

!=======================================================================
!> This routine opens a formatted output file and returns a flag telling if it already existed.

!=======================================================================
!> This routine opens a formatted output file in append mode if it exists, otherwise opens a new file


!=======================================================================
!>  This routine opens an unformatted input file of RecLen-byte data records
!!  stored in Big Endian format.


!=======================================================================
!>  This routine opens an unformatted input file.


!=======================================================================
!>  This routine opens an unformatted output file.

!=======================================================================
!> This subroutine prints the contents of the FileInfo data structure to the screen
!! This may be useful for diagnostic purposes.  this is written to unit U


!=======================================================================
!> This subroutine parses the specified line of text for AryLen CHARACTER values.
!! Generate an error message if the value is the wrong type.
!! Use ParseAry (nwtc_io::parseary) instead of directly calling a specific routine in the generic interface.   


!=======================================================================
!> This subroutine parses a comment line


!=======================================================================
!> This subroutine parses the specified line of text for two words.  One should be a
!! the name of a variable and the other the value of the variable.
!! Generate an error message if the value is the wrong type or if only one "word" is found.
!!
!! WARNING: This routine assumes the "words" containing the variable name and value are <= 20 characters. \n
!! Use ParseVar (nwtc_io::parsevar) instead of directly calling a specific routine in the generic interface.   


!=======================================================================
!> This subroutine parses the specified line of text for two words.  One should be a
!! the name of a variable and the other a value for the variable. If the variable is the
!! character string "DEFAULT", a default value will be used to set the variable.
!! Generate an error message if the value is the wrong type or if only one "word" is found.   
!!
!! WARNING: This routine assumes the "words" containing the variable name and value are <= 20 characters.
!! Use ParseVarWDefault (nwtc_io::parsevarwdefault) instead of directly calling a specific routine in the generic interface.   


!=======================================================================
!> This subroutine parses the specified line of text for AryLen REAL values.
!! Generate an error message if the value is the wrong type.
!! Use ParseAry (nwtc_io::parseary) instead of directly calling a specific routine in the generic interface.   


!=======================================================================
!> \copydoc nwtc_io::parsechvar


!=======================================================================
!> \copydoc nwtc_io::parsechvarwdefault


!=======================================================================
!> \copydoc nwtc_io::parsedbary


!=======================================================================
!> This subroutine parses the include information that occurs after a "@" when processing an input file.


!=======================================================================
!> \copydoc nwtc_io::parsechvar


!=======================================================================
!> \copydoc nwtc_io::parsechvarwdefault


!=======================================================================
!> \copydoc nwtc_io::parsedbary


!=======================================================================
!> \copydoc nwtc_io::parsechvar


!=======================================================================
!> \copydoc nwtc_io::parsechvarwdefault


!=======================================================================
!> \copydoc nwtc_io::parsedbary


!=======================================================================
!> \copydoc nwtc_io::parsechvar  


!=======================================================================
!> \copydoc nwtc_io::parsechvarwdefault


!=======================================================================
!> This routine determines if the given file name is absolute or relative.
!! We will consider an absolute path one that satisfies one of the
!! following four criteria:
!!     1. It contains ":/"
!!     2. It contains ":\"
!!     3. It starts with "/"
!!     4. It starts with "\"
!!   
!! All others are considered relative.

!=======================================================================
!> This routine prints out an end-of-file message and aborts the program.


!=======================================================================
!> The following takes an input file as a C_Char string with C_NULL_CHAR deliniating line endings


!=======================================================================


!=======================================================================
!> This routine calls ScanComFile (nwtc_io::scancomfile) and ReadComFile (nwtc_io::readcomfile) 
!! to move non-comments in a set of nested files starting with TopFile into the FileInfo (nwtc_io::fileinfo) structure.


!=======================================================================
!> This routine outputs fatal error messages and stops the program.


!=======================================================================
!> This routine pauses the program.

!=======================================================================
!> This routine outputs non-fatal warning messages and returns to the calling routine.
!! It beeps if ntwc_io::beep is true.

!=======================================================================
!> \copydoc nwtc_io::int2lstr

   FUNCTION R2LStr4 ( Num, Fmt_in )
      ! Function declaration.


   CHARACTER(15)                :: R2LStr4                                         ! This function.
   CHARACTER(*), OPTIONAL       :: Fmt_in
      ! Argument declarations.


   REAL(SiKi), INTENT(IN)       :: Num                                             ! The number to convert.
   CHARACTER(15)                :: Fmt                                             ! format for output
      ! Return a 0 if that's what we have.


   IF ( Num == 0.0_SiKi )  THEN
      R2LStr4 = '0'
      RETURN
   END IF
      ! Write the number into the string using G format and left justify it.


   if ( present( Fmt_in ) ) then
      Fmt = '('//Fmt_in//')'
   else
      Fmt = '(1PG15.5)'
   end if
      

   WRITE (R2LStr4,Fmt)  Num

   CALL AdjRealStr( R2LStr4 )


   RETURN
   END FUNCTION R2LStr4
!=======================================================================
!> \copydoc nwtc_io::int2lstr
   FUNCTION R2LStr8 ( Num, Fmt_in )
      ! Function declaration.


   CHARACTER(15)                :: R2LStr8                                         ! This function.
   CHARACTER(*), OPTIONAL       :: Fmt_in
      ! Argument declarations.


   REAL(R8Ki), INTENT(IN)       :: Num                                             ! The floating-point number to convert.
   CHARACTER(15)                :: Fmt                                             ! format for output
      ! Return a 0 if that's what we have.


   IF ( Num == 0.0_R8Ki )  THEN
      R2LStr8 = '0'
      RETURN
   END IF
      ! Write the number into the string using G format and left justify it.


   if ( present( Fmt_in ) ) then
      Fmt = '('//Fmt_in//')'
   else
      Fmt = '(1PG15.5)'
   end if

   WRITE (R2LStr8,Fmt)  Num

   CALL AdjRealStr( R2LStr8 )


   RETURN
   END FUNCTION R2LStr8
!======================================================================
!> This routine reads a AryLen values separated by whitespace (or other Fortran record delimiters such as commas) 
!!  into an array (either on same line or multiple lines).
!! Use ReadAry (nwtc_io::readary) instead of directly calling a specific routine in the generic interface.   


!======================================================================
!> This routine reads a AryLen values separated by whitespace (or other Fortran record delimiters such as commas) 
!!  into an array (either on same line or multiple lines) from an input string
!! Use ReadAry (nwtc_io::readary) instead of directly calling a specific routine in the generic interface.   


!=======================================================================
!> This routine reads a AryLen values into a real array from the next AryLen lines of the input file (one value per line).
!! Use ReadAryLines (nwtc_io::readarylines) instead of directly calling a specific routine in the generic interface.   


!=======================================================================
!> This routine reads a comment from the next line of the input file.


!=============================================================================
!> This routine opens and reads the contents of a file with comments and stores the good stuff in the FileInfo structure.
!! You need to call ScanComFile() first to count the number of lines and get the list of files in the recursive tree.
!! This information needs to be stored in the FileInfo structure before calling this routine.


!=======================================================================
!> This routine reads a variable from the next line of the input file.
!! Use ReadVar (nwtc_io::readvar) instead of directly calling a specific routine in the generic interface.   


!=======================================================================
!> This routine reads the contents of a FAST binary output file (FASTbinFile) and stores it in FASTdata.
!! It is assumed that the name of the binary file is preloaded into FASTdata%File by the calling procedure.


!=======================================================================
!> \copydoc nwtc_io::readcary


!> This routine reads a AryLen values separated by whitespace (or other Fortran record delimiters such as commas) 
!!  into an array (either on same line or multiple lines) from an input string
!! Use ReadAry (nwtc_io::readary) instead of directly calling a specific routine in the generic interface.   


!=======================================================================
!> \copydoc nwtc_io::readcvar
!! WARNING: this routine limits the size of the number being read to 30 characters   


!=======================================================================
!> This routine reads a scalar variable from the next line of the input file.
!! Use ReadVarWDefault (nwtc_io::readvarwdefault) instead of directly calling a specific routine in the generic interface.    
!! WARNING: this routine limits the size of the number being read to 30 characters   


!=======================================================================
!> This routine reads a logical variable from the next line of the input file.
!! Use ReadVarWDefault (nwtc_io::readvarwdefault) instead of directly calling a specific routine in the generic interface.    
!! WARNING: this routine limits the size of the number being read to 30 characters   


!=======================================================================
!> \copydoc nwtc_io::readcary


!=============================================================================
!> This routine reads a line from the specified input file and returns the non-comment
!! portion of the line.


!=======================================================================
!> \copydoc nwtc_io::readcvar


!=======================================================================
!> This routine reads a single word from a file and tests to see if it's a pure number (no true or false).


!=======================================================================
!> This routine reads up to MaxAryLen values from an input file and store them in CharAry(:).
!! These values represent the names of output channels, and they are specified in the format
!! required for OutList(:) in FAST input files.
!! The end of this list is specified with the line beginning with the 3 characters "END".


!=======================================================================
!> This routine reads up to MaxAryLen values from an input file and store them in CharAry(:).
!! These values represent the names of output channels, and they are specified in the format
!! required for OutList(:) in FAST input files.
!! The end of this list is specified with the line beginning with the 3 characters "END".


!=======================================================================
!> \copydoc nwtc_io::readcary


!======================================================================
!> This routine reads a AryLen values separated by whitespace (or other Fortran record delimiters such as commas) 
!!  into an array (either on same line or multiple lines) from an input string
!! Use ReadAry (nwtc_io::readary) instead of directly calling a specific routine in the generic interface.   


!=======================================================================
!> \copydoc nwtc_io::readcary


!======================================================================
!> This routine reads a AryLen values separated by whitespace (or other Fortran record delimiters such as commas) 
!!  into an array (either on same line or multiple lines) from an input string
!! Use ReadAry (nwtc_io::readary) instead of directly calling a specific routine in the generic interface.   


!=======================================================================
!> This routine reads a AryLen values separated by whitespace (or other Fortran record delimiters such as commas) 
!!  into an array (either on same line or multiple lines), or sets default values.
!! Use ReadAryWDefault (nwtc_io::readarywdefault) instead of directly calling a specific routine in the generic interface.   


!=======================================================================
!> \copydoc nwtc_io::readr4arywdefault   


!=======================================================================
!> \copydoc nwtc_io::readcarylines   


!=======================================================================
!> \copydoc nwtc_io::readcarylines   


!=======================================================================
!> \copydoc nwtc_io::readcvar
!! WARNING: this routine limits the size of the number being read to 30 characters   


!=======================================================================
!> \copydoc nwtc_io::readivarwdefault


!=======================================================================
!> \copydoc nwtc_io::readcvar
!! WARNING: this routine limits the size of the number being read to 30 characters   


!=======================================================================
!> \copydoc nwtc_io::readr4varwdefault


!=======================================================================
!> \copydoc nwtc_io::readr4varwdefault


!=======================================================================
!> This routine reads a string from the next line of the input file.


!=======================================================================   
!> This routine removes trailing C_NULL characters, which can be present when
!! passing strings between C and Fortran.

!=============================================================================
!> This routine opens and scans the contents of a file with comments counting non-comment lines.
!! If a line has "@Filename" on a line, it recursively scans that file to add the non-comment lines
!! to the total.
!! This routine is typically called before ReadComFile() (nwtc_io::readcomfile) to count the number on non-comment lines
!! that will need to be stored.
!! It also adds to a linked list of unique file names that are in the call chain.


!=======================================================================
!> This routine converts a string (character array) into an 
!! equivalent ASCII array of integers.
!! This routine is the inverse of the IntAry2Str() routine.


!=======================================================================
!> This routine pauses program executaion for a specified
!! number of seconds.

!=======================================================================
!> This subroutine opens a binary file named FileName, and writes a the AllOutData Matrix to a 16-bit packed 
!! binary file. A text DescStr is written to the file as well as the text in the ChanName and ChanUnit arrays.
!!  The file is closed at the end of this subroutine call (and on error). \n
!! NOTE: Developers may wish to inquire if the file can be opened at the start of a simulation to ensure that 
!!       it's available before running the simulation (i.e., don't run a code for a long time only to find out 
!!       that the file cannot be opened for writing).


!==================================================================================================================================
!> This routine writes out a string to the file connected to Unit without following it with a new line.

!=======================================================================
!> This routine writes all the values of a 1- or 2-dimensional array, A, 
!! of real numbers to unit Un, using ReFmt for each individual value
!! in the array. If MatName is present, it also preceeds the matrix
!! with "MatName" and the number of rows (dimension 1 of A) and columns (dimension 2 of A).
!! It is useful for debugging and/or writing summary files.
!! Use WrMatrix (nwtc_io::wrmatrix) instead of directly calling a specific routine in the generic interface.


!=======================================================================
!> \copydoc nwtc_io::wrmatrix1r4


!=======================================================================
!> \copydoc nwtc_io::wrmatrix1r4


!=======================================================================
!> \copydoc nwtc_io::wrmatrix1r4


!=======================================================================  
!> Based on nwtc_io::wrmatrix, this routine writes a matrix to an already-open text file. It allows
!! the user to omit rows and columns of A in the file.
!! Use WrPartialMatrix (nwtc_io::wrpartialmatrix) instead of directly calling a specific routine in the generic interface.


!=======================================================================  
!> \copydoc nwtc_io::wrpartialmatrix1r8


!=======================================================================  
!> This routine writes out a prompt to the screen without
!! following it with a new line, though a new line precedes it.

!=======================================================================
!> This routine writes out a real array to the file connected to Unit without following it with a new line.
!! Use WrNumAryFileNR (nwtc_io::wrnumaryfilenr) instead of directly calling a specific routine in the generic interface.   


!=======================================================================
!> This routine writes out an integer array to the file connected to Unit without following it with a new line.
!! Use WrNumAryFileNR (nwtc_io::wrnumaryfilenr) instead of directly calling a specific routine in the generic interface.   


!=======================================================================
!> \copydoc nwtc_io::wrr4aryfilenr


!=======================================================================
!> This routine writes out a string to the screen.


!=======================================================================
!> This routine writes out a string to the screen after a blank line.

   !----------------------------------------------------------------------------------------------------------------------------------
   !> Read a delimited file of float with one or multiple lines of header
   !! TODO: put me in a CSV.f90 file of the NWTC library
   !! TODO: automatic detection of number of columns for instance using ReadCAryFromStr
   !!       See also the quick and dirty check introduced to read blade files that don't have Buoyancy columns


   !----------------------------------------------------------------------------------------------------------------------------------
   !> Counts number of lines in a file, do not count last line if empty


      
END MODULE NWTC_IO