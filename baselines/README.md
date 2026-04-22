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

## Platform drift investigation

**Status: RESOLVED.** Our baselines differ from NREL's shipped r-test references due to platform drift. Four investigations plus two NREL-matching container builds conclusively identified the causes and proved that bit-identity with NREL is not achievable on Apple Silicon hardware. **Our ARM64 baselines are confirmed as the correct verification infrastructure.** See dev notes `202604210915` (root cause) and `202604212346` (NREL-matching attempts) for the full analysis.

**TL;DR:** Rosetta x86_64 emulation introduces its own deterministic FP noise floor that masks all toolchain differences (BLAS, compiler, build flags). Two separate Rosetta containers (gfortran-14+ATLAS and gfortran-12+liblapack) produced byte-identical output — proving Rosetta, not toolchain, is the dominant variable. Our ARM64 native baselines are actually closer to NREL for some cases (MHK: 100% vs Rosetta's 68.52%). NREL themselves use 1e-2 tolerance, not bit-identity.

Our baselines differ from NREL's shipped r-test references. The magnitude varies across cases — from **0% drift** (MHK_RM1_Fixed and MHK_RM1_Floating match NREL bit-exactly on ARM64) to **1749 N·m absolute / 75% of values outside 1e-5 tolerance** (BAR_OLAF, VerticalAxis_OLAF). This section documents the investigations that characterized the drift.

### Observed drift summary (from Phase 2 generation)

For context, these are the drift-vs-NREL numbers that prompted the investigation:

| Case | % within 1e-5 rel OR 1e-6 abs | Max abs | Drifting channels | Aero model | Concern level |
|------|-------------------------------|---------|-------------------|-----------|---------------|
| ad_MHK_RM1_Fixed | 100.00% | 0.0 | 0 / 54 | BEMT | None (perfect match) |
| ad_MHK_RM1_Floating | 100.00% | 0.0 | 0 / 54 | BEMT | None (perfect match) |
| ad_MultipleHAWT | 100.00% | 3.3e-10 | 1 / 426 | BEMT | None |
| ad_BAR_SineMotion | 99.94% | 2.1e-1 | 12 / 127 | BEMT | Low |
| ad_BAR_SineMotion_UA4_DBEMT3 | 99.93% | 4.2e-1 | 9 / 127 | BEMT+UA4+DBEMT3 | Low |
| ad_BAR_CombinedCases | 99.99% | 7.2e-2 | 16 / 215 | BEMT | Low |
| ad_BAR_RNAMotion | 97.95% | 3.3 | 65 / 123 | BEMT | Medium |
| ad_Kite_OLAF | 99.27% | 2.8e-2 | 197 / 433 | OLAF | Medium |
| ad_HelicalWakeInf_OLAF | 99.84% | 2.4e-2 | 48 / 180 | OLAF | Medium |
| ad_BAR_OLAF | 98.68% | **1749** | **215 / 543** | **OLAF** | **High** |
| ad_QuadRotor_OLAF | 99.48% | 573 | 25 / 213 | OLAF | High |
| ad_timeseries_shutdown | 94.37% | 2.6e-2 | 5 / 22 | BEMT | Medium |
| ad_VerticalAxis_OLAF | **25.75%** | 3.1e-2 | **111 / 129** | **OLAF** | **High** |
| ad_B1n2_OLAF | 100.00% | 2.9e-7 | 4 / 40 | OLAF | None |
| ad_EllipticalWingInf_OLAF | 100.00% | 7.6e-9 | 26 / 314 | OLAF | None |
| ad_MHK_RM1_Fixed_IfW | 99.96% | 1.9 | 11 / 56 | BEMT+IfW | Low |

**Key patterns:**
- BEMT cases generally show low drift; OLAF cases show higher drift
- Simple OLAF cases (B1n2, Elliptical) have negligible drift; complex OLAF (BAR, QuadRotor, VerticalAxis) have large drift
- MHK cases match perfectly — something about that code path avoids all platform-dependent operations
- The 1749 N·m max abs in BAR_OLAF could be FP accumulation through the iterative FVW solver OR it could indicate a fundamentally different wake evolution

### Investigation 1: NREL CI build configuration

**Hypothesis:** NREL builds their r-test references with different cmake flags, compiler, or BLAS than we use. If their CI uses Intel MKL instead of OpenBLAS, or a different gfortran version, or specific optimization flags, that would be the primary explanation.

**Method:** read NREL's CI configuration files. Look for:
- GitHub Actions workflows at `.github/workflows/` in the openfast repo
- CTest configuration at `reg_tests/CMakeLists.txt` — look for tolerance values, compiler flags
- Any `Dockerfile` or CI scripts that document the build environment
- The r-test repo's own CI or README for how references are generated

**What to look for specifically:**
- BLAS/LAPACK library used (MKL? reference BLAS? OpenBLAS? Apple Accelerate?)
- Compiler and version (gfortran N.N.N? ifort? ifx?)
- Architecture (x86_64? ARM64? Both?)
- cmake flags beyond what we set (`-DCMAKE_BUILD_TYPE`, `-DDOUBLE_PRECISION`, FMA flags, optimization level overrides)
- How r-test references are regenerated (automated? manual? which machine?)

**Files to check** (all inside `openfast/` repo):
- `.github/workflows/*.yml` — GitHub Actions CI definitions
- `reg_tests/CMakeLists.txt` — CTest setup, tolerance defaults
- `reg_tests/CTestList.cmake` — per-case test registration, tolerance overrides
- `reg_tests/r-test/README.md` — may document reference generation process
- `Dockerfile` or `docker/` at repo root — CI container definition if present
- `share/` or `cmake/` — compiler flag definitions

**Expected outcome:** a concrete list of configuration differences between NREL's build and ours. If they use MKL on x86_64 and we use OpenBLAS on ARM64, that's a ~complete explanation for the drift. If they use the same OpenBLAS on x86_64, the explanation is narrower (architecture only).

**Status:** [x] **Complete.** NREL uses ATLAS BLAS on x86_64 with gfortran-14 and `RelWithDebInfo`. Three major differences from our build: BLAS library (ATLAS vs OpenBLAS — NREL specifically chose ATLAS because of a documented "bug in OpenBLAS" with OpenMP), architecture (x86_64 vs ARM64), compiler (gfortran-14 vs 13.3.0). Additional: NREL's reg_test tolerance is `1e-2` relative (not `1e-5`), 1000× looser than what we tested with. NREL does not expect cross-platform bit-identity.

**Dev note:** `202604210915-platform-drift-root-cause.md` (VIT repo)

---

### Investigation 2: Time-series drift profile for ad_BAR_OLAF

**Hypothesis:** if the 1749 N·m drift in ad_BAR_OLAF is FP accumulation through an iterative solver, the error should grow monotonically over the 60 timesteps. If it's a discrete branch divergence (e.g., a convergence check flipping at one timestep), the error should jump suddenly.

**Method:** parse both our `.outb` and NREL's reference `.outb` for ad_BAR_OLAF using `fast_io.load_output()` (from `reg_tests/lib/`). For the top 5 drifting channels (by max abs), plot abs_diff vs timestep. Also plot the actual values side-by-side.

**Specific commands** (run inside `vit-dev-openfast`):
```bash
docker exec vit-dev-openfast bash -c "cd /workspace/openfast/reg_tests/lib && python3 << 'PYEOF'
import sys; sys.path.insert(0, '.')
from fast_io import load_output
import numpy as np

# Our baseline
ours, info_ours, _ = load_output('/workspace/openfast/baselines/aerodyn/ad_BAR_OLAF/ad_driver.baseline.outb')
# NREL reference
ref, info_ref, _ = load_output('/workspace/openfast/reg_tests/r-test/modules/aerodyn/ad_BAR_OLAF/ad_driver.outb')

names = info_ref.get('attribute_names', [])
abs_diff = np.abs(ours - ref)
max_abs_per_ch = abs_diff.max(axis=0)

# Top 5 drifting channels
top5 = np.argsort(max_abs_per_ch)[::-1][:5]
for c_idx in top5:
    ch_name = names[c_idx] if c_idx < len(names) else f'ch{c_idx}'
    ts_diff = abs_diff[:, c_idx]
    ts_ours = ours[:, c_idx]
    ts_ref = ref[:, c_idx]
    # Print timestep-by-timestep profile
    print(f'\\n=== {ch_name} (max_abs={max_abs_per_ch[c_idx]:.3e}) ===')
    print('t_idx  abs_diff        our_value       ref_value')
    for t in range(len(ts_diff)):
        if ts_diff[t] > 0:
            print(f'{t:5d}  {ts_diff[t]:14.6e}  {ts_ours[t]:14.6e}  {ts_ref[t]:14.6e}')
PYEOF
"
```

**What to look for:**
- **Gradual growth:** abs_diff increases smoothly from ~0 at t=0 to max at final timestep → FP accumulation through iterative solver. Expected for OLAF's vortex filament updates where each timestep builds on the previous state.
- **Sudden jump:** abs_diff is near-zero for many timesteps then spikes at one specific timestep → branch divergence (a convergence check or conditional that takes a different path due to a threshold being crossed differently). More concerning — might indicate a real functional difference.
- **Oscillatory:** abs_diff fluctuates without trend → independent per-timestep FP noise. Would suggest the drift is in a per-timestep computation (like an airfoil lookup) rather than in cumulative state.
- **Constant offset:** abs_diff is nonzero but ~constant from the first timestep → different initial condition or parameter. Most concerning — might indicate a build configuration difference.

**Also do the same for `ad_VerticalAxis_OLAF`** — the case with 25.75% within tolerance. Same script, different file paths.

**Status:** [x] **Complete.** Three distinct signatures found:
1. **Constant offset** (ad_BAR_SineMotion `RtAeroMyh`): abs_diff is exactly `0.2146758` at every single timestep — fingerprint of a single BLAS/lookup operation producing a different result, propagated uniformly. Physically negligible (2e-8 relative at peak).
2. **Intermittent sensitivity** (ad_BAR_OLAF): most timesteps bit-identical (48/60 for `RtAeroMxh`), with spikes at specific sensitive wake configurations. The 1749 N·m peak at t_idx=26 is a transient that subsides — NOT accumulation, NOT divergence.
3. **Oscillatory growth** (ad_VerticalAxis_OLAF): drift grows ~1.5 orders of magnitude over 37 timesteps (3 revolutions) through cyclic wake feedback. Max 0.031 deg on a ±30° dynamic range — 0.1% relative, physically negligible.

None of these patterns suggest bugs. All are consistent with ATLAS-vs-OpenBLAS + x86_64-vs-ARM64 differences.

**Dev note:** `202604210915-platform-drift-root-cause.md` (VIT repo)

---

### Investigation 3: Reference BLAS comparison

**Hypothesis:** OpenBLAS is the primary driver of cross-platform drift. OpenBLAS uses optimized BLAS kernels that may produce different floating-point results from the reference (Netlib) BLAS implementation that NREL may use.

**Method:** rebuild AeroDyn_Driver with OpenFAST's built-in option to download and build reference (Netlib) LAPACK/BLAS instead of linking the system OpenBLAS:

```bash
# In vit-dev-openfast:
cd /workspace/openfast/build
rm -rf *
cmake .. \
    -DBUILD_FASTFARM=off \
    -DBUILD_OPENFAST_CPP_API=off \
    -DBUILD_TESTING=off \
    -DCMAKE_BUILD_TYPE=Release \
    -DUSE_LOCAL_STATIC_LAPACK=on      # <-- this flag downloads reference LAPACK/BLAS
make aerodyn_driver -j$(nproc)
```

**NOTE:** the `-DUSE_LOCAL_STATIC_LAPACK=on` option triggers a download of the reference LAPACK source from a NREL-hosted URL during cmake configure. This requires network access from inside the container. We confirmed during Docker container setup (dev note `202604140204`) that `docker build` has network access through the host, but whether a running container (`docker exec`) has network access is a SEPARATE question — the original `vit-dev` ROSCO container had no network access from inside a running container (CLAUDE.md documents "No network access from inside the container due to corporate TLS inspection"). **If the download fails, we may need to manually download the LAPACK tarball on the Mac and copy it into the container.**

After rebuilding, run a subset of cases (at minimum: `ad_BAR_SineMotion`, `ad_BAR_OLAF`, `ad_VerticalAxis_OLAF`, `ad_MHK_RM1_Fixed`) and compare against NREL's reference using the same `fast_io` comparison we've been doing. If drift shrinks dramatically with reference BLAS, OpenBLAS is the explanation. If drift stays the same, the cause is elsewhere (compiler, architecture, FMA).

**What to compare:**
- Same 4 cases, using `check_aerodyn_nrel_drift.sh` (but pointed at the reference-BLAS build)
- Specifically: does ad_MHK_RM1_Fixed remain bit-identical (it should, since it already matched with OpenBLAS)? Does ad_BAR_OLAF's 1749 N·m shrink substantially?

**Alternative if network fails:** skip the reference-BLAS download and instead compare with `OPENBLAS_NUM_THREADS=1` (force single-threaded OpenBLAS to eliminate threading nondeterminism as a variable). If single-threaded doesn't change results, threading isn't the issue.

**Status:** [ ] **Deferred.** Root cause identified by investigations 1 and 2 — ATLAS vs OpenBLAS is the dominant factor. This experiment would quantify how much drift is BLAS-specific vs architecture-specific, which is informative but academic. If we want to reduce cross-platform drift in the future, the actionable step is to match NREL's BLAS choice (`libatlas-base-dev` instead of `libopenblas-dev` in the Dockerfile), not to isolate the BLAS contribution.

---

### Investigation 4: FMA contraction flag

**Hypothesis:** gfortran and/or g++'s FMA (fused multiply-add) contraction scheduling differs between our build and NREL's. This was the dominant source of cross-build drift in ROSCO (see dev note `202603191041-fma-contraction-fix.md` in the VIT repo) — adding `-ffp-contract=off` to both compilers eliminated all ROSCO drift. OpenFAST's cmake does NOT set `-ffp-contract` explicitly, so the compiler default applies (`-ffp-contract=fast` for gfortran at optimization levels above -O0).

**Method:** rebuild with `-ffp-contract=off` on both Fortran and C++ compilers:

```bash
cd /workspace/openfast/build
rm -rf *
cmake .. \
    -DBUILD_FASTFARM=off \
    -DBUILD_OPENFAST_CPP_API=off \
    -DBUILD_TESTING=off \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_Fortran_FLAGS="-ffp-contract=off" \
    -DCMAKE_CXX_FLAGS="-ffp-contract=off"
make aerodyn_driver -j$(nproc)
```

Then run the same 4 representative cases and compare against NREL's reference. If NREL also builds with the compiler default (`-ffp-contract=fast`), this won't help — both builds would have FMA enabled. But if NREL builds with `-ffp-contract=off` (which some CI pipelines do for reproducibility), disabling FMA on our side should reduce drift to near-zero for the non-BLAS-dependent code paths.

**What to compare:**
- Same 4 cases as Investigation 3, drift vs NREL
- Also compare vs our own OpenBLAS+FMA baselines — this tells us how much drift is from FMA specifically vs BLAS

**Important:** after this investigation, rebuild with the original flags (no `-ffp-contract=off`) to restore the production configuration. We only want `-ffp-contract=off` as a diagnostic, not as the permanent build — same principle as ROSCO where it was used during verification but not in production.

**Status:** [ ] **Deferred.** Neither our build nor NREL's sets FMA flags (both use compiler default). Investigation 1 showed FMA scheduling is not a differentiator between our builds — the BLAS library and architecture differences are much larger. FMA investigation would only be informative if we wanted to explore whether `-ffp-contract=off` would reduce OLAF sensitivity windows, which is a research question rather than a verification question.

---

### Investigation order and dependencies

```
Investigation 1 (read NREL CI config) ──────────> can run immediately, cheapest
Investigation 2 (time-series analysis)  ──────────> can run immediately, uses existing data
Investigation 3 (reference BLAS rebuild) ─────────> requires rebuild (~5 min) + re-run (~2 min)
Investigation 4 (FMA flag rebuild)       ─────────> requires rebuild (~5 min) + re-run (~2 min)
```

Investigations 1 and 2 are independent and can run in parallel. They are also the cheapest — no rebuilds, no downloads, just reading files and parsing existing `.outb` data. Start with these.

Investigations 3 and 4 are rebuild experiments. They CAN run in parallel (each rebuilds from scratch) but share the build directory, so in practice they must be sequential. Do 3 first (more likely to be informative — BLAS is the bigger variable than FMA for OLAF's matrix operations).

**After all four complete:** write a summary dev note that synthesizes the findings into a revised characterization of the drift. Either:
- "Confirmed: platform drift from [specific causes]. Our baselines are correct references for our platform." → proceed with confidence
- "Found: [specific configuration issue]. Our baselines may be based on a misconfigured build." → fix the configuration, regenerate all 16 baselines, re-verify

### Build environment reference (for fresh sessions)

These are the current build parameters. Any investigation that changes them should document the change and restore afterwards.

**Current (production) build configuration:**
```bash
# Inside vit-dev-openfast container
cd /workspace/openfast/build
cmake .. \
    -DBUILD_FASTFARM=off \
    -DBUILD_OPENFAST_CPP_API=off \
    -DBUILD_TESTING=off \
    -DCMAKE_BUILD_TYPE=Release
make aerodyn_driver -j$(nproc)
```

**Container:** `vit-dev-openfast:latest` built from `vit/docker/Dockerfile.openfast` (commit `3564874` on VIT repo)
**Platform:** ARM64 Linux (Ubuntu 24.04 via Colima on Apple Silicon)
**Compiler:** gfortran 13.3.0 (`Ubuntu 13.3.0-6ubuntu2~24.04.1`)
**cmake:** 3.28.3
**BLAS/LAPACK:** OpenBLAS 0.3.26 (`libopenblas-dev:arm64 0.3.26+ds-1ubuntu0.1`) — provides both BLAS and LAPACK symbols
**OpenFAST commit:** `2895884d2` (v5.0.1 release merge)
**r-test submodule:** `dd5feaaa` (v5.0.0 tag)
**FMA flags:** not explicitly set → gfortran default is `-ffp-contract=fast` at -O2+

**Key scripts:**
- `scripts/generate_aerodyn_baseline.sh <case>` — generate a baseline for one case
- `scripts/verify_aerodyn_baselines.sh <case|all>` — verify against committed baselines (bit-identical gate)
- `scripts/check_aerodyn_nrel_drift.sh <case|all>` — informational drift vs NREL reference

**Key data files:**
- `baselines/aerodyn/<case>/ad_driver.baseline.outb` — our committed baselines (16 cases)
- `baselines/aerodyn/<case>/drift_vs_nrel.txt` — drift report at generation time
- `reg_tests/r-test/modules/aerodyn/<case>/ad_driver.outb` — NREL's reference (in submodule)
- `reg_tests/lib/fast_io.py` — `.outb` parser (`load_output()` function)
- `reg_tests/lib/pass_fail.py` — tolerance comparison logic

**Repos and remotes:**
- OpenFAST fork: `~/Artifacts/vit_translation_openfast/openfast/` — `origin` = `git@github.com:kevinmenear/openfast.git`, `upstream` = `https://github.com/OpenFAST/openfast.git`
- VIT: `~/Artifacts/vit_translation_openfast/vit/` — `origin` = `git@github.com:NatLabRockies/vit.git`
- KGen: `~/Artifacts/vit_translation_openfast/KGen/` — `origin` = `git@github.com:kevinmenear/KGen.git`

**Related dev notes** (in VIT repo `vit/dev/`):
- `202604140253-outb-format-and-verification-strategy.md` — `.outb` format analysis, tier-2 strategy decision, empirical validation with 5 failing elements identified
- `202604140330-aerodyn-baseline-infrastructure.md` — Phase 1 infrastructure (1 case)
- `202604210845-aerodyn-baseline-phase2-complete.md` — Phase 2 extension (all 16 cases)
- `202604140241-openfast-build-aerodyn-baseline.md` — original OpenFAST build + AeroDyn Driver smoke test
- `202604140204-vit-dev-openfast-docker-plan.md` — Docker container setup
- `202604140013-openfast-aerodyn-phase-start.md` — AeroDyn phase kickoff

## Phase 3: NREL-matching environment — COMPLETED (bit-identity not achievable via Rosetta)

Investigations 1 and 2 identified three root causes of drift vs NREL: BLAS library (ATLAS vs OpenBLAS), architecture (x86_64 vs ARM64), and compiler (gfortran-14 vs 13). Phase 3 attempted to eliminate all three by building NREL-matching containers.

**Original goal:** produce AeroDyn output bit-identical to NREL's shipped r-test references.

**Outcome:** bit-identity is **not achievable on Apple Silicon hardware**. Rosetta's x86_64 instruction translation introduces a deterministic FP noise floor that dominates all toolchain differences. Two separate Rosetta-based containers (gfortran-14+ATLAS matching current CI, gfortran-12+liblapack matching old reference generators) produced **byte-identical output** — proving Rosetta is the only variable that matters. Our ARM64 native baselines remain the correct approach.

**Key finding:** for the MHK case, our ARM64 native build was **closer** to NREL (100% bit-identical) than either Rosetta build (68.52%). Rosetta makes some cases worse, not better.

### What changes from the current setup

| Parameter | Current (`vit-dev-openfast`) | NREL-matching target | How to change |
|-----------|------------------------------|---------------------|---------------|
| **BLAS** | OpenBLAS 0.3.26 (`libopenblas-dev`) | **ATLAS** (`libatlas-base-dev`) | Swap apt package in Dockerfile |
| **Architecture** | ARM64 (native Apple Silicon) | **x86_64** (Rosetta emulation) | New Colima profile: `colima start --profile x86 --arch x86_64` |
| **Compiler** | gfortran-13.3.0 | **gfortran-14** | `apt install gfortran-14 g++-14 gcc-14` in Dockerfile |
| **Build type** | `Release` (`-O3`) | **`RelWithDebInfo`** (`-O2 -g`) | cmake flag |
| **OpenMP** | Not set (default OFF) | **ON** | cmake `-DOPENMP:BOOL=ON` |
| **FMA flags** | None (compiler default) | None (same) | No change needed |

### Execution steps

#### Step 1: Create x86_64 Colima profile

Colima supports multiple profiles. Create a second one for x86_64 without touching the existing ARM64 profile:

```bash
# On Mac (not inside any container):
colima start --profile x86 --arch x86_64 --cpu 4 --memory 8
```

This starts a new Colima VM running x86_64 Linux via Rosetta 2. Docker commands will target this VM while the profile is active. The existing `default` profile (ARM64) remains intact and can be switched back to with `colima start --profile default`.

**Risk:** Rosetta's FP translation for x86_64 SIMD instructions (SSE, AVX) should be faithful, but hasn't been verified for the specific BLAS/LAPACK operations OpenFAST uses. If bit-identity fails even with everything else matching, Rosetta FP translation is the residual factor and we document it.

**Status:** [x] Done. `qemu-img` shim created at `~/homebrew/bin/qemu-img`, lima x86_64 guest agent installed. Colima `--arch x86_64` still uses QEMU backend (VZ+Rosetta doesn't create x86_64 VMs — it creates aarch64 VMs with Rosetta inside). Docker's built-in binfmt handles amd64 containers on our aarch64 VM. `crane` installed for Mac-side image pulls (bypasses Docker-in-VM TLS issue).

#### Step 2: Write `Dockerfile.openfast-nrel-match`

New Dockerfile in `vit/docker/` that targets x86_64 with NREL's dependencies:

```dockerfile
FROM ubuntu:24.04

# NREL-matching system packages
RUN apt-get update && apt-get install -y --no-install-recommends \
        gfortran-14 g++-14 gcc-14 \
        libatlas-base-dev \
        libyaml-cpp-dev \
        cmake \
        make \
        wget \
        build-essential \
        libssl-dev zlib1g-dev libffi-dev libbz2-dev \
        libreadline-dev libsqlite3-dev libncurses-dev \
        python3 python3-pip python3-dev \
    && rm -rf /var/lib/apt/lists/*

# Set gfortran-14 as default
RUN update-alternatives --install /usr/bin/gfortran gfortran /usr/bin/gfortran-14 100 \
    && update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-14 100 \
    && update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-14 100

# Python 2.7 (for KGen)
RUN wget -q https://www.python.org/ftp/python/2.7.18/Python-2.7.18.tar.xz -O /tmp/Python-2.7.18.tar.xz \
    && cd /tmp && tar -xf Python-2.7.18.tar.xz \
    && cd Python-2.7.18 && ./configure --prefix=/opt/python27 \
    && make -j$(nproc) && make install \
    && ln -sf /opt/python27/bin/python2.7 /usr/local/bin/python2.7 \
    && cd / && rm -rf /tmp/Python-2.7.18*

# VIT Python dependencies + fparser
RUN pip3 install --break-system-packages \
        numpy pyyaml rich fparser vtk nptdms \
        'Bokeh>=2.4,!=3.0.0,!=3.0.1,!=3.0.2,!=3.0.3'

WORKDIR /workspace
CMD ["sleep", "infinity"]
```

Key differences from `Dockerfile.openfast`:
- Starts from `ubuntu:24.04` (not `vit-dev-image` which is ARM64)
- Uses `gfortran-14` (not whatever the base image had)
- Uses `libatlas-base-dev` (not `libopenblas-dev`)
- Installs Python 2.7 from source (same as before, but under x86_64 emulation — will be slower)
- Installs all Python deps from scratch (not inheriting from `vit-dev-image`)

**NOTE:** this is a FROM-scratch build, not layered on `vit-dev-image`, because `vit-dev-image` is ARM64. The entire container is rebuilt for x86_64. Expect ~20-30 minutes for the Docker build under Rosetta emulation (Python 2.7 source build + pip installs + ATLAS build are all slower under emulation).

**Status:** [x] Done. `Dockerfile.openfast-nrel-match` written and built (~10 min). Also built `Dockerfile.openfast-rtest-match` (Ubuntu 22.04 + gfortran-12 + liblapack) when we discovered the toolchain mismatch. Both committed to VIT repo.

#### Step 3: Build and start the container

```bash
# Ensure x86 Colima profile is active:
colima list   # verify x86 profile is running

# Build (from vit/docker/):
cd ~/Artifacts/vit_translation_openfast/vit/docker
docker build --platform linux/amd64 -f Dockerfile.openfast-nrel-match -t vit-dev-openfast-nrel .

# Run with the same workspace mount:
docker run -d --name vit-dev-openfast-nrel \
    -v ~/Artifacts/vit_translation_openfast:/workspace \
    vit-dev-openfast-nrel

# Install VIT as editable:
docker exec vit-dev-openfast-nrel pip3 install -e /workspace/vit --break-system-packages
```

**Status:** [x] Done. Both `vit-dev-openfast-nrel` (gfortran-14+ATLAS) and `vit-dev-openfast-rtest` (gfortran-12+liblapack) running.

#### Step 4: Verify the environment matches NREL

```bash
docker exec vit-dev-openfast-nrel bash -c "
  uname -m                    # should be x86_64
  gfortran --version | head -1   # should be GNU Fortran 14.x
  dpkg -l libatlas-base-dev | tail -1  # should show ATLAS installed
"
```

**Status:** [x] Done. Both containers verified: gfortran-14/ATLAS and gfortran-12/liblapack respectively. Architecture `x86_64` confirmed via `uname -m`.

#### Step 5: Build OpenFAST with NREL-matching cmake flags

```bash
docker exec vit-dev-openfast-nrel bash -c "
  cd /workspace/openfast/build && rm -rf * &&
  cmake .. \
    -DBUILD_FASTFARM=off \
    -DBUILD_OPENFAST_CPP_API=off \
    -DBUILD_TESTING=off \
    -DCMAKE_BUILD_TYPE=RelWithDebInfo \
    -DBLA_VENDOR:STRING=ATLAS \
    -DOPENMP:BOOL=ON \
    -DDOUBLE_PRECISION=ON &&
  make aerodyn_driver -j\$(nproc)
"
```

**Expected:** cmake finds ATLAS BLAS/LAPACK (not OpenBLAS). Build succeeds. AeroDyn_Driver produced.

**Status:** [x] Done in both containers. cmake found ATLAS and liblapack respectively. AeroDyn_Driver built and ran.

#### Step 6: Spot-check against NREL references (4 representative cases)

Run 4 cases that span the drift spectrum and compare directly against NREL's r-test references:

```bash
# Cases to test:
#   ad_MHK_RM1_Fixed      — was 100% bit-identical on ARM64+OpenBLAS (should remain so)
#   ad_BAR_SineMotion     — was 99.94% within tolerance, constant-offset signature
#   ad_BAR_OLAF           — was 98.68%, max abs 1749, intermittent sensitivity
#   ad_VerticalAxis_OLAF  — was 25.75%, oscillatory growth
```

For each case, run `check_aerodyn_nrel_drift.sh` and record the results. The key metric: **did the drift shrink?** Specifically:
- `ad_MHK_RM1_Fixed`: should remain bit-identical (0 drift)
- `ad_BAR_SineMotion`: the constant 0.2147 offset should disappear or shrink dramatically
- `ad_BAR_OLAF`: the 1749 N·m intermittent peak should shrink or vanish
- `ad_VerticalAxis_OLAF`: the 75% out-of-tolerance rate should improve substantially

If all four match NREL within `1e-5` (or ideally bit-identical), we've successfully matched the toolchain.

**Status:** [x] Done — **two rounds of spot-checks** (one per container). Results:

| Case | ARM64+OpenBLAS (native) | gfortran-14+ATLAS (Rosetta) | gfortran-12+liblapack (Rosetta) |
|------|------------------------|-----------------------------|--------------------------------|
| BAR_SineMotion | 90.55% bit-identical | **100%** | **100%** |
| MHK_RM1_Fixed | **100%** | 68.52% | **68.52%** (identical to ATLAS) |
| BAR_OLAF | max abs 1749 | max abs 1749 | **max abs 1749** (identical) |
| VerticalAxis_OLAF | 25.75% within tol | 25.75% | **25.75%** (identical) |

**Critical finding:** both Rosetta containers produce **byte-identical output** despite different BLAS (ATLAS vs liblapack) and compilers (gfortran-14 vs 12). Rosetta's FP translation layer is the sole remaining variable — it masks all toolchain differences. Bit-identity with NREL is not achievable through Rosetta.

#### Step 7: Full 16-case baseline regeneration — SKIPPED

Skipped — spot-check showed Rosetta-based containers do not improve on ARM64 baselines overall. The ARM64 baselines committed in Phase 2 remain the canonical references. No regeneration needed.

**Status:** [x] Skipped (correct decision based on Step 6 results)

#### Step 8: Decide on the container strategy going forward

Two options after we know whether NREL-matching works:

**Option A (recommended if bit-identical): use `vit-dev-openfast-nrel` as the primary container.** Replace the ARM64 container with the x86_64 NREL-matching one. Accept the ~2x performance penalty from Rosetta emulation in exchange for NREL-reference-compatible baselines. The 0.27s BAR_SineMotion case becomes ~0.5s — still fast enough for a development workflow.

**Option B (if residual drift remains): keep both containers.** Use `vit-dev-openfast` (ARM64) for fast daily development, and `vit-dev-openfast-nrel` (x86_64) for periodic NREL-compatibility checks. Baselines committed from the ARM64 container (deterministic, faster), with the x86_64 container as a sanity-check tool.

**Option C (fallback if Rosetta FP is the issue): document Rosetta as a known limitation.** If even with ATLAS + gfortran-14 + x86_64 emulation we still see drift, the remaining factor is Rosetta's FP instruction translation. This is documented, accepted, and we revert to Option B.

**Status:** [x] **Decision: Option A (ARM64 platform-specific baselines).** Rosetta noise makes Option C moot; native x86_64 not available. Our ARM64 baselines are the correct verification infrastructure. The NREL-matching containers remain available if native x86_64 hardware becomes accessible in the future.

### Build environment reference (NREL-matching target)

For fresh sessions, these are the target parameters for the NREL-matching container:

**Target (NREL-matching) build configuration:**
```bash
# Inside vit-dev-openfast-nrel container
cd /workspace/openfast/build
cmake .. \
    -DBUILD_FASTFARM=off \
    -DBUILD_OPENFAST_CPP_API=off \
    -DBUILD_TESTING=off \
    -DCMAKE_BUILD_TYPE=RelWithDebInfo \
    -DBLA_VENDOR:STRING=ATLAS \
    -DOPENMP:BOOL=ON \
    -DDOUBLE_PRECISION=ON
make aerodyn_driver -j$(nproc)
```

**Container:** `vit-dev-openfast-nrel:latest` built from `vit/docker/Dockerfile.openfast-nrel-match`
**Platform:** x86_64 Linux (Ubuntu 24.04 via Colima `--arch x86_64` Rosetta 2 on Apple Silicon)
**Compiler:** gfortran-14 (matching NREL CI)
**cmake:** 3.28.x (Ubuntu 24.04 default, same as before)
**BLAS/LAPACK:** ATLAS (`libatlas-base-dev`) — matching NREL CI
**OpenMP:** ON — matching NREL CI
**OpenFAST commit:** `2895884d2` (v5.0.1 release merge, same as before)
**FMA flags:** not explicitly set (same as NREL)

**NREL's actual CI configuration** (from `.github/workflows/automated-dev-tests.yml`):
- OS: `ubuntu-24.04` (x86_64, GitHub Actions runner)
- Compiler: `gfortran-14`, `g++-14`, `gcc-14`
- BLAS: ATLAS (`-DBLA_VENDOR:STRING=ATLAS`)
- Build type: `RelWithDebInfo`
- OpenMP: ON
- Double precision: ON

**Colima profiles (on the Mac):**
```bash
colima list                                    # show all profiles
colima start --profile default                 # ARM64 (original, for vit-dev and vit-dev-openfast)
colima start --profile x86 --arch x86_64       # x86_64 (for vit-dev-openfast-nrel)
```

**Key scripts** (same as before, run in whichever container is appropriate):
- `scripts/generate_aerodyn_baseline.sh <case>` — generate a baseline for one case
- `scripts/verify_aerodyn_baselines.sh <case|all>` — verify against committed baselines
- `scripts/check_aerodyn_nrel_drift.sh <case|all>` — informational drift vs NREL reference

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
