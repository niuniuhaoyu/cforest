# Changelog

All notable changes to this project will be documented in this file.

## [0.2.0] — 2026-10-08

### Added
- `cforest_predict`: out-of-sample CATE after `cforest`. Reuses the model from
  the last fit (written to a session file) or one saved with `saving(filename)`;
  optional `lower()` / `upper()` pointwise intervals; respects `if` / `in`.
- `cforest, saving(filename)`: persist the fitted model to a file.
- Cross-check against R `grf` (`examples/reference/run_grf_check.R`):
  corr(τ̂_cforest, τ̂_grf) = **0.97**, both recover the true CATE τ(x) = x₁,
  and both ATE / CATT ≈ 0. `grf` (C++) and `econml.grf` (Python) are different
  implementations, so agreement is qualitative, not bit-exact.
- Reproducibility assertion: same seed → identical CATE (in `_test_cforest.do`).
- Tests: `examples/_test_predict.do`, `examples/_test_cforest_grf.do`.

## [0.1.0] — 2026-10-07 — Stage A

### Added
- `cforest` command: causal forest (CATE) for a binary treatment, driven through
  Stata's Python integration calling `econml.grf.CausalForest`
  (`cforest.ado` + `cforest.py`). Returns per-observation CATE (`cforest_tau`)
  with pointwise bounds (`cforest_tau_lb` / `cforest_tau_ub`) and `r(ate)`,
  `r(catt)`.
- Verified on a known-CATE DGP (`examples/_test_cforest.do`): corr(τ̂, x1) ≈ 0.94,
  ATE ≈ 0.

## [0.0.1] — 2026-10-07

### Added
- Repository skeleton and design spec / implementation plan
  (`docs/specs/2026-10-07-cforest-design.md`, `docs/plans/2026-10-07-cforest-plan.md`).
