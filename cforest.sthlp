{smcl}
{* 07 Oct 2026}{...}
{hline}
{p 4 8 2}{bf:cforest} — Causal forests for heterogeneous treatment effects{right:version 0.0.1}
{hline}

{title:Title}

{p 4 4 2}
{cmd:cforest} — Estimate the conditional average treatment effect (CATE) for a
binary treatment using a causal forest.

{title:Syntax}

{p 8 12 2}
{cmd:cforest} {it:depvar indepvars} {ifin}, {cmdab:treat:(}{it:varname}{cmd:)}
{cmd:[}{cmd:numtrees:(}{it:#}{cmd:)} {cmd:honesty} {cmd:nohonesty}
{cmd:mtry:(}{it:#}{cmd:)} {cmd:minnodesize:(}{it:#}{cmd:)}
{cmd:sampleratio:(}{it:#}{cmd:)} {cmd:seed:(}{it:#}{cmd:)} {cmd:level:(}{it:#}{cmd:)}{cmd:]}

{title:Description}

{p 4 4 2}
{cmd:cforest} estimates heterogeneous treatment effects (CATE) using a causal
forest, following Wager and Athey (2018) and Athey, Tibshirani and Wager (2019).

{pstd}
This is a {bf:skeleton} (version 0.0.1); the estimator is not implemented yet.
See {browse "docs/plans/2026-10-07-cforest-plan.md":docs/plans/2026-10-07-cforest-plan.md}.

{title:References}

{pstd}
Wager, S., and S. Athey. 2018. Estimation and inference of heterogeneous treatment
effects using random forests. {it:Journal of the American Statistical Association} 113(523): 1228-1242.

{pstd}
Athey, S., J. Tibshirani, and S. Wager. 2019. Generalized random forests.
{it:Annals of Statistics} 47(2): 1148-1178.
