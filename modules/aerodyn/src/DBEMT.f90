!**********************************************************************************************************************************
! LICENSING
! Copyright (C) 2015-2016  National Renewable Energy Laboratory
! Copyright (C) 2017  Envision Energy USA, LTD
!
!    This file is part of AeroDyn.
!
! Licensed under the Apache License, Version 2.0 (the "License");
! you may not use this file except in compliance with the License.
! You may obtain a copy of the License at
!
!     http://www.apache.org/licenses/LICENSE-2.0
!
! Unless required by applicable law or agreed to in writing, software
! distributed under the License is distributed on an "AS IS" BASIS,
! WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
! See the License for the specific language governing permissions and
! limitations under the License.
!**********************************************************************************************************************************
!
! References:
!   [1] E. Branlard, B. Jonkman, G.R. Pirrung, K. Dixon, J. Jonkman (2022)
!       Dynamic inflow and unsteady aerodynamics models for modal and stability analyses in OpenFAST, 
!       Journal of Physics: Conference Series, doi:10.1088/1742-6596/2265/3/032044
!   [2] R. Damiani, J.Jonkman
!       DBEMT Theory Rev. 3
!       Unpublished
!
module DBEMT
   
   use NWTC_Library   
   use DBEMT_Types
   
   USE ISO_C_BINDING
   implicit none 

private


   public :: DBEMT_Init
   public :: DBEMT_UpdateStates
   public :: DBEMT_CalcOutput
   public :: DBEMT_End
   PUBLIC :: DBEMT_CalcContStateDeriv             !  Tight coupling routine for computing derivatives of continuous states
   

   public :: DBEMT_ReInit
   public :: DBEMT_InitStates_AllNodes


    ! Auto-generated interface for C++ implementation of ComputeTau2
    INTERFACE
        SUBROUTINE computetau2_c(i, j, u, p, tau1, tau2, has_k_tau_out, k_tau_out) BIND(C, NAME='computetau2_c')
            USE ISO_C_BINDING
            INTEGER(C_INT), VALUE :: i
            INTEGER(C_INT), VALUE :: j
            TYPE(C_PTR), VALUE :: u
            TYPE(C_PTR), VALUE :: p
            REAL(C_DOUBLE), VALUE :: tau1
            REAL(C_DOUBLE), INTENT(OUT) :: tau2
            INTEGER(C_INT), VALUE :: has_k_tau_out
            REAL(C_DOUBLE), INTENT(OUT) :: k_tau_out
        END SUBROUTINE computetau2_c
    END INTERFACE


    ! Auto-generated interface for C++ implementation of ComputeTau1
    INTERFACE
        SUBROUTINE computetau1_c(u, p, m, tau1, errStat, errMsg) BIND(C, NAME='computetau1_c')
            USE ISO_C_BINDING
            TYPE(C_PTR), VALUE :: u
            TYPE(C_PTR), VALUE :: p
            TYPE(C_PTR), VALUE :: m
            REAL(C_DOUBLE), INTENT(OUT) :: tau1
            INTEGER(C_INT), INTENT(OUT) :: errStat
            CHARACTER(KIND=C_CHAR), INTENT(OUT) :: errMsg(*)
        END SUBROUTINE computetau1_c
    END INTERFACE


    ! Auto-generated interface for C++ implementation of DBEMT_InitStates
    INTERFACE
        SUBROUTINE dbemt_initstates_c(i, j, u, p, x, OtherState) BIND(C, NAME='dbemt_initstates_c')
            USE ISO_C_BINDING
            INTEGER(C_INT), VALUE :: i
            INTEGER(C_INT), VALUE :: j
            TYPE(C_PTR), VALUE :: u
            TYPE(C_PTR), VALUE :: p
            TYPE(C_PTR), VALUE :: x
            TYPE(C_PTR), VALUE :: OtherState
        END SUBROUTINE dbemt_initstates_c
    END INTERFACE


    ! Auto-generated interface for C++ implementation of DBEMT_CalcOutput
    INTERFACE
        SUBROUTINE dbemt_calcoutput_c(i, j, t, u, y_vind, p, x, OtherState, m, errStat, errMsg) BIND(C, NAME='dbemt_calcoutput_c')
            USE ISO_C_BINDING
            INTEGER(C_INT), VALUE :: i
            INTEGER(C_INT), VALUE :: j
            REAL(C_DOUBLE), VALUE :: t
            TYPE(C_PTR), VALUE :: u
            REAL(C_DOUBLE), INTENT(OUT) :: y_vind(*)
            TYPE(C_PTR), VALUE :: p
            TYPE(C_PTR), VALUE :: x
            TYPE(C_PTR), VALUE :: OtherState
            TYPE(C_PTR), VALUE :: m
            INTEGER(C_INT), INTENT(OUT) :: errStat
            CHARACTER(KIND=C_CHAR), INTENT(OUT) :: errMsg(*)
        END SUBROUTINE dbemt_calcoutput_c
    END INTERFACE


    ! Auto-generated interface for C++ implementation of DBEMT_CalcContStateDeriv
    INTERFACE
        SUBROUTINE dbemt_calccontstatederiv_c(i, j, t, u, p, x, OtherState, m, dxdt, ErrStat, ErrMsg) BIND(C, NAME='dbemt_calccontstatederiv_c')
            USE ISO_C_BINDING
            INTEGER(C_INT), VALUE :: i
            INTEGER(C_INT), VALUE :: j
            REAL(C_DOUBLE), VALUE :: t
            TYPE(C_PTR), VALUE :: u
            TYPE(C_PTR), VALUE :: p
            TYPE(C_PTR), VALUE :: x
            TYPE(C_PTR), VALUE :: OtherState
            TYPE(C_PTR), VALUE :: m
            TYPE(C_PTR), VALUE :: dxdt
            INTEGER(C_INT), INTENT(OUT) :: ErrStat
            CHARACTER(KIND=C_CHAR), INTENT(OUT) :: ErrMsg(*)
        END SUBROUTINE dbemt_calccontstatederiv_c
    END INTERFACE


    ! Auto-generated interface for C++ implementation of DBEMT_RK4
    INTERFACE
        SUBROUTINE dbemt_rk4_c(i, j, t, n, u, n_u, utimes, n_utimes, p, x, OtherState, m, ErrStat, ErrMsg) BIND(C, NAME='dbemt_rk4_c')
            USE ISO_C_BINDING
            INTEGER(C_INT), VALUE :: i
            INTEGER(C_INT), VALUE :: j
            REAL(C_DOUBLE), VALUE :: t
            INTEGER(C_INT), VALUE :: n
            TYPE(C_PTR), VALUE :: u
            INTEGER(C_INT), VALUE :: n_u
            REAL(C_DOUBLE), INTENT(IN) :: utimes(*)
            INTEGER(C_INT), VALUE :: n_utimes
            TYPE(C_PTR), VALUE :: p
            TYPE(C_PTR), VALUE :: x
            TYPE(C_PTR), VALUE :: OtherState
            TYPE(C_PTR), VALUE :: m
            INTEGER(C_INT), INTENT(OUT) :: ErrStat
            CHARACTER(KIND=C_CHAR), INTENT(OUT) :: ErrMsg(*)
        END SUBROUTINE dbemt_rk4_c
    END INTERFACE


    ! Auto-generated interface for C++ implementation of DBEMT_AB4
    INTERFACE
        SUBROUTINE dbemt_ab4_c(i, j, t, n, u, n_u, utimes, n_utimes, p, x, OtherState, m, ErrStat, ErrMsg) BIND(C, NAME='dbemt_ab4_c')
            USE ISO_C_BINDING
            INTEGER(C_INT), VALUE :: i
            INTEGER(C_INT), VALUE :: j
            REAL(C_DOUBLE), VALUE :: t
            INTEGER(C_INT), VALUE :: n
            TYPE(C_PTR), VALUE :: u
            INTEGER(C_INT), VALUE :: n_u
            REAL(C_DOUBLE), INTENT(IN) :: utimes(*)
            INTEGER(C_INT), VALUE :: n_utimes
            TYPE(C_PTR), VALUE :: p
            TYPE(C_PTR), VALUE :: x
            TYPE(C_PTR), VALUE :: OtherState
            TYPE(C_PTR), VALUE :: m
            INTEGER(C_INT), INTENT(OUT) :: ErrStat
            CHARACTER(KIND=C_CHAR), INTENT(OUT) :: ErrMsg(*)
        END SUBROUTINE dbemt_ab4_c
    END INTERFACE


    ! Auto-generated interface for C++ implementation of DBEMT_ABM4
    INTERFACE
        SUBROUTINE dbemt_abm4_c(i, j, t, n, u, n_u, utimes, n_utimes, p, x, OtherState, m, ErrStat, ErrMsg) BIND(C, NAME='dbemt_abm4_c')
            USE ISO_C_BINDING
            INTEGER(C_INT), VALUE :: i
            INTEGER(C_INT), VALUE :: j
            REAL(C_DOUBLE), VALUE :: t
            INTEGER(C_INT), VALUE :: n
            TYPE(C_PTR), VALUE :: u
            INTEGER(C_INT), VALUE :: n_u
            REAL(C_DOUBLE), INTENT(IN) :: utimes(*)
            INTEGER(C_INT), VALUE :: n_utimes
            TYPE(C_PTR), VALUE :: p
            TYPE(C_PTR), VALUE :: x
            TYPE(C_PTR), VALUE :: OtherState
            TYPE(C_PTR), VALUE :: m
            INTEGER(C_INT), INTENT(OUT) :: ErrStat
            CHARACTER(KIND=C_CHAR), INTENT(OUT) :: ErrMsg(*)
        END SUBROUTINE dbemt_abm4_c
    END INTERFACE


    ! Auto-generated interface for C++ implementation of DBEMT_UpdateStates
    INTERFACE
        SUBROUTINE dbemt_updatestates_c(i, j, t, n, u, n_u, uTimes, p, x, OtherState, m, errStat, errMsg) BIND(C, NAME='dbemt_updatestates_c')
            USE ISO_C_BINDING
            INTEGER(C_INT), VALUE :: i
            INTEGER(C_INT), VALUE :: j
            REAL(C_DOUBLE), VALUE :: t
            INTEGER(C_INT), VALUE :: n
            TYPE(C_PTR), VALUE :: u
            INTEGER(C_INT), VALUE :: n_u
            REAL(C_DOUBLE), INTENT(IN) :: uTimes(*)
            TYPE(C_PTR), VALUE :: p
            TYPE(C_PTR), VALUE :: x
            TYPE(C_PTR), VALUE :: OtherState
            TYPE(C_PTR), VALUE :: m
            INTEGER(C_INT), INTENT(OUT) :: errStat
            CHARACTER(KIND=C_CHAR), INTENT(OUT) :: errMsg(*)
        END SUBROUTINE dbemt_updatestates_c
    END INTERFACE


    ! Auto-generated interface for C++ implementation of DBEMT_InitStates_AllNodes
    INTERFACE
        SUBROUTINE dbemt_initstates_allnodes_c(u, p, x, OtherState) BIND(C, NAME='dbemt_initstates_allnodes_c')
            USE ISO_C_BINDING
            TYPE(C_PTR), VALUE :: u
            TYPE(C_PTR), VALUE :: p
            TYPE(C_PTR), VALUE :: x
            TYPE(C_PTR), VALUE :: OtherState
        END SUBROUTINE dbemt_initstates_allnodes_c
    END INTERFACE


    ! Auto-generated interface for C++ implementation of DBEMT_ValidateInitInp
    INTERFACE
        SUBROUTINE dbemt_validateinitinp_c(interval, InitInp, errStat, errMsg) BIND(C, NAME='dbemt_validateinitinp_c')
            USE ISO_C_BINDING
            REAL(C_DOUBLE), VALUE :: interval
            TYPE(C_PTR), VALUE :: InitInp
            INTEGER(C_INT), INTENT(OUT) :: errStat
            CHARACTER(KIND=C_CHAR), INTENT(OUT) :: errMsg(*)
        END SUBROUTINE dbemt_validateinitinp_c
    END INTERFACE


    ! Auto-generated interface for C++ implementation of DBEMT_ReInit
    INTERFACE
        SUBROUTINE dbemt_reinit_c(p, x, OtherState, m) BIND(C, NAME='dbemt_reinit_c')
            USE ISO_C_BINDING
            TYPE(C_PTR), VALUE :: p
            TYPE(C_PTR), VALUE :: x
            TYPE(C_PTR), VALUE :: OtherState
            TYPE(C_PTR), VALUE :: m
        END SUBROUTINE dbemt_reinit_c
    END INTERFACE


    ! Auto-generated interface for C++ implementation of DBEMT_Init
    INTERFACE
        SUBROUTINE dbemt_init_c(InitInp, u, p, x, OtherState, m, Interval, ErrStat, ErrMsg) BIND(C, NAME='dbemt_init_c')
            USE ISO_C_BINDING
            TYPE(C_PTR), VALUE :: InitInp
            TYPE(C_PTR), VALUE :: u
            TYPE(C_PTR), VALUE :: p
            TYPE(C_PTR), VALUE :: x
            TYPE(C_PTR), VALUE :: OtherState
            TYPE(C_PTR), VALUE :: m
            REAL(C_DOUBLE), VALUE :: Interval
            INTEGER(C_INT), INTENT(OUT) :: ErrStat
            CHARACTER(KIND=C_CHAR), INTENT(OUT) :: ErrMsg(*)
        END SUBROUTINE dbemt_init_c
    END INTERFACE

   contains
   
   
    SUBROUTINE DBEMT_ValidateInitInp(interval, InitInp, errStat, errMsg)
        USE ISO_C_BINDING
        USE vit_dbemt_initinputtype_view, ONLY: dbemt_initinputtype_view_t, vit_populate_dbemt_initinputtype
        IMPLICIT NONE
        REAL(8), INTENT(IN) :: interval
        TYPE(DBEMT_INITINPUTTYPE), INTENT(IN), TARGET :: InitInp
        INTEGER(4), INTENT(OUT) :: errStat
        CHARACTER(*), INTENT(OUT) :: errMsg
        CHARACTER(KIND=C_CHAR) :: errMsg_c(LEN(errMsg))
        INTEGER :: vit_i_errMsg
        TYPE(dbemt_initinputtype_view_t), TARGET :: InitInp_view
        ! Populate view structs from Fortran types
        CALL vit_populate_dbemt_initinputtype(InitInp, InitInp_view)
        ! Convert CHARACTER args to C_CHAR arrays
        DO vit_i_errMsg = 1, LEN(errMsg)
            errMsg_c(vit_i_errMsg) = errMsg(vit_i_errMsg:vit_i_errMsg)
        END DO
        CALL dbemt_validateinitinp_c(interval, C_LOC(InitInp_view), errStat, errMsg_c)
        ! Copy C_CHAR arrays back to CHARACTER args (INTENT OUT/INOUT)
        DO vit_i_errMsg = 1, LEN(errMsg)
            errMsg(vit_i_errMsg:vit_i_errMsg) = errMsg_c(vit_i_errMsg)
        END DO
    END SUBROUTINE DBEMT_ValidateInitInp


!----------------------------------------------------------------------------------------------------------------------------------   
!> This routine is called at the start of the simulation to perform initialization steps.
!! The parameters are set here and not changed during the simulation.
!! The initial states and initial guess for the input are defined.
    SUBROUTINE DBEMT_Init(InitInp, u, p, x, OtherState, m, Interval, InitOut, ErrStat, ErrMsg)
        USE ISO_C_BINDING
        USE vit_dbemt_initinputtype_view, ONLY: dbemt_initinputtype_view_t, vit_populate_dbemt_initinputtype
        USE vit_dbemt_parametertype_view, ONLY: dbemt_parametertype_view_t, vit_populate_dbemt_parametertype, vit_copy_scalars_to_dbemt_parametertype
        IMPLICIT NONE
        TYPE(DBEMT_INITINPUTTYPE), INTENT(IN), TARGET :: InitInp
        TYPE(DBEMT_INPUTTYPE), INTENT(OUT), TARGET :: u
        TYPE(DBEMT_PARAMETERTYPE), INTENT(OUT), TARGET :: p
        TYPE(DBEMT_CONTINUOUSSTATETYPE), INTENT(OUT), TARGET :: x
        TYPE(DBEMT_OTHERSTATETYPE), INTENT(OUT), TARGET :: OtherState
        TYPE(DBEMT_MISCVARTYPE), INTENT(OUT), TARGET :: m
        REAL(8), INTENT(IN) :: Interval
        TYPE(DBEMT_INITOUTPUTTYPE), INTENT(OUT) :: InitOut
        INTEGER(4), INTENT(OUT) :: ErrStat
        CHARACTER(*), INTENT(OUT) :: ErrMsg
        CHARACTER(KIND=C_CHAR) :: ErrMsg_c(LEN(ErrMsg))
        INTEGER :: vit_i_ErrMsg, i
        INTEGER(4) :: ErrStat2
        CHARACTER(ErrMsgLen) :: ErrMsg2
        TYPE(dbemt_initinputtype_view_t), TARGET :: InitInp_view
        TYPE(dbemt_parametertype_view_t), TARGET :: p_view

        ErrStat = ErrID_None
        ErrMsg = ""
        InitOut%Ver = ProgDesc('DBEMT', '', '')

        CALL DBEMT_ValidateInitInp(Interval, InitInp, ErrStat2, ErrMsg2)
        CALL SetErrStat(ErrStat2, ErrMsg2, ErrStat, ErrMsg, 'DBEMT_Init')
        IF (ErrStat >= AbortErrLev) RETURN

        ALLOCATE(u%element(InitInp%numNodes, InitInp%numBlades), STAT=ErrStat2)
        IF (ErrStat2 /= 0) THEN
            CALL SetErrStat(ErrID_Fatal, " Error allocating u%element.", ErrStat, ErrMsg, 'DBEMT_Init')
            RETURN
        END IF

        IF (InitInp%DBEMT_Mod == DBEMT_tauConst .OR. InitInp%DBEMT_Mod == DBEMT_cont_tauConst) THEN
            ALLOCATE(p%spanRatio(InitInp%numNodes, InitInp%numBlades), STAT=ErrStat2)
            IF (ErrStat2 /= 0) THEN
                CALL SetErrStat(ErrID_Fatal, " Error allocating p%spanRatio.  ", ErrStat, ErrMsg, 'DBEMT_Init')
                RETURN
            END IF
        END IF

        ALLOCATE(x%element(InitInp%numNodes, InitInp%numBlades), STAT=ErrStat2)
        IF (ErrStat2 /= 0) THEN
            CALL SetErrStat(ErrID_Fatal, " Error allocating x%element.  ", ErrStat, ErrMsg, 'DBEMT_Init')
            RETURN
        END IF

        IF (InitInp%DBEMT_Mod == DBEMT_cont_tauConst) THEN
            ALLOCATE(OtherState%n(InitInp%numNodes, InitInp%numBlades), STAT=ErrStat2)
            IF (ErrStat2 /= 0) THEN
                CALL SetErrStat(ErrID_Fatal, " Error allocating OtherState%n.", ErrStat, ErrMsg, 'DBEMT_Init')
                RETURN
            END IF
            DO i = 1, SIZE(OtherState%xdot)
                CALL DBEMT_CopyContState(x, OtherState%xdot(i), MESH_NEWCOPY, ErrStat2, ErrMsg2)
                IF (ErrStat2 /= 0) THEN
                    CALL SetErrStat(ErrID_Fatal, " Error allocating OtherState%xdot.", ErrStat, ErrMsg, 'DBEMT_Init')
                    RETURN
                END IF
            END DO
        END IF

        ALLOCATE(OtherState%areStatesInitialized(InitInp%numNodes, InitInp%numBlades), STAT=ErrStat2)
        IF (ErrStat2 /= 0) THEN
            CALL SetErrStat(ErrID_Fatal, " Error allocating OtherState%areStatesInitialized.  ", ErrStat, ErrMsg, 'DBEMT_Init')
            RETURN
        END IF

        CALL vit_populate_dbemt_initinputtype(InitInp, InitInp_view)
        CALL vit_populate_dbemt_parametertype(p, p_view)
        DO vit_i_ErrMsg = 1, LEN(ErrMsg)
            ErrMsg_c(vit_i_ErrMsg) = ErrMsg(vit_i_ErrMsg:vit_i_ErrMsg)
        END DO
        CALL dbemt_init_c(C_LOC(InitInp_view), C_LOC(u), C_LOC(p_view), C_LOC(x), C_LOC(OtherState), C_LOC(m), Interval, ErrStat, ErrMsg_c)
        DO vit_i_ErrMsg = 1, LEN(ErrMsg)
            ErrMsg(vit_i_ErrMsg:vit_i_ErrMsg) = ErrMsg_c(vit_i_ErrMsg)
        END DO
        CALL vit_copy_scalars_to_dbemt_parametertype(p_view, p)

        CALL DBEMT_ReInit(p, x, OtherState, m)
    END SUBROUTINE DBEMT_Init

!..................................................................................................................................
    SUBROUTINE DBEMT_ReInit(p, x, OtherState, m)
        USE ISO_C_BINDING
        USE vit_dbemt_parametertype_view, ONLY: dbemt_parametertype_view_t, vit_populate_dbemt_parametertype, vit_copy_scalars_to_dbemt_parametertype
        USE vit_dbemt_continuousstatetype_view, ONLY: dbemt_continuousstatetype_view_t, vit_populate_dbemt_continuousstatetype, vit_copy_scalars_to_dbemt_continuousstatetype
        USE vit_dbemt_otherstatetype_view, ONLY: dbemt_otherstatetype_view_t, vit_populate_dbemt_otherstatetype, vit_copy_scalars_to_dbemt_otherstatetype
        IMPLICIT NONE
        TYPE(DBEMT_PARAMETERTYPE), INTENT(IN), TARGET :: p
        TYPE(DBEMT_CONTINUOUSSTATETYPE), INTENT(INOUT), TARGET :: x
        TYPE(DBEMT_OTHERSTATETYPE), INTENT(INOUT), TARGET :: OtherState
        TYPE(DBEMT_MISCVARTYPE), INTENT(INOUT), TARGET :: m
        TYPE(dbemt_parametertype_view_t), TARGET :: p_view
        TYPE(dbemt_continuousstatetype_view_t), TARGET :: x_view
        TYPE(dbemt_otherstatetype_view_t), TARGET :: OtherState_view
        ! Populate view structs from Fortran types
        CALL vit_populate_dbemt_parametertype(p, p_view)
        CALL vit_populate_dbemt_continuousstatetype(x, x_view)
        CALL vit_populate_dbemt_otherstatetype(OtherState, OtherState_view)
        CALL dbemt_reinit_c(C_LOC(p_view), C_LOC(x_view), C_LOC(OtherState_view), C_LOC(m))
        ! Copy modified scalars back from view to Fortran type
        CALL vit_copy_scalars_to_dbemt_continuousstatetype(x_view, x)
        CALL vit_copy_scalars_to_dbemt_otherstatetype(OtherState_view, OtherState)
    END SUBROUTINE DBEMT_ReInit
!!----------------------------------------------------------------------------------------------------------------------------------
!> routine to initialize the states based on inputs
    SUBROUTINE DBEMT_InitStates_AllNodes(u, p, x, OtherState)
        USE ISO_C_BINDING
        USE vit_dbemt_inputtype_view, ONLY: dbemt_inputtype_view_t, vit_populate_dbemt_inputtype, vit_copy_scalars_to_dbemt_inputtype
        USE vit_dbemt_parametertype_view, ONLY: dbemt_parametertype_view_t, vit_populate_dbemt_parametertype, vit_copy_scalars_to_dbemt_parametertype
        USE vit_dbemt_continuousstatetype_view, ONLY: dbemt_continuousstatetype_view_t, vit_populate_dbemt_continuousstatetype, vit_copy_scalars_to_dbemt_continuousstatetype
        USE vit_dbemt_otherstatetype_view, ONLY: dbemt_otherstatetype_view_t, vit_populate_dbemt_otherstatetype, vit_copy_scalars_to_dbemt_otherstatetype
        IMPLICIT NONE
        TYPE(DBEMT_INPUTTYPE), INTENT(IN), TARGET :: u
        TYPE(DBEMT_PARAMETERTYPE), INTENT(IN), TARGET :: p
        TYPE(DBEMT_CONTINUOUSSTATETYPE), INTENT(INOUT), TARGET :: x
        TYPE(DBEMT_OTHERSTATETYPE), INTENT(INOUT), TARGET :: OtherState
        TYPE(dbemt_inputtype_view_t), TARGET :: u_view
        TYPE(dbemt_parametertype_view_t), TARGET :: p_view
        TYPE(dbemt_continuousstatetype_view_t), TARGET :: x_view
        TYPE(dbemt_otherstatetype_view_t), TARGET :: OtherState_view
        ! Populate view structs from Fortran types
        CALL vit_populate_dbemt_inputtype(u, u_view)
        CALL vit_populate_dbemt_parametertype(p, p_view)
        CALL vit_populate_dbemt_continuousstatetype(x, x_view)
        CALL vit_populate_dbemt_otherstatetype(OtherState, OtherState_view)
        CALL dbemt_initstates_allnodes_c(C_LOC(u_view), C_LOC(p_view), C_LOC(x_view), C_LOC(OtherState_view))
        ! Copy modified scalars back from view to Fortran type
        CALL vit_copy_scalars_to_dbemt_continuousstatetype(x_view, x)
        CALL vit_copy_scalars_to_dbemt_otherstatetype(OtherState_view, OtherState)
    END SUBROUTINE DBEMT_InitStates_AllNodes
!!----------------------------------------------------------------------------------------------------------------------------------
!> routine to initialize the states based on inputs
    SUBROUTINE DBEMT_InitStates(i, j, u, p, x, OtherState)
        USE ISO_C_BINDING
        USE vit_dbemt_inputtype_view, ONLY: dbemt_inputtype_view_t, vit_populate_dbemt_inputtype
        USE vit_dbemt_parametertype_view, ONLY: dbemt_parametertype_view_t, vit_populate_dbemt_parametertype
        USE vit_dbemt_continuousstatetype_view, ONLY: dbemt_continuousstatetype_view_t, vit_populate_dbemt_continuousstatetype
        USE vit_dbemt_otherstatetype_view, ONLY: dbemt_otherstatetype_view_t, vit_populate_dbemt_otherstatetype
        IMPLICIT NONE
        INTEGER(4), INTENT(IN) :: i
        INTEGER(4), INTENT(IN) :: j
        TYPE(DBEMT_INPUTTYPE), INTENT(IN), TARGET :: u
        TYPE(DBEMT_PARAMETERTYPE), INTENT(IN), TARGET :: p
        TYPE(DBEMT_CONTINUOUSSTATETYPE), INTENT(INOUT), TARGET :: x
        TYPE(DBEMT_OTHERSTATETYPE), INTENT(INOUT), TARGET :: OtherState
        TYPE(dbemt_inputtype_view_t), TARGET :: u_view
        TYPE(dbemt_parametertype_view_t), TARGET :: p_view
        TYPE(dbemt_continuousstatetype_view_t), TARGET :: x_view
        TYPE(dbemt_otherstatetype_view_t), TARGET :: OtherState_view
        ! Populate view structs from Fortran types
        CALL vit_populate_dbemt_inputtype(u, u_view)
        CALL vit_populate_dbemt_parametertype(p, p_view)
        CALL vit_populate_dbemt_continuousstatetype(x, x_view)
        CALL vit_populate_dbemt_otherstatetype(OtherState, OtherState_view)
        CALL dbemt_initstates_c(i, j, C_LOC(u_view), C_LOC(p_view), C_LOC(x_view), C_LOC(OtherState_view))
    END SUBROUTINE DBEMT_InitStates
!!----------------------------------------------------------------------------------------------------------------------------------
!> Loose coupling routine for solving for constraint states, integrating continuous states, and updating discrete and other states.
!! Continuous, constraint, discrete, and other states are updated for t + Interval
    SUBROUTINE DBEMT_UpdateStates(i, j, t, n, u, uTimes, p, x, OtherState, m, errStat, errMsg)
        USE ISO_C_BINDING
        USE vit_dbemt_inputtype_view, ONLY: dbemt_inputtype_view_t, vit_populate_dbemt_inputtype, vit_copy_scalars_to_dbemt_inputtype
        USE vit_dbemt_parametertype_view, ONLY: dbemt_parametertype_view_t, vit_populate_dbemt_parametertype, vit_copy_scalars_to_dbemt_parametertype
        USE vit_dbemt_continuousstatetype_view, ONLY: dbemt_continuousstatetype_view_t, vit_populate_dbemt_continuousstatetype, vit_copy_scalars_to_dbemt_continuousstatetype
        USE vit_dbemt_otherstatetype_view, ONLY: dbemt_otherstatetype_view_t, vit_populate_dbemt_otherstatetype, vit_copy_scalars_to_dbemt_otherstatetype
        IMPLICIT NONE
        INTEGER(4), INTENT(IN) :: i
        INTEGER(4), INTENT(IN) :: j
        REAL(8), INTENT(IN) :: t
        INTEGER(4), INTENT(IN) :: n
        TYPE(DBEMT_INPUTTYPE), INTENT(IN), TARGET :: u(2)
        REAL(8), INTENT(IN) :: uTimes(2)
        TYPE(DBEMT_PARAMETERTYPE), INTENT(IN), TARGET :: p
        TYPE(DBEMT_CONTINUOUSSTATETYPE), INTENT(INOUT), TARGET :: x
        TYPE(DBEMT_OTHERSTATETYPE), INTENT(INOUT), TARGET :: OtherState
        TYPE(DBEMT_MISCVARTYPE), INTENT(INOUT), TARGET :: m
        INTEGER(4), INTENT(OUT) :: errStat
        CHARACTER(*), INTENT(OUT) :: errMsg
        CHARACTER(KIND=C_CHAR) :: errMsg_c(LEN(errMsg))
        INTEGER :: vit_i_errMsg
        TYPE(dbemt_inputtype_view_t), TARGET :: u_view(2)
        TYPE(dbemt_parametertype_view_t), TARGET :: p_view
        TYPE(dbemt_continuousstatetype_view_t), TARGET :: x_view
        TYPE(dbemt_otherstatetype_view_t), TARGET :: OtherState_view
        INTEGER :: vit_view_i
        ! Populate view structs from Fortran types
        DO vit_view_i = 1, 2
            CALL vit_populate_dbemt_inputtype(u(vit_view_i), u_view(vit_view_i))
        END DO
        CALL vit_populate_dbemt_parametertype(p, p_view)
        CALL vit_populate_dbemt_continuousstatetype(x, x_view)
        CALL vit_populate_dbemt_otherstatetype(OtherState, OtherState_view)
        ! Convert CHARACTER args to C_CHAR arrays
        DO vit_i_errMsg = 1, LEN(errMsg)
            errMsg_c(vit_i_errMsg) = errMsg(vit_i_errMsg:vit_i_errMsg)
        END DO
        CALL dbemt_updatestates_c(i, j, t, n, C_LOC(u_view(1)), 2, uTimes, C_LOC(p_view), C_LOC(x_view), C_LOC(OtherState_view), C_LOC(m), errStat, errMsg_c)
        ! Copy C_CHAR arrays back to CHARACTER args (INTENT OUT/INOUT)
        DO vit_i_errMsg = 1, LEN(errMsg)
            errMsg(vit_i_errMsg:vit_i_errMsg) = errMsg_c(vit_i_errMsg)
        END DO
        ! Copy modified scalars back from view to Fortran type
        CALL vit_copy_scalars_to_dbemt_continuousstatetype(x_view, x)
        CALL vit_copy_scalars_to_dbemt_otherstatetype(OtherState_view, OtherState)
    END SUBROUTINE DBEMT_UpdateStates

!----------------------------------------------------------------------------------------------------------------------------------
!> This subroutine computes the (rotor) value of tau1 for DBEMT
!----------------------------------------------------------------------------------------------------------------------------------
    SUBROUTINE ComputeTau1(u, p, m, tau1, errStat, errMsg)
        USE ISO_C_BINDING
        USE vit_dbemt_inputtype_view, ONLY: dbemt_inputtype_view_t, vit_populate_dbemt_inputtype
        USE vit_dbemt_parametertype_view, ONLY: dbemt_parametertype_view_t, vit_populate_dbemt_parametertype
        IMPLICIT NONE
        TYPE(DBEMT_INPUTTYPE), INTENT(IN), TARGET :: u
        TYPE(DBEMT_PARAMETERTYPE), INTENT(IN), TARGET :: p
        TYPE(DBEMT_MISCVARTYPE), INTENT(INOUT), TARGET :: m
        REAL(8), INTENT(OUT) :: tau1
        INTEGER(4), INTENT(OUT) :: errStat
        CHARACTER(*), INTENT(OUT) :: errMsg
        CHARACTER(KIND=C_CHAR) :: errMsg_c(LEN(errMsg))
        INTEGER :: vit_i_errMsg
        TYPE(dbemt_inputtype_view_t), TARGET :: u_view
        TYPE(dbemt_parametertype_view_t), TARGET :: p_view
        ! Populate view structs from Fortran types
        CALL vit_populate_dbemt_inputtype(u, u_view)
        CALL vit_populate_dbemt_parametertype(p, p_view)
        ! Convert CHARACTER args to C_CHAR arrays
        DO vit_i_errMsg = 1, LEN(errMsg)
            errMsg_c(vit_i_errMsg) = errMsg(vit_i_errMsg:vit_i_errMsg)
        END DO
        CALL computetau1_c(C_LOC(u_view), C_LOC(p_view), C_LOC(m), tau1, errStat, errMsg_c)
        ! Copy C_CHAR arrays back to CHARACTER args (INTENT OUT/INOUT)
        DO vit_i_errMsg = 1, LEN(errMsg)
            errMsg(vit_i_errMsg:vit_i_errMsg) = errMsg_c(vit_i_errMsg)
        END DO
    END SUBROUTINE ComputeTau1
!----------------------------------------------------------------------------------------------------------------------------------
!> This subroutine computes the (rotor) value of tau1, tau2, and k_tau for DBEMT
!----------------------------------------------------------------------------------------------------------------------------------
    SUBROUTINE ComputeTau2(i, j, u, p, tau1, tau2, k_tau_out)
        USE ISO_C_BINDING
        USE vit_dbemt_parametertype_view, ONLY: dbemt_parametertype_view_t, vit_populate_dbemt_parametertype
        IMPLICIT NONE
        INTEGER(4), INTENT(IN) :: i
        INTEGER(4), INTENT(IN) :: j
        TYPE(DBEMT_ELEMENTINPUTTYPE), INTENT(IN), TARGET :: u
        TYPE(DBEMT_PARAMETERTYPE), INTENT(IN), TARGET :: p
        REAL(8), INTENT(IN) :: tau1
        REAL(8), INTENT(OUT) :: tau2
        REAL(8), INTENT(OUT), OPTIONAL :: k_tau_out
        TYPE(dbemt_parametertype_view_t), TARGET :: p_view

        ! Local variables for OPTIONAL args
        INTEGER(C_INT) :: has_k_tau_out_flag
        REAL(C_DOUBLE) :: k_tau_out_val

        has_k_tau_out_flag = 0
        k_tau_out_val = 0.0D0
        IF (PRESENT(k_tau_out)) THEN
            has_k_tau_out_flag = 1
            k_tau_out_val = REAL(k_tau_out, C_DOUBLE)
        END IF
        ! Populate view structs from Fortran types
        CALL vit_populate_dbemt_parametertype(p, p_view)
        CALL computetau2_c(i, j, C_LOC(u), C_LOC(p_view), tau1, tau2, has_k_tau_out_flag, k_tau_out_val)
        IF (PRESENT(k_tau_out)) k_tau_out = k_tau_out_val
    END SUBROUTINE ComputeTau2

!----------------------------------------------------------------------------------------------------------------------------------
!> Routine for computing outputs, used in both loose and tight coupling.
!! This subroutine is used to compute the output channels (motions and loads) and place them in the WriteOutput() array.
!! The descriptions of the output channels are not given here. Please see the included OutListParameters.xlsx sheet for
!! for a complete description of each output parameter.
    SUBROUTINE DBEMT_CalcOutput(i, j, t, u, y_vind, p, x, OtherState, m, errStat, errMsg)
        USE ISO_C_BINDING
        USE vit_dbemt_inputtype_view, ONLY: dbemt_inputtype_view_t, vit_populate_dbemt_inputtype
        USE vit_dbemt_parametertype_view, ONLY: dbemt_parametertype_view_t, vit_populate_dbemt_parametertype
        USE vit_dbemt_continuousstatetype_view, ONLY: dbemt_continuousstatetype_view_t, vit_populate_dbemt_continuousstatetype
        USE vit_dbemt_otherstatetype_view, ONLY: dbemt_otherstatetype_view_t, vit_populate_dbemt_otherstatetype
        IMPLICIT NONE
        INTEGER(4), INTENT(IN) :: i
        INTEGER(4), INTENT(IN) :: j
        REAL(8), INTENT(IN) :: t
        TYPE(DBEMT_INPUTTYPE), INTENT(IN), TARGET :: u
        REAL(8), INTENT(OUT) :: y_vind(2)
        TYPE(DBEMT_PARAMETERTYPE), INTENT(IN), TARGET :: p
        TYPE(DBEMT_CONTINUOUSSTATETYPE), INTENT(IN), TARGET :: x
        TYPE(DBEMT_OTHERSTATETYPE), INTENT(IN), TARGET :: OtherState
        TYPE(DBEMT_MISCVARTYPE), INTENT(INOUT), TARGET :: m
        INTEGER(4), INTENT(OUT) :: errStat
        CHARACTER(*), INTENT(OUT) :: errMsg
        CHARACTER(KIND=C_CHAR) :: errMsg_c(LEN(errMsg))
        INTEGER :: vit_i_errMsg
        TYPE(dbemt_inputtype_view_t), TARGET :: u_view
        TYPE(dbemt_parametertype_view_t), TARGET :: p_view
        TYPE(dbemt_continuousstatetype_view_t), TARGET :: x_view
        TYPE(dbemt_otherstatetype_view_t), TARGET :: OtherState_view
        ! Populate view structs from Fortran types
        CALL vit_populate_dbemt_inputtype(u, u_view)
        CALL vit_populate_dbemt_parametertype(p, p_view)
        CALL vit_populate_dbemt_continuousstatetype(x, x_view)
        CALL vit_populate_dbemt_otherstatetype(OtherState, OtherState_view)
        ! Convert CHARACTER args to C_CHAR arrays
        DO vit_i_errMsg = 1, LEN(errMsg)
            errMsg_c(vit_i_errMsg) = errMsg(vit_i_errMsg:vit_i_errMsg)
        END DO
        CALL dbemt_calcoutput_c(i, j, t, C_LOC(u_view), y_vind, C_LOC(p_view), C_LOC(x_view), C_LOC(OtherState_view), C_LOC(m), errStat, errMsg_c)
        ! Copy C_CHAR arrays back to CHARACTER args (INTENT OUT/INOUT)
        DO vit_i_errMsg = 1, LEN(errMsg)
            errMsg(vit_i_errMsg:vit_i_errMsg) = errMsg_c(vit_i_errMsg)
        END DO
    END SUBROUTINE DBEMT_CalcOutput

!----------------------------------------------------------------------------------------------------------------------------------
!> Tight coupling routine for computing derivatives of continuous states.
    SUBROUTINE DBEMT_CalcContStateDeriv(i, j, t, u, p, x, OtherState, m, dxdt, ErrStat, ErrMsg)
        USE ISO_C_BINDING
        USE vit_dbemt_parametertype_view, ONLY: dbemt_parametertype_view_t, vit_populate_dbemt_parametertype
        USE vit_dbemt_otherstatetype_view, ONLY: dbemt_otherstatetype_view_t, vit_populate_dbemt_otherstatetype
        IMPLICIT NONE
        INTEGER(4), INTENT(IN) :: i
        INTEGER(4), INTENT(IN) :: j
        REAL(8), INTENT(IN) :: t
        TYPE(DBEMT_ELEMENTINPUTTYPE), INTENT(IN), TARGET :: u
        TYPE(DBEMT_PARAMETERTYPE), INTENT(IN), TARGET :: p
        TYPE(DBEMT_ELEMENTCONTINUOUSSTATETYPE), INTENT(IN), TARGET :: x
        TYPE(DBEMT_OTHERSTATETYPE), INTENT(IN), TARGET :: OtherState
        TYPE(DBEMT_MISCVARTYPE), INTENT(INOUT), TARGET :: m
        TYPE(DBEMT_ELEMENTCONTINUOUSSTATETYPE), INTENT(OUT), TARGET :: dxdt
        INTEGER(4), INTENT(OUT) :: ErrStat
        CHARACTER(*), INTENT(OUT) :: ErrMsg
        CHARACTER(KIND=C_CHAR) :: ErrMsg_c(LEN(ErrMsg))
        INTEGER :: vit_i_ErrMsg
        TYPE(dbemt_parametertype_view_t), TARGET :: p_view
        TYPE(dbemt_otherstatetype_view_t), TARGET :: OtherState_view
        ! Populate view structs from Fortran types
        CALL vit_populate_dbemt_parametertype(p, p_view)
        CALL vit_populate_dbemt_otherstatetype(OtherState, OtherState_view)
        ! Convert CHARACTER args to C_CHAR arrays
        DO vit_i_ErrMsg = 1, LEN(ErrMsg)
            ErrMsg_c(vit_i_ErrMsg) = ErrMsg(vit_i_ErrMsg:vit_i_ErrMsg)
        END DO
        CALL dbemt_calccontstatederiv_c(i, j, t, C_LOC(u), C_LOC(p_view), C_LOC(x), C_LOC(OtherState_view), C_LOC(m), C_LOC(dxdt), ErrStat, ErrMsg_c)
        ! Copy C_CHAR arrays back to CHARACTER args (INTENT OUT/INOUT)
        DO vit_i_ErrMsg = 1, LEN(ErrMsg)
            ErrMsg(vit_i_ErrMsg:vit_i_ErrMsg) = ErrMsg_c(vit_i_ErrMsg)
        END DO
    END SUBROUTINE DBEMT_CalcContStateDeriv
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
    SUBROUTINE DBEMT_RK4(i, j, t, n, u, utimes, p, x, OtherState, m, ErrStat, ErrMsg)
        USE ISO_C_BINDING
        USE vit_dbemt_parametertype_view, ONLY: dbemt_parametertype_view_t, vit_populate_dbemt_parametertype
        USE vit_dbemt_continuousstatetype_view, ONLY: dbemt_continuousstatetype_view_t, vit_populate_dbemt_continuousstatetype
        USE vit_dbemt_otherstatetype_view, ONLY: dbemt_otherstatetype_view_t, vit_populate_dbemt_otherstatetype
        IMPLICIT NONE
        INTEGER(4), INTENT(IN) :: i
        INTEGER(4), INTENT(IN) :: j
        REAL(8), INTENT(IN) :: t
        INTEGER(4), INTENT(IN) :: n
        TYPE(DBEMT_ELEMENTINPUTTYPE), INTENT(IN), TARGET :: u(:)
        REAL(8), INTENT(IN) :: utimes(:)
        TYPE(DBEMT_PARAMETERTYPE), INTENT(IN), TARGET :: p
        TYPE(DBEMT_CONTINUOUSSTATETYPE), INTENT(INOUT), TARGET :: x
        TYPE(DBEMT_OTHERSTATETYPE), INTENT(INOUT), TARGET :: OtherState
        TYPE(DBEMT_MISCVARTYPE), INTENT(INOUT), TARGET :: m
        INTEGER(4), INTENT(OUT) :: ErrStat
        CHARACTER(*), INTENT(OUT) :: ErrMsg
        CHARACTER(KIND=C_CHAR) :: ErrMsg_c(LEN(ErrMsg))
        INTEGER :: vit_i_ErrMsg
        TYPE(dbemt_parametertype_view_t), TARGET :: p_view
        TYPE(dbemt_continuousstatetype_view_t), TARGET :: x_view
        TYPE(dbemt_otherstatetype_view_t), TARGET :: OtherState_view
        ! Populate view structs from Fortran types
        CALL vit_populate_dbemt_parametertype(p, p_view)
        CALL vit_populate_dbemt_continuousstatetype(x, x_view)
        CALL vit_populate_dbemt_otherstatetype(OtherState, OtherState_view)
        ! Convert CHARACTER args to C_CHAR arrays
        DO vit_i_ErrMsg = 1, LEN(ErrMsg)
            ErrMsg_c(vit_i_ErrMsg) = ErrMsg(vit_i_ErrMsg:vit_i_ErrMsg)
        END DO
        CALL dbemt_rk4_c(i, j, t, n, C_LOC(u(1)), SIZE(u), utimes, SIZE(utimes), C_LOC(p_view), C_LOC(x_view), C_LOC(OtherState_view), C_LOC(m), ErrStat, ErrMsg_c)
        ! Copy C_CHAR arrays back to CHARACTER args (INTENT OUT/INOUT)
        DO vit_i_ErrMsg = 1, LEN(ErrMsg)
            ErrMsg(vit_i_ErrMsg:vit_i_ErrMsg) = ErrMsg_c(vit_i_ErrMsg)
        END DO
    END SUBROUTINE DBEMT_RK4
!----------------------------------------------------------------------------------------------------------------------------------
!> This subroutine implements the fourth-order Adams-Bashforth Method (RK4) for numerically integrating ordinary differential 
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
    SUBROUTINE DBEMT_AB4(i, j, t, n, u, utimes, p, x, OtherState, m, ErrStat, ErrMsg)
        USE ISO_C_BINDING
        USE vit_dbemt_parametertype_view, ONLY: dbemt_parametertype_view_t, vit_populate_dbemt_parametertype
        USE vit_dbemt_continuousstatetype_view, ONLY: dbemt_continuousstatetype_view_t, vit_populate_dbemt_continuousstatetype
        USE vit_dbemt_otherstatetype_view, ONLY: dbemt_otherstatetype_view_t, vit_populate_dbemt_otherstatetype
        IMPLICIT NONE
        INTEGER(4), INTENT(IN) :: i
        INTEGER(4), INTENT(IN) :: j
        REAL(8), INTENT(IN) :: t
        INTEGER(4), INTENT(IN) :: n
        TYPE(DBEMT_ELEMENTINPUTTYPE), INTENT(IN), TARGET :: u(:)
        REAL(8), INTENT(IN) :: utimes(:)
        TYPE(DBEMT_PARAMETERTYPE), INTENT(IN), TARGET :: p
        TYPE(DBEMT_CONTINUOUSSTATETYPE), INTENT(INOUT), TARGET :: x
        TYPE(DBEMT_OTHERSTATETYPE), INTENT(INOUT), TARGET :: OtherState
        TYPE(DBEMT_MISCVARTYPE), INTENT(INOUT), TARGET :: m
        INTEGER(4), INTENT(OUT) :: ErrStat
        CHARACTER(*), INTENT(OUT) :: ErrMsg
        CHARACTER(KIND=C_CHAR) :: ErrMsg_c(LEN(ErrMsg))
        INTEGER :: vit_i_ErrMsg
        TYPE(dbemt_parametertype_view_t), TARGET :: p_view
        TYPE(dbemt_continuousstatetype_view_t), TARGET :: x_view
        TYPE(dbemt_otherstatetype_view_t), TARGET :: OtherState_view
        ! Populate view structs from Fortran types
        CALL vit_populate_dbemt_parametertype(p, p_view)
        CALL vit_populate_dbemt_continuousstatetype(x, x_view)
        CALL vit_populate_dbemt_otherstatetype(OtherState, OtherState_view)
        ! Convert CHARACTER args to C_CHAR arrays
        DO vit_i_ErrMsg = 1, LEN(ErrMsg)
            ErrMsg_c(vit_i_ErrMsg) = ErrMsg(vit_i_ErrMsg:vit_i_ErrMsg)
        END DO
        CALL dbemt_ab4_c(i, j, t, n, C_LOC(u(1)), SIZE(u), utimes, SIZE(utimes), C_LOC(p_view), C_LOC(x_view), C_LOC(OtherState_view), C_LOC(m), ErrStat, ErrMsg_c)
        ! Copy C_CHAR arrays back to CHARACTER args (INTENT OUT/INOUT)
        DO vit_i_ErrMsg = 1, LEN(ErrMsg)
            ErrMsg(vit_i_ErrMsg:vit_i_ErrMsg) = ErrMsg_c(vit_i_ErrMsg)
        END DO
    END SUBROUTINE DBEMT_AB4
!----------------------------------------------------------------------------------------------------------------------------------
!> This subroutine implements the fourth-order Adams-Bashforth-Moulton Method (RK4) for numerically integrating ordinary 
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
    SUBROUTINE DBEMT_ABM4(i, j, t, n, u, utimes, p, x, OtherState, m, ErrStat, ErrMsg)
        USE ISO_C_BINDING
        USE vit_dbemt_parametertype_view, ONLY: dbemt_parametertype_view_t, vit_populate_dbemt_parametertype
        USE vit_dbemt_continuousstatetype_view, ONLY: dbemt_continuousstatetype_view_t, vit_populate_dbemt_continuousstatetype
        USE vit_dbemt_otherstatetype_view, ONLY: dbemt_otherstatetype_view_t, vit_populate_dbemt_otherstatetype
        IMPLICIT NONE
        INTEGER(4), INTENT(IN) :: i
        INTEGER(4), INTENT(IN) :: j
        REAL(8), INTENT(IN) :: t
        INTEGER(4), INTENT(IN) :: n
        TYPE(DBEMT_ELEMENTINPUTTYPE), INTENT(IN), TARGET :: u(:)
        REAL(8), INTENT(IN) :: utimes(:)
        TYPE(DBEMT_PARAMETERTYPE), INTENT(IN), TARGET :: p
        TYPE(DBEMT_CONTINUOUSSTATETYPE), INTENT(INOUT), TARGET :: x
        TYPE(DBEMT_OTHERSTATETYPE), INTENT(INOUT), TARGET :: OtherState
        TYPE(DBEMT_MISCVARTYPE), INTENT(INOUT), TARGET :: m
        INTEGER(4), INTENT(OUT) :: ErrStat
        CHARACTER(*), INTENT(OUT) :: ErrMsg
        CHARACTER(KIND=C_CHAR) :: ErrMsg_c(LEN(ErrMsg))
        INTEGER :: vit_i_ErrMsg
        TYPE(dbemt_parametertype_view_t), TARGET :: p_view
        TYPE(dbemt_continuousstatetype_view_t), TARGET :: x_view
        TYPE(dbemt_otherstatetype_view_t), TARGET :: OtherState_view
        ! Populate view structs from Fortran types
        CALL vit_populate_dbemt_parametertype(p, p_view)
        CALL vit_populate_dbemt_continuousstatetype(x, x_view)
        CALL vit_populate_dbemt_otherstatetype(OtherState, OtherState_view)
        ! Convert CHARACTER args to C_CHAR arrays
        DO vit_i_ErrMsg = 1, LEN(ErrMsg)
            ErrMsg_c(vit_i_ErrMsg) = ErrMsg(vit_i_ErrMsg:vit_i_ErrMsg)
        END DO
        CALL dbemt_abm4_c(i, j, t, n, C_LOC(u(1)), SIZE(u), utimes, SIZE(utimes), C_LOC(p_view), C_LOC(x_view), C_LOC(OtherState_view), C_LOC(m), ErrStat, ErrMsg_c)
        ! Copy C_CHAR arrays back to CHARACTER args (INTENT OUT/INOUT)
        DO vit_i_ErrMsg = 1, LEN(ErrMsg)
            ErrMsg(vit_i_ErrMsg:vit_i_ErrMsg) = ErrMsg_c(vit_i_ErrMsg)
        END DO
    END SUBROUTINE DBEMT_ABM4
!----------------------------------------------------------------------------------------------------------------------------------
!> This routine is called at the end of the simulation.
subroutine DBEMT_End( u, p, x, OtherState, m, ErrStat, ErrMsg )
!..................................................................................................................................

      TYPE(DBEMT_InputType),           INTENT(INOUT)  :: u(2)           !< System inputs
      TYPE(DBEMT_ParameterType),       INTENT(INOUT)  :: p              !< Parameters
      TYPE(DBEMT_ContinuousStateType), INTENT(INOUT)  :: x              !< Continuous states
      type(DBEMT_MiscVarType),         intent(inout)  :: m              !< Initial misc/optimization variables
      type(DBEMT_OtherStateType),      intent(inout)  :: OtherState     !< Initial misc/optimization variables
      INTEGER(IntKi),                  INTENT(  OUT)  :: ErrStat        !< Error status of the operation
      CHARACTER(*),                    INTENT(  OUT)  :: ErrMsg         !< Error message if ErrStat /= ErrID_None



         ! Initialize ErrStat

      ErrStat = ErrID_None
      ErrMsg  = ""


         ! Place any last minute operations or calculations here:


         ! Close files here:



         ! Destroy the input data:

      CALL DBEMT_DestroyInput( u(1), ErrStat, ErrMsg )
      CALL DBEMT_DestroyInput( u(2), ErrStat, ErrMsg )


         ! Destroy the parameter data:

      CALL DBEMT_DestroyParam( p, ErrStat, ErrMsg )


         ! Destroy the state data:

      CALL DBEMT_DestroyContState(   x,           ErrStat, ErrMsg )


      CALL DBEMT_DestroyMisc(   m,           ErrStat, ErrMsg )
      CALL DBEMT_DestroyOtherState(   OtherState,           ErrStat, ErrMsg )


END SUBROUTINE DBEMT_End

end module DBEMT
