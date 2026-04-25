#!/bin/bash
# generate_coverage.sh
#
# Build aerodyn_driver with gcov coverage instrumentation, run all 17 AeroDyn
# regression test cases, and collect per-line execution counts for every source
# file. Produces gcov JSON output that parse_gcov.py consolidates into
# vit/analysis/aerodyn/line_coverage.json.
#
# This gives definitive "which test case exercises which call site" data —
# eliminating guesswork when choosing test cases for KGen extraction.
#
# Usage (inside container):
#   cd /workspace/openfast && ./scripts/generate_coverage.sh
#   cd /workspace/openfast && ./scripts/generate_coverage.sh --rebuild
#
# From Mac:
#   docker exec vit-dev-openfast bash -c "cd /workspace/openfast && ./scripts/generate_coverage.sh"

set -euo pipefail

OPENFAST_ROOT="/workspace/openfast"
BUILD_DIR="${OPENFAST_ROOT}/build-coverage"
GCOV_OUTPUT_DIR="${BUILD_DIR}/gcov_json"
RTEST_CASES_ROOT="${OPENFAST_ROOT}/reg_tests/r-test/modules/aerodyn"
DRIVER="${BUILD_DIR}/modules/aerodyn/aerodyn_driver"
PARSER="/workspace/vit/scripts/parse_gcov.py"
OUTPUT="/workspace/vit/analysis/aerodyn/line_coverage.json"

REBUILD="${1:-}"

# ── Step 1: Coverage build ──────────────────────────────────────────────

if [[ ! -x "$DRIVER" ]] || [[ "$REBUILD" == "--rebuild" ]]; then
    echo "=== Building aerodyn_driver with --coverage ==="
    mkdir -p "$BUILD_DIR"
    cmake -S "$OPENFAST_ROOT" -B "$BUILD_DIR" \
        -DBUILD_TESTING=ON \
        -DCODECOVERAGE=ON \
        -DCMAKE_BUILD_TYPE=Debug \
        -DFP_CONTRACT_OFF=ON \
        -DDOUBLE_PRECISION=ON \
        > "${BUILD_DIR}/cmake_configure.log" 2>&1
    cmake --build "$BUILD_DIR" --target aerodyn_driver -j$(nproc)
    echo "  Build complete: $DRIVER"
else
    echo "=== Using cached coverage build at $BUILD_DIR ==="
fi

# ── Step 2: Copy shared data directories ────────────────────────────────

BAR_SRC="${RTEST_CASES_ROOT}/BAR_Baseline"
BAR_DST="${BUILD_DIR}/modules/aerodyn/BAR_Baseline"
if [[ -d "$BAR_SRC" ]] && [[ ! -d "$BAR_DST" ]]; then
    echo "Copying BAR_Baseline to coverage build dir"
    cp -a "$BAR_SRC" "$BAR_DST"
fi

FMW_SRC="${OPENFAST_ROOT}/reg_tests/r-test/glue-codes/openfast/5MW_Baseline"
FMW_DST="${BUILD_DIR}/glue-codes/openfast/5MW_Baseline"
if [[ -d "$FMW_SRC" ]] && [[ ! -d "$FMW_DST" ]]; then
    echo "Copying 5MW_Baseline to coverage build dir"
    mkdir -p "$(dirname "$FMW_DST")"
    cp -a "$FMW_SRC" "$FMW_DST"
fi

# ── Step 3: Discover test cases ─────────────────────────────────────────

mapfile -t CASES < <(
    find "$RTEST_CASES_ROOT" -mindepth 1 -maxdepth 1 -type d -name "ad_*" \
        -exec basename {} \; | sort
)

echo "=== Found ${#CASES[@]} test cases ==="

# ── Step 4: Run each test case and collect gcov JSON ────────────────────

rm -rf "$GCOV_OUTPUT_DIR"
mkdir -p "$GCOV_OUTPUT_DIR"

PASSED=0
FAILED=0
TOTAL=${#CASES[@]}

for i in "${!CASES[@]}"; do
    CASE="${CASES[$i]}"
    N=$((i + 1))

    # Check for driver file
    if [[ ! -f "${RTEST_CASES_ROOT}/${CASE}/ad_driver.dvr" ]]; then
        echo "[${N}/${TOTAL}] ${CASE}: skipped (no ad_driver.dvr)"
        continue
    fi

    echo -n "[${N}/${TOTAL}] ${CASE}..."

    # Reset coverage counters
    find "$BUILD_DIR" -name "*.gcda" -delete 2>/dev/null || true

    # Prepare scratch directory
    SCRATCH="${BUILD_DIR}/modules/aerodyn/coverage_${CASE}"
    rm -rf "$SCRATCH"
    mkdir -p "$SCRATCH"
    cp -a "${RTEST_CASES_ROOT}/${CASE}/." "$SCRATCH/"
    rm -f "${SCRATCH}"/ad_driver*.outb

    # Run the driver
    pushd "$SCRATCH" > /dev/null
    if "$DRIVER" ad_driver.dvr > driver.log 2>&1; then
        PASSED=$((PASSED + 1))
    else
        echo -n " (driver failed)"
        FAILED=$((FAILED + 1))
        # Still collect partial coverage
    fi
    popd > /dev/null

    # Collect gcov JSON
    mkdir -p "${GCOV_OUTPUT_DIR}/${CASE}"
    pushd "$BUILD_DIR" > /dev/null

    # Find all directories containing .gcda files and run gcov on them
    for gcda_dir in $(find . -name "*.gcda" -printf '%h\n' 2>/dev/null | sort -u); do
        # Only process if .gcno files exist alongside
        if ls "$gcda_dir"/*.gcno 1>/dev/null 2>&1; then
            gcov -j -o "$gcda_dir" "$gcda_dir"/*.gcno 2>/dev/null || true
        fi
    done

    # Move all .gcov.json.gz from build root to per-test-case directory
    find . -maxdepth 1 -name "*.gcov.json.gz" -exec mv {} "${GCOV_OUTPUT_DIR}/${CASE}/" \;
    popd > /dev/null

    COUNT=$(find "${GCOV_OUTPUT_DIR}/${CASE}" -name "*.gcov.json.gz" 2>/dev/null | wc -l)
    echo " ${COUNT} coverage files"
done

echo ""
echo "=== Coverage collection: ${PASSED} passed, ${FAILED} failed out of ${TOTAL} ==="

# ── Step 5: Parse into consolidated JSON ────────────────────────────────

echo "=== Parsing gcov output ==="
python3 "$PARSER" \
    --gcov-dir "$GCOV_OUTPUT_DIR" \
    --output "$OUTPUT" \
    --source-root "$OPENFAST_ROOT"

echo "=== Done. Coverage data: $OUTPUT ==="
