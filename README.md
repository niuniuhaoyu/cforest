# cforest

[English](README.md) | [简体中文](README_zh.md)

**Causal forests for heterogeneous treatment effects, for Stata**

[![Stata 16+](https://img.shields.io/badge/Stata-16%2B-blue.svg)](https://www.stata.com/)
[![License: AGPL-3.0](https://img.shields.io/badge/License-AGPL--3.0-blue.svg)](LICENSE)

> Status: **v0.3.0 (Stage A)** — estimates CATE with a causal forest;
> predicts it out of sample, reports the best linear projection and variable
> importance, and plots the CATE curve. Cross-checked against R `grf`.
> Stage B (native C++ plugin, zero dependency) is the remaining work.

`cforest` estimates the **conditional average treatment effect (CATE)**
τ(x) = E[Y(1) − Y(0) | X = x] with a **causal forest**, following
Wager & Athey (2018) and Athey, Tibshirani & Wager (2019).

Average methods (regression, DiD) give one number; a causal forest tells you how
the effect varies with covariates. R `grf` and Python EconML/`skgrf` exist, but
**Stata has no usable implementation** — this package fills that gap.

## Architecture

A faithful causal forest needs thousands of trees with honest splitting and
variance estimation, so pure Mata is too slow. Two stages:

- **Stage A (Python bridge)** — ✅ **done**: drives `econml.grf.CausalForest`
  through Stata's built-in Python integration.
- **Stage B (native plugin)** — ⏳ pending (see [`docs/stage-b.md`](docs/stage-b.md)):
  compile `grf`'s C++ core into a Stata plugin (SPI) for zero dependencies.
  (`skgrf` proves the core can be reused outside R.)

## Commands

```stata
cforest depvar indepvars [if] [in], treat(varname) ///
    [numtrees(#) minnodesize(#) seed(#) level(#) saving(filename) graph]

cforest_predict newvar [if] [in], [model(filename) level(#) lower(newvar) upper(newvar)]
cforest_blp [indepvars] [, level(#)]
cforest_plot, over(varname) [bins(#) level(#) title(string) saving(filename)]
```

- **`cforest`** estimates τ̂(x) and adds `cforest_tau` (CATE), `cforest_tau_lb` /
  `cforest_tau_ub` (pointwise bounds), and `cforest_tau_oob` (out-of-bag CATE);
  returns `r(ate)`, `r(catt)`, `r(ate_oob)`, `r(importance)`, `r(covariates)`.
  `graph` draws a variable-importance bar chart; `saving()` persists the model.
- **`cforest_predict`** predicts CATE on new data (reuses the last model or one
  saved with `saving()`), optionally writing `lower()`/`upper()` bounds.
- **`cforest_blp`** reports the best linear projection of τ̂(x) on the covariates
  (GRF heterogeneity summary, robust SE).
- **`cforest_plot`** draws a binned CATE curve with a confidence band.

## Example

```stata
cforest y x1 x2 x3, treat(w) numtrees(2000) seed(12345) saving(mymodel.joblib)
cforest_blp
cforest_plot, over(x1) saving(cate.png)
* ... load new data with x1 x2 x3 ...
cforest_predict tauhat, model(mymodel.joblib) lower(tau_lo) upper(tau_hi)
```

## Results

Estimated CATE vs the covariate that drives heterogeneity (truth: τ(x) = x₁):

![CATE curve](examples/cforest_cate.png)

Variable importance:

![Variable importance](examples/cforest_importance.png)

## Verification (Stage A)

Simulated DGP with known CATE τ(x) = x₁ (1,000 trees unless noted):

| Check | Result |
|---|---|
| Known-CATE recovery | corr(τ̂, x₁) = **0.94** |
| Out-of-sample prediction (500 held out) | corr(τ̂, x₁) = **0.93** |
| Out-of-bag τ̂ | corr(τ̂_oob, x₁) = **0.94** |
| R `grf` cross-check (`examples/reference/run_grf_check.R`) | corr(τ̂_cforest, τ̂_grf) = **0.97** |
| ATE / CATT (true = 0) | ≈ 0 (R `grf` ATE = +0.0009) |
| Best linear projection | slope on x₁ = **0.70**, on x₂/x₃ ≈ 0.02 / 0.01 |
| Variable importance | x₁ = **0.72**, x₂ = 0.21, x₃ = 0.07 |
| Reproducibility | same seed → identical τ̂ |

The BLP slope on x₁ is positive and dominant but **attenuated** (0.70 vs 1): the
forest estimate τ̂ is noisy, and OLS of τ̂ on x₁ suffers regression dilution —
the same caveat applies to `grf::best_linear_projection`. `grf` (C++ kernel) and
`econml.grf` (pure Python) are different implementations, so agreement is
qualitative, not bit-exact; both recover the true CATE.

Tests: `examples/_test_cforest.do`, `examples/_test_predict.do`,
`examples/_test_extras.do`, `examples/_test_cforest_grf.do` +
`examples/reference/run_grf_check.R`. Figures: `examples/cforest_figures.do`.

## License & attribution

Method: Wager & Athey (2018); Athey, Tibshirani & Wager (2019).
The `grf` reference implementation is GPL-3; linking its core yields a
GPL/AGPL-licensed plugin. This package is AGPL-3.0.

---

[English](README.md) | [简体中文](README_zh.md)
