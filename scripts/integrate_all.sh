#!/bin/bash
# Integrate all translated AeroDyn functions into the source tree.
#
# Run from the openfast repo root, inside the vit-dev-openfast container.
# Assumes source has been reset to clean Fortran (reset_to_clean.sh).
# After running, rebuild and run verify_aerodyn_baselines.sh.
#
# Usage: bash scripts/integrate_all.sh
#        cd build && cmake --build . --target aerodyn_driver -j$(nproc)
#        bash scripts/verify_aerodyn_baselines.sh all

set -e
cd "$(dirname "$0")/.."  # openfast repo root

SRC=modules/aerodyn/src/AirfoilInfo.f90
passed=0
failed=0
total=0

integrate() {
    local func="$1"
    local cpp="$2"
    local flags="${3:-}"
    total=$((total + 1))

    if vit integrate "$func" "$cpp" -f "$SRC" --apply $flags > /dev/null 2>&1; then
        echo "  ✓ $func"
        passed=$((passed + 1))
    else
        echo "  ✗ $func"
        failed=$((failed + 1))
    fi
}

echo "Integrating AeroDyn translations..."
echo ""

# Order matters: functions that are callees of later functions must be
# integrated first (so their _c declarations appear in vit_translated.h).

# --- Leaf functions (no callees, or framework-only callees) ---
integrate Calculate_Cn              translations/AirfoilInfo/calculate_cn.cpp
integrate FindBoundingTables        translations/AirfoilInfo/findboundingtables.cpp
integrate Compute_iLoweriUpper      translations/AirfoilInfo/compute_iloweriupper.cpp
integrate ComputeUA360_CnOffset     translations/AirfoilInfo/computeua360_cnoffset.cpp
integrate Calculate_C_alpha         translations/AirfoilInfo/calculate_c_alpha.cpp

# --- Functions that modify view-struct scalars (need --reverse-copy) ---
integrate ComputeUASeparationFunction_zero \
    translations/AirfoilInfo/computeuaseparationfunction_zero.cpp \
    "--reverse-copy"

# --- Functions that call already-translated callees ---
integrate ComputeUA360_updateCnSeparated \
    translations/AirfoilInfo/computeua360_updatecnseparated.cpp
integrate ComputeUA360_updateSeparationF \
    translations/AirfoilInfo/computeua360_updateseparationf.cpp

# --- Callee-dependent functions ---
integrate ComputeUASeparationFunction_onCl \
    translations/AirfoilInfo/computeuaseparationfunction_oncl.cpp

# --- Functions with NWTC utility callees (fZeros, InterpExtrapStp) ---
integrate ComputeUA360_AttachedFlow \
    translations/AirfoilInfo/computeua360_attachedflow.cpp \
    "--reverse-copy"

echo ""
echo "===================="
echo "Summary: $passed/$total passed, $failed failed"

if [ "$failed" -gt 0 ]; then
    exit 1
fi
