! VIT: Kernel callee bridge for InterpExtrapStp
! Allows C++ translations to call the original Fortran function.
    FUNCTION interpextrapstp_bridge(XVal, XAry, YAry, Ind, AryLen) &
        BIND(C, NAME='interpextrapstp_c') RESULT(bridge_result)
        USE ISO_C_BINDING
        USE NWTC_Num, ONLY: InterpExtrapStp
        IMPLICIT NONE
        REAL(C_DOUBLE), VALUE :: XVal
        REAL(C_DOUBLE), INTENT(IN) :: XAry(*)
        REAL(C_DOUBLE), INTENT(IN) :: YAry(*)
        INTEGER(C_INT), INTENT(INOUT) :: Ind
        INTEGER(C_INT), VALUE :: AryLen
        REAL(C_DOUBLE) :: bridge_result
        bridge_result = REAL(InterpExtrapStp(XVal, XAry, YAry, Ind, AryLen), C_DOUBLE)
    END FUNCTION interpextrapstp_bridge