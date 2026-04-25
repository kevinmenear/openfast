!KGEN-generated Fortran source file 
  
!Generated at : 2026-04-25 11:14:49 
!KGEN version : 0.8.1 
  
!**********************************************************************************************************************************
! Copyright (C) 2013-2016  National Renewable Energy Laboratory
!> This code provides a wrapper for the LAPACK routines currently used at the NWTC (mainly codes in the FAST framework). This 
!! enables us to call generic routines (not single- or double-precision specific ones) so that we don't have to change source
!! code to compile in double vs. single precision.   
!**********************************************************************************************************************************


!
!
MODULE NWTC_LAPACK

    USE nwtc_io 
   ! bjj: when using the built-in (or dynamic) lapack libraries, S=Real(SiKi); D=Real(R8Ki).
   !      if people are compiling the lapack source, S=real; D=double precision. (default real and doubles)
   !      we need to check this somehow to make sure the right routines are called.
   ! (or define a directive)
   ! http://www.netlib.org/lapack/explore-html/ 
    USE kgen_utils_mod
    USE tprof_mod, ONLY: tstart, tstop, tnull, tprnt 
   

   
   
    IMPLICIT NONE 
   !> Computes the linear least squares solution for a real general matrix A, where A is assumed to have full rank. Minimizes Norm(B-A*X)
   
   INTERFACE LAPACK_gels
      MODULE PROCEDURE LAPACK_dgels
      MODULE PROCEDURE LAPACK_sgels
   END INTERFACE
   !> Computes the solution to system of linear equations A * X = B for GB matrices.

   

   !> Computes scalar1*op( A )*op( B ) + scalar2*C where op(x) = x or op(x) = x**T for matrices A, B, and C.


   !> Computes the solution to system of linear equations A * X = B for GE matrices.
   

   !> Factor matrix into A=PLU.


   !> Compute the inverse of a matrix using the LU factorization.


   !> Solve system(s) of linear equations Ax=PLUx=b.


   !> Compute generalized eigenvalues and/or eigenvectors for a pair of N-by-N real nonsymmetric matrices (A,B).


   !> Compute the solution to system of linear equations A * X = B for PO matrices.


   !> Compute the Cholesky factorization of a real symmetric positive definite matrix A stored in packed format (internally handled as unpacked).


   !> Compute the Cholesky factorization of a real symmetric positive definite matrix A stored in packed format.


   !> Compute the SVD for a general matrix A = USV^T.


   !> Unpack  packed (1D) to regular matrix format (2D)


   !> straight-up lapack routines (from ExtPtfm_MCKF):
   


   


   


   CONTAINS
!=======================================================================
!> general banded solve: Computes the solution to system of linear equations A * X = B for GB (general, banded) matrices.
!! use LAPACK_GBSV (nwtc_lapack::lapack_gbsv) instead of this specific function.


!=======================================================================
!> general banded solve: Computes the solution to system of linear equations A * X = B for GB (general, banded) matrices.
!! use LAPACK_GBSV (nwtc_lapack::lapack_gbsv) instead of this specific function.

!=======================================================================
!> SGELS solves overdetermined or underdetermined real linear systems
!!     involving an M-by-N matrix A, or its transpose, using a QR or LQ
!!     factorization of A.  It is assumed that A has full rank.
   SUBROUTINE LAPACK_DGELS(TRANS, A, B, ErrStat, ErrMsg)
      ! passed parameters

      CHARACTER(1),    intent(in   ) :: TRANS             !< On entry, TRANS specifies the form of op( A ) to be used in the matrix multiplication as follows:
                                                          !!     TRANSA = 'N' or 'n', op( A ) = A.
                                                          !!     TRANSA = 'T' or 't', op( A ) = A**T.
      REAL(R8Ki)      ,intent(inout) :: A( :, : )         !< On entry, the M-by-N matrix A. On exit, if M >= N, A is overwritten by details of its QR factorization as returned by SGEQRF;
                                                          !!                                         if M <  N, A is overwritten by details of its LQ factorization as returned by SGELQF.

      REAL(R8Ki)      ,intent(inout) :: B( :, : )         !< On entry, the matrix B of right hand side vectors, stored columnwise; B is M-by-NRHS if TRANS = 'N', or N-by-NRHS if TRANS = 'T'.
                                                          !! On exit, if INFO = 0, B is overwritten by the solution vectors, stored columnwise:
                                                          !!    if TRANS = 'N' and m >= n, rows 1 to n of B contain the least squares solution vectors; the residual sum of squares for the
                                                          !!                               solution in each column is given by the sum of squares of elements N+1 to M in that column;
                                                          !!    if TRANS = 'N' and m < n, rows 1 to N of B contain the minimum norm solution vectors;
                                                          !!    if TRANS = 'T' and m >= n, rows 1 to M of B contain the minimum norm solution vectors;
                                                          !!    if TRANS = 'T' and m < n, rows 1 to M of B contain the least squares solution vectors; the residual sum of squares
                                                          !!                              for the solution in each column is given by the sum of squares of elements M+1 to N in that column.
      
      INTEGER(IntKi),  intent(  out) :: ErrStat           !< Error level
      CHARACTER(*),    intent(  out) :: ErrMsg            !< Message describing error
         ! local variables

      REAL(R8Ki), ALLOCATABLE        :: WORK( : )         !< dimension (MAX(1,LWORK)); On exit, if INFO=0, then WORK(1) returns the optimal LWORK.
      REAL(R8Ki)                     :: WORK_SIZE(1)      !< the optimal LWORK
      INTEGER                        :: LWORK             !< The dimension of the array WORK. LWORK >= max( 1, MN + max( MN, NRHS ) ). For optimal performance LWORK >= max( 1, MN + max( MN, NRHS )*NB ), where MN = min(M,N) and NB is the optimum block size.
                                                          !! If LWORK = -1, then a workspace query is assumed; the routine only calculates the optimal size of the WORK array, returns this value as the first
                                                          !! entry of the WORK array, and no error message related to LWORK is issued by XERBLA.


      INTEGER                        :: INFO              ! = 0:  successful exit; < 0:  if INFO = -i, the i-th argument had an illegal value; > 0: if INFO = i, the i-th diagonal element of the triangular factor of A is zero, so that A does not have full rank; the least squares solution could not be computed.

      INTEGER                        :: LDA               ! The leading dimension of the array A.  LDA >= MAX(1,M).
      INTEGER                        :: LDB               ! The leading dimension of the array B.  LDB >= MAX(1,M,N).
      INTEGER                        :: M                 !< The number of rows of the matrix A.  M >= 0.
      INTEGER                        :: N                 !< The number of columns of the matrix A.  N >= 0.
      INTEGER                        :: NRHS              !< The number of right hand sides, i.e., the number of columns of the matrices B and X. NRHS >=0.

      INTEGER(IntKi)                 :: ErrStat2          !< Error level
      CHARACTER(8196)           :: ErrMsg2           !< Message describing error
      CHARACTER(*), PARAMETER        :: RoutineName = 'LAPACK_DGELS'
      
      
      ErrStat = ErrID_None
      ErrMsg  = ""

      M = SIZE(A,1)
      N = SIZE(A,2)

      LDA = SIZE(A,1)
      
      LDB = SIZE(B,1)
      NRHS = SIZE(B,2)

      IF ( M == 0 .or. N == 0 ) THEN
         ! this is a null case...
         RETURN
      END IF
      
      
      LWORK = -1 ! get size for work array
      call DGELS(TRANS, M, N, NRHS, A, LDA, B, LDB, WORK_SIZE, LWORK, INFO) !!! UNRESOLVED !!! dgels
      
      LWORK = WORK_SIZE(1)
      call AllocAry(WORK, LWORK, 'Work', ErrStat2, ErrMsg2)
         call SetErrStat(ErrStat2,ErrMsg2, ErrStat, ErrMsg,RoutineName) !!! UNRESOLVED !!! seterrstat
         if (ErrStat >= AbortErrLev) return
      

      call DGELS(TRANS, M, N, NRHS, A, LDA, B, LDB, WORK, LWORK, INFO) !!! UNRESOLVED !!! dgels
      deallocate(WORK)

      IF (INFO /= 0) THEN
         WRITE( ErrMsg2, * ) INFO
         IF (INFO < 0) THEN
            ErrMsg2  = "Illegal value in argument "//TRIM(ErrMsg2)//"."
         ELSE
            ErrMsg2 = "Diagonal element "//TRIM(ErrMsg2)//" of the triangular factor of A is zero, so that A does not have full rank. The least squares solution could not be computed."
         END IF
         call SetErrStat(ErrID_FATAL, ErrMsg2, ErrStat, ErrMsg, RoutineName) !!! UNRESOLVED !!! seterrstat
      END IF
   
   END SUBROUTINE LAPACK_DGELS
!=======================================================================
!> SGELS solves overdetermined or underdetermined real linear systems
!!     involving an M-by-N matrix A, or its transpose, using a QR or LQ
!!     factorization of A.  It is assumed that A has full rank.
   SUBROUTINE LAPACK_SGELS(TRANS, A, B, ErrStat, ErrMsg)
      ! passed parameters

      CHARACTER(1),    intent(in   ) :: TRANS             !< On entry, TRANS specifies the form of op( A ) to be used in the matrix multiplication as follows:
                                                          !!     TRANSA = 'N' or 'n', op( A ) = A.
                                                          !!     TRANSA = 'T' or 't', op( A ) = A**T.
      REAL(SiKi)      ,intent(inout) :: A( :, : )         !< On entry, the M-by-N matrix A. On exit, if M >= N, A is overwritten by details of its QR factorization as returned by SGEQRF;
                                                          !!                                         if M <  N, A is overwritten by details of its LQ factorization as returned by SGELQF.

      REAL(SiKi)      ,intent(inout) :: B( :, : )         !< On entry, the matrix B of right hand side vectors, stored columnwise; B is M-by-NRHS if TRANS = 'N', or N-by-NRHS if TRANS = 'T'.
                                                          !! On exit, if INFO = 0, B is overwritten by the solution vectors, stored columnwise:
                                                          !!    if TRANS = 'N' and m >= n, rows 1 to n of B contain the least squares solution vectors; the residual sum of squares for the
                                                          !!                               solution in each column is given by the sum of squares of elements N+1 to M in that column;
                                                          !!    if TRANS = 'N' and m < n, rows 1 to N of B contain the minimum norm solution vectors;
                                                          !!    if TRANS = 'T' and m >= n, rows 1 to M of B contain the minimum norm solution vectors;
                                                          !!    if TRANS = 'T' and m < n, rows 1 to M of B contain the least squares solution vectors; the residual sum of squares
                                                          !!                              for the solution in each column is given by the sum of squares of elements M+1 to N in that column.
      
      INTEGER(IntKi),  intent(  out) :: ErrStat           !< Error level
      CHARACTER(*),    intent(  out) :: ErrMsg            !< Message describing error
         ! local variables

      REAL(SiKi), ALLOCATABLE        :: WORK( : )         !< dimension (MAX(1,LWORK)); On exit, if INFO=0, then WORK(1) returns the optimal LWORK.
      REAL(SiKi)                     :: WORK_SIZE(1)      !< the optimal LWORK
      INTEGER                        :: LWORK             !< The dimension of the array WORK. LWORK >= max( 1, MN + max( MN, NRHS ) ). For optimal performance LWORK >= max( 1, MN + max( MN, NRHS )*NB ), where MN = min(M,N) and NB is the optimum block size.
                                                          !! If LWORK = -1, then a workspace query is assumed; the routine only calculates the optimal size of the WORK array, returns this value as the first
                                                          !! entry of the WORK array, and no error message related to LWORK is issued by XERBLA.


      INTEGER                        :: INFO              ! = 0:  successful exit; < 0:  if INFO = -i, the i-th argument had an illegal value; > 0: if INFO = i, the i-th diagonal element of the triangular factor of A is zero, so that A does not have full rank; the least squares solution could not be computed.

      INTEGER                        :: LDA               ! The leading dimension of the array A.  LDA >= MAX(1,M).
      INTEGER                        :: LDB               ! The leading dimension of the array B.  LDB >= MAX(1,M,N).
      INTEGER                        :: M                 !< The number of rows of the matrix A.  M >= 0.
      INTEGER                        :: N                 !< The number of columns of the matrix A.  N >= 0.
      INTEGER                        :: NRHS              !< The number of right hand sides, i.e., the number of columns of the matrices B and X. NRHS >=0.

      INTEGER(IntKi)                 :: ErrStat2          !< Error level
      CHARACTER(8196)           :: ErrMsg2           !< Message describing error
      CHARACTER(*), PARAMETER        :: RoutineName = 'LAPACK_SGELS'
      
      
      ErrStat = ErrID_None
      ErrMsg  = ""

      M = SIZE(A,1)
      N = SIZE(A,2)

      LDA = SIZE(A,1)
      
      LDB = SIZE(B,1)
      NRHS = SIZE(B,2)

      IF ( M == 0 .or. N == 0 ) THEN
         ! this is a null case...
         RETURN
      END IF
      
      
      LWORK = -1 ! get size for work array
      call SGELS(TRANS, M, N, NRHS, A, LDA, B, LDB, WORK_SIZE, LWORK, INFO) !!! UNRESOLVED !!! sgels
      
      LWORK = WORK_SIZE(1)
      call AllocAry(WORK, LWORK, 'Work', ErrStat2, ErrMsg2)
         call SetErrStat(ErrStat2,ErrMsg2, ErrStat, ErrMsg,RoutineName) !!! UNRESOLVED !!! seterrstat
         if (ErrStat >= AbortErrLev) return
      

      call SGELS(TRANS, M, N, NRHS, A, LDA, B, LDB, WORK, LWORK, INFO) !!! UNRESOLVED !!! sgels
      deallocate(WORK)

      IF (INFO /= 0) THEN
         WRITE( ErrMsg2, * ) INFO
         IF (INFO < 0) THEN
            ErrMsg2  = "Illegal value in argument "//TRIM(ErrMsg2)//"."
         ELSE
            ErrMsg2 = "Diagonal element "//TRIM(ErrMsg2)//" of the triangular factor of A is zero, so that A does not have full rank. The least squares solution could not be computed."
         END IF
         call SetErrStat(ErrID_FATAL, ErrMsg2, ErrStat, ErrMsg, RoutineName) !!! UNRESOLVED !!! seterrstat
      END IF
   
   END SUBROUTINE LAPACK_SGELS
!=======================================================================
!> general matrix multiply: computes C = alpha*op( A )*op( B ) + beta*C where op(x) = x or op(x) = x**T for matrices A, B, and C
!! use LAPACK_GEMM (nwtc_lapack::lapack_gemm) instead of this specific function.


!=======================================================================
!> general matrix multiply: computes C = alpha*op( A )*op( B ) + beta*C where op(x) = x or op(x) = x**T for matrices A, B, and C
!! use LAPACK_GEMM (nwtc_lapack::lapack_gemm) instead of this specific function.


!=======================================================================
!> general solve: Computes the solution to system of linear equations A * X = B for GE matrices.
!! use LAPACK_GESV (nwtc_lapack::lapack_gesv) instead of this specific function.

!=======================================================================
!> general solve: Computes the solution to system of linear equations A * X = B for GE matrices.
!! use LAPACK_GESV (nwtc_lapack::lapack_gesv) instead of this specific function.

!=======================================================================
!> general matrix factorization: Factor matrix into A=PLU.
!! use LAPACK_GETRF (nwtc_lapack::lapack_getrf) instead of this specific function.

!=======================================================================
!> general matrix factorization: Factor matrix into A=PLU.
!! use LAPACK_GETRF (nwtc_lapack::lapack_getrf) instead of this specific function.

!=======================================================================
!> general solve of factorized matrix: Solve system of linear equations Ax=PLUx=b.
!! use LAPACK_GETRS (nwtc_lapack::lapack_getrs) instead of this specific function.

!=======================================================================
!> general solve of factorized matrix: Solve system of linear equations Ax=PLUx=b.
!! use LAPACK_GETRS (nwtc_lapack::lapack_getrs) instead of this specific function.

!=======================================================================
!> general solve of factorized matrix: Solve system of linear equations Ax=PLUx=b.
!! use LAPACK_GETRS (nwtc_lapack::lapack_getrs) instead of this specific function.

!=======================================================================
!> general solve of factorized matrix: Solve system of linear equations Ax=PLUx=b.
!! use LAPACK_GETRS (nwtc_lapack::lapack_getrs) instead of this specific function.

!=======================================================================
!> Compute the inverse of a general matrix using the LU factorization.
!! use LAPACK_GETRI (nwtc_lapack::lapack_getri) instead of this specific function.

!=======================================================================
!> Compute the inverse of a general matrix using the LU factorization.
!! use LAPACK_GETRI (nwtc_lapack::lapack_getri) instead of this specific function.

!=======================================================================
!> Compute generalized eigenvalues and/or eigenvectors for a pair of N-by-N real nonsymmetric matrices (A,B).
!! use LAPACK_GGEV (nwtc_lapack::lapack_ggev) instead of this specific function.

!=======================================================================
!> Compute generalized eigenvalues and/or eigenvectors for a pair of N-by-N real nonsymmetric matrices (A,B).
!! use LAPACK_GGEV (nwtc_lapack::lapack_ggev) instead of this specific function.

!=======================================================================
!> Compute the solution to system of linear equations A * X = B for PO (positive-definite) matrices.
!! use LAPACK_POSV (nwtc_lapack::lapack_posv) instead of this specific function.

!=======================================================================
!> Compute the solution to system of linear equations A * X = B for PO (positive-definite) matrices.
!! use LAPACK_POSV (nwtc_lapack::lapack_posv) instead of this specific function.

!=======================================================================
!> Compute the Cholesky factorization of a real symmetric positive definite matrix A stored in packed format.
!! use LAPACK_POTRF (nwtc_lapack::lapack_potrf) instead of this specific function.


!=======================================================================
!> Compute the Cholesky factorization of a real symmetric positive definite matrix A stored in packed format.
!! use LAPACK_POTRF (nwtc_lapack::lapack_potrf) instead of this specific function.


!=======================================================================
!> Compute the Cholesky factorization of a real symmetric positive definite matrix A stored in packed format.
!! use LAPACK_PPTRF (nwtc_lapack::lapack_pptrf) instead of this specific function.

!=======================================================================
!> Compute the Cholesky factorization of a real symmetric positive definite matrix A stored in packed format.
!! use LAPACK_PPTRF (nwtc_lapack::lapack_pptrf) instead of this specific function.

!=======================================================================
!> Compute singular value decomposition (SVD) for a general matrix, A.
!! use LAPACK_DGESVD (nwtc_lapack::lapack_dgesvd) instead of this specific function.

!=======================================================================
!> Compute singular value decomposition (SVD) for a general matrix, A.
!! use LAPACK_SGESVD (nwtc_lapack::lapack_sgesvd) instead of this specific function.

!=======================================================================
!INTERFACE LAPACK_TPTTR:
!>  Unpack a by-column-packed array into a 2D matrix format
!!  See documentation in  DTPTTR/STPTTR source code.
!=======================================================================

!=======================================================================

!=======================================================================

END MODULE NWTC_LAPACK