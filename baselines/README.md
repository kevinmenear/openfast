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

## Current cases

| Case | Description | Added | Baseline file size |
|------|-------------|-------|--------------------|
| `ad_BAR_SineMotion` | BAR turbine, sinusoidal base motion, BEMT, 7s / 70 timesteps | 2026-04-14 | ~22 KB |

Phase 2 work will extend this to the remaining 16 AeroDyn r-test cases (`ad_BAR_OLAF`, `ad_BAR_CombinedCases`, `ad_BAR_RNAMotion`, `ad_BAR_SineMotion_UA4_DBEMT3`, `ad_B1n2_OLAF`, `ad_MultipleHAWT`, `ad_timeseries_shutdown`, `ad_MHK_RM1_*`, `ad_VerticalAxis_OLAF`, `ad_Sphere_OLAF`, etc.) after the infrastructure is proven on `ad_BAR_SineMotion`.

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
