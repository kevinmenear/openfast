# ad_BAR_SineMotion baseline

Platform-specific baseline for the `ad_BAR_SineMotion` r-test case.

## Test case description

From `reg_tests/r-test/modules/aerodyn/ad_BAR_SineMotion/`:
- **Turbine:** BAR (Big Adaptive Rotor), NREL's 206-meter-rotor research configuration
- **Aerodynamic model:** BEMT (Blade Element Momentum Theory), 2D legacy mode, legacy NoSweepPitchTwist projection
- **Motion:** sinusoidal base motion in the x-direction, 0.1 Hz frequency, 5 m amplitude
- **Rotor speed:** 7 rpm (fixed)
- **Blade pitch:** 1° collective (fixed)
- **Wind:** steady 9 m/s, no InflowWind turbulence
- **Duration:** 7 seconds simulated, 0.1 s timestep → 70 timesteps
- **Analysis type:** 1 (multiple turbines, one simulation — though NumTurbines = 1 here)

## Why this is a good first baseline

- **Fast:** ~0.27 seconds wall clock per run on `vit-dev-openfast`
- **Simple:** BEMT not OLAF, no motion prescribed via CSV, no MHK, no time-series inputs
- **Real:** uses actual BAR blade geometry and BAR0 airfoil polars from `BAR_Baseline/`, not a toy case
- **Deterministic:** confirmed bit-identical across two successive runs on `vit-dev-openfast` (see initial determinism test in the infrastructure dev note)

## Files in this directory

- `ad_driver.baseline.outb` — our committed baseline (the canonical reference for this case). Binary `.outb` format. Produced by `aerodyn_driver` on `vit-dev-openfast`.
- `drift_vs_nrel.txt` — informational: drift comparison between this baseline and NREL's shipped `reg_tests/r-test/modules/aerodyn/ad_BAR_SineMotion/ad_driver.outb` at the time of generation. Shows per-channel max absolute and relative differences for the channels that drift.
- `README.md` — this file

## Build environment fingerprint

Captured at baseline generation time:

- **Container image:** `vit-dev-openfast:latest` (built from `vit/docker/Dockerfile.openfast`, commit `3564874`)
- **Host:** ARM64 Linux via Colima on Apple Silicon
- **OS:** Ubuntu 24.04
- **Compiler:** gfortran 13.3.0 (`Ubuntu 13.3.0-6ubuntu2~24.04.1`)
- **cmake:** 3.28.3
- **BLAS:** OpenBLAS 0.3.26 (`libopenblas-dev:arm64 0.3.26+ds-1ubuntu0.1`)
- **LAPACK:** same (OpenBLAS provides LAPACK symbols)
- **OpenFAST git SHA:** `2895884d2` (v5.0.1 release merge, branch `main`)
- **r-test submodule SHA:** `dd5feaa` (v5.0.0 tag)

If any of these change (Docker rebuild, OpenFAST upstream merge, apt upgrade), this baseline must be regenerated. See `baselines/README.md` for the regeneration procedure.

## Regenerating this baseline

```bash
docker exec vit-dev-openfast bash -c "cd /workspace/openfast && ./scripts/generate_aerodyn_baseline.sh ad_BAR_SineMotion"
```

After regeneration, review the updated `drift_vs_nrel.txt`. If the drift vs NREL has grown substantially (new channels appearing, or existing channels showing larger max rel diff), that's a signal worth investigating before committing the new baseline — it may indicate a meaningful platform change.
