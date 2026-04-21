#!/bin/bash
# verify_aerodyn_baselines.sh
#
# Verify one or all AeroDyn test cases against our committed platform-specific baselines.
#
# The primary gate is bit-identical: our current build, run on vit-dev-openfast, should produce
# output byte-for-byte identical to the committed baseline (both are produced on the same
# platform, by the same container, with the same BLAS/gfortran/OS, so drift should be zero).
# If cmp -s fails, a Python diagnostic runs to report the max abs/rel drift per channel — this
# tells us whether the failure is a real regression or just a subtle environmental change.
#
# Exit code: 0 if all specified cases pass (bit-identical), non-zero if any fail.
#
# Invocation:
#   ./scripts/verify_aerodyn_baselines.sh ad_BAR_SineMotion  # one case
#   ./scripts/verify_aerodyn_baselines.sh all                # all cases with committed baselines
#
# Inside the container:
#   docker exec vit-dev-openfast bash -c "cd /workspace/openfast && ./scripts/verify_aerodyn_baselines.sh ad_BAR_SineMotion"
#
# Rationale and strategy context: vit/dev/202604140253-outb-format-and-verification-strategy.md

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
    if [[ ${#CASES[@]} -eq 0 ]]; then
        echo "No committed baselines found in $BASELINES_ROOT" >&2
        exit 2
    fi
else
    CASES=("$TARGET")
fi

# Ensure shared data directories are in place for cases that reference them
if [[ ! -d "$BAR_BASELINE_DST" ]]; then
    echo "Copying BAR_Baseline to build dir (shared by BAR-family cases)"
    cp -a "$BAR_BASELINE_SRC" "$BAR_BASELINE_DST"
fi
FMW_BASELINE_SRC="${RTEST_CASES_ROOT}/../../../glue-codes/openfast/5MW_Baseline"
FMW_BASELINE_DST="${OPENFAST_ROOT}/build/glue-codes/openfast/5MW_Baseline"
if [[ -d "$FMW_BASELINE_SRC" ]] && [[ ! -d "$FMW_BASELINE_DST" ]]; then
    echo "Copying 5MW_Baseline to build dir (shared by 5MW-family cases)"
    mkdir -p "$(dirname "$FMW_BASELINE_DST")"
    cp -a "$FMW_BASELINE_SRC" "$FMW_BASELINE_DST"
fi

PASSED=0
FAILED=0
FAILED_CASES=()

for CASE_NAME in "${CASES[@]}"; do
    BASELINE_FILE="${BASELINES_ROOT}/${CASE_NAME}/ad_driver.baseline.outb"
    if [[ ! -f "$BASELINE_FILE" ]]; then
        echo "✗ ${CASE_NAME}: no committed baseline at $BASELINE_FILE"
        FAILED=$((FAILED + 1))
        FAILED_CASES+=("$CASE_NAME")
        continue
    fi

    RTEST_CASE_DIR="${RTEST_CASES_ROOT}/${CASE_NAME}"
    if [[ ! -d "$RTEST_CASE_DIR" ]]; then
        echo "✗ ${CASE_NAME}: r-test case directory missing at $RTEST_CASE_DIR"
        FAILED=$((FAILED + 1))
        FAILED_CASES+=("$CASE_NAME")
        continue
    fi

    # Scratch subdirectory for this verification run
    SCRATCH="${BUILD_ROOT}/verify_${CASE_NAME}"
    rm -rf "$SCRATCH"
    mkdir -p "$SCRATCH"
    cp -a "${RTEST_CASE_DIR}/." "$SCRATCH/"
    # Remove the NREL reference so the driver's output can take its place
    rm -f "${SCRATCH}/ad_driver.outb"

    # Run the driver
    pushd "$SCRATCH" > /dev/null
    if ! "$DRIVER" ad_driver.dvr > driver.log 2>&1; then
        echo "✗ ${CASE_NAME}: aerodyn_driver failed (see ${SCRATCH}/driver.log)"
        popd > /dev/null
        FAILED=$((FAILED + 1))
        FAILED_CASES+=("$CASE_NAME")
        continue
    fi
    popd > /dev/null

    # Detect output-file variant (combined cases: .4.outb; multi-turbine: .T2.outb)
    OUR_OUT="${SCRATCH}/ad_driver.outb"
    if [[ -f "${SCRATCH}/ad_driver.T2.outb" ]]; then
        OUR_OUT="${SCRATCH}/ad_driver.T2.outb"
    elif [[ -f "${SCRATCH}/ad_driver.4.outb" ]]; then
        OUR_OUT="${SCRATCH}/ad_driver.4.outb"
    fi
    if [[ ! -f "$OUR_OUT" ]]; then
        echo "✗ ${CASE_NAME}: driver did not produce an output file"
        FAILED=$((FAILED + 1))
        FAILED_CASES+=("$CASE_NAME")
        continue
    fi

    # Primary gate: cmp -s (fast, catches any binary difference)
    if cmp -s "$OUR_OUT" "$BASELINE_FILE"; then
        echo "✓ ${CASE_NAME}: bit-identical vs our baseline ($(stat -c%s "$OUR_OUT") bytes)"
        PASSED=$((PASSED + 1))
    else
        # cmp -s failed — could be a header-only diff (e.g., .outb embeds scratch dir path
        # in the header, which differs between generator and verifier runs). Parse both files
        # with fast_io and compare the actual simulation data. If data is identical, count as
        # PASS with a note about the header-only binary diff.
        DATA_MATCH=$(python3 <<PYEOF
import sys
sys.path.insert(0, "${REG_LIB_DIR}")
from fast_io import load_output
import numpy as np

ours, info_ours, _ = load_output("${OUR_OUT}")
ref, info_ref, _ = load_output("${BASELINE_FILE}")

if ours.shape != ref.shape:
    print("SHAPE_MISMATCH")
elif np.array_equal(ours, ref):
    print("DATA_IDENTICAL")
else:
    abs_diff = np.abs(ours - ref)
    with np.errstate(divide='ignore', invalid='ignore'):
        rel_diff = np.where(np.abs(ref) > 1e-12, abs_diff / np.abs(ref), 0.0)
    n_exact = int((abs_diff == 0).sum())
    print(f"DATA_DIFFERS {n_exact}/{ours.size} {abs_diff.max():.6e} {rel_diff.max():.6e}")
    names = info_ref.get('attribute_names', [])
    max_abs_per_ch = abs_diff.max(axis=0)
    top = np.argsort(max_abs_per_ch)[::-1][:3]
    for c_idx in top:
        if max_abs_per_ch[c_idx] == 0: break
        ch_name = names[c_idx] if c_idx < len(names) else f"ch{c_idx}"
        print(f"  {ch_name}: max_abs={max_abs_per_ch[c_idx]:.3e}")
PYEOF
        )

        if [[ "$DATA_MATCH" == "DATA_IDENTICAL" ]]; then
            echo "✓ ${CASE_NAME}: data identical vs our baseline (header-only binary diff, $(stat -c%s "$OUR_OUT") vs $(stat -c%s "$BASELINE_FILE") bytes)"
            PASSED=$((PASSED + 1))
        else
            echo "✗ ${CASE_NAME}: does NOT match baseline"
            echo "    $DATA_MATCH"
            FAILED=$((FAILED + 1))
            FAILED_CASES+=("$CASE_NAME")
        fi
    fi
done

echo ""
echo "===================="
echo "Summary: ${PASSED} passed, ${FAILED} failed"
if [[ $FAILED -gt 0 ]]; then
    echo "Failed cases: ${FAILED_CASES[*]}"
    exit 1
fi
exit 0
