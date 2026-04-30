! VIT: Production bridge for DBEMT_ElementInputType_ExtrapInterp
! Allows C++ translations to call the Fortran ExtrapInterp routine.
SUBROUTINE dbemt_elementinputtype_extrapinterp_bridge(u, n_u, t, n_t, u_out, t_out, ErrStat, ErrMsg) &
    BIND(C, NAME='dbemt_elementinputtype_extrapinterp_c')
    USE ISO_C_BINDING
    USE DBEMT_Types, ONLY: DBEMT_ElementInputType_ExtrapInterp, DBEMT_ElementInputType
    IMPLICIT NONE
    TYPE(C_PTR), VALUE :: u
    INTEGER(C_INT), VALUE :: n_u
    REAL(C_DOUBLE), INTENT(IN) :: t(*)
    INTEGER(C_INT), VALUE :: n_t
    TYPE(C_PTR), VALUE :: u_out
    REAL(C_DOUBLE), VALUE :: t_out
    INTEGER(C_INT), INTENT(OUT) :: ErrStat
    CHARACTER(KIND=C_CHAR), INTENT(OUT) :: ErrMsg(*)
    TYPE(DBEMT_ElementInputType), POINTER :: u_f(:)
    TYPE(DBEMT_ElementInputType), POINTER :: u_out_f
    CHARACTER(8196) :: local_ErrMsg
    INTEGER :: vit_i
    CALL C_F_POINTER(u, u_f, [n_u])
    CALL C_F_POINTER(u_out, u_out_f)
    CALL DBEMT_ElementInputType_ExtrapInterp(u_f(1:n_u), t(1:n_t), u_out_f, t_out, ErrStat, local_ErrMsg)
    DO vit_i = 1, MIN(LEN_TRIM(local_ErrMsg), 8196)
        ErrMsg(vit_i) = local_ErrMsg(vit_i:vit_i)
    END DO
END SUBROUTINE dbemt_elementinputtype_extrapinterp_bridge
