!KGEN-generated Fortran source file 
  
!Generated at : 2026-04-25 21:22:06 
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
!> This module contains numeric-type routines with non-system-specific logic and references.


!
!
!
!

MODULE NWTC_Num
!..................................................................................................................................
   
    USE nwtc_io 
    USE kgen_utils_mod
    USE tprof_mod, ONLY: tstart, tstop, tnull, tprnt 

    IMPLICIT NONE 
!=======================================================================
      ! Global numeric-related variables.


   REAL(ReKi)                                :: D2R                           !< Factor to convert degrees to radians
   REAL(ReKi)                                :: PiBy2                         !< Pi/2
   REAL(ReKi)                                :: R2D                           !< Factor to convert radians to degrees
   REAL(ReKi)                                :: TwoPi                         !< 2*Pi


   ! constants for kernel smoothing
   
   INTEGER, PARAMETER :: kernelType_EPANECHINIKOV = 1
   INTEGER, PARAMETER :: kernelType_QUARTIC       = 2
   INTEGER, PARAMETER :: kernelType_BIWEIGHT      = 3
   INTEGER, PARAMETER :: kernelType_TRIWEIGHT     = 4
   INTEGER, PARAMETER :: kernelType_TRICUBE       = 5
   INTEGER, PARAMETER :: kernelType_GAUSSIAN      = 6
      ! constants for output formats
   
!=======================================================================
      ! Create interfaces for generic routines that use specific routines.
      !> \copydoc nwtc_num::equalrealnos4()


   INTERFACE EqualRealNos
      MODULE PROCEDURE EqualRealNos4
      MODULE PROCEDURE EqualRealNos8
   END INTERFACE
      !> \copydoc nwtc_num::eulerconstructr4()


      !> \copydoc nwtc_num::eulerextractr4()
   


      !> \copydoc nwtc_num::fzero_r4()

   INTERFACE fZeros
      MODULE PROCEDURE fzero_r4
      MODULE PROCEDURE fzero_r8
   END INTERFACE
      !> \copydoc nwtc_num::taitbryanyxzextractr4()
      !! See nwtc_num::taitbryanyxzextractr4() for details on the algorithm


   

      !> \copydoc nwtc_num::outerproductr4


      !> \copydoc nwtc_num::cross_productr4()


      !> \copydoc nwtc_num::smllrottransd()
   

      !> \copydoc nwtc_num::getsmllrotangsd()


      !> \copydoc nwtc_num::zero2twopir4
  

      !> \copydoc nwtc_num::twonormr4
   

      !> \copydoc nwtc_num::tracer4
   

      !> \copydoc nwtc_num::dcm_expd
   

      !> \copydoc nwtc_num::dcm_logmapd
   

      !> \copydoc nwtc_num::dcm_setlogmapforinterpd


      !> \copydoc nwtc_num::eye2
   

      !> \copydoc nwtc_num::interpbincomp


      !> \copydoc nwtc_num::interpstpcomp4

   INTERFACE InterpStp
      MODULE PROCEDURE InterpStpComp4
      MODULE PROCEDURE InterpStpComp8
      MODULE PROCEDURE InterpStpReal4
      MODULE PROCEDURE InterpStpReal4_8
      MODULE PROCEDURE InterpStpReal8
   END INTERFACE
      !> \copydoc nwtc_num::interpstpmat4


      !> \copydoc nwtc_num::interparrayr4
   
   

      !> \copydoc nwtc_num::interpwrappedstpreal4


      !> \copydoc nwtc_num::locatestpr4
   

   !> \copydoc nwtc_num::skewsymmatr4


      !> \copydoc nwtc_num::angle_extrapinterp2_r4
   

      !> \copydoc nwtc_num::addorsub2pi_r4


      !> \copydoc nwtc_num::mpi2pi_r4
   

   PUBLIC kr_externs_in_nwtc_num 
   PUBLIC kr_externs_out_nwtc_num 
   
CONTAINS
!=======================================================================
!> This routine is used to convert NewAngle to an angle within Pi of
!!   OldAngle by adding or subtracting 2*Pi accordingly.  
!!   This routine is useful for converting
!!   angles returned from a call to the ATAN2() FUNCTION into angles that may
!!   exceed the -Pi to Pi limit of ATAN2().  For example, if the nacelle yaw
!!   angle was 179deg in the previous time step and the yaw angle increased
!!   by 2deg in the new time step, we want the new yaw angle returned from a
!!   call to the ATAN2() FUNCTION to be 181deg instead of -179deg.  This
!!   routine assumes that the angle change between calls is not more than
!!   Pi in absolute value.
!! Use AddOrSub2Pi (nwtc_num::addorsub2pi) instead of directly calling a specific routine in the generic interface.


!=======================================================================
!> \copydoc nwtc_num::addorsub2pi_r4

!=======================================================================

!=======================================================================
!> This routine sorts a list of real numbers. It uses the bubble sort algorithm,
!! which is only suitable for short lists.

!=======================================================================
!> This subroutine takes an "oldUnits" array, compares the strings
!! to a list of units that will be converted to SI, and returns two arrays
!! that give the new units and the multiplicative scaling factor to convert 
!! the old units to the new ones. The three arrays must be the same size.

!=======================================================================
!> This subroutine takes an "oldUnits" array, compares the strings
!! to a list of units that will be converted to engineering units (kN and deg), and returns two arrays
!! that give the new units and the multiplicative scaling factor to convert 
!! the old units to the new ones. The three arrays must be the same size.

!=======================================================================
!> This function computes the cross product of two 3-element arrays (resulting in a vector): \n
!! cross_product = Vector1 \f$\times\f$ Vector2 \n
!! Use cross_product (nwtc_num::cross_product) instead of directly calling a specific routine in the generic interface.

!=======================================================================
!> \copydoc nwtc_num::cross_productr4

!=======================================================================
!> \copydoc nwtc_num::cross_productr4

!=======================================================================
!> \copydoc nwtc_num::cross_productr4

!=======================================================================
!> This routine calculates the parameters needed to compute a irregularly-spaced natural cubic spline.
!! Natural cubic splines are used in that the curvature at the end points is zero.
!! This routine does not require that the XAry be regularly spaced.


!=======================================================================
!> This routine calculates the parameters needed to compute a irregularly-spaced natural cubic spline.
!! Natural cubic splines are used in that the curvature at the end points is zero.
!! This routine does not require that the XAry be regularly spaced.
!! This version of the routine works with multiple curves that share the same X values.


!=======================================================================
!> This routine calculates the parameters needed to compute a irregularly-spaced natural linear spline.      
!! This routine does not require that the XAry be regularly spaced.

!=======================================================================
!> This routine interpolates a pair of arrays using cubic splines to find the function value at X.
!! One must call cubicsplineinit first to compute the coefficients of the cubics.
!! This routine does not require that the XAry be regularly spaced.

!=======================================================================
!> This routine interpolates a pair of arrays using cubic splines to find the function value at X.
!! One must call cubicsplineinit first to compute the coefficients of the cubics.
!! This routine does not require that the XAry be regularly spaced.
!! This version of the routine works with multiple curves that share the same X values.

!=======================================================================         
!> This function returns the matrix exponential, \f$\Lambda = \exp(\lambda)\f$, of an input skew-symmetric matrix, \f$\lambda\f$.
!!
!! \f$\lambda\f$ is defined as:
!!
!! \f{equation}{  \lambda = \begin{bmatrix}
!!  0          &  \lambda_3 & -\lambda_2 \!!  -\lambda_3 &  0         &  \lambda_1 \!!   \lambda_2 & -\lambda_1 &  0          
!! 	\end{bmatrix}
!! \f}   
!! The angle of rotation for \f$\lambda\f$ is 
!! \f{equation}{ \theta = \sqrt{{\lambda_1}^2+{\lambda_2}^2+{\lambda_3}^2} \f}
!!
!! The matrix exponential is calculated as
!! \f{equation}{
!!  \Lambda = \exp(\lambda) = \left\{ \begin{matrix}
!!  I                                                                              &  \theta = 0 \!!  I + \frac{\sin\theta}{\theta}\lambda + \frac{1-\cos\theta}{\theta^2}\lambda^2  &  \theta > 0 
!!  \end{matrix}  \right.
!! \f}
!!
!! This routine is the inverse of DCM_logMap (nwtc_num::dcm_logmap). \n
!! Use DCM_exp (nwtc_num::dcm_exp) instead of directly calling a specific routine in the generic interface.   

!=======================================================================  
!> \copydoc nwtc_num::dcm_expd

!=======================================================================  
!> For any direction cosine matrix (DCM), \f$\Lambda\f$, this routine calculates the
!! logarithmic map, \f$\lambda\f$, which a skew-symmetric matrix:
!!
!! \f{equation}{
!! \lambda 
!! = \log( \Lambda )
!! = \begin{bmatrix}
!!       0          &  \lambda_3 & -\lambda_2 \!!      -\lambda_3  &  0         &  \lambda_1 \!!       \lambda_2 & -\lambda_1 &  0          
!! \end{bmatrix}
!! \f}
!! The angle of rotation for \f$\Lambda\f$ is
!! \f{equation}{
!! \theta= \begin{matrix} \cos^{-1}\left(\frac{1}{2}\left(\mathrm{trace}(\Lambda)-1\right)\right) & \theta \in \left[0,\pi\right]\end{matrix}
!! \f}
!! And the logarithmic map is
!! \f{equation}{
!!  \lambda = \left\{ \begin{matrix}
!! 0                                                             &  \theta = 0 \!! \frac{\theta}{2\sin\theta} \left( \Lambda - \Lambda^T\right)  &  \theta \in \left(0,\pi\right) \!! \pm\pi v  &  \theta = \pi 
!!  \end{matrix}  \right.
!! \f}
!! where \f$v\f$ is the skew-symmetric matrix associated with the unit-length eigenvector of \f$\Lambda\f$ associated with the eigenvalue 1.
!! However, this equation has numerical issues near \f$\theta = \pi\f$, so for \f$\theta > 3.1\f$  we instead implement
!! a separate equation to find lambda * sign(lambda(indx_max))
!! and use \f$\Lambda - \Lambda^T\f$ to choose the appropriate signs. 
!!   
!! This routine is the inverse of DCM_exp (nwtc_num::dcm_exp). \n
!! Use DCM_logMap (nwtc_num::dcm_logmap) instead of directly calling a specific routine in the generic interface. 


!=======================================================================
!> \copydoc nwtc_num::dcm_logmapd


!=======================================================================  
!> This routine sets the rotation parameters (logMap tensors from dcm_logmap)
!! so that they can be appropriately interpolated, based on
!! continunity of the neighborhood. The tensor input matrix has columns
!! of rotational parameters; one column for each set of values to be 
!! interpolated (i.e., for each column, i, tensor(:,i) is the returned logMap value from the routine dcm_logmap).
!!
!! This is based on the \f$2\pi\f$ periodicity of rotations: \n
!! if \f$\lambda\f$ is one solution to \f$\log(\Lambda)\f$, then so is 
!! \f$\lambda_k = \lambda \left( 1 + \frac{2k\pi}{\left\| \lambda \right\|}\right)\f$ for any integer k.  
!! 
!! Use DCM_SetLogMapForInterp (nwtc_num::dcm_setlogmapforinterp) instead of directly calling a specific routine in the generic interface. 


!=======================================================================         
!> \copydoc nwtc_num::dcm_setlogmapforinterpd


!=======================================================================     
!> This function compares two real numbers and determines if they
!! are "almost" equal, i.e. within some relative tolerance (basically ignoring the last 2 significant digits)
!! (see "Safe Comparisons" suggestion from http://www.lahey.com/float.htm)
!!
!! Note that the numbers are added together in this routine, so overflow can result if comparing two "huge" numbers. \n
!! Use EqualRealNos (nwtc_num::equalrealnos) instead of directly calling a specific routine in the generic interface. 
   PURE FUNCTION EqualRealNos4 ( ReNum1, ReNum2 )
      ! passed variables


   REAL(SiKi), INTENT(IN )         :: ReNum1                            !< the first  real number to compare
   REAL(SiKi), INTENT(IN )         :: ReNum2                            !< the second real number to compare

   LOGICAL                         :: EqualRealNos4                     !< .true. if and only if the numbers are almost equal
      ! local variables

   REAL(SiKi), PARAMETER           :: Eps = EPSILON(ReNum1)             ! machine precision
   REAL(SiKi), PARAMETER           :: Tol = 100.0_SiKi*Eps / 2.0_SiKi   ! absolute tolerance (ignore the last 2 significant digits)

   REAL(SiKi)                      :: Fraction
      ! make sure we're never trying to get more precision than Tol


   Fraction = MAX( ABS(ReNum1+ReNum2), 1.0_SiKi )
      ! determine if ReNum1 and ReNum2 are approximately equal


   IF ( ABS(ReNum1 - ReNum2) <= Fraction*Tol ) THEN  ! the relative error
      EqualRealNos4 = .TRUE.
   ELSE
      EqualRealNos4 = .FALSE.
   ENDIF


   END FUNCTION EqualRealNos4
!=======================================================================
!> \copydoc nwtc_num::equalrealnos4
   PURE FUNCTION EqualRealNos8 ( ReNum1, ReNum2 )
      ! passed variables


   REAL(R8Ki), INTENT(IN )         :: ReNum1                            ! the first  real number to compare
   REAL(R8Ki), INTENT(IN )         :: ReNum2                            ! the second real number to compare

   LOGICAL                         :: EqualRealNos8                     !< .true. if and only if the numbers are almost equal
      ! local variables

   REAL(R8Ki), PARAMETER           :: Eps = EPSILON(ReNum1)             ! machine precision
   REAL(R8Ki), PARAMETER           :: Tol = 100.0_R8Ki*Eps / 2.0_R8Ki   ! absolute tolerance (ignore the last 2 significant digits)

   REAL(R8Ki)                      :: Fraction
      ! make sure we're never trying to get more precision than Tol


   Fraction = MAX( ABS(ReNum1+ReNum2), 1.0_R8Ki )
      ! determine if ReNum1 and ReNum2 are approximately equal


   IF ( ABS(ReNum1 - ReNum2) <= Fraction*Tol ) THEN  ! the relative error
      EqualRealNos8 = .TRUE.
   ELSE
      EqualRealNos8 = .FALSE.
   ENDIF


   END FUNCTION EqualRealNos8
!=======================================================================
!> This function creates a rotation matrix, M, from a 3-2-1 intrinsic rotation
!! sequence of the 3 Tait-Bryan angles (1-2-3 extrinsic rotation), \f$\theta_x\f$, \f$\theta_y\f$, and \f$\theta_z\f$, in radians.
!! M represents a change of basis (from global to local coordinates; 
!! not a physical rotation of the body). It is the inverse of EulerExtract (nwtc_num::eulerextract).
!!
!! \f{eqnarray*}{   
!! M & = & R(\theta_z) R(\theta_y) R(\theta_x) \!!   & = & \begin{bmatrix}  \cos(\theta_z) & \sin(\theta_z) & 0 \!!                         -\sin(\theta_z) & \cos(\theta_z) & 0 \!!                           0      &  0      & 1 \end{bmatrix}
!!         \begin{bmatrix}  \cos(\theta_y) & 0 & -\sin(\theta_y) \!!                                0 & 1 & 0        \!!                          \sin(\theta_y) & 0 & \cos(\theta_y)  \end{bmatrix}
!!         \begin{bmatrix}   1 &  0       & 0       \!!                           0 &  \cos(\theta_x) & \sin(\theta_x) \!!                           0 & -\sin(\theta_x) & \cos(\theta_x) \end{bmatrix} \!!   & = & \begin{bmatrix}  
!!    \cos(\theta_y)\cos(\theta_z) &   \cos(\theta_x)\sin(\theta_z)+\sin(\theta_x)\sin(\theta_y)\cos(\theta_z) &
!!                                     \sin(\theta_x)\sin(\theta_z)-\cos(\theta_x)\sin(\theta_y)\cos(\theta_z) \!!    -\cos(\theta_y)\sin(\theta_z)  & \cos(\theta_x)\cos(\theta_z)-\sin(\theta_x)\sin(\theta_y)\sin(\theta_z) & 
!!                                     \sin(\theta_x)\cos(\theta_z)+\cos(\theta_x)\sin(\theta_y)\sin(\theta_z) \!!    \sin(\theta_y)                & -\sin(\theta_x)\cos(\theta_y) & \cos(\theta_x)\cos(\theta_y) \!!         \end{bmatrix}   
!! \f}
!! Use EulerConstruct (nwtc_num::eulerconstruct) instead of directly calling a specific routine in the generic interface. 

!=======================================================================
!> \copydoc nwtc_num::eulerconstructr4

!=======================================================================
!> if M is a rotation matrix from a 1-2-3 rotation sequence, this function returns 
!! the 3 Euler angles, \f$\theta_x\f$, \f$\theta_y\f$, and \f$\theta_z\f$ (in radians), that formed 
!! the matrix. M represents a change of basis (from global to local coordinates; 
!! not a physical rotation of the body). M is the inverse of EulerConstruct (nwtc_num::eulerconstruct).
!!
!! \f{eqnarray*}{   
!! M & = & R(\theta_z) R(\theta_y) R(\theta_x) \!!   & = & \begin{bmatrix}  \cos(\theta_z) & \sin(\theta_z) & 0 \!!                         -\sin(\theta_z) & \cos(\theta_z) & 0 \!!                           0      &  0      & 1 \end{bmatrix}
!!         \begin{bmatrix}  \cos(\theta_y) & 0 & -\sin(\theta_y) \!!                                0 & 1 & 0        \!!                          \sin(\theta_y) & 0 & \cos(\theta_y)  \end{bmatrix}
!!         \begin{bmatrix}   1 &  0       & 0       \!!                           0 &  \cos(\theta_x) & \sin(\theta_x) \!!                           0 & -\sin(\theta_x) & \cos(\theta_x) \end{bmatrix} \!!   & = & \begin{bmatrix}  
!!    \cos(\theta_y)\cos(\theta_z) &   \cos(\theta_x)\sin(\theta_z)+\sin(\theta_x)\sin(\theta_y)\cos(\theta_z) &
!!                                     \sin(\theta_x)\sin(\theta_z)-\cos(\theta_x)\sin(\theta_y)\cos(\theta_z) \!!    -\cos(\theta_y)\sin(\theta_z)  & \cos(\theta_x)\cos(\theta_z)-\sin(\theta_x)\sin(\theta_y)\sin(\theta_z) & 
!!                                     \sin(\theta_x)\cos(\theta_z)+\cos(\theta_x)\sin(\theta_y)\sin(\theta_z) \!!    \sin(\theta_y)                & -\sin(\theta_x)\cos(\theta_y) & \cos(\theta_x)\cos(\theta_y) \!!         \end{bmatrix}   
!! \f}
!! returned angles are in the range \f$\theta_x,\theta_y, \theta_z \in \left[ \pi, -\pi \right]\f$ \n
!! Use EulerExtract (nwtc_num::eulerextract)  instead of directly calling a specific routine in the generic interface. 

!=======================================================================
!> \copydoc nwtc_num::eulerextractr4 

!=======================================================================
!> 


!=======================================================================
!> 


!=======================================================================
!> 


!=======================================================================
!> 


!=======================================================================
!> This routine sets the matrices in the first two dimensions of A equal 
!! to the identity matrix (all zeros, with ones on the diagonal).
!! If the first two dimensions of A are not equal (i.e., matrix A(:,:,n)    
!! is non-square), this routine returns the pseudo-identity.  
!!
!! Use eye (nwtc_num::eye) instead of directly calling a specific routine in the generic interface. 


!=======================================================================
!> \copydoc nwtc_num::eye2 


!=======================================================================
!> \copybrief nwtc_num::eye2 


!=======================================================================
!> \copybrief nwtc_num::eye2 


!====================================================================================================


!=======================================================================
!> This routine uses the Gauss-Jordan elimination method for the
!!   solution of a given set of simultaneous linear equations.
!! NOTE: this routine works if no pivot points are zero and you
!!   don't want the eschelon or reduced eschelon form of the
!!   augmented matrix.  The form of the original augmented matrix
!!   IS preserved in this call.
!! This routine was originally in FAST.f90.
!! When AugMatIn = [ A b ], this routine returns the solution
!! vector x to the equation Ax = b.


!=======================================================================
!> Determine index of the point in Ary just below Val and the fractional distance to the next point in the array.
!! The elements of the array are assumed to be regularly spaced.


!=======================================================================
!   SUBROUTINE GetPermMat ( InpMat, PMat, ErrStat )
!      ! This subroutine computes a permutation matrix, PMat, for a given
!      ! input matrix, InpMat. It assumes that InpMat is of full rank
!      ! and for now, the matrices are 3 x 3.
!      ! passed variables
!   REAL(ReKi), INTENT(IN )         :: InpMat       (3,3)
!   REAL(ReKi), INTENT(OUT )        :: PMat         (3,3) !this could be integer, but we'll leave it real now
!   INTEGER,    INTENT(OUT )        :: ErrStat            ! a non-zero value indicates an error in the permutation matrix algorithm
!      ! local variables
!   INTEGER                         :: iCol               ! loop counter
!   INTEGER                         :: iRow               ! loop counter
!   INTEGER                         :: MaxCol             ! holds index of maximum value in a column
!   LOGICAL                         :: ChkCols     (3)    ! a check to make sure we have only one non-zero element per column
!      ! initialize some variables
!   PMat    = 0.0
!   ChkCols = .FALSE.
!   ErrStat = 0
!      ! find the pivots
!   DO iRow = 1,3
!      MaxCol = 1        ! initialize max index
!      DO iCol = 2,3
!         IF ( ABS(InpMat(iRow,iCol)) > ABS(InpMat(iRow,MaxCol)) ) &
!            MaxCol = iCol
!      END DO ! iCol
!      IF ( ChkCols(MaxCol) ) THEN   ! we can have only 1 non-zero entry per row and column, but we've just violated that!
!         CALL ProgAbort( ' Error in GetPermMat(): InpMat is not full rank.', TrapErrors = .TRUE. )
!         ErrStat = 1
!      END IF
!      PMat(MaxCol, iRow) = SIGN( 1.0_ReKi, InpMat(iRow,MaxCol) )  ! technically a permutation matrix would only have +1.0 (not -1.0)
!      ChkCols(MaxCol)    = .TRUE.
!   END DO ! iRow
!   RETURN
!   END SUBROUTINE GetPermMat ! ( InpMat, PMat, ErrStat )
!=======================================================================
!> This subroutine computes the angles that make up the input direction cosine matrix, DCMat,
!! assuming small angles. It is the inverse of SmllRotTrans (nwtc_num::smllrottrans). \n
!! Use GetSmllRotAngs (nwtc_num::getsmllrotangs) instead of directly calling a specific routine in the generic interface. 
!=======================================================================
!
!
!
!
!
!
!
!
!
!
!
!


!=======================================================================
!> \copydoc nwtc_num::getsmllrotangsd 


!=======================================================================
!> This function returns the non-dimensional (-1:+1) location of the given Gauss-Legendre Quadrature point and its weight.
!! It works for NPts \f$\in \left[{1,6\right]\f$.
!! The values came from Carnahan, Brice; Luther, H.A.; Wilkes, James O.  (1969)  "Applied Numerical Methods."


!=======================================================================
!> This function returns an integer index such that CAry(IndexCharAry) = CVal. If
!! no element in the array matches CVal, the value -1 is returned.  The routine
!! performs a binary search on the input array to determine if CVal is an
!! element of the array; thus, CAry must be sorted and stored in increasing
!! alphebetical (ASCII) order. The routine does not check that the array is
!! sorted.  The routine assumes that CVal is type CHARACTER and CAry
!! is an array of CHARACTERS.

!=======================================================================
!> This function returns a y-value that corresponds to an input x-value by interpolating into the arrays.
!! It uses a binary interpolation scheme that takes about log(AryLen) / log(2) steps to converge.
!! It returns the first or last YAry() value if XVal is outside the limits of XAry(). 
!!
!! Use InterpBin (nwtc_num::interpbin) instead of directly calling a specific routine in the generic interface. 


!=======================================================================
!> \copydoc nwtc_num::interpbincomp


!=======================================================================
!> This function returns a y-value that corresponds to an input x-value by interpolating into the arrays.
!! It uses the passed index as the starting point and does a stepwise interpolation from there. This is
!! especially useful when the calling routines save the value from the last time this routine was called
!! for a given case where XVal does not change much from call to call. When there is no correlation
!! from one interpolation to another, InterpBin() (nwtc_num::interpbin) may be a better choice.
!! It returns the first or last YAry() value if XVal is outside the limits of XAry().
!!
!! Use InterpStp (nwtc_num::interpstp) instead of directly calling a specific routine in the generic interface. 
   FUNCTION InterpStpComp4( XVal, XAry, YAry, Ind, AryLen )
      ! Function declaration.


   COMPLEX(SiKi)                :: InterpStpComp4                                  ! The interpolated value of Y at XVal
      ! Argument declarations.


   INTEGER, INTENT(IN)          :: AryLen                                          !< Length of the arrays.
   INTEGER, INTENT(INOUT)       :: Ind                                             !< Initial and final index into the arrays.

   REAL(SiKi), INTENT(IN)       :: XAry    (AryLen)                                !< Array of X values to be interpolated.
   REAL(SiKi), INTENT(IN)       :: XVal                                            !< X value to be interpolated.

   COMPLEX(SiKi), INTENT(IN)    :: YAry    (AryLen)                                !< Array of Y values to be interpolated.
      ! Let's check the limits first.


   IF ( XVal <= XAry(1) )  THEN
      InterpStpComp4 = YAry(1)
      Ind            = 1
      RETURN
   ELSE IF ( XVal >= XAry(AryLen) )  THEN
      InterpStpComp4 = YAry(AryLen)
      Ind            = MAX(AryLen - 1, 1)
      RETURN
   END IF
     ! Let's interpolate!


   Ind = MAX( MIN( Ind, AryLen-1 ), 1 )

   DO

      IF ( XVal < XAry(Ind) )  THEN

         Ind = Ind - 1

      ELSE IF ( XVal >= XAry(Ind+1) )  THEN

         Ind = Ind + 1

      ELSE

         InterpStpComp4 = ( YAry(Ind+1) - YAry(Ind) )*( XVal - XAry(Ind) )/( XAry(Ind+1) - XAry(Ind) ) + YAry(Ind)
         RETURN

      END IF

   END DO


   RETURN
   END FUNCTION InterpStpComp4
!=======================================================================
!> \copydoc nwtc_num::interpstpcomp4
   FUNCTION InterpStpComp8( XVal, XAry, YAry, Ind, AryLen )
      ! Function declaration.


   COMPLEX(R8Ki)                :: InterpStpComp8                                  !< The interpolated value of Y at XVal
      ! Argument declarations.


   INTEGER, INTENT(IN)          :: AryLen                                          !< Length of the arrays.
   INTEGER, INTENT(INOUT)       :: Ind                                             !< Initial and final index into the arrays.

   REAL(R8Ki), INTENT(IN)       :: XAry    (AryLen)                                !< Array of X values to be interpolated.
   REAL(R8Ki), INTENT(IN)       :: XVal                                            !< X value to be interpolated.

   COMPLEX(R8Ki), INTENT(IN)    :: YAry    (AryLen)                                !< Array of Y values to be interpolated.
      ! Let's check the limits first.


   IF ( XVal <= XAry(1) )  THEN
      InterpStpComp8 = YAry(1)
      Ind            = 1
      RETURN
   ELSE IF ( XVal >= XAry(AryLen) )  THEN
      InterpStpComp8 = YAry(AryLen)
      Ind            = MAX(AryLen - 1, 1)
      RETURN
   END IF
     ! Let's interpolate!


   Ind = MAX( MIN( Ind, AryLen-1 ), 1 )

   DO

      IF ( XVal < XAry(Ind) )  THEN

         Ind = Ind - 1

      ELSE IF ( XVal >= XAry(Ind+1) )  THEN

         Ind = Ind + 1

      ELSE

         InterpStpComp8 = ( YAry(Ind+1) - YAry(Ind) )*( XVal - XAry(Ind) )/( XAry(Ind+1) - XAry(Ind) ) + YAry(Ind)
         RETURN

      END IF

   END DO


   RETURN
   END FUNCTION InterpStpComp8
!=======================================================================
!> Routine to interpolate and/or extrapolate
   FUNCTION InterpExtrapStp( XVal, XAry, YAry, Ind, AryLen ) RESULT(InterpExtrap)
      ! Function declaration.


   REAL(ReKi)                   :: InterpExtrap                                     !< The interpolated or extrapolated value of Y at XVal
      ! Argument declarations.


   INTEGER, INTENT(IN)          :: AryLen                                          ! Length of the arrays.
   INTEGER, INTENT(INOUT)       :: Ind                                             ! Initial and final index into the arrays.

   REAL(ReKi), INTENT(IN)       :: XAry    (AryLen)                                ! Array of X values to be interpolated.
   REAL(ReKi), INTENT(IN)       :: XVal                                            ! X value to be interpolated.
   REAL(ReKi), INTENT(IN)       :: YAry    (AryLen)                                ! Array of Y values to be interpolated.
      ! Let's check the limits first.


   IF (AryLen < 2) THEN
      Ind = 1
      InterpExtrap = YAry(1)
      RETURN
   END IF
   
   IF ( XVal <= XAry(1) )  THEN
      Ind            = 1
      InterpExtrap = GetLinearVal()  ! extrapolate (using slope of x(1) and x(2))
      RETURN
   ELSE IF ( XVal >= XAry(AryLen) )  THEN
      Ind            = MAX(AryLen - 1, 1)
      InterpExtrap = GetLinearVal()  ! extrapolate (using slope of x(AryLen-1) and x(AryLen))
      RETURN
   END IF
     ! Let's interpolate!


   Ind = MAX( MIN( Ind, AryLen-1 ), 1 )

   DO

      IF ( XVal < XAry(Ind) )  THEN

         Ind = Ind - 1

      ELSE IF ( XVal >= XAry(Ind+1) )  THEN

         Ind = Ind + 1

      ELSE

         InterpExtrap = GetLinearVal()
         RETURN

      END IF

   END DO


   RETURN
   
   contains
      real(ReKi) function GetLinearVal()
         GetLinearVal = ( YAry(Ind+1) - YAry(Ind) )*( XVal - XAry(Ind) )/( XAry(Ind+1) - XAry(Ind) ) + YAry(Ind)
      end function GetLinearVal
   END FUNCTION InterpExtrapStp
!=======================================================================
!> \copydoc nwtc_num::interpstpcomp4
   FUNCTION InterpStpReal4( XVal, XAry, YAry, Ind, AryLen )
      ! Function declaration.


   REAL(SiKi)                   :: InterpStpReal4                                  !< The interpolated value of Y at XVal
      ! Argument declarations.


   INTEGER, INTENT(IN)          :: AryLen                                          ! Length of the arrays.
   INTEGER, INTENT(INOUT)       :: Ind                                             ! Initial and final index into the arrays.

   REAL(SiKi), INTENT(IN)       :: XAry    (AryLen)                                ! Array of X values to be interpolated.
   REAL(SiKi), INTENT(IN)       :: XVal                                            ! X value to be interpolated.
   REAL(SiKi), INTENT(IN)       :: YAry    (AryLen)                                ! Array of Y values to be interpolated.
      ! Let's check the limits first.


   IF ( XVal <= XAry(1) )  THEN
      InterpStpReal4 = YAry(1)
      Ind            = 1
      RETURN
   ELSE IF ( XVal >= XAry(AryLen) )  THEN
      InterpStpReal4 = YAry(AryLen)
      Ind            = MAX(AryLen - 1, 1)
      RETURN
   END IF
     ! Let's interpolate!


   Ind = MAX( MIN( Ind, AryLen-1 ), 1 )

   DO

      IF ( XVal < XAry(Ind) )  THEN

         Ind = Ind - 1

      ELSE IF ( XVal >= XAry(Ind+1) )  THEN

         Ind = Ind + 1

      ELSE

         InterpStpReal4 = ( YAry(Ind+1) - YAry(Ind) )*( XVal - XAry(Ind) )/( XAry(Ind+1) - XAry(Ind) ) + YAry(Ind)
         RETURN

      END IF

   END DO


   RETURN
   END FUNCTION InterpStpReal4
!=======================================================================
!> \copydoc nwtc_num::interpstpcomp4
   FUNCTION InterpStpReal4_8( XVal, XAry, YAry, Ind, AryLen )
      ! Function declaration.


   REAL(R8Ki)                   :: InterpStpReal4_8                                !< The interpolated value of Y at XVal
      ! Argument declarations.


   INTEGER, INTENT(IN)          :: AryLen                                          ! Length of the arrays.
   INTEGER, INTENT(INOUT)       :: Ind                                             ! Initial and final index into the arrays.

   REAL(SiKi), INTENT(IN)       :: XAry    (AryLen)                                ! Array of X values to be interpolated.
   REAL(SiKi), INTENT(IN)       :: XVal                                            ! X value to be interpolated.
   REAL(R8Ki), INTENT(IN)       :: YAry    (AryLen)                                ! Array of Y values to be interpolated.
      ! Let's check the limits first.


   IF ( XVal <= XAry(1) )  THEN
      InterpStpReal4_8 = YAry(1)
      Ind            = 1
      RETURN
   ELSE IF ( XVal >= XAry(AryLen) )  THEN
      InterpStpReal4_8 = YAry(AryLen)
      Ind            = MAX(AryLen - 1, 1)
      RETURN
   END IF
     ! Let's interpolate!


   Ind = MAX( MIN( Ind, AryLen-1 ), 1 )

   DO

      IF ( XVal < XAry(Ind) )  THEN

         Ind = Ind - 1

      ELSE IF ( XVal >= XAry(Ind+1) )  THEN

         Ind = Ind + 1

      ELSE

         InterpStpReal4_8 = ( YAry(Ind+1) - YAry(Ind) )*( XVal - XAry(Ind) )/( XAry(Ind+1) - XAry(Ind) ) + YAry(Ind)
         RETURN

      END IF

   END DO


   RETURN
   END FUNCTION InterpStpReal4_8 
!=======================================================================
!> \copydoc nwtc_num::interpstpcomp4
   FUNCTION InterpStpReal8( XVal, XAry, YAry, Ind, AryLen )
      ! Function declaration.


   REAL(R8Ki)                   :: InterpStpReal8                                  !< The interpolated value of Y at XVal
      ! Argument declarations.


   INTEGER, INTENT(IN)          :: AryLen                                          ! Length of the arrays.
   INTEGER, INTENT(INOUT)       :: Ind                                             ! Initial and final index into the arrays.

   REAL(R8Ki), INTENT(IN)       :: XAry    (AryLen)                                ! Array of X values to be interpolated.
   REAL(R8Ki), INTENT(IN)       :: XVal                                            ! X value to be interpolated.
   REAL(R8Ki), INTENT(IN)       :: YAry    (AryLen)                                ! Array of Y values to be interpolated.
      ! Let's check the limits first.


   IF ( XVal <= XAry(1) )  THEN
      InterpStpReal8 = YAry(1)
      Ind            = 1
      RETURN
   ELSE IF ( XVal >= XAry(AryLen) )  THEN
      InterpStpReal8 = YAry(AryLen)
      Ind            = MAX(AryLen - 1, 1)
      RETURN
   END IF
     ! Let's interpolate!


   Ind = MAX( MIN( Ind, AryLen-1 ), 1 )

   DO

      IF ( XVal < XAry(Ind) )  THEN

         Ind = Ind - 1

      ELSE IF ( XVal >= XAry(Ind+1) )  THEN

         Ind = Ind + 1

      ELSE

         InterpStpReal8 = ( YAry(Ind+1) - YAry(Ind) )*( XVal - XAry(Ind) )/( XAry(Ind+1) - XAry(Ind) ) + YAry(Ind)
         RETURN

      END IF

   END DO


   RETURN
   END FUNCTION InterpStpReal8 
!=======================================================================
!> This function returns a y-value array that corresponds to an input x-value by interpolating into the arrays.
!! It uses the passed index as the starting point and does a stepwise interpolation from there. This is
!! especially useful when the calling routines save the value from the last time this routine was called
!! for a given case where XVal does not change much from call to call. 
!! It returns the first or last Y() row value if XVal is outside the limits of XAry().


!=======================================================================
!> This function returns a y-value array that corresponds to an input x-value by interpolating into the arrays.
!! It uses the passed index as the starting point and does a stepwise interpolation from there. This is
!! especially useful when the calling routines save the value from the last time this routine was called
!! for a given case where XVal does not change much from call to call. 
!! It returns the first or last Y() row value if XVal is outside the limits of XAry().


!=======================================================================
!----------------------------------------------------------------------------------------------------------------------------------
!> Perform linear interpolation of an array, where first column is assumed to be ascending time values
!! Similar to InterpStpMat, I think (to check), interpTimeValues=InterpStpMat( array(:,1), time, array(:,1:), iLast, AryLen, values )
!! First value is used for times before, and last value is used for time beyond


!=======================================================================   
!< This routine linearly interpolates Dataset. It is
!! set for a 2-d interpolation on x and y of the input point.
!! x and y must be in increasing order. Each dimension may contain only 1 value.
!! The method is described in this paper: 
!!   http://www.colorado.edu/engineering/CAS/courses.d/AFEM.d/AFEM.Ch11.d/AFEM.Ch11.pdf


!=======================================================================
!< This routine linearly interpolates Dataset. It is set for a 3-d 
!! interpolation on x and y of the input point. x, y, and z must be 
!! in increasing order. Each dimension may contain only 1 value.
!! The method is described in this paper: 
!!   http://www.colorado.edu/engineering/CAS/courses.d/AFEM.d/AFEM.Ch11.d/AFEM.Ch11.pdf

!=======================================================================
!> This function returns a y-value that corresponds to an input x-value which is wrapped back
!! into the range [0-XAry(AryLen)] by interpolating into the arrays.  
!! It is assumed that XAry is sorted in ascending order.
!! It uses the passed index as the starting point and does a stepwise interpolation from there.  This is
!! especially useful when the calling routines save the value from the last time this routine was called
!! for a given case where XVal does not change much from call to call.  When there is no correlation
!! from one interpolation to another, InterpBin() may be a better choice.
!! It returns the first or last YAry() value if XVal is outside the limits of XAry().
!!
!! Use InterpWrappedStpReal (nwtc_num::interpwrappedstpreal) instead of directly calling a specific routine in the generic interface. 

!=======================================================================
!> \copydoc nwtc_num::interpwrappedstpreal4

!=======================================================================
!> \copydoc nwtc_num::interpwrappedstpreal4

!=======================================================================
!> This subroutine calculates interpolated values for an array of input values.
!! The size of the xknown and yknown arrays must match, and the size of the
!! xnew and ynew arrays must match. Xknown must be in ascending order.
!! Values outside the range of xknown are fixed to the end points.


!=======================================================================
!> \copydoc nwtc_num::interparrayr4


!=======================================================================
!> This subroutine calculates the iosparametric coordinates, isopc, which is a value between -1 and 1 
!! (for each dimension of a dataset), indicating where InCoord falls between posLo and posHi.
!! It is used in InterpStpReal2D (nwtcnum::interpstpreal2d) and InterpStpReal3D (nwtcnum::interpstpreal3d).

!=======================================================================   
!> This function returns a logical TRUE/FALSE value that indicates
!! if the given (2-dimensional) matrix, A, is symmetric. If A is not
!! square it returns FALSE.


!=======================================================================
!> KERNELSMOOTHING Kernel smoothing of vector data
!!
!!   fNew = kernelSmoothing( x, f, KERNELTYPE, RADIUS ) generates a smoothed
!!   version of the data f(x) in fNew.  Supported KERNELTYPE values are
!!   'EPANECHINIKOV', 'QUARTIC' or 'BIWEIGHT', 'TRIWEIGHT', 'TRICUBE' and
!!   'GAUSSIAN'.  RADIUS controls the width of the kernel relative to the
!!   vector x.
!!
!!   See also: https://en.wikipedia.org/wiki/Kernel_(statistics)#Kernel_functions_in_common_use
subroutine kernelSmoothing(x, f, kernelType, radius, fNew)

   REAL(ReKi),             INTENT(in   ) :: x(:)         !> independent axis
   REAL(ReKi),             INTENT(in   ) :: f(:)         !> function values, f(x), to be smoothed
   INTEGER,                INTENT(in   ) :: kernelType   !> what kind of smoothing function to use
   REAL(ReKi),             INTENT(in   ) :: radius       !> width of the "window", in the units of x
   REAL(ReKi),             INTENT(  out) :: fNew(:)      !> smoothed function values
   
   REAL(ReKi)                            :: k
   REAL(ReKi)                            :: k_sum
   REAL(ReKi)                            :: w
   REAL(ReKi)                            :: RadiusFix
   INTEGER(IntKi)                        :: Exp1
   INTEGER(IntKi)                        :: Exp2
   REAL(ReKi)                            :: u(size(x))
   INTEGER                               :: i, j
   INTEGER                               :: n
   ! check that size(x) = size(f)=size(fNew)
   ! check that kernelType is a valid number
   
   
   n = size(x)
   RadiusFix = max(abs(radius),epsilon(radius)) ! ensure radius is a positive number
   ! make sure that the value of u is in [-1 and 1] for these kernels:
   
   
   if (kernelType /= kernelType_GAUSSIAN) then

      select case ( kernelType )
         case (kernelType_EPANECHINIKOV)
            w = 3.0_ReKi/4.0_ReKi
            Exp1 = 2
            Exp2 = 1
         case (kernelType_QUARTIC, kernelType_BIWEIGHT)
            w = 15.0_ReKi/16.0_ReKi
            Exp1 = 2
            Exp2 = 2
         case (kernelType_TRIWEIGHT)
            w = 35.0_ReKi/32.0_ReKi
            Exp1 = 2
            Exp2 = 3
         case (kernelType_TRICUBE)
            w = 70.0_ReKi/81.0_ReKi
            Exp1 = 3
            Exp2 = 3
      end select
         
      fNew = 0.0_ReKi ! whole array operation
      do j=1,n ! for each value in f:
      
         u = (x - x(j)) / RadiusFix ! whole array operation
         do i=1,n
            u(i) = min( 1.0_ReKi, max( -1.0_ReKi, u(i) ) )
         end do
         
         k_sum   = 0.0_ReKi
         do i=1,n
            k = w*(1.0_ReKi-abs(u(i))**Exp1)**Exp2;
            k_sum = k_sum + k
            fNew(j) = fNew(j) + k*f(i)
         end do
         if (k_sum > 0.0_ReKi) then
            fNew(j) = fNew(j) / k_sum
         end if
         
      end do ! j (each output value)
      
   else ! kernelType_GAUSSIAN
      w = 1.0_ReKi/sqrt(TwoPi)
      
      fNew = 0.0_ReKi ! whole array operation
      do j=1,n ! for each value in f:
      
         u = (x - x(j)) / RadiusFix ! whole array operation
      
         k_sum   = 0.0_ReKi
         do i=1,n
            k = w*exp(-0.5*u(i)**2);
            k_sum = k_sum + k
            fNew(j) = fNew(j) + k*f(i)
         end do
         if (k_sum > 0.0_ReKi) then
            fNew(j) = fNew(j) / k_sum
         end if
         
      end do ! j (each output value)
      
   end if

end subroutine kernelSmoothing
!=======================================================================
!> This subroutine finds the lower-bound index of an input x-value located in an array.
!! On return, Ind has a value such that
!!           XAry(Ind) <= XVal < XAry(Ind+1), with the exceptions that
!!             Ind = 0 when XVal < XAry(1), and
!!          Ind = AryLen when XAry(AryLen) <= XVal.
!!
!! It uses a binary interpolation scheme that takes about log(AryLen)/log(2) steps to converge.
!! If the index doesn't change much between calls, LocateStp() (nwtc_num::locatestp) may be a better option.

!=======================================================================
!> This subroutine finds the lower-bound index of an input x-value located in an array.
!! On return, Ind has a value such that
!!           XAry(Ind) <= XVal < XAry(Ind+1), with the exceptions that
!!             Ind = 0 when XVal < XAry(1), and
!!          Ind = AryLen when XAry(AryLen) <= XVal.
!!
!! It uses the passed index as the starting point and does a stepwise search from there.  This is
!! especially useful when the calling routines save the value from the last time this routine was called
!! for a given case where XVal does not change much from call to call.  When there is no correlation
!! from one interpolation to another, a binary search may be a better choice (see nwtc_num::locatebin).
!!
!! Use LocateStp (nwtc_num::locatestp) instead of directly calling a specific routine in the generic interface.    

!=======================================================================
!> \copydoc nwtc_num::locatestpr4

!=======================================================================
!> This routine calculates the mean value of an array.

!=======================================================================
!> This routine is used to convert Angle to an equivalent value
!!  between \f$-\pi\f$ and \f$pi\f$.
!!
!! Use MPi2Pi (nwtc_num::mpi2pi) instead of directly calling a specific routine in the generic interface.

!=======================================================================
!> \copydoc nwtc_num::mpi2pi_r4

!=======================================================================
!> This function takes an angle in radians and converts it to 
!! an angle in degrees in the range [-180,180]

!=======================================================================
!> This routine calculates the outer product of two vectors, 
!! \f$u = \left(u_1, u_2, \ldots, u_m\right)\f$ and 
!! \f$v = \left(v_1, v_2, \ldots ,v_n\right)\f$. The outer product is defined as
!! \f{equation}{
!!   A = u \otimes v = \begin{bmatrix}
!!   u_1 v_1 & u_1 v_2 & \dots  & u_1 v_n \!!   u_2 v_1 & u_2 v_2 & \dots  & u_2 v_n \!!    \vdots & \vdots  & \ddots & \vdots \!!   u_m v_1 & u_m v_2 & \dots  & u_m v_n
!!   \end{bmatrix}  
!! \f}   
!!
!! Use OuterProduct (nwtc_num::outerproduct) instead of directly calling a specific routine in the generic interface.    
   

!=======================================================================
!> \copydoc nwtc_num::outerproductr4

!=======================================================================
!> This subroutine perturbs an orientation matrix by a small angle.  Two methods
!! are used:
!!    small angle DCM:  perturb small angles extracted from DCM
!!    large angle DCM:  multiply input DCM with DCM created with small angle
!!                      perturbations
!! NOTE1: this routine originally used logarithmic mapping for small angle
!!          perturbations
!! NOTE2: all warnings from SmllRotTrans are ignored.
!! NOTE3: notice no checks are made to verify correct set of inputs given
!!          one of the follwing combinations must be provided (others truly
!!          optional):
!!             Perturbations
!!             Perturbation + AngleDim


!=======================================================================
!> This routine factors the number N into its primes. If any of those
!! prime factors is greater than the NumPrimes'th prime, a value of 1
!! is added to N and the new number is factored.  This process is 
!! repeated until no prime factors are greater than the NumPrimes'th 
!! prime.
!!
!! If subract is .true., we will subtract 1 from the value of N instead
!! of adding it.


!=======================================================================  
!> This function computes the conjugate of a quaternion, q

!=======================================================================  
!> This function computes the 2-norm of a quaternion, q

!=======================================================================  
!> This function computes the quaternion, q, raised to an arbitrary
!! real exponent, alpha.

!=======================================================================  
!> This function computes the product of two quaternions, p and q

!=======================================================================  
!> This function converts a quaternion to an equivalent direction cosine matrix.

!=======================================================================  
!> This function converts a direction cosine matrix to an equivalent quaternion.

!=======================================================================         
!> This function computes the interpolated quaternion at time
!! t1 + s*(t2-t1) and s is in [0,1]

!=======================================================================
!> This routine calculates the parameters needed to compute a regularly-spaced natural cubic spline.
!! Natural cubic splines are used in that the curvature at the end points is zero.
!! It assumes the XAry values are equally spaced for speed. If you have multiple curves that share the 
!! same value, use RegCubicSplineInitM (nwtc_num::regcubicsplineinitm) instead of calling this routine multiple times.


!=======================================================================
!> This routine calculates the parameters needed to compute a regularly-spaced natural cubic spline.
!! Natural cubic splines are used in that the curvature at the end points is zero.
!! It assumes the XAry values are equally spaced for speed.
!! This version of the routine works with multiple curves that share the same X values.


!=======================================================================
!> This routine interpolates a pair of arrays using cubic splines to find the function value at X.
!! One must call RegCubicSplineInit() (nwtc_num::regcubicsplineinit) first to compute the coefficients of the cubics.
!! This routine requires that the XAry be regularly spaced, which improves performance.

!=======================================================================
!> This routine interpolates a pair of arrays using cubic splines to find the function value at X.
!! One must call RegCubicSplineInitM() (nwtc_num::regcubicsplineinitm) first to compute the coefficients of the cubics.
!! This routine requires that the XAry be regularly spaced, which improves performance.
!! This version of the routine works with multiple curves that share the same X values.


!=======================================================================
!> This routine is used to integrate function f over the interval [a, b]. This routine
!! is useful for sufficiently smooth (e.g., analytic) integrands, integrated over
!! intervals which contain no singularities, and where the endpoints are also nonsingular.
!!
!! f is an external function. For example f(x) = 1 + x.
!!
!!   FUNCTION f(x)
!!      USE PRECISION
!!      IMPLICIT NONE
!!
!!      REAL(ReKi) f
!!      REAL(ReKi) x
!!
!!      f = 1 + x
!!
!!      RETURN
!!   END FUNCTION f


!=======================================================================
!> This routine displays a message that gives that status of the simulation and the predicted end time of day.
!! It is intended to be used with SimStatus (nwtc_num::simstatus) and SimStatus_FirstTime (nwtc_num::simstatus_firsttime).


!=======================================================================   
!> this routine takes angles (in radians) and converts them to appropriate
!! ranges so they can be interpolated appropriately
!! (i.e., interpolating between pi+.1 and -pi should give pi+0.5 
!! instead of of 0.05 radians, so we return the angles pi+.1 and -pi+2pi=pi
!! we assume the interpolation occurs in the second dimension of angles
!! and it is done for each angle in the first dimension


!=======================================================================
!> This routine computes numeric constants stored in the NWTC Library

!=======================================================================   
!> This routine displays a message that gives that status of the simulation.
!! It is intended to be used with RunTimes (nwtc_num::runtimes) and SimStatus (nwtc_num::simstatus).


!=======================================================================
!> This routine displays a message that gives that status of the simulation and the predicted end time of day.
!! It is intended to be used with RunTimes (nwtc_num::runtimes) and SimStatus_FirstTime (nwtc_num::simstatus_firsttime).


!=======================================================================
!>  This routine computes the 3x3 transformation matrix, \f$TransMat\f$,
!!   to a coordinate system \f$x\f$ (with orthogonal axes \f$x_1, x_2, x_3\f$)
!!   resulting from three rotations (\f$\theta_1\f$, \f$\theta_2\f$, \f$\theta_3\f$) about the
!!   orthogonal axes (\f$X_1, X_2, X_3\f$) of coordinate system \f$X\f$.  All angles
!!   are assummed to be small, as such, the order of rotations does
!!   not matter and Euler angles do not need to be used.  This routine
!!   is used to compute the transformation matrix (\f$TransMat\f$) between
!!   undeflected (\f$X\f$) and deflected (\f$x\f$) coordinate systems.  In matrix
!!   form:
!! \f{equation}{   
!!   \left\{ \begin{matrix} x_1 \\ x_2 \\ x_3 \end{matrix} \right\} =
!!   \left[ TransMat(\theta_1, \theta_2, \theta_3) \right]
!!   \left\{ \begin{matrix} X_1 \\ X_2 \\ X_3 \end{matrix} \right\}   
!! \f}
!!
!! The transformation matrix, \f$TransMat\f$, is the closest orthonormal
!!   matrix to the nonorthonormal, but skew-symmetric, Bernoulli-Euler
!!   matrix:
!! \f{equation}{   A =
!!   \begin{bmatrix}    1      &  \theta_3 & -\theta_2 \!!                   -\theta_3 &  1        &  \theta_1 \!!                    \theta_2 & -\theta_1 &  1 \end{bmatrix}   
!! \f}
!!   In the Frobenius Norm sense, the closest orthornormal matrix is:
!!      \f$TransMat = U V^T\f$,
!!   where the columns of \f$U\f$ contain the eigenvectors of\f$ AA^T\f$ and the
!!   columns of \f$V\f$ contain the eigenvectors of \f$A^TA\f$ (note that \f$^T\f$ = transpose).
!!   This result comes directly from the Singular Value Decomposition
!!   (SVD) of \f$A = USV^T\f$ where \f$S\f$ is a diagonal matrix containing the
!!   singular values of \f$A\f$, which are sqrt( eigenvalues of \f$AA^T\f$ ) =
!!   sqrt( eigenvalues of \f$A^TA\f$ ).
!!
!! The algebraic form of the transformation matrix, as implemented
!!   below, was derived symbolically by J. Jonkman by computing \f$UV^T\f$
!!   by hand with verification in Mathematica.
!!
!! Note: this formulation has been updated with new equations from J. Jonkman, derived from
!! using quaternions. It is accurrate longer.
!! This routine is the inverse of GetSmllRotAngs (nwtc_num::getsmllrotangs). \n
!! Use SmllRotTrans (nwtc_num::smllrottrans) instead of directly calling a specific routine in the generic interface. 

!=======================================================================
!> \copydoc nwtc_num::smllrottransd

!=======================================================================
!> This routine takes two sorted arrays and finds the sorted union of the two.
!!
!! Note: If the same value is found in both arrays, only one is kept. However, if either
!!       array as multiple occurances of the same value, the largest multiple will be
!!       kept. Duplicates should be eliminated externally if this is not desirable.


!=======================================================================
!> This routine calculates the standard deviation of a population contained in Ary.
!!
!! This can be calculated as either\n
!! \f$ \sqrt{ \frac{\sum_{i=1}^N \left(x_i -\bar{x}\right)^2 }{N-1} } \f$   \n
!! or \n
!! \f$ \sqrt{ \frac{\sum_{i=1}^N \left(x_i -\bar{x}\right)^2 }{N} } \f$ if `UseN` is true \n


!=======================================================================
!> This function returns the 3x3 skew-symmetric matrix for cross-product
!! calculation of vector \f$\vec{x}\f$ via matrix multiplication, defined as
!! \f{equation}{
!!   f_{_\times}\left( \vec{x} \right) = 
!!  \begin{bmatrix}
!!       0  & -x_3 &  x_2 \!!      x_3 &  0   & -x_1 \!!     -x_2 &  x_1 &  0          
!! \end{bmatrix}
!! \f}   
!> Use SkewSymMat (nwtc_num::skewsymmat) instead of directly calling a specific routine in the generic interface.

!=======================================================================
!> \copydoc nwtc_num::skewsymmatr4

!=======================================================================
!> If M is a rotation matrix from a 1-2-3 rotation sequence about Y-X-Z, this function returns 
!! the 3 sequential angles, \f$\theta_y\f$, \f$\theta_x\f$, and \f$\theta_z\f$ (in radians), that formed 
!! the matrix. M represents a change of basis (from global to local coordinates; 
!! not a physical rotation of the body; passive rotation).
!!
!! See Tait-Bryan angle \f$ Y_1 X_2 Z_3 \f$ at https://en.wikipedia.org/wiki/Euler_angles#Rotation_matrix
!! Note that what we are using here is the passive rotation, which is the transpose of what appears in the
!! wikipedia article.
!! 
!!
!! \f{eqnarray*}{   
!! M & = & R(\theta_z) R(\theta_x) R(\theta_y)
!!   & = & R(\theta_3) R(\theta_2) R(\theta_1) \!!   & = & \begin{bmatrix}    \cos(\theta_z)    & \sin(\theta_z)     & 0                  \!!                            -\sin(\theta_z)   & \cos(\theta_z)     & 0                  \!!                            0                 &  0                 & 1                  \end{bmatrix}
!!         \begin{bmatrix}    1                 &  0                 & 0                  \!!                            0                 &  \cos(\theta_x)    & \sin(\theta_x)     \!!                            0                 & -\sin(\theta_x)    & \cos(\theta_x)     \end{bmatrix}
!!         \begin{bmatrix}    \cos(\theta_y)    & 0                  & -\sin(\theta_y)    \!!                            0                 & 1                  & 0                  \!!                            \sin(\theta_y)    & 0                  & \cos(\theta_y)     \end{bmatrix}
!!   & = & \begin{bmatrix}    C_3               & S_3                & 0                  \!!                            -S_3              & C_3                & 0                  \!!                            0                 & 0                  & 1                  \end{bmatrix}
!!         \begin{bmatrix}    1                 & 0                  & 0                  \!!                            0                 & C_2                & S_2                \!!                            0                 & -S_2               & C_2                \end{bmatrix}
!!         \begin{bmatrix}    C_1               & 0                  & -S_1               \!!                            0                 & 1                  & 0                  \!!                            S_1               & 0                  & C_1                \end{bmatrix}  \!!   & = & \begin{bmatrix}  
!!             \cos(\theta_y) \cos(\theta_z) + \sin(\theta_y) \sin(\theta_x) \sin(\theta_z)     &  \cos(\theta_x) \sin(\theta_z)    &  \cos(\theta_y) \sin(\theta_x) \sin(\theta_z) - \sin(\theta_y) \cos(\theta_z)  \!!             \sin(\theta_y) \sin(\theta_x) \cos(\theta_z) - \cos(\theta_y) \sin(\theta_z)     &  \cos(\theta_x) \cos(\theta_z)    &  \cos(\theta_y) \sin(\theta_x) \cos(\theta_z) + \sin(\theta_y) \sin(\theta_z)  \!!             \sin(\theta_y) \cos(\theta_x)                                                    &  -\sin(\theta_x)                  &  \cos(\theta_y) \cos(\theta_x)                                                 \!!         \end{bmatrix}   
!!   & = & \begin{bmatrix}  
!!             C_1 C_3 + S_1 S_2 S_3   &  C_2 S_3     &  C_1 S_2 S_3 - S_1 C_3   \!!             S_1 S_2 C_3 - C_1 S_3   &  C_2 C_3     &  C_1 S_2 C_3 + S_1 S_3   \!!             S_1 C_2                 &  -S_2        &  C_1 C_2                 \!!         \end{bmatrix}   
!! \f}
!! returned angles are in the range \f$\theta_y,\theta_x, \theta_z \in \left[ \pi, -\pi \right]\f$ \n
!! Use TaitBryanYXZExtract (nwtc_num::taitbryanyxzextract)  instead of directly calling a specific routine in the generic interface. 

!> See nwtc_num::taitbryanyxzextractr4 for detailed explanation of algorithm


!=======================================================================
!> this function creates a rotation matrix, M, from a 1-2-3 rotation
!! sequence of the 3 TaitBryan angles, theta_x, theta_y, and theta_z, in radians.
!! M represents a change of basis (from global to local coordinates; 
!! not a physical rotation of the body). it is the inverse of TaitBryanYXZExtract().
!! 
!! M = R(theta_z) * R(theta_x) * R(theta_y)
!!   = [ cz sz 0 |  [ 1   0   0 |    [ cy  0 -sy | 
!!     |-sz cz 0 |* | 0  cx  sx |  * |  0  1   0 | 
!!     |  0  0 1 ]  | 0 -sx  cx ]    | sy  0  cy ] 
!!   = [ cy*cz+sy*sx*sz   cx*sz    cy*sx*sz-cz*sy |
!!     |cz*sy*sx-cy*sz   cx*cz    cy*cz*sx+sy*sz |
!!     |cx*sy           -sx             cx*cy    ]
!! where cz = cos(theta_z), sz = sin(theta_z), cy = cos(theta_y), etc.

!=======================================================================

!=======================================================================
!> This routine takes an array of time values such as that returned from
!!     CALL DATE_AND_TIME ( Values=TimeAry )
!! and converts TimeAry to the number of seconds past midnight.


!=======================================================================
!> This function computes the trace of a matrix \f$A \in \mathbb{R}^{m,n}\f$. The 
!! trace of \f$A\f$, \f$\mathrm{Tr}\left[ A \right]\f$, is the sum of the diagonal elements of \f$A\f$:   
!! \f{equation}{   
!!   \mathrm{Tr}\left[ A \right] = \sum_{i=1}^{\min(m,n)} A(i,i)
!! \f}   
!!
!! Use trace (nwtc_num::trace) instead of directly calling a specific routine in the generic interface.    

!=======================================================================
!> \copydoc nwtc_num::tracer4

!=======================================================================
!> This function returns the \f$l_2\f$ (Euclidian) norm of a vector, 
!! \f$v = \left(v_1, v_2, \ldots ,v_n\right)\f$. The \f$l_2\f$-norm is defined as   
!! \f{equation}{   
!!  \lVert v \rVert_2 = \left( \sum_{i=1}^{n} {v_i}^2 \right)^{1/2}
!! \f} \n
!! Use TwoNorm (nwtc_num::twonorm) instead of directly calling a specific routine in the generic interface.    


!=======================================================================
!> \copydoc nwtc_num::twonormr4

!=======================================================================  
!> This routine is used to convert Angle to an equivalent value
!!  in the range \f$[0, 2\pi)\f$. \n
!! Use Zero2TwoPi (nwtc_num::zero2twopi) instead of directly calling a specific routine in the generic interface.    


!=======================================================================  
!> \copydoc nwtc_num::zero2twopir4

!=======================================================================
   !< This routine extrapolates or interpolates between angles

!=======================================================================  
   !< This routine extrapolates or interpolates between angles

!=======================================================================
   !< This routine extrapolates or interpolates between angles

!=======================================================================  
   !< This routine extrapolates or interpolates between angles

!=======================================================================  
   !< This routine extrapolates or interpolates between angles

!=======================================================================  
   !< This routine extrapolates or interpolates between angles

!=======================================================================  
   !< This routine extrapolates or interpolates between angles


!=======================================================================  
   !< This routine extrapolates or interpolates between angles

!=======================================================================  
   SUBROUTINE fZero_R4(x, f, roots, nZeros, Period)
      REAL(R4Ki),           intent(in)    :: x(:) ! assumed to be monotonic increasing: x(1) < x(2) < ... < x(n)
      REAL(R4Ki),           intent(in)    :: f(:) ! f(x)
      REAL(R4Ki),           intent(inout) :: roots(:)
      INTEGER(IntKi),       intent(  out) :: nZeros
      REAL(R4Ki), OPTIONAL, intent(in)    :: Period   ! if this is provided, the function f is assumed to be periodic with f(x(j)) = f(x(j)+Period)
      
      integer(IntKi)                :: n, j
      real(R4Ki)                    :: dx, df, m ! help to find zero crossing
      
      n = size(f)
      
      nZeros = 0
      do j=2,n
         if ((f(j-1) < 0 .and. f(j) >= 0) .or. (f(j-1) >= 0 .and. f(j) < 0)) then !this is a zero-crossing, so a root is located here
            nZeros = nZeros + 1
            
            df = f(j) - f(j-1)
            dx = x(j) - x(j-1)
            
            roots( min(nZeros,size(roots)) ) = x(j) - f(j) * dx / df
         end if
      end do
            
      if (present(Period)) then
         if ((f(n) < 0 .and. f(1) >= 0) .or. (f(n) >= 0 .and. f(1) < 0)) then !this is a zero-crossing, so a root is located here
            nZeros = nZeros + 1
            
            df = f(1) - f(n)
            dx = x(1) - x(n) + Period
            
            roots( min(nZeros,size(roots)) ) = x(1) - f(1) * dx / df
         end if
      end if
   
   END SUBROUTINE fZero_R4
!=======================================================================
   SUBROUTINE fZero_R8(x, f, roots, nZeros, Period)
      REAL(R8Ki),           intent(in)    :: x(:) ! assumed to be monotonic increasing: x(1) < x(2) < ... < x(n)
      REAL(R8Ki),           intent(in)    :: f(:) ! f(x)
      REAL(R8Ki),           intent(inout) :: roots(:)
      INTEGER(IntKi),       intent(  out) :: nZeros
      REAL(R8Ki), OPTIONAL, intent(in)    :: Period   ! if this is provided, the function f is assumed to be periodic with f(x(j)) = f(x(j)+Period)
      
      integer(IntKi)                :: n, j
      real(R8Ki)                    :: dx, df, m ! help to find zero crossing
      
      n = size(f)
      
      nZeros = 0
      do j=2,n
         if ((f(j-1) < 0 .and. f(j) >= 0) .or. (f(j-1) >= 0 .and. f(j) < 0)) then !this is a zero-crossing, so a root is located here
            nZeros = nZeros + 1
            
            df = f(j) - f(j-1)
            dx = x(j) - x(j-1)
            
            roots( min(nZeros,size(roots)) ) = x(j) - f(j) * dx / df
         end if
      end do
            
      if (present(Period)) then
         if ((f(n) < 0 .and. f(1) >= 0) .or. (f(n) >= 0 .and. f(1) < 0)) then !this is a zero-crossing, so a root is located here
            nZeros = nZeros + 1
            
            df = f(1) - f(n)
            dx = x(1) - x(n) + Period
            
            roots( min(nZeros,size(roots)) ) = x(1) - f(1) * dx / df
         end if
      end if
   
   END SUBROUTINE fZero_R8
!=======================================================================
   ! Copy of EigenSolve from SubDyn, migrated here to use for beamdyn modal damping.
   !> Return eigenvalues, Omega, and eigenvectors


!=======================================================================
   !read state subroutine for kr_externs_in_nwtc_num 
   SUBROUTINE kr_externs_in_nwtc_num(kgen_unit) 
       INTEGER, INTENT(IN) :: kgen_unit 
       LOGICAL :: kgen_istrue 
       REAL(KIND=8) :: kgen_array_sum 
         
       READ (UNIT = kgen_unit) d2r 
       READ (UNIT = kgen_unit) piby2 
       READ (UNIT = kgen_unit) r2d 
       READ (UNIT = kgen_unit) twopi 
   END SUBROUTINE kr_externs_in_nwtc_num 
     
   !read state subroutine for kr_externs_out_nwtc_num 
   SUBROUTINE kr_externs_out_nwtc_num(kgen_unit) 
       INTEGER, INTENT(IN) :: kgen_unit 
         
       LOGICAL :: kgen_istrue 
       REAL(KIND=8) :: kgen_array_sum 
   END SUBROUTINE kr_externs_out_nwtc_num 
     
END MODULE NWTC_Num