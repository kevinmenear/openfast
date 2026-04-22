#!/bin/bash
# run_nrel_regression.sh
#
# Wrapper around NREL's executeAerodynRegressionCase.py that handles shared-data
# setup (BAR_Baseline, 5MW_Baseline) before running. Produces a clean 16/16 PASS
# in a single command with no manual prerequisites.
#
# Usage:
#   ./scripts/run_nrel_regression.sh <case | all> [rtol] [atol]
#
# Examples:
#   ./scripts/run_nrel_regression.sh all                    # NREL's default tolerance (rtol=2, atol=1.9)
#   ./scripts/run_nrel_regression.sh all 5 5                # stricter tolerance (1e-5)
#   ./scripts/run_nrel_regression.sh ad_BAR_SineMotion      # single case
#   ./scripts/run_nrel_regression.sh ad_BAR_SineMotion 2 2  # single case, custom tolerance
#
# Inside the container:
#   docker exec vit-dev-openfast bash -c "cd /workspace/openfast && ./scripts/run_nrel_regression.sh all"

set -euo pipefail

TARGET="${1:-}"
RTOL="${2:-2}"
ATOL="${3:-1.9}"

if [[ -z "$TARGET" ]]; then
    echo "Usage: $0 <case_name | all> [rtol] [atol]" >&2
    echo "" >&2
    echo "  rtol/atol are order-of-magnitude tolerances (NREL default: rtol=2 atol=1.9)" >&2
    echo "  rtol=2 means 1e-2 relative tolerance; rtol=5 means 1e-5" >&2
    exit 1
fi

OPENFAST_ROOT="/workspace/openfast"
DRIVER="${OPENFAST_ROOT}/build/modules/aerodyn/aerodyn_driver"
RTEST_AD="${OPENFAST_ROOT}/reg_tests/r-test/modules/aerodyn"
BUILD_AD="${OPENFAST_ROOT}/build/modules/aerodyn"
REG_SCRIPT="${OPENFAST_ROOT}/reg_tests/executeAerodynRegressionCase.py"

# Preconditions
if [[ ! -x "$DRIVER" ]]; then
    echo "ERROR: aerodyn_driver not built at $DRIVER" >&2
    echo "       Run: cd build && cmake .. && make aerodyn_driver -j\$(nproc)" >&2
    exit 2
fi
if [[ ! -f "$REG_SCRIPT" ]]; then
    echo "ERROR: NREL regression script not found at $REG_SCRIPT" >&2
    exit 2
fi

# ============================================================
# Setup shared data directories that some test cases reference
# via deep relative paths (../../../glue-codes/...) from the
# scratch build directory. NREL's script handles BAR_Baseline
# but not 5MW_Baseline.
# ============================================================
BAR_SRC="${RTEST_AD}/BAR_Baseline"
BAR_DST="${BUILD_AD}/BAR_Baseline"
if [[ -d "$BAR_SRC" ]] && [[ ! -d "$BAR_DST" ]]; then
    echo "Setting up BAR_Baseline in build tree..."
    cp -a "$BAR_SRC" "$BAR_DST"
fi

FMW_SRC="${OPENFAST_ROOT}/reg_tests/r-test/glue-codes/openfast/5MW_Baseline"
FMW_DST="${OPENFAST_ROOT}/build/glue-codes/openfast/5MW_Baseline"
if [[ -d "$FMW_SRC" ]] && [[ ! -d "$FMW_DST" ]]; then
    echo "Setting up 5MW_Baseline in build tree..."
    mkdir -p "$(dirname "$FMW_DST")"
    cp -a "$FMW_SRC" "$FMW_DST"
fi

# ============================================================
# Resolve target list
# ============================================================
if [[ "$TARGET" == "all" ]]; then
    # All cases that have r-test inputs (excluding non-.outb cases like ad_Sphere_OLAF)
    CASES=()
    for dir in "$RTEST_AD"/ad_*/; do
        case_name=$(basename "$dir")
        # Skip Sphere (VTK comparison, not .outb)
        [[ "$case_name" == "ad_Sphere_OLAF" ]] && continue
        # Skip if no .dvr file
        [[ -f "$dir/ad_driver.dvr" ]] && CASES+=("$case_name")
    done
else
    CASES=("$TARGET")
fi

if [[ ${#CASES[@]} -eq 0 ]]; then
    echo "No test cases found." >&2
    exit 2
fi

# ============================================================
# Run each case through NREL's regression script
# ============================================================
echo "Running NREL AeroDyn regression test (rtol=$RTOL → 1e-$RTOL, atol=$ATOL → ~1e-$ATOL)"
echo "Cases: ${#CASES[@]}"
echo ""

PASSED=0
FAILED=0
FAILED_CASES=()

for CASE_NAME in "${CASES[@]}"; do
    OUTPUT=$(python3 "$REG_SCRIPT" "$CASE_NAME" "$DRIVER" "$OPENFAST_ROOT" "$BUILD_AD" "$RTOL" "$ATOL" 2>&1)
    RC=$?

    if [[ $RC -eq 0 ]]; then
        echo "✓ $CASE_NAME"
        PASSED=$((PASSED + 1))
    else
        echo "✗ $CASE_NAME (rc=$RC)"
        # Show relevant error lines
        echo "$OUTPUT" | grep -iE 'not found|FATAL|Error|FAIL' | head -3 | sed 's/^/    /'
        FAILED=$((FAILED + 1))
        FAILED_CASES+=("$CASE_NAME")
    fi
done

echo ""
echo "===================="
echo "NREL regression: ${PASSED}/${#CASES[@]} passed (rtol=$RTOL, atol=$ATOL)"

if [[ $FAILED -gt 0 ]]; then
    echo "Failed: ${FAILED_CASES[*]}"
    exit 1
fi

echo "ALL CASES PASS"
exit 0
