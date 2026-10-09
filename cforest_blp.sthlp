{smcl}
{* 08 Oct 2026}{...}
{hline}
{p 4 8 2}{bf:cforest_blp} — best linear projection after {bf:cforest}{right:version 0.3.0}
{hline}

{title:Title}

{p 4 4 2}
{cmd:cforest_blp} — regress the estimated CATE on the covariates (the GRF
best linear projection), with robust standard errors.

{title:Syntax}

{p 8 12 2}
{cmd:cforest_blp} {it:[indepvars]} {cmd:[,} {cmd:level:(}{it:#}{cmd:)}{cmd:]}

{title:Description}

{p 4 4 2}
{cmd:cforest_blp} runs OLS of the CATE estimated by {help cforest}
({cmd:cforest_tau}) on the covariates. The projection coefficients summarize how
the estimated effect varies with the covariates and provide a calibration check:
if the covariates driving heterogeneity are correctly captured, their
coefficients of a well-specified CATE are near one. If {it:indepvars} is omitted,
the covariates from the most recent {cmd:cforest} call are used, so
{cmd:cforest_blp} must then be run immediately after {cmd:cforest}.

{pstd}
This mirrors {cmd:grf::best_linear_projection} in R (as an unweighted OLS
projection; the R implementation uses the forest's weights).

{title:Options}

{p 4 8 2}{cmd:level(}{it:#}{cmd:)} confidence level; default {cmd:level(95)}.

{title:Stored results}

{p 4 8 2}{cmd:r(blp)} (coefficient vector), {cmd:r(N)}.

{title:Examples}

{p 8 8 2}{cmd:. cforest y x1 x2 x3, treat(w)}
{p 8 8 2}{cmd:. cforest_blp}

{title:Also see}

{p 4 4 2}
{help cforest}
