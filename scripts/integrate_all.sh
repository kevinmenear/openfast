#!/bin/bash
# Re-apply all VIT integrations to AeroDyn source files.
# Run ON THE MAC (not inside Docker) after reset_to_clean.sh.
#
# Usage:
#   bash scripts/reset_to_clean.sh    # clean source for extraction
#   # ... run extraction ...
#   bash scripts/integrate_all.sh     # restore integrated state
#   docker exec vit-dev-openfast bash -c "cd /workspace/openfast/build && cmake .. && cmake --build . --target aerodyn_driver -j\$(nproc)"
#   docker exec vit-dev-openfast bash -c "cd /workspace/openfast && bash scripts/verify_aerodyn_baselines.sh all"

set -e
cd "$(dirname "$0")/.."

PASS=0
FAIL=0

integrate() {
    local name=$1; local cpp=$2; local f90=$3; shift 3
    local flags="$@"
    result=$(docker exec vit-dev-openfast bash -c "cd /workspace/openfast && vit integrate '$name' '$cpp' -f '$f90' --apply $flags" 2>&1)
    if echo "$result" | grep -q "Integration applied successfully"; then
        echo "  OK $name"
        PASS=$((PASS + 1))
    else
        echo "FAIL $name"
        echo "$result" | tail -3
        FAIL=$((FAIL + 1))
    fi
}

echo "=== AeroDyn integrate_all.sh ==="
echo ""

# -----------------------------------------------------------------------
# Step 1: Restore committed source files (hand-integrated wrappers)
# -----------------------------------------------------------------------
echo "Restoring committed source files..."
git checkout HEAD -- modules/aerodyn/src/AirfoilInfo.f90
git checkout HEAD -- modules/aerodyn/src/vit_afi_parametertype_view.f90
git checkout HEAD -- modules/aerodyn/src/vit_afi_table_type_view.f90
git checkout HEAD -- modules/aerodyn/src/vit_dbemt_parametertype_view.f90
git checkout HEAD -- modules/aerodyn/src/vit_nwtc.cpp
echo "  Done"

# -----------------------------------------------------------------------
# Step 2: Integrate AirfoilInfo leaf functions via vit integrate
# -----------------------------------------------------------------------
echo ""
echo "--- AirfoilInfo leaf functions (11) ---"
F90=modules/aerodyn/src/AirfoilInfo.f90
T=translations/AirfoilInfo

integrate Calculate_Cn                      $T/calculate_cn.cpp                      $F90
integrate FindBoundingTables                $T/findboundingtables.cpp                $F90
integrate Compute_iLoweriUpper              $T/compute_iloweriupper.cpp              $F90
integrate ComputeUA360_CnOffset             $T/computeua360_cnoffset.cpp             $F90
integrate Calculate_C_alpha                 $T/calculate_c_alpha.cpp                 $F90
integrate ComputeUASeparationFunction_zero  $T/computeuaseparationfunction_zero.cpp  $F90
integrate ComputeUA360_updateCnSeparated    $T/computeua360_updatecnseparated.cpp    $F90
integrate ComputeUA360_updateSeparationF    $T/computeua360_updateseparationf.cpp    $F90
integrate ComputeUASeparationFunction_onCl  $T/computeuaseparationfunction_oncl.cpp  $F90
integrate ComputeUA360_AttachedFlow         $T/computeua360_attachedflow.cpp         $F90 --reverse-copy
integrate CalculateUACoeffs                 $T/calculateuacoeffs.cpp                 $F90 --reverse-copy

echo ""
echo "--- AirfoilInfo validation + orchestrators (2) ---"
integrate AFI_ValidateInitInput             $T/afi_validateinitinput.cpp              $F90
integrate AFI_ComputeAirfoilCoefs           $T/afi_computeairfoilcoefs.cpp            $F90

# Hand-integrated functions (AFI_Init, ReadAFfile, AFI_ComputeUACoefs,
# AFI_WrHeader, AFI_WrData, AFI_WrTables) are already in the committed
# AirfoilInfo.f90 restored in Step 1.

# -----------------------------------------------------------------------
# Step 3: Restore committed .cpp files
# -----------------------------------------------------------------------
# vit integrate creates .cpp files with duplicate extern "C" wrappers.
# The committed versions have the correct single wrapper.
echo ""
echo "Restoring committed .cpp files..."
git checkout HEAD -- \
    modules/aerodyn/src/calculate_cn.cpp \
    modules/aerodyn/src/findboundingtables.cpp \
    modules/aerodyn/src/compute_iloweriupper.cpp \
    modules/aerodyn/src/computeua360_cnoffset.cpp \
    modules/aerodyn/src/calculate_c_alpha.cpp \
    modules/aerodyn/src/computeuaseparationfunction_zero.cpp \
    modules/aerodyn/src/computeua360_updatecnseparated.cpp \
    modules/aerodyn/src/computeua360_updateseparationf.cpp \
    modules/aerodyn/src/computeuaseparationfunction_oncl.cpp \
    modules/aerodyn/src/computeua360_attachedflow.cpp \
    modules/aerodyn/src/calculateuacoeffs.cpp \
    modules/aerodyn/src/afi_validateinitinput.cpp \
    modules/aerodyn/src/afi_computeairfoilcoefs.cpp \
    modules/aerodyn/src/afi_computeuacoefs.cpp \
    modules/aerodyn/src/readaffile.cpp \
    modules/aerodyn/src/afi_init.cpp \
    modules/aerodyn/src/afi_wrheader.cpp \
    modules/aerodyn/src/afi_wrdata.cpp \
    modules/aerodyn/src/afi_wrtables.cpp
echo "  Done"

# -----------------------------------------------------------------------
# Summary
# -----------------------------------------------------------------------
echo ""
echo "===================="
echo "Summary: $PASS passed, $FAIL failed"
if [ $FAIL -gt 0 ]; then
    exit 1
fi
