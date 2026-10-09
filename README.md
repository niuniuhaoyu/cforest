# cforest

**Causal forests for heterogeneous treatment effects, for Stata**

[![Stata 16+](https://img.shields.io/badge/Stata-16%2B-blue.svg)](https://www.stata.com/)
[![License: AGPL-3.0](https://img.shields.io/badge/License-AGPL--3.0-blue.svg)](LICENSE)

> Status: **v0.2.0 (Stage A)** — `cforest` estimates the CATE and
> `cforest_predict` predicts it on new data; cross-checked against R `grf`
> (corr of the two CATE estimates ≈ 0.97). Stage B (native C++ plugin,
> zero dependency) is the remaining work.
> Design: [`docs/specs/2026-10-07-cforest-design.md`](docs/specs/2026-10-07-cforest-design.md)
> Plan: [`docs/plans/2026-10-07-cforest-plan.md`](docs/plans/2026-10-07-cforest-plan.md)

`cforest` estimates the **conditional average treatment effect (CATE)**
τ(x) = E[Y(1) − Y(0) | X = x] with a **causal forest**, following
Wager & Athey (2018) and Athey, Tibshirani & Wager (2019).

Average methods (regression, DiD) give one number; a causal forest tells you how
the effect varies with covariates. R `grf` and Python EconML/`skgrf` exist, but
**Stata has no usable implementation** — this package fills that gap.

## Architecture

A faithful causal forest needs thousands of trees with honest splitting and
variance estimation, so pure Mata is too slow. Two stages:

- **Stage A (Python bridge)** — ✅ **done**: `cforest` drives
  `econml.grf.CausalForest` through Stata's built-in Python integration.
- **Stage B (native plugin)** — ⏳ pending: compile `grf`'s C++ core into a
  Stata plugin (SPI) for zero dependencies. (`skgrf` proves the core can be
  reused outside R.)

## Syntax

```stata
cforest depvar indepvars [if] [in], treat(varname) ///
    [numtrees(#) minnodesize(#) seed(#) level(#) saving(filename)]

cforest_predict newvar [if] [in], [model(filename) level(#) lower(newvar) upper(newvar)]
```

`cforest` adds `cforest_tau` (the CATE) with pointwise bounds `cforest_tau_lb`
and `cforest_tau_ub`, and returns `r(ate)`, `r(catt)`, `r(numtrees)`.
`cforest_predict` writes the CATE for the data currently in memory, reusing the
last fitted model or one saved with `saving()`.

```stata
cforest y x1 x2 x3, treat(w) numtrees(2000) seed(12345) saving(mymodel.joblib)
* ... load new data with x1 x2 x3 ...
cforest_predict tauhat, model(mymodel.joblib) lower(tau_lo) upper(tau_hi)
```

## Verification (Stage A)

On the simulated DGP with known CATE τ(x) = x₁:

| Check | Result |
|---|---|
| Known-CATE recovery | corr(τ̂, x₁) = **0.94** |
| Out-of-sample prediction (500 held out) | corr(τ̂, x₁) = **0.93** |
| R `grf` cross-check (`examples/reference/run_grf_check.R`) | corr(τ̂_cforest, τ̂_grf) = **0.97** |
| ATE / CATT (true = 0) | ≈ 0 (R `grf` ATE = +0.0009) |
| Reproducibility | same seed → identical τ̂ |

`grf` (C++ kernel) and `econml.grf` (pure Python) are different implementations,
so agreement is qualitative, not bit-exact; both recover the true CATE.

Tests: `examples/_test_cforest.do`, `examples/_test_predict.do`,
`examples/_test_cforest_grf.do` + `examples/reference/run_grf_check.R`.

## License & attribution

Method: Wager & Athey (2018); Athey, Tibshirani & Wager (2019).
The `grf` reference implementation is GPL-3; linking its core yields a
GPL/AGPL-licensed plugin. This package is AGPL-3.0.
