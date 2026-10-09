# cforest — Stage B roadmap (native C++ plugin, zero dependency)

> Status: **not started** (this is the month-level part). Stage A ships a working
> causal forest in Stata; Stage B replaces the Python bridge with a native Stata
> plugin that links the `grf` C++ core, so users need **no Python**.

## Goal

`cforest` (same command interface as Stage A) implemented as a **Stata plugin
(SPI)**: data in from Stata → `grf` C++ core → τ̂(x), σ̂(x) back to Stata.
Deliverable: a `net install`-able package with precompiled binaries for
Windows / macOS (Intel & ARM) / Linux.

## Why it is hard

1. **Strip R from `grf`.** `grf-labs/grf` is GPL-3 C++17; the R package is an
   `Rcpp` shell over the core. `skgrf` (PyPI) already proved the core can be
   used outside R — Stage B does the same for Stata.
2. **Vendor Eigen** (`RcppEigen` → plain Eigen headers) and remove Rcpp types.
3. **Stata Plugin Interface (SPI).** `rdrobust`, `honestdid`, … ship plugins:
   `stplugin.c/h`, a `ST_plugin` entry point, `st_store`/`st_data` for matrices.
   Needs `stplugin.h` for Stata 16+ and a matching `stata_version` value.
4. **Cross-platform build & distribution.** Each OS/arch needs its own binary;
   `net install` must ship them. This is the tedious M5/M6 work in the plan.

## Toolchain

Building requires a C++17 compiler and the Stata plugin headers. **This machine
currently has no compiler** (`gcc` / `cl` / `clang` all absent), so Stage B
cannot even be compiled here today. Options:

- **Windows (MSVC):** Visual Studio Build Tools (or Rtools45's gcc).
- **Stata headers:** ship with Stata; `stplugin.h` / `stplugin.c` are in the
  Stata installation (see `help plugin`).
- Cross-compilation from one machine is not practical; plan an OS per binary.

Reference build command sketch (MSVC, after vendoring `grf` core + Eigen):

```
cl /LD /O2 /I <eigen> /I <grf_core> /I <stata_include> ^
   plugin/cforest_plugin.c plugin/grf_shim.cpp ^
   /Fe:cforest_windows.plugin
```

## Milestones (from `docs/plans/2026-10-07-cforest-plan.md`)

| # | Deliverable | Rough |
|---|---|---|
| M3 | Vendor `grf` core + Eigen; strip Rcpp; build a **minimal SPI plugin** that copies a matrix in/out | 2–4 weeks (hardest) |
| M4 | Plugin `cforest`: pass X/Y/W, return τ̂ / σ̂; match Stage A exactly | 3–6 weeks |
| M5 | Cross-platform binaries (Win / mac ARM / mac Intel / Linux) + `net install` packaging | 2–4 weeks |
| M6 | Docs, examples, Stata Journal submission, SSC | ongoing |

Overall: **3–6 months** of focused work. Stage A remains the shipping product
meanwhile and defines the exact interface Stage B must reproduce.

## Acceptance (Stage B)

- `cforest` plugin output equals Stage A / R `grf` to numerical tolerance.
- `net install cforest, from(...)` works on a clean machine with **no Python**.
- Same command syntax, stored results, and `cforest_predict`/`cforest_blp`/
  `cforest_plot` continue to work unchanged.

## Licensing

`grf` is GPL-3. Linking its C++ core into a plugin makes the distributed binary
GPL-3; this package is AGPL-3.0 (compatible). Method attribution to
Athey–Tibshirani–Wager is mandatory.
