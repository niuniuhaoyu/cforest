{smcl}
{* 08 Oct 2026}{...}
{hline}
{p 4 8 2}{bf:cforest_plot} — binned CATE curve after {bf:cforest}{right:version 0.3.0}
{hline}

{title:Title}

{p 4 4 2}
{cmd:cforest_plot} — plot the estimated CATE against a covariate, in equal-count
bins, with a confidence band.

{title:Syntax}

{p 8 12 2}
{cmd:cforest_plot,} {cmd:over(}{it:varname}{cmd:)}
{cmd:[}{cmd:bins:(}{it:#}{cmd:)} {cmd:level:(}{it:#}{cmd:)}
{cmd:title:(}{it:string}{cmd:)} {cmd:saving:(}{it:filename}{cmd:)}{cmd:]}

{title:Description}

{p 4 4 2}
{cmd:cforest_plot} bins the covariate {it:varname} into equal-count bins, plots
the mean estimated CATE ({cmd:cforest_tau}) in each bin as a connected line, and
draws a pointwise confidence band. It is the natural way to visualise the
heterogeneity estimated by {help cforest}.

{title:Options}

{p 4 8 2}{cmd:over(}{it:varname}{cmd:)} the covariate on the x-axis; required.

{p 4 8 2}{cmd:bins(}{it:#}{cmd:)} number of equal-count bins; default
{cmd:bins(20)}.

{p 4 8 2}{cmd:level(}{it:#}{cmd:)} confidence level for the band; default
{cmd:level(95)}.

{p 4 8 2}{cmd:title(}{it:string}{cmd:)} graph title.

{p 4 8 2}{cmd:saving(}{it:filename}{cmd:)} export the graph to a file (PNG).

{title:Examples}

{p 8 8 2}{cmd:. cforest y x1 x2 x3, treat(w)}
{p 8 8 2}{cmd:. cforest_plot, over(x1) bins(20) saving(cate.png)}

{title:Also see}

{p 4 4 2}
{help cforest}; {help cforest_blp}
