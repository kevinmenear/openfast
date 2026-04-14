#!/bin/bash
# check_aerodyn_nrel_drift.sh
#
# Informational check: how much does our AeroDyn output drift from NREL's shipped r-test reference?
#
# This is NOT a gate. It always exits 0 unless the driver itself fails. The purpose is to track
# cross-platform floating-point drift over time — specifically, whether our OpenBLAS/gfortran/ARM64
# stack drifts further from NREL's reference over time (e.g., after a Docker rebuild, a BLAS
# version bump, or an OpenFAST upstream merge). Use verify_aerodyn_baselines.sh for the actual
# regression gate; this script is a sanity signal.
#
# For each case, the script:
#   1. Runs aerodyn_driver on a scratch copy of the inputs
#   2. Parses both our output and the r-test reference via fast_io.load_output
#   3. Prints a summary: bit-identical count, max abs/rel drift, top 5 drifting channels
#
# Invocation:
#   ./scripts/check_aerodyn_nrel_drift.sh ad_BAR_SineMotion  # one case
#   ./scripts/check_aerodyn_nrel_drift.sh all                # all cases with committed baselines
#
# Rationale: vit/dev/202604140253-outb-format-and-verification-strategy.md

set -euo pipefail

TARGET="${1:-}"
if [[ -z "$TARGET" ]]; then
    echo "Usage: $0 <case_name | all>" >&2
    exit 1
fi

OPENFAST_ROOT="/workspace/openfast"
BASELINES_ROOT="${OPENFAST_ROOT}/baselines/aerodyn"
BUILD_ROOT="${OPENFAST_ROOT}/build/modules/aerodyn"
DRIVER="${BUILD_ROOT}/aerodyn_driver"
REG_LIB_DIR="${OPENFAST_ROOT}/reg_tests/lib"
RTEST_CASES_ROOT="${OPENFAST_ROOT}/reg_tests/r-test/modules/aerodyn"
BAR_BASELINE_SRC="${RTEST_CASES_ROOT}/BAR_Baseline"
BAR_BASELINE_DST="${BUILD_ROOT}/BAR_Baseline"

if [[ ! -x "$DRIVER" ]]; then
    echo "ERROR: aerodyn_driver not built at $DRIVER" >&2
    exit 2
fi

# Resolve target list
if [[ "$TARGET" == "all" ]]; then
    mapfile -t CASES < <(find "$BASELINES_ROOT" -mindepth 1 -maxdepth 1 -type d -exec basename {} \; | sort)
else
    CASES=("$TARGET")
fi

# Ensure BAR_Baseline is in place
if [[ ! -d "$BAR_BASELINE_DST" ]]; then
    cp -a "$BAR_BASELINE_SRC" "$BAR_BASELINE_DST"
fi

for CASE_NAME in "${CASES[@]}"; do
    RTEST_CASE_DIR="${RTEST_CASES_ROOT}/${CASE_NAME}"
    REF_OUT="${RTEST_CASE_DIR}/ad_driver.outb"
    if [[ ! -f "$REF_OUT" ]]; then
        echo "✗ ${CASE_NAME}: NREL reference not found at $REF_OUT"
        continue
    fi

    SCRATCH="${BUILD_ROOT}/nrel_drift_${CASE_NAME}"
    rm -rf "$SCRATCH"
    mkdir -p "$SCRATCH"
    cp -a "${RTEST_CASE_DIR}/." "$SCRATCH/"
    # Remove the reference so the driver's output can take its place
    rm -f "${SCRATCH}/ad_driver.outb"

    pushd "$SCRATCH" > /dev/null
    if ! "$DRIVER" ad_driver.dvr > driver.log 2>&1; then
        echo "✗ ${CASE_NAME}: aerodyn_driver failed"
        popd > /dev/null
        continue
    fi
    popd > /dev/null

    OUR_OUT="${SCRATCH}/ad_driver.outb"

    echo "=== ${CASE_NAME} drift vs NREL r-test reference ==="
    python3 <<PYEOF
import sys
sys.path.insert(0, "${REG_LIB_DIR}")
from fast_io import load_output
import numpy as np

ours, info_ours, _ = load_output("${OUR_OUT}")
ref, info_ref, _ = load_output("${REF_OUT}")

if ours.shape != ref.shape:
    print(f"  SHAPE MISMATCH: ours={ours.shape}, ref={ref.shape}")
    sys.exit(0)

abs_diff = np.abs(ours - ref)
with np.errstate(divide='ignore', invalid='ignore'):
    rel_diff = np.where(np.abs(ref) > 1e-12, abs_diff / np.abs(ref), 0.0)

n = ours.size
n_exact = int((abs_diff == 0).sum())
n_1e5 = int((rel_diff < 1e-5).sum())
n_combined = int(((rel_diff < 1e-5) | (abs_diff < 1e-6)).sum())

print(f"  Array shape:              {ours.shape}  ({n} values)")
print(f"  Bit-identical:            {n_exact:>6d} / {n} ({100*n_exact/n:.2f}%)")
print(f"  Within 1e-5 rel:          {n_1e5:>6d} / {n} ({100*n_1e5/n:.2f}%)")
print(f"  Within 1e-5 rel OR 1e-6:  {n_combined:>6d} / {n} ({100*n_combined/n:.2f}%)")
print(f"  Max abs drift:            {abs_diff.max():.6e}")
print(f"  Max rel drift:            {rel_diff.max():.6e}")

# Top 5 drifting channels
names = info_ref.get('attribute_names', [])
units = info_ref.get('attribute_units', [])
max_abs_per_ch = abs_diff.max(axis=0)
top = np.argsort(max_abs_per_ch)[::-1][:5]
print(f"  Top drifting channels:")
for c_idx in top:
    if max_abs_per_ch[c_idx] == 0:
        break
    ch_name = names[c_idx] if c_idx < len(names) else f"ch{c_idx}"
    ch_unit = units[c_idx] if c_idx < len(units) else ""
    worst_t = int(abs_diff[:, c_idx].argmax())
    ref_val = ref[worst_t, c_idx]
    rel = max_abs_per_ch[c_idx] / abs(ref_val) if abs(ref_val) > 1e-12 else float('inf')
    print(f"    {ch_name:<22s} ({ch_unit:<8s})  abs={max_abs_per_ch[c_idx]:.3e}  rel={rel:.3e}")
PYEOF
    echo ""
done

exit 0
