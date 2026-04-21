# baselines/

Platform-specific regression test baselines for the VIT / AeroDyn translation effort.

## Why this directory exists

OpenFAST's `reg_tests/r-test/` submodule ships reference `.outb` files produced by NREL's internal CI. When we run the same tests on `vit-dev-openfast` (ARM64 Linux, OpenBLAS, gfortran 13.3.0, Ubuntu 24.04), our output differs from NREL's reference by ULP-level floating-point drift — not a simulation bug, but enough to fail NREL's strict element-wise tolerance gate. This is expected behavior when moving between platforms; see dev note `202604140253-outb-format-and-verification-strategy.md` in the VIT repo for the full analysis.

This directory holds **our own baselines** — reference `.outb` files generated on `vit-dev-openfast` that we commit and use as the primary comparison target for regression gating. Our translations are verified against these baselines bit-identically, not against NREL's cross-platform reference. NREL's reference is still useful as an informational drift signal but is not the gate.

This pattern mirrors ROSCO's `baseline_arrays/` and `upstream_arrays/` split: `baseline_arrays/` was our canonical reference (committed, used as the gate), `upstream_arrays/` was NREL-equivalent data for informational cross-platform comparison.

## Directory layout

```
baselines/
├── README.md                                           (this file)
└── aerodyn/
    └── <case_name>/                                    one subdirectory per AeroDyn r-test case
        ├── ad_driver.baseline.outb                     our committed baseline
        ├── drift_vs_nrel.txt                           informational drift at time of generation
        └── README.md                                   case-specific notes (build env, date, etc.)
```

## Workflow

**Generating a baseline** (one-time per case, or after environment changes):

```bash
docker exec vit-dev-openfast bash -c "cd /workspace/openfast && ./scripts/generate_aerodyn_baseline.sh <case_name>"
```

This runs the driver in a scratch build directory, computes drift against NREL's reference, and saves our output to `baselines/aerodyn/<case_name>/ad_driver.baseline.outb`. Re-runnable — each invocation overwrites the previous baseline.

**Verifying a build against committed baselines** (every test cycle):

```bash
docker exec vit-dev-openfast bash -c "cd /workspace/openfast && ./scripts/verify_aerodyn_baselines.sh <case_name | all>"
```

Runs the driver and compares its output byte-for-byte against the committed baseline. Exit 0 if bit-identical, non-zero otherwise. If a `cmp` failure occurs, a Python diagnostic (via `reg_tests/lib/fast_io.load_output`) prints per-channel drift to help distinguish real regressions from environmental drift.

**Checking cross-platform drift vs NREL** (informational, not a gate):

```bash
docker exec vit-dev-openfast bash -c "cd /workspace/openfast && ./scripts/check_aerodyn_nrel_drift.sh <case_name | all>"
```

Prints a drift summary comparing our build against NREL's shipped reference. Always exits 0 unless the driver itself fails. Useful for tracking whether the platform-drift has grown (e.g., after a Dockerfile rebuild or an OpenFAST upstream merge).

## Phase 2: Baseline extension — all AeroDyn r-test cases

Phase 1 (2026-04-14) proved the infrastructure on `ad_BAR_SineMotion`. Phase 2 extends to the remaining 16 cases. Cases are categorized into three groups by compatibility with the existing scripts.

### Group A — drop-in compatible (AT=1, NT=1, standard `ad_driver.outb` output)

These 12 cases should work with the existing `generate_aerodyn_baseline.sh` as-is — same output-file pattern as `ad_BAR_SineMotion`.

| | Case | Aero model | Key features | CompInflow | MHK | Status |
|-|------|-----------|-------------|------------|-----|--------|
| [x] | `ad_BAR_SineMotion` | BEMT | sinusoidal base motion, 7s/70 steps | 0 | 0 | **Phase 1 complete** (2026-04-14) |
| [x] | `ad_B1n2_OLAF` | OLAF | single blade, 2 nodes — simplest OLAF case | 0 | 0 | |
| [x] | `ad_BAR_OLAF` | OLAF (Wake_Mod=3) | BAR turbine with Free Vortex Wake — may be slow | 0 | 0 | |
| [x] | `ad_BAR_RNAMotion` | BEMT | BAR with prescribed rotor-nacelle-assembly motion | 0 | 0 | |
| [x] | `ad_BAR_SineMotion_UA4_DBEMT3` | BEMT + UA4 + DBEMT3 | unsteady aero model 4 + dynamic BEMT 3 | 1 | 0 | |
| [x] | `ad_EllipticalWingInf_OLAF` | OLAF | elliptical wing analytical case | 1 | 0 | |
| [x] | `ad_HelicalWakeInf_OLAF` | OLAF | helical wake analytical case | 1 | 0 | |
| [x] | `ad_Kite_OLAF` | OLAF | kite configuration | 1 | 0 | |
| [x] | `ad_MHK_RM1_Fixed` | BEMT | Marine Hydro-Kinetic reference model 1, fixed | 1 | Fixed | |
| [x] | `ad_MHK_RM1_Fixed_IfW` | BEMT | MHK RM1 + InflowWind | 1 | Fixed | |
| [x] | `ad_MHK_RM1_Floating` | BEMT | MHK RM1, floating | 1 | Floating | |
| [x] | `ad_timeseries_shutdown` | BEMT | time-dependent analysis (AT=2), shutdown maneuver | 0 | 0 | |
| [x] | `ad_VerticalAxis_OLAF` | OLAF | vertical-axis turbine | 0 | 0 | |

**Execution plan for Group A:** run each case one at a time through the existing generator script. If any fail (driver error, missing files, unexpected output naming), diagnose before continuing to the next. OLAF cases may be substantially slower than the 0.27s BEMT baseline — Free Vortex Wake is computationally heavier. MHK cases may reference SeaState (`CompSeaSt`); confirm it's 0 (no waves) in each `.dvr` before running.

**Determinism note:** Phase 1 confirmed BEMT determinism. OLAF determinism has not been independently confirmed. If any OLAF case produces different output on re-run, we have a scrubber-class investigation (same as ROSCO's FITPACK issue). Run two successive iterations of the first OLAF case (`ad_B1n2_OLAF`, the simplest) and `cmp -s` them before generating the baseline.

### Group B — need script updates for non-standard output filenames

These 3 cases write output files with different naming conventions. The existing `generate_aerodyn_baseline.sh` and `verify_aerodyn_baselines.sh` look for `ad_driver.outb` — they need to also detect and handle `.T2.outb` (multi-turbine) and `.4.outb` (combined cases) variants. The detection logic should mirror `executeAerodynRegressionCase.py` lines 107-113:

```python
localOutFileWT2   = os.path.join(testBuildDirectory, "ad_driver.T2.outb")
localOutFileCase4 = os.path.join(testBuildDirectory, "ad_driver.4.outb")
if os.path.exists(localOutFileWT2):
    localOutFile = localOutFileWT2
elif os.path.exists(localOutFileCase4):
    localOutFile = localOutFileCase4
```

| | Case | AT | NT | Expected output file | Notes |
|-|------|----|----|---------------------|-------|
| [x] | `ad_BAR_CombinedCases` | 3 | 1 | `ad_driver.4.outb` (case 4 of 4) | NREL's script compares the last case. Multiple `.outb` files produced; we baseline the one NREL baselines. |
| [x] | `ad_MultipleHAWT` | 1 | 2 | `ad_driver.T2.outb` (turbine 2) | NREL's script compares turbine 2. Turbine 1 output is `ad_driver.outb`. |
| [x] | `ad_QuadRotor_OLAF` | 1 | 5 | `ad_driver.T2.outb` (turbine 2) | OLAF quad rotor, 5 turbines. NREL's script compares turbine 2. |

**Execution plan for Group B:** update both `generate_aerodyn_baseline.sh` and `verify_aerodyn_baselines.sh` to detect `.T2.outb` and `.4.outb` variants (check existence after driver run, prefer the variant if it exists, fall back to `ad_driver.outb`). The baseline filename in `baselines/aerodyn/<case>/` should match the actual output filename (e.g., `ad_driver.T2.baseline.outb`). Then run the generator for each.

### Group C — skip (completely different verification pattern)

| | Case | Why skipped |
|-|------|-------------|
| [ ] | `ad_Sphere_OLAF` | NT=0, no `.outb` output. NREL's script special-cases this: it reads a VTK file (`vtk_fvw/ad_driver.FVW_Glb.SrcPnl.000000002.vtk`), extracts line 1062 for a Cp value, and compares against a hardcoded reference `CpMaxRef = -1.259784`. This is fundamentally different from `.outb` comparison and would need a dedicated handler. Not blocking for AeroDyn translation work — Sphere is a validation case for the OLAF panel solver, not a BEMT/DBEMT/FVW translation target. |

**Action:** document as skipped in this table. If we need Sphere verification later (e.g., when translating OLAF panel solver code), write a custom baseline handler at that point.

### Execution order

1. **OLAF determinism check** — run `ad_B1n2_OLAF` twice, `cmp -s` both outputs. Gate for all OLAF cases.
2. **Group A (12 cases)** — one at a time through `generate_aerodyn_baseline.sh`. Verify each immediately after generation with `verify_aerodyn_baselines.sh <case>`.
3. **Script updates for Group B** — add output-variant detection to both scripts.
4. **Group B (3 cases)** — generate + verify each.
5. **Final `verify_aerodyn_baselines.sh all`** — end-to-end regression run confirming every committed baseline passes.
6. **Commit** — one commit to OpenFAST fork with all 15 new baselines + script updates. Dev note + CLAUDE.md in VIT repo.
7. **Skip `ad_Sphere_OLAF`** — documented above.

### Progress summary

When Phase 2 is complete, this table should show the final state:

| Group | Cases | Baselined | Skipped | Notes |
|-------|-------|-----------|---------|-------|
| Phase 1 | 1 | 1 | 0 | `ad_BAR_SineMotion` (BEMT, determinism confirmed) |
| Group A | 12 | **12 / 12** | 0 | **Complete.** All passed. OLAF determinism confirmed on `ad_B1n2_OLAF`. `ad_timeseries_shutdown` required 5MW_Baseline path fix. |
| Group B | 3 | **3 / 3** | 0 | **Complete.** Required output-variant detection (`.T2.outb`, `.4.outb`). Header-only binary diffs in 2 cases (data bit-identical; verifier handles this via `fast_io` fallback). |
| Group C | 1 | 0 | 1 | `ad_Sphere_OLAF` — skipped (VTK, not `.outb`) |
| **Total** | **17** | **16 / 16** | **1** | **Phase 2 complete. 16 baselined, 1 skipped. `verify_aerodyn_baselines.sh all` exits 0.** |

## Regenerating baselines

Baselines are platform-specific by definition. They **must be regenerated** when any of the following changes:

- `vit-dev-openfast` Docker image rebuilt (different base packages, different Python deps)
- OpenBLAS or LAPACK version changes (e.g., Ubuntu apt-get updates)
- gfortran version changes
- OpenFAST source changes from upstream merges (`git merge upstream/main`)
- Our own changes to OpenFAST source (integration wrappers, CMakeLists edits during the AeroDyn translation effort)

**Regeneration procedure:**

1. Rebuild the AeroDyn driver: `cd build && cmake --build . --target aerodyn_driver`
2. Re-run the generator for each affected case: `./scripts/generate_aerodyn_baseline.sh <case_name>`
3. Inspect the new `drift_vs_nrel.txt` — if drift grew dramatically, that's worth investigating before committing
4. Commit the updated baseline files

The baselines' authority derives from "these are what our build produces on our platform, right now." If the platform changes, the baselines change. That's the intended model.

## Platform constraint

**These baselines are only valid on `vit-dev-openfast` (ARM64 Linux, OpenBLAS, gfortran 13.3.0, Ubuntu 24.04).** Running `verify_aerodyn_baselines.sh` on a different platform (x86_64, Intel MKL, different gfortran) will almost certainly fail the bit-identical gate because of ULP-level floating-point differences — same reason NREL's reference fails for us on our platform.

Anyone using VIT on a different platform would need to:
1. Set up their own equivalent of `vit-dev-openfast` (use `vit/docker/Dockerfile.openfast` as the starting point)
2. Generate their own baselines via `generate_aerodyn_baseline.sh`
3. Use those baselines as their local gate

This is not a problem to solve — it's a property of the approach. Platform-specific baselines are the whole point.

## Relationship to the r-test submodule

The `reg_tests/r-test/` directory is a git submodule pointing at `https://github.com/OpenFAST/r-test.git` — NREL's repository. We do **not** modify files inside it. Our workflow copies inputs from r-test to scratch build subdirectories, runs the driver there, and leaves r-test untouched. If you ever see changes inside `reg_tests/r-test/` after running our scripts, that's a bug in the script — report it.

NREL's reference `.outb` files at `reg_tests/r-test/modules/aerodyn/<case>/ad_driver.outb` remain as the upstream reference for cross-platform comparison. Our `baselines/aerodyn/<case>/ad_driver.baseline.outb` is our platform-specific canonical. Both are useful, they answer different questions.
