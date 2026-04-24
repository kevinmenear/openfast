#!/bin/bash
# Reset AeroDyn source to clean Fortran for KGen extraction.
#
# Integration wrappers in AirfoilInfo.f90 reference VIT view modules that
# KGen's build can't find, so extraction fails on integrated source.
# This script restores clean Fortran and creates stubs so the CMakeLists
# still compiles.
#
# Usage: bash scripts/reset_to_clean.sh
# Run from the openfast repo root (not inside the container).

set -e
cd "$(dirname "$0")/.."  # openfast repo root

echo "Resetting AeroDyn source for clean extraction..."

# Pre-integration commit: the last upstream commit before VIT integration wrappers.
# Update this when the upstream base changes (e.g., after merging NREL updates).
PRE_INTEGRATION_COMMIT="edab46311"

# 1. Restore integrated Fortran source files to pre-integration state.
#    git checkout HEAD would restore the committed (integrated) version,
#    which still has wrappers. We need the upstream version WITHOUT wrappers.
#    Add more files here as integration expands to other modules.
restored=0
for f in modules/aerodyn/src/AirfoilInfo.f90; do
    git checkout "$PRE_INTEGRATION_COMMIT" -- "$f"
    echo "  Restored: $f (from $PRE_INTEGRATION_COMMIT)"
    restored=$((restored + 1))
done

# 2. Create C++ stubs for CMakeLists-referenced .cpp files
stubs=0
for f in modules/aerodyn/src/*.cpp; do
    [ -f "$f" ] || continue
    echo "// stub" > "$f"
    stubs=$((stubs + 1))
done
echo "  Created $stubs C++ stubs"

# 3. Create Fortran module stubs for view populator files
for f in modules/aerodyn/src/vit_*_view.f90; do
    [ -f "$f" ] || continue
    modname=$(basename "$f" .f90)
    printf 'MODULE %s\n    IMPLICIT NONE\nEND MODULE %s\n' "$modname" "$modname" > "$f"
    echo "  Stubbed: $f"
done

# 4. Clean KGen artifacts (may be at repo root or in src/)
cleaned=0
for artifact in elapsedtime state model; do
    if [ -d "$artifact" ]; then
        rm -rf "$artifact"
        cleaned=$((cleaned + 1))
    fi
done
for artifact in model.ini include.ini kgen.log; do
    if [ -f "$artifact" ]; then
        rm -f "$artifact"
        cleaned=$((cleaned + 1))
    fi
done
# KGen backup files
for f in modules/aerodyn/src/*.kgen_org; do
    [ -f "$f" ] || continue
    rm -f "$f"
    cleaned=$((cleaned + 1))
done

echo ""
echo "Done. Restored $restored source files, created $stubs C++ stubs, cleaned $cleaned artifacts."
echo "Source is ready for extraction. Next: rebuild and run vit extract."
