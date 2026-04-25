! VIT: Kernel callee bridge for ComputeUA360_CnOffset
! Allows C++ translations to call the original Fortran function.
    FUNCTION computeua360_cnoffset_bridge(p, cn_cl, n_cn_cl, Row, iLower) &
        BIND(C, NAME='computeua360_cnoffset_c') RESULT(bridge_result)
        USE ISO_C_BINDING
        USE AirfoilInfo, ONLY: ComputeUA360_CnOffset
        USE vit_afi_table_type_view, ONLY: vit_original_afi_table_type
        IMPLICIT NONE
        TYPE(C_PTR), VALUE :: p
        REAL(C_DOUBLE), INTENT(IN) :: cn_cl(*)
        INTEGER(C_INT), VALUE :: n_cn_cl
        INTEGER(C_INT), VALUE :: Row
        INTEGER(C_INT), VALUE :: iLower
        REAL(C_DOUBLE) :: bridge_result
        bridge_result = REAL(ComputeUA360_CnOffset(vit_original_afi_table_type, cn_cl(1:n_cn_cl), Row, iLower), C_DOUBLE)
    END FUNCTION computeua360_cnoffset_bridge