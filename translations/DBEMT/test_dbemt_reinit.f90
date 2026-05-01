PROGRAM test_dbemt_reinit
    USE ISO_C_BINDING
    USE NWTC_Library
    USE DBEMT_Types
    USE DBEMT
    USE vit_dbemt_parametertype_view
    USE vit_dbemt_continuousstatetype_view
    USE vit_dbemt_otherstatetype_view
    IMPLICIT NONE

    INTERFACE
        SUBROUTINE dbemt_reinit_c(p, x, OtherState, m) BIND(C)
            USE ISO_C_BINDING
            TYPE(C_PTR), VALUE :: p, x, OtherState, m
        END SUBROUTINE
    END INTERFACE

    INTEGER :: passed, failed

    passed = 0
    failed = 0

    CALL NWTC_Init()

    CALL test_tauconst_allocated(passed, failed)
    CALL test_tauvaries_allocated(passed, failed)
    CALL test_cont_tauconst(passed, failed)
    CALL test_n_not_allocated(passed, failed)

    WRITE(*,'(A)') ''
    WRITE(*,'(I3,A,I3,A)') passed, ' passed, ', failed, ' failed'
    IF (failed > 0) STOP 1

CONTAINS

    SUBROUTINE setup_types(NumNodes, NumBlades, DBEMT_Mod, allocate_n, p, x, OtherState, m)
        INTEGER, INTENT(IN) :: NumNodes, NumBlades, DBEMT_Mod
        LOGICAL, INTENT(IN) :: allocate_n
        TYPE(DBEMT_ParameterType), INTENT(OUT) :: p
        TYPE(DBEMT_ContinuousStateType), INTENT(OUT) :: x
        TYPE(DBEMT_OtherStateType), INTENT(OUT) :: OtherState
        TYPE(DBEMT_MiscVarType), INTENT(OUT) :: m
        INTEGER :: i, j, k

        ALLOCATE(x%element(NumNodes, NumBlades))
        ALLOCATE(OtherState%areStatesInitialized(NumNodes, NumBlades))
        IF (allocate_n) THEN
            ALLOCATE(OtherState%n(NumNodes, NumBlades))
            DO k = 1, 4
                ALLOCATE(OtherState%xdot(k)%element(NumNodes, NumBlades))
            END DO
        END IF

        p%DBEMT_Mod = DBEMT_Mod
        p%k_0ye = 0.3_ReKi
        p%tau1_const = 0.75_ReKi
        p%DT = 0.01_DbKi
        p%NumBlades = NumBlades
        p%NumNodes = NumNodes

        OtherState%tau1 = 99.0_ReKi
        OtherState%tau2 = 88.0_ReKi
        OtherState%areStatesInitialized = .TRUE.
        IF (allocate_n) OtherState%n = 5

        DO j = 1, NumBlades
            DO i = 1, NumNodes
                x%element(i,j)%vind(1) = REAL(i + j*10, ReKi)
                x%element(i,j)%vind(2) = REAL(i + j*10, ReKi) + 0.5_ReKi
                x%element(i,j)%vind_1(1) = REAL(i + j*10, ReKi) * 2.0_ReKi
                x%element(i,j)%vind_1(2) = REAL(i + j*10, ReKi) * 2.0_ReKi + 0.5_ReKi
            END DO
        END DO

        IF (allocate_n) THEN
            DO k = 1, 4
                DO j = 1, NumBlades
                    DO i = 1, NumNodes
                        OtherState%xdot(k)%element(i,j)%vind(1) = 77.0_ReKi
                        OtherState%xdot(k)%element(i,j)%vind(2) = 78.0_ReKi
                        OtherState%xdot(k)%element(i,j)%vind_1(1) = 79.0_ReKi
                        OtherState%xdot(k)%element(i,j)%vind_1(2) = 80.0_ReKi
                    END DO
                END DO
            END DO
        END IF

        m%FirstWarn_tau1 = .FALSE.
    END SUBROUTINE

    SUBROUTINE call_cpp_reinit(p, x, OtherState, m)
        TYPE(DBEMT_ParameterType), INTENT(IN), TARGET :: p
        TYPE(DBEMT_ContinuousStateType), INTENT(INOUT), TARGET :: x
        TYPE(DBEMT_OtherStateType), INTENT(INOUT), TARGET :: OtherState
        TYPE(DBEMT_MiscVarType), INTENT(INOUT), TARGET :: m
        TYPE(dbemt_parametertype_view_t), TARGET :: p_view
        TYPE(dbemt_continuousstatetype_view_t), TARGET :: x_view
        TYPE(dbemt_otherstatetype_view_t), TARGET :: os_view

        CALL vit_populate_dbemt_parametertype(p, p_view)
        CALL vit_populate_dbemt_continuousstatetype(x, x_view)
        CALL vit_populate_dbemt_otherstatetype(OtherState, os_view)
        CALL dbemt_reinit_c(C_LOC(p_view), C_LOC(x_view), C_LOC(os_view), C_LOC(m))
        CALL vit_copy_scalars_to_dbemt_otherstatetype(os_view, OtherState)
    END SUBROUTINE

    SUBROUTINE compare_reinit(label, NumNodes, NumBlades, allocate_n, expected_tau1, &
                              x_f90, x_cpp, os_f90, os_cpp, m_f90, m_cpp, passed, failed)
        CHARACTER(*), INTENT(IN) :: label
        INTEGER, INTENT(IN) :: NumNodes, NumBlades
        LOGICAL, INTENT(IN) :: allocate_n
        REAL(ReKi), INTENT(IN) :: expected_tau1
        TYPE(DBEMT_ContinuousStateType), INTENT(IN) :: x_f90, x_cpp
        TYPE(DBEMT_OtherStateType), INTENT(IN) :: os_f90, os_cpp
        TYPE(DBEMT_MiscVarType), INTENT(IN) :: m_f90, m_cpp
        INTEGER, INTENT(INOUT) :: passed, failed
        INTEGER :: i, j, k
        LOGICAL :: ok

        ok = .TRUE.

        DO j = 1, NumBlades
            DO i = 1, NumNodes
                IF (x_f90%element(i,j)%vind(1) /= x_cpp%element(i,j)%vind(1) .OR. &
                    x_f90%element(i,j)%vind(2) /= x_cpp%element(i,j)%vind(2) .OR. &
                    x_f90%element(i,j)%vind_1(1) /= x_cpp%element(i,j)%vind_1(1) .OR. &
                    x_f90%element(i,j)%vind_1(2) /= x_cpp%element(i,j)%vind_1(2)) THEN
                    WRITE(*,'(A,A,A,I2,A,I2,A)') '  FAIL ', label, ' x%element(', i, ',', j, ') mismatch'
                    ok = .FALSE.
                END IF
                IF (os_f90%areStatesInitialized(i,j) .NEQV. os_cpp%areStatesInitialized(i,j)) THEN
                    WRITE(*,'(A,A,A,I2,A,I2,A)') '  FAIL ', label, ' areStatesInitialized(', i, ',', j, ') mismatch'
                    ok = .FALSE.
                END IF
            END DO
        END DO

        IF (os_f90%tau1 /= os_cpp%tau1) THEN
            WRITE(*,'(A,A,A,ES15.8,A,ES15.8)') '  FAIL ', label, ' tau1: f90=', os_f90%tau1, ' cpp=', os_cpp%tau1
            ok = .FALSE.
        END IF

        IF (allocate_n) THEN
            DO j = 1, NumBlades
                DO i = 1, NumNodes
                    IF (os_f90%n(i,j) /= os_cpp%n(i,j)) THEN
                        WRITE(*,'(A,A,A,I2,A,I2,A)') '  FAIL ', label, ' n(', i, ',', j, ') mismatch'
                        ok = .FALSE.
                    END IF
                END DO
            END DO

            DO k = 1, 4
                DO j = 1, NumBlades
                    DO i = 1, NumNodes
                        IF (os_f90%xdot(k)%element(i,j)%vind(1) /= os_cpp%xdot(k)%element(i,j)%vind(1) .OR. &
                            os_f90%xdot(k)%element(i,j)%vind(2) /= os_cpp%xdot(k)%element(i,j)%vind(2) .OR. &
                            os_f90%xdot(k)%element(i,j)%vind_1(1) /= os_cpp%xdot(k)%element(i,j)%vind_1(1) .OR. &
                            os_f90%xdot(k)%element(i,j)%vind_1(2) /= os_cpp%xdot(k)%element(i,j)%vind_1(2)) THEN
                            WRITE(*,'(A,A,A,I1,A,I2,A,I2,A)') '  FAIL ', label, &
                                ' xdot(', k, ')%element(', i, ',', j, ') mismatch'
                            ok = .FALSE.
                        END IF
                    END DO
                END DO
            END DO
        END IF

        IF (m_f90%FirstWarn_tau1 .NEQV. m_cpp%FirstWarn_tau1) THEN
            WRITE(*,'(A,A,A)') '  FAIL ', label, ' FirstWarn_tau1 mismatch'
            ok = .FALSE.
        END IF

        IF (ok) THEN
            WRITE(*,'(A,A)') '  PASS ', label
            passed = passed + 1
        ELSE
            failed = failed + 1
        END IF
    END SUBROUTINE

    SUBROUTINE test_tauconst_allocated(passed, failed)
        INTEGER, INTENT(INOUT) :: passed, failed
        TYPE(DBEMT_ParameterType) :: p
        TYPE(DBEMT_ContinuousStateType) :: x_f90, x_cpp
        TYPE(DBEMT_OtherStateType) :: os_f90, os_cpp
        TYPE(DBEMT_MiscVarType) :: m_f90, m_cpp
        INTEGER :: ErrStat
        CHARACTER(ErrMsgLen) :: ErrMsg

        CALL setup_types(5, 3, DBEMT_tauConst, .TRUE., p, x_f90, os_f90, m_f90)
        CALL DBEMT_CopyContState(x_f90, x_cpp, MESH_NEWCOPY, ErrStat, ErrMsg)
        CALL DBEMT_CopyOtherState(os_f90, os_cpp, MESH_NEWCOPY, ErrStat, ErrMsg)
        m_cpp = m_f90

        CALL DBEMT_ReInit(p, x_f90, os_f90, m_f90)
        CALL call_cpp_reinit(p, x_cpp, os_cpp, m_cpp)

        CALL compare_reinit('tauConst_alloc_5x3', 5, 3, .TRUE., p%tau1_const, &
                            x_f90, x_cpp, os_f90, os_cpp, m_f90, m_cpp, passed, failed)
    END SUBROUTINE

    SUBROUTINE test_tauvaries_allocated(passed, failed)
        INTEGER, INTENT(INOUT) :: passed, failed
        TYPE(DBEMT_ParameterType) :: p
        TYPE(DBEMT_ContinuousStateType) :: x_f90, x_cpp
        TYPE(DBEMT_OtherStateType) :: os_f90, os_cpp
        TYPE(DBEMT_MiscVarType) :: m_f90, m_cpp
        INTEGER :: ErrStat
        CHARACTER(ErrMsgLen) :: ErrMsg

        CALL setup_types(3, 2, DBEMT_tauVaries, .TRUE., p, x_f90, os_f90, m_f90)
        CALL DBEMT_CopyContState(x_f90, x_cpp, MESH_NEWCOPY, ErrStat, ErrMsg)
        CALL DBEMT_CopyOtherState(os_f90, os_cpp, MESH_NEWCOPY, ErrStat, ErrMsg)
        m_cpp = m_f90

        CALL DBEMT_ReInit(p, x_f90, os_f90, m_f90)
        CALL call_cpp_reinit(p, x_cpp, os_cpp, m_cpp)

        CALL compare_reinit('tauVaries_alloc_3x2', 3, 2, .TRUE., 0.0_ReKi, &
                            x_f90, x_cpp, os_f90, os_cpp, m_f90, m_cpp, passed, failed)
    END SUBROUTINE

    SUBROUTINE test_cont_tauconst(passed, failed)
        INTEGER, INTENT(INOUT) :: passed, failed
        TYPE(DBEMT_ParameterType) :: p
        TYPE(DBEMT_ContinuousStateType) :: x_f90, x_cpp
        TYPE(DBEMT_OtherStateType) :: os_f90, os_cpp
        TYPE(DBEMT_MiscVarType) :: m_f90, m_cpp
        INTEGER :: ErrStat
        CHARACTER(ErrMsgLen) :: ErrMsg

        CALL setup_types(2, 2, DBEMT_cont_tauConst, .TRUE., p, x_f90, os_f90, m_f90)
        CALL DBEMT_CopyContState(x_f90, x_cpp, MESH_NEWCOPY, ErrStat, ErrMsg)
        CALL DBEMT_CopyOtherState(os_f90, os_cpp, MESH_NEWCOPY, ErrStat, ErrMsg)
        m_cpp = m_f90

        CALL DBEMT_ReInit(p, x_f90, os_f90, m_f90)
        CALL call_cpp_reinit(p, x_cpp, os_cpp, m_cpp)

        CALL compare_reinit('cont_tauConst_2x2', 2, 2, .TRUE., p%tau1_const, &
                            x_f90, x_cpp, os_f90, os_cpp, m_f90, m_cpp, passed, failed)
    END SUBROUTINE

    SUBROUTINE test_n_not_allocated(passed, failed)
        INTEGER, INTENT(INOUT) :: passed, failed
        TYPE(DBEMT_ParameterType) :: p
        TYPE(DBEMT_ContinuousStateType) :: x_f90, x_cpp
        TYPE(DBEMT_OtherStateType) :: os_f90, os_cpp
        TYPE(DBEMT_MiscVarType) :: m_f90, m_cpp
        INTEGER :: ErrStat
        CHARACTER(ErrMsgLen) :: ErrMsg

        CALL setup_types(3, 2, DBEMT_tauConst, .FALSE., p, x_f90, os_f90, m_f90)
        CALL DBEMT_CopyContState(x_f90, x_cpp, MESH_NEWCOPY, ErrStat, ErrMsg)
        CALL DBEMT_CopyOtherState(os_f90, os_cpp, MESH_NEWCOPY, ErrStat, ErrMsg)
        m_cpp = m_f90

        CALL DBEMT_ReInit(p, x_f90, os_f90, m_f90)
        CALL call_cpp_reinit(p, x_cpp, os_cpp, m_cpp)

        CALL compare_reinit('n_not_alloc_3x2', 3, 2, .FALSE., p%tau1_const, &
                            x_f90, x_cpp, os_f90, os_cpp, m_f90, m_cpp, passed, failed)
    END SUBROUTINE

END PROGRAM test_dbemt_reinit
