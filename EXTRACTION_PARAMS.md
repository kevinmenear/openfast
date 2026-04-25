# AeroDyn Extraction Parameters

Per-function extraction parameters for KGen state capture. Line numbers are for **clean source** (after `reset_to_clean.sh`). Always re-check with grep before extracting — line numbers shift after integration.

## Completed Extractions

| Function | Caller | Source file | Test case | Invocation | Cases |
|----------|--------|-------------|-----------|------------|-------|
| Calculate_Cn | CalculateUACoeffs (line 974, else branch) | AirfoilInfo.f90 | ad_BAR_SineMotion | 0:0:1-5 | 20 |
| FindBoundingTables | AFI_ComputeAirfoilCoefs2D | AirfoilInfo.f90 | ad_MHK_RM1_Fixed | 0:0:1-5 | 21 |
| Compute_iLoweriUpper | CalculateUACoeffs (`.not. UA_f_cn` branch) | AirfoilInfo.f90 | ad_BAR_SineMotion_UA4_DBEMT3 | 0:0:1-20 | 20 |
| ComputeUA360_CnOffset | ComputeUA360_updateSeparationF (line 1482) | AirfoilInfo.f90 | ad_Kite_OLAF | 0:0:1-20 | 21 |

## Finding Call Sites

Two methods, use whichever fits:

**Method 1 — grep (simple, for leaf functions with 1-2 callers):**
```bash
bash scripts/reset_to_clean.sh
grep -n "call FunctionName" modules/aerodyn/src/SourceFile.f90
```

**Method 2 — call graph lookup (for functions with complex call paths):**
The fparser structural inventory at `vit/analysis/aerodyn/call_graph.json` has 3,451 caller→callee edges. Look up a function's callers to understand which code path reaches it, then trace to the mode flag that gates that path. Use with the test case coverage map in CLAUDE.md to choose the right test case.

```bash
# Example: find all callers of Compute_iLoweriUpper
python3 -c "import json; cg=json.load(open('vit/analysis/aerodyn/call_graph.json')); print([e for e in cg if e.get('callee','').lower()=='compute_iloweriupper'])"
```

## Notes

- **Invocation range:** Default `0:0:1-5` works for runtime functions. Use `0:0:1-20` for init-time functions (called once per airfoil during AFI_Init).
- **UA-gated functions (UA_f_cn=FALSE branch)** require `ad_BAR_SineMotion_UA4_DBEMT3` (UA_Mod=4, makes `UA_f_cn=FALSE`).
- **UA-gated functions (UA_f_cn=TRUE branch, ComputeUA360_*)** require `ad_Kite_OLAF` (UA_Mod=3, makes `UA_f_cn=TRUE`). Also needs `InclUAdata=TRUE` in the airfoil files (BAR airfoils have FALSE).
- **Multi-table functions** require `ad_MHK_RM1_Fixed` (AFTabMod=2). Default has AFTabMod=1.
- **OLAF/FVW functions** require an OLAF test case (e.g., `ad_BAR_OLAF`). BEMT test cases don't exercise FVW code paths.
