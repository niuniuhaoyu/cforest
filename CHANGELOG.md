# Changelog

All notable changes to this project will be documented in this file.

## [Unreleased]

### Added (v0.1.0, Stage A)
- `cforest` command: causal forest (CATE) for a binary treatment, driven through
  Stata's Python integration calling `econml.grf.CausalForest`
  (`cforest.ado` + `cforest.py`). Returns per-observation CATE (new variable
  `cforest_tau`) and `r(ate)`, `r(catt)`.
- Verified on a known-CATE DGP (`examples/_test_cforest.do`): corr(tau_hat, x1) ≈ 0.94,
  ATE ≈ 0.
- Not yet: standard errors / CIs, `predict` on new data, best linear projection,
  and the native C++ plugin (Stage B, zero-dependency).

## [0.0.1]

### Added
- Repository skeleton and design spec / implementation plan
  (`docs/specs/2026-10-07-cforest-design.md`, `docs/plans/2026-10-07-cforest-plan.md`).
