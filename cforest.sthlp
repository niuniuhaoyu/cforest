{smcl}
{* 08 Oct 2026}{...}
{hline}
{p 4 8 2}{bf:cforest} — Causal forests for heterogeneous treatment effects{right:version 0.2.0}
{hline}

{title:Title}

{p 4 4 2}
{cmd:cforest} — Estimate the conditional average treatment effect (CATE) for a
binary treatment using a causal forest.

{title:Syntax}

{p 8 12 2}
{cmd:cforest} {it:depvar indepvars} {ifin}, {cmdab:treat:(}{it:varname}{cmd:)}
{cmd:[}{cmd:numtrees:(}{it:#}{cmd:)} {cmd:minnodesize:(}{it:#}{cmd:)}
{cmd:seed:(}{it:#}{cmd:)} {cmd:level:(}{it:#}{cmd:)}
{cmd:saving:(}{it:filename}{cmd:)}{cmd:]}

{title:Description}

{p 4 4 2}
{cmd:cforest} estimates heterogeneous treatment effects (CATE)
{&tau}(x) = E[Y(1) {&minus} Y(0) | X = x] using a causal forest, following
Wager and Athey (2018) and Athey, Tibshirani and Wager (2019).

{pstd}
This is {bf:Stage A}: the estimator is driven through Stata's Python
integration, calling {cmd:econml.grf.CausalForest}. It adds
{cmd:cforest_tau} (the CATE) with pointwise bounds {cmd:cforest_tau_lb} and
{cmd:cforest_tau_ub}, and returns {cmd:r(ate)}, {cmd:r(catt)} and
{cmd:r(numtrees)}. Use {help cforest_predict} to predict CATE for new data.

{title:Options}

{p 4 8 2}{cmd:treat(}{it:varname}{cmd:)} specifies the binary treatment
variable; required.

{p 4 8 2}{cmd:numtrees(}{it:#}{cmd:)} sets the number of trees; default is
{cmd:numtrees(2000)}.

{p 4 8 2}{cmd:minnodesize(}{it:#}{cmd:)} sets the minimum leaf size; default is
{cmd:minnodesize(5)}.

{p 4 8 2}{cmd:seed(}{it:#}{cmd:)} sets the random-number seed for
reproducibility; default is {cmd:seed(12345)}.

{p 4 8 2}{cmd:level(}{it:#}{cmd:)} sets the confidence level for the pointwise
intervals; default is {cmd:level(95)}.

{p 4 8 2}{cmd:saving(}{it:filename}{cmd:)} saves the fitted model for later use
by {help cforest_predict}.

{title:Examples}

{p 8 8 2}{cmd:. cforest y x1 x2 x3, treat(w) numtrees(2000) seed(12345)}
{p 8 8 2}{cmd:. cforest_predict tauhat, lower(tau_lo) upper(tau_hi)}

{title:References}

{pstd}
Wager, S., and S. Athey. 2018. Estimation and inference of heterogeneous treatment
effects using random forests. {it:Journal of the American Statistical Association} 113(523): 1228-1242.

{pstd}
Athey, S., J. Tibshirani, and S. Wager. 2019. Generalized random forests.
{it:Annals of Statistics} 47(2): 1148-1178.

{title:Also see}

{p 4 4 2}
{help cforest_predict}
