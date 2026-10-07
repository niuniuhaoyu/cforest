# cforest

**Causal forests for heterogeneous treatment effects, for Stata**

[![Stata 16+](https://img.shields.io/badge/Stata-16%2B-blue.svg)](https://www.stata.com/)
[![License: AGPL-3.0](https://img.shields.io/badge/License-AGPL--3.0-blue.svg)](LICENSE)

> Status: **skeleton** (v0.0.1) — estimator not implemented yet.
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

- **Stage A (Python bridge):** `cforest` drives `skgrf`/`grf` through Stata's
  built-in Python integration — fast to ship.
- **Stage B (native plugin):** compile `grf`'s C++ core into a Stata plugin (SPI)
  — zero dependencies. (`skgrf` proves the core can be reused outside R.)

## Planned syntax

```stata
cforest y x1 x2 x3, treat(w) numtrees(2000) seed(12345)
```

## License & attribution

Method: Wager & Athey (2018); Athey, Tibshirani & Wager (2019).
The `grf` reference implementation is GPL-3; linking its core yields a
GPL/AGPL-licensed plugin. This package is AGPL-3.0.
