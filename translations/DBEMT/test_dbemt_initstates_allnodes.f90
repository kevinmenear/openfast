PROGRAM test_dbemt_initstates_allnodes
    USE ISO_C_BINDING
    USE NWTC_Library
    USE DBEMT_Types
    USE DBEMT
    USE vit_dbemt_inputtype_view
    USE vit_dbemt_parametertype_view
    USE vit_dbemt_continuousstatetype_view
    USE vit_dbemt_otherstatetype_view
    IMPLICIT NONE

    INTERFACE
        SUBROUTINE dbemt_initstates_allnodes_c(u, p, x, OtherState) BIND(C)
            USE ISO_C_BINDING
            TYPE(C_PTR), VALUE :: u, p, x, OtherState
        END SUBROUTINE
    END INTERFACE

    INTEGER :: passed, failed, total_tests
    passed = 0
    failed = 0

    CALL NWTC_Init()

    CALL test_all_uninitialized(3, 5, 2, passed, failed)
    CALL test_partial_init(3, 5, 2, passed, failed)
    CALL test_continuous_mode(2, 3, 3, passed, failed)
    CALL test_1x1_grid(1, 1, 2, passed, failed)

    total_tests = passed + failed
    WRITE(*,'(A)') ''
    WRITE(*,'(I3,A,I3,A)') passed, ' passed, ', failed, ' failed'
    IF (failed > 0) STOP 1

CONTAINS

    SUBROUTINE setup_types(NumNodes, NumBlades, DBEMT_Mod, u, p, x, OtherState)
        INTEGER, INTENT(IN) :: NumNodes, NumBlades, DBEMT_Mod
        TYPE(DBEMT_InputType), INTENT(OUT) :: u
        TYPE(DBEMT_ParameterType), INTENT(OUT) :: p
        TYPE(DBEMT_ContinuousStateType), INTENT(OUT) :: x
        TYPE(DBEMT_OtherStateType), INTENT(OUT) :: OtherState
        INTEGER :: i, j, k

        ALLOCATE(u%element(NumNodes, NumBlades))
        ALLOCATE(x%element(NumNodes, NumBlades))
        ALLOCATE(OtherState%areStatesInitialized(NumNodes, NumBlades))
        ALLOCATE(OtherState%n(NumNodes, NumBlades))
        DO k = 1, 4
            ALLOCATE(OtherState%xdot(k)%element(NumNodes, NumBlades))
        END DO

        p%DBEMT_Mod = DBEMT_Mod
        p%k_0ye = 0.3_ReKi
        p%tau1_const = 0.5_DbKi
        p%DT = 0.01_DbKi
        p%NumBlades = NumBlades
        p%NumNodes = NumNodes
        OtherState%tau1 = 0.5_DbKi
        OtherState%tau2 = 0.2_DbKi
        OtherState%areStatesInitialized = .FALSE.
        OtherState%n = -1

        DO j = 1, NumBlades
            DO i = 1, NumNodes
                u%element(i,j)%vind_s(1) = REAL(i, ReKi) + REAL(j, ReKi) * 10.0_ReKi
                u%element(i,j)%vind_s(2) = REAL(i, ReKi) * 2.0_ReKi + REAL(j, ReKi) * 20.0_ReKi
                u%element(i,j)%spanRatio = 0.5_ReKi
                x%element(i,j)%vind = 0.0_ReKi
                x%element(i,j)%vind_1 = 0.0_ReKi
            END DO
        END DO

        u%AxInd_disk = 0.3_ReKi
        u%Un_disk = 10.0_ReKi
        u%R_disk = 50.0_ReKi

        DO k = 1, 4
            DO j = 1, NumBlades
                DO i = 1, NumNodes
                    OtherState%xdot(k)%element(i,j)%vind = 0.0_ReKi
                    OtherState%xdot(k)%element(i,j)%vind_1 = 0.0_ReKi
                END DO
            END DO
        END DO
    END SUBROUTINE

    SUBROUTINE compare_results(label, NumNodes, NumBlades, x_f90, x_cpp, os_f90, os_cpp, passed, failed)
        CHARACTER(*), INTENT(IN) :: label
        INTEGER, INTENT(IN) :: NumNodes, NumBlades
        TYPE(DBEMT_ContinuousStateType), INTENT(IN) :: x_f90, x_cpp
        TYPE(DBEMT_OtherStateType), INTENT(IN) :: os_f90, os_cpp
        INTEGER, INTENT(INOUT) :: passed, failed
        INTEGER :: i, j
        LOGICAL :: ok

        ok = .TRUE.
        DO j = 1, NumBlades
            DO i = 1, NumNodes
                IF (x_f90%element(i,j)%vind(1) /= x_cpp%element(i,j)%vind(1) .OR. &
                    x_f90%element(i,j)%vind(2) /= x_cpp%element(i,j)%vind(2) .OR. &
                    x_f90%element(i,j)%vind_1(1) /= x_cpp%element(i,j)%vind_1(1) .OR. &
                    x_f90%element(i,j)%vind_1(2) /= x_cpp%element(i,j)%vind_1(2)) THEN
                    WRITE(*,'(A,A,A,I2,A,I2,A)') '  FAIL ', label, ' element(', i, ',', j, ') mismatch'
                    ok = .FALSE.
                END IF
                IF (os_f90%areStatesInitialized(i,j) .NEQV. os_cpp%areStatesInitialized(i,j)) THEN
                    WRITE(*,'(A,A,A,I2,A,I2,A)') '  FAIL ', label, ' areStatesInitialized(', i, ',', j, ') mismatch'
                    ok = .FALSE.
                END IF
            END DO
        END DO

        IF (ok) THEN
            WRITE(*,'(A,A)') '  PASS ', label
            passed = passed + 1
        ELSE
            failed = failed + 1
        END IF
    END SUBROUTINE

    SUBROUTINE call_cpp_allnodes(u, p, x, OtherState)
        TYPE(DBEMT_InputType), INTENT(IN), TARGET :: u
        TYPE(DBEMT_ParameterType), INTENT(IN), TARGET :: p
        TYPE(DBEMT_ContinuousStateType), INTENT(INOUT), TARGET :: x
        TYPE(DBEMT_OtherStateType), INTENT(INOUT), TARGET :: OtherState
        TYPE(dbemt_inputtype_view_t), TARGET :: u_view
        TYPE(dbemt_parametertype_view_t), TARGET :: p_view
        TYPE(dbemt_continuousstatetype_view_t), TARGET :: x_view
        TYPE(dbemt_otherstatetype_view_t), TARGET :: os_view

        CALL vit_populate_dbemt_inputtype(u, u_view)
        CALL vit_populate_dbemt_parametertype(p, p_view)
        CALL vit_populate_dbemt_continuousstatetype(x, x_view)
        CALL vit_populate_dbemt_otherstatetype(OtherState, os_view)
        CALL dbemt_initstates_allnodes_c(C_LOC(u_view), C_LOC(p_view), C_LOC(x_view), C_LOC(os_view))
        CALL vit_copy_scalars_to_dbemt_otherstatetype(os_view, OtherState)
    END SUBROUTINE

    SUBROUTINE test_all_uninitialized(NumBlades, NumNodes, DBEMT_Mod, passed, failed)
        INTEGER, INTENT(IN) :: NumBlades, NumNodes, DBEMT_Mod
        INTEGER, INTENT(INOUT) :: passed, failed
        TYPE(DBEMT_InputType) :: u
        TYPE(DBEMT_ParameterType) :: p
        TYPE(DBEMT_ContinuousStateType) :: x_f90, x_cpp
        TYPE(DBEMT_OtherStateType) :: os_f90, os_cpp
        INTEGER :: ErrStat
        CHARACTER(ErrMsgLen) :: ErrMsg

        CALL setup_types(NumNodes, NumBlades, DBEMT_Mod, u, p, x_f90, os_f90)
        CALL DBEMT_CopyContState(x_f90, x_cpp, MESH_NEWCOPY, ErrStat, ErrMsg)
        CALL DBEMT_CopyOtherState(os_f90, os_cpp, MESH_NEWCOPY, ErrStat, ErrMsg)

        CALL DBEMT_InitStates_AllNodes(u, p, x_f90, os_f90)
        CALL call_cpp_allnodes(u, p, x_cpp, os_cpp)

        CALL compare_results('all_uninitialized_3x5_mod2', NumNodes, NumBlades, x_f90, x_cpp, os_f90, os_cpp, passed, failed)
    END SUBROUTINE

    SUBROUTINE test_partial_init(NumBlades, NumNodes, DBEMT_Mod, passed, failed)
        INTEGER, INTENT(IN) :: NumBlades, NumNodes, DBEMT_Mod
        INTEGER, INTENT(INOUT) :: passed, failed
        TYPE(DBEMT_InputType) :: u
        TYPE(DBEMT_ParameterType) :: p
        TYPE(DBEMT_ContinuousStateType) :: x_f90, x_cpp
        TYPE(DBEMT_OtherStateType) :: os_f90, os_cpp
        INTEGER :: ErrStat
        CHARACTER(ErrMsgLen) :: ErrMsg

        CALL setup_types(NumNodes, NumBlades, DBEMT_Mod, u, p, x_f90, os_f90)

        os_f90%areStatesInitialized(1,1) = .TRUE.
        x_f90%element(1,1)%vind(1) = 99.0_ReKi
        x_f90%element(1,1)%vind(2) = 98.0_ReKi
        x_f90%element(1,1)%vind_1(1) = 97.0_ReKi
        x_f90%element(1,1)%vind_1(2) = 96.0_ReKi

        CALL DBEMT_CopyContState(x_f90, x_cpp, MESH_NEWCOPY, ErrStat, ErrMsg)
        CALL DBEMT_CopyOtherState(os_f90, os_cpp, MESH_NEWCOPY, ErrStat, ErrMsg)

        CALL DBEMT_InitStates_AllNodes(u, p, x_f90, os_f90)
        CALL call_cpp_allnodes(u, p, x_cpp, os_cpp)

        CALL compare_results('partial_init_3x5_mod2', NumNodes, NumBlades, x_f90, x_cpp, os_f90, os_cpp, passed, failed)
    END SUBROUTINE

    SUBROUTINE test_continuous_mode(NumBlades, NumNodes, DBEMT_Mod, passed, failed)
        INTEGER, INTENT(IN) :: NumBlades, NumNodes, DBEMT_Mod
        INTEGER, INTENT(INOUT) :: passed, failed
        TYPE(DBEMT_InputType) :: u
        TYPE(DBEMT_ParameterType) :: p
        TYPE(DBEMT_ContinuousStateType) :: x_f90, x_cpp
        TYPE(DBEMT_OtherStateType) :: os_f90, os_cpp
        INTEGER :: ErrStat
        CHARACTER(ErrMsgLen) :: ErrMsg

        CALL setup_types(NumNodes, NumBlades, DBEMT_Mod, u, p, x_f90, os_f90)
        CALL DBEMT_CopyContState(x_f90, x_cpp, MESH_NEWCOPY, ErrStat, ErrMsg)
        CALL DBEMT_CopyOtherState(os_f90, os_cpp, MESH_NEWCOPY, ErrStat, ErrMsg)

        CALL DBEMT_InitStates_AllNodes(u, p, x_f90, os_f90)
        CALL call_cpp_allnodes(u, p, x_cpp, os_cpp)

        CALL compare_results('continuous_mode_2x3_mod3', NumNodes, NumBlades, x_f90, x_cpp, os_f90, os_cpp, passed, failed)
    END SUBROUTINE

    SUBROUTINE test_1x1_grid(NumBlades, NumNodes, DBEMT_Mod, passed, failed)
        INTEGER, INTENT(IN) :: NumBlades, NumNodes, DBEMT_Mod
        INTEGER, INTENT(INOUT) :: passed, failed
        TYPE(DBEMT_InputType) :: u
        TYPE(DBEMT_ParameterType) :: p
        TYPE(DBEMT_ContinuousStateType) :: x_f90, x_cpp
        TYPE(DBEMT_OtherStateType) :: os_f90, os_cpp
        INTEGER :: ErrStat
        CHARACTER(ErrMsgLen) :: ErrMsg

        CALL setup_types(NumNodes, NumBlades, DBEMT_Mod, u, p, x_f90, os_f90)
        CALL DBEMT_CopyContState(x_f90, x_cpp, MESH_NEWCOPY, ErrStat, ErrMsg)
        CALL DBEMT_CopyOtherState(os_f90, os_cpp, MESH_NEWCOPY, ErrStat, ErrMsg)

        CALL DBEMT_InitStates_AllNodes(u, p, x_f90, os_f90)
        CALL call_cpp_allnodes(u, p, x_cpp, os_cpp)

        CALL compare_results('edge_case_1x1_mod2', NumNodes, NumBlades, x_f90, x_cpp, os_f90, os_cpp, passed, failed)
    END SUBROUTINE

END PROGRAM
