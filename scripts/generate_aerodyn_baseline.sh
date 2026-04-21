#!/bin/bash
# generate_aerodyn_baseline.sh
#
# Generate a platform-specific baseline for one AeroDyn r-test case.
#
# For each test case, this script:
#   1. Copies inputs from reg_tests/r-test/modules/aerodyn/<case>/ to a scratch build dir
#   2. Copies BAR_Baseline/ as needed (shared by BAR-family cases)
#   3. Runs aerodyn_driver on the copied .dvr, writing output in the build dir
#      (This keeps the r-test submodule working tree untouched — no git needed in container)
#   4. Uses NREL's fast_io.load_output to parse both our new output and the r-test reference
#   5. Computes max abs/rel drift per channel and writes to baselines/aerodyn/<case>/drift_vs_nrel.txt
#   6. Copies our new output to baselines/aerodyn/<case>/ad_driver.baseline.outb
#   7. Prints a summary line with bit-exact match count and max drift
#
# Invoke from the OpenFAST repo root inside vit-dev-openfast:
#   docker exec vit-dev-openfast bash -c "cd /workspace/openfast && ./scripts/generate_aerodyn_baseline.sh ad_BAR_SineMotion"
#
# Or from the Mac via docker exec directly (same command).
#
# Rationale and strategy context: see dev notes
#   vit/dev/202604140253-outb-format-and-verification-strategy.md
#   vit/dev/202604140241-openfast-build-aerodyn-baseline.md

set -euo pipefail

CASE_NAME="${1:-}"
if [[ -z "$CASE_NAME" ]]; then
    echo "Usage: $0 <case_name>" >&2
    echo "Example: $0 ad_BAR_SineMotion" >&2
    exit 1
fi

# Paths are absolute (container-side) so the script is independent of CWD.
OPENFAST_ROOT="/workspace/openfast"
RTEST_CASE_DIR="${OPENFAST_ROOT}/reg_tests/r-test/modules/aerodyn/${CASE_NAME}"
BAR_BASELINE_DIR="${OPENFAST_ROOT}/reg_tests/r-test/modules/aerodyn/BAR_Baseline"
BUILD_SCRATCH_DIR="${OPENFAST_ROOT}/build/modules/aerodyn/baseline_gen_${CASE_NAME}"
BUILD_BAR_BASELINE_DIR="${OPENFAST_ROOT}/build/modules/aerodyn/BAR_Baseline"
DRIVER="${OPENFAST_ROOT}/build/modules/aerodyn/aerodyn_driver"
BASELINE_OUT_DIR="${OPENFAST_ROOT}/baselines/aerodyn/${CASE_NAME}"
REG_LIB_DIR="${OPENFAST_ROOT}/reg_tests/lib"

# Preconditions
if [[ ! -d "$RTEST_CASE_DIR" ]]; then
    echo "ERROR: r-test case directory not found: $RTEST_CASE_DIR" >&2
    echo "       Did you run 'git submodule update --init --recursive reg_tests/r-test' on the host?" >&2
    exit 2
fi
if [[ ! -x "$DRIVER" ]]; then
    echo "ERROR: aerodyn_driver not built at $DRIVER" >&2
    echo "       Run: cd build && make aerodyn_driver -j\$(nproc)" >&2
    exit 2
fi
# Check for ANY .outb reference (may be ad_driver.outb, .T2.outb, or .4.outb)
NREL_REF_FILES=$(find "${RTEST_CASE_DIR}" -maxdepth 1 -name 'ad_driver*.outb' 2>/dev/null)
if [[ -z "$NREL_REF_FILES" ]]; then
    echo "ERROR: no ad_driver*.outb reference found in $RTEST_CASE_DIR" >&2
    exit 2
fi

echo "=== generate_aerodyn_baseline.sh for ${CASE_NAME} ==="

# Step 1: prepare scratch build dir (clean every time to ensure reproducibility)
echo "[1/7] Preparing scratch build dir: $BUILD_SCRATCH_DIR"
rm -rf "$BUILD_SCRATCH_DIR"
mkdir -p "$BUILD_SCRATCH_DIR"

# Step 2: copy test case inputs (all files except .outb so we don't touch the reference yet)
echo "[2/7] Copying inputs from r-test"
cp -a "${RTEST_CASE_DIR}/." "$BUILD_SCRATCH_DIR/"
# Rename all .outb reference files so they don't get overwritten when the driver writes output
for outb in "${BUILD_SCRATCH_DIR}"/ad_driver*.outb; do
    [[ -f "$outb" ]] && mv "$outb" "${outb%.outb}_nrel_ref.outb"
done

# Step 3: copy shared data directories to build tree so relative paths resolve.
# BAR_Baseline (referenced as ../BAR_Baseline/ by BAR-family cases):
echo "[3/7] Copying shared data directories"
if [[ -d "$BAR_BASELINE_DIR" ]] && [[ ! -d "$BUILD_BAR_BASELINE_DIR" ]]; then
    cp -a "$BAR_BASELINE_DIR" "$BUILD_BAR_BASELINE_DIR"
fi
# 5MW_Baseline (referenced as ../../../glue-codes/openfast/5MW_Baseline/ by some cases):
FMW_BASELINE_SRC="${OPENFAST_ROOT}/reg_tests/r-test/glue-codes/openfast/5MW_Baseline"
FMW_BASELINE_DST="${OPENFAST_ROOT}/build/glue-codes/openfast/5MW_Baseline"
if [[ -d "$FMW_BASELINE_SRC" ]] && [[ ! -d "$FMW_BASELINE_DST" ]]; then
    mkdir -p "$(dirname "$FMW_BASELINE_DST")"
    cp -a "$FMW_BASELINE_SRC" "$FMW_BASELINE_DST"
fi

# Step 4: run the driver
echo "[4/7] Running aerodyn_driver ${CASE_NAME}/ad_driver.dvr"
pushd "$BUILD_SCRATCH_DIR" > /dev/null
if ! "$DRIVER" ad_driver.dvr > driver.log 2>&1; then
    echo "ERROR: aerodyn_driver failed. Tail of driver.log:" >&2
    tail -20 driver.log >&2
    popd > /dev/null
    exit 3
fi
popd > /dev/null

# Detect which output file the driver produced (may vary by AnalysisType / NumTurbines).
# Combined cases (AT=3) write ad_driver.N.outb; multi-turbine writes ad_driver.T2.outb.
# NREL's reg_test convention: compare .T2 if exists, else .4 if exists, else .outb.
OUR_OUT="${BUILD_SCRATCH_DIR}/ad_driver.outb"
if [[ -f "${BUILD_SCRATCH_DIR}/ad_driver.T2.outb" ]]; then
    OUR_OUT="${BUILD_SCRATCH_DIR}/ad_driver.T2.outb"
elif [[ -f "${BUILD_SCRATCH_DIR}/ad_driver.4.outb" ]]; then
    OUR_OUT="${BUILD_SCRATCH_DIR}/ad_driver.4.outb"
fi
# Find the NREL reference — it was renamed to *_nrel_ref.outb in the scratch dir.
# Detect which variant exists: .T2, .4, or plain.
REF_OUT="${BUILD_SCRATCH_DIR}/ad_driver_nrel_ref.outb"
if [[ -f "${BUILD_SCRATCH_DIR}/ad_driver.T2_nrel_ref.outb" ]]; then
    REF_OUT="${BUILD_SCRATCH_DIR}/ad_driver.T2_nrel_ref.outb"
elif [[ -f "${BUILD_SCRATCH_DIR}/ad_driver.4_nrel_ref.outb" ]]; then
    REF_OUT="${BUILD_SCRATCH_DIR}/ad_driver.4_nrel_ref.outb"
fi

if [[ ! -f "$OUR_OUT" ]]; then
    echo "ERROR: driver did not produce an output file (checked .outb, .T2.outb, .4.outb)" >&2
    exit 4
fi

# Step 5: compute drift vs NREL reference using fast_io
echo "[5/7] Computing drift vs NREL reference"
mkdir -p "$BASELINE_OUT_DIR"
DRIFT_FILE="${BASELINE_OUT_DIR}/drift_vs_nrel.txt"

python3 <<PYEOF > "$DRIFT_FILE" 2>&1
import sys
sys.path.insert(0, "${REG_LIB_DIR}")
from fast_io import load_output
import numpy as np

ours, info_ours, _ = load_output("${OUR_OUT}")
ref, info_ref, _ = load_output("${REF_OUT}")

channel_names = info_ref.get('attribute_names', [])
channel_units = info_ref.get('attribute_units', [])

print(f"Drift report: ${CASE_NAME} vs NREL r-test reference")
print(f"Generated: $(date -u +%Y-%m-%dT%H:%M:%SZ)")
print(f"Platform: {open('/etc/os-release').read().split(chr(10))[1] if open('/etc/os-release').read() else 'unknown'}")
print()
print(f"Our output: ${OUR_OUT}")
print(f"NREL ref:   ${REF_OUT}")
print(f"Array shape: {ours.shape} (timesteps, channels) = {ours.size} values")
print()

if ours.shape != ref.shape:
    print(f"*** SHAPE MISMATCH: ours={ours.shape}, ref={ref.shape} — aborting comparison")
    sys.exit(0)

abs_diff = np.abs(ours - ref)
with np.errstate(divide='ignore', invalid='ignore'):
    rel_diff = np.where(np.abs(ref) > 1e-12, abs_diff / np.abs(ref), 0.0)

n_total = ours.size
n_exact = int((abs_diff == 0).sum())
n_within_1e5_rel = int((rel_diff < 1e-5).sum())
n_within_combined = int(((rel_diff < 1e-5) | (abs_diff < 1e-6)).sum())

print(f"Bit-identical:                 {n_exact:>6d} / {n_total} ({100*n_exact/n_total:.2f}%)")
print(f"Within 1e-5 rel:               {n_within_1e5_rel:>6d} / {n_total} ({100*n_within_1e5_rel/n_total:.2f}%)")
print(f"Within 1e-5 rel OR 1e-6 abs:   {n_within_combined:>6d} / {n_total} ({100*n_within_combined/n_total:.2f}%)")
print(f"Max abs difference:            {abs_diff.max():.6e}")
print(f"Max rel difference:            {rel_diff.max():.6e}")
print()

# Per-channel worst element (only channels that drift)
print("Per-channel drift (non-zero channels only):")
max_abs_per_ch = abs_diff.max(axis=0)
drifting = np.argsort(max_abs_per_ch)[::-1]
n_drifting = 0
for c_idx in drifting:
    if max_abs_per_ch[c_idx] == 0:
        break
    n_drifting += 1
    ch_name = channel_names[c_idx] if c_idx < len(channel_names) else f"ch{c_idx}"
    ch_unit = channel_units[c_idx] if c_idx < len(channel_units) else ""
    worst_t = int(abs_diff[:, c_idx].argmax())
    ref_val = ref[worst_t, c_idx]
    abs_at_worst = max_abs_per_ch[c_idx]
    rel_at_worst = abs_at_worst / abs(ref_val) if abs(ref_val) > 1e-12 else float('inf')
    print(f"  {ch_name:<22s} ({ch_unit:<8s})  abs={abs_at_worst:.3e}  rel={rel_at_worst:.3e}  at t_idx={worst_t}")
print()
print(f"Total channels with drift:     {n_drifting} / {ours.shape[1]}")
PYEOF

# Step 6: copy our output as the canonical baseline
echo "[6/7] Saving baseline: ${BASELINE_OUT_DIR}/ad_driver.baseline.outb"
cp "$OUR_OUT" "${BASELINE_OUT_DIR}/ad_driver.baseline.outb"

# Step 7: summary
echo "[7/7] Summary:"
grep -E "Bit-identical|Within 1e-5 rel OR|Max abs|Max rel|Total channels with drift" "$DRIFT_FILE" | sed 's/^/    /'
echo ""
echo "Baseline written to: ${BASELINE_OUT_DIR}/ad_driver.baseline.outb"
echo "Drift report at:     ${DRIFT_FILE}"
echo "=== done ==="
