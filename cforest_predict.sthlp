{smcl}
{* 08 Oct 2026}{...}
{hline}
{p 4 8 2}{bf:cforest_predict} — predict CATE after {bf:cforest}{right:version 0.2.0}
{hline}

{title:Title}

{p 4 4 2}
{cmd:cforest_predict} — predict the conditional average treatment effect (CATE)
{it:newvar} for the data currently in memory, after fitting a causal forest
with {help cforest}.

{title:Syntax}

{p 8 12 2}
{cmd:cforest_predict} {it:newvar} {ifin}{cmd:,}
{cmd:[}{cmd:model:(}{it:filename}{cmd:)} {cmd:level:(}{it:#}{cmd:)}
{cmd:lower:(}{it:newvar}{cmd:)} {cmd:upper:(}{it:newvar}{cmd:)}{cmd:]}

{title:Description}

{p 4 4 2}
{cmd:cforest_predict} writes {it:newvar} containing the predicted CATE
{&tau}(x) for each observation in the current dataset. By default it reuses the
model fitted by the most recent {help cforest} in this session; alternatively,
{cmd:model(}{it:filename}{cmd:)} loads a model saved with
{cmd:cforest, saving(}{it:filename}{cmd:)}.

{pstd}
The current data must contain variables with the same names as the covariates
used to fit the model. With {cmd:lower()} and {cmd:upper()}, pointwise
confidence intervals are written to the named variables.

{title:Options}

{p 4 8 2}{cmd:model(}{it:filename}{cmd:)} loads a previously saved model
({it:filename} as given to {cmd:cforest, saving()}). If omitted, the model from
the most recent {cmd:cforest} call in this session is used.

{p 4 8 2}{cmd:level(}{it:#}{cmd:)} sets the confidence level for the interval;
default is {cmd:level(95)}.

{p 4 8 2}{cmd:lower(}{it:newvar}{cmd:)} and {cmd:upper(}{it:newvar}{cmd:)} name
the variables that receive the lower and upper confidence limits.

{title:Examples}

{p 8 8 2}{cmd:. cforest y x1 x2 x3, treat(w) saving(mymodel.joblib)}
{p 8 8 2}{cmd:. use testdata, clear}
{p 8 8 2}{cmd:. cforest_predict tauhat, model(mymodel.joblib) lower(tau_lo) upper(tau_hi)}

{title:References}

{pstd}
Wager, S., and S. Athey. 2018. Estimation and inference of heterogeneous treatment
effects using random forests. {it:Journal of the American Statistical Association} 113(523): 1228-1242.

{pstd}
Athey, S., J. Tibshirani, and S. Wager. 2019. Generalized random forests.
{it:Annals of Statistics} 47(2): 1148-1178.

{title:Also see}

{p 4 4 2}
{help cforest}
