{smcl}
{* *! version 0.3.0  08oct2026}{...}
{hline}
{p 4 8 2}{bf:cforest} —— 因果森林 / 广义随机森林（GRF）{right:版本 0.3.0}
{hline}

{p 4 4 2}{it:英文帮助：} {help cforest}、{help cforest_predict}、{help cforest_blp}、{help cforest_plot}

{title:标题}

{p 4 4 2}
{cmd:cforest} —— 用{bf:因果森林}估计二值处理下的{bf:条件平均处理效应}（CATE）
τ(x) = E[Y(1) − Y(0) | X = x]，遵循 Wager & Athey (2018) 与 Athey、Tibshirani & Wager (2019)。
配套命令：{cmd:cforest_predict}（样本外预测）、{cmd:cforest_blp}（最优线性投影）、
{cmd:cforest_plot}（分箱 CATE 曲线）。

{pstd}
版本 0.3.0 为{bf:Stage A}：经 Stata 内置 Python 集成调用 {cmd:econml.grf.CausalForest}。

{title:cforest 语法}

{p 8 12 2}
{cmd:cforest} {it:depvar indepvars} {ifin}, {cmdab:treat:(}{it:varname}{cmd:)}
{cmd:[}{cmd:numtrees:(}{it:#}{cmd:)} {cmd:minnodesize:(}{it:#}{cmd:)}
{cmd:seed:(}{it:#}{cmd:)} {cmd:level:(}{it:#}{cmd:)}
{cmd:saving:(}{it:filename}{cmd:)} {cmd:graph}{cmd:]}

{title:cforest 描述}

{pstd}
{cmd:cforest} 估计 CATE，并生成变量 {cmd:cforest_tau}（CATE）、{cmd:cforest_tau_lb} 与
{cmd:cforest_tau_ub}（逐点界）、{cmd:cforest_tau_oob}（袋外 CATE）；返回 {cmd:r(ate)}、
{cmd:r(catt)}、{cmd:r(ate_oob)}、{cmd:r(importance)}（变量重要性矩阵）、
{cmd:r(covariates)}、{cmd:r(numtrees)}。

{title:cforest 选项}

{p 4 8 2}{cmd:treat(}{it:varname}{cmd:)} 二值处理变量；必填。
{p 4 8 2}{cmd:numtrees(#)} 树数量；默认 2000。
{p 4 8 2}{cmd:minnodesize(#)} 叶最小样本数；默认 5。
{p 4 8 2}{cmd:seed(#)} 随机种子；默认 12345。
{p 4 8 2}{cmd:level(#)} 逐点区间的置信水平；默认 95。
{p 4 8 2}{cmd:saving(}{it:filename}{cmd:)} 保存拟合模型，供 {cmd:cforest_predict} 使用。
{p 4 8 2}{cmd:graph} 绘制变量重要性条形图。

{title:cforest_predict 语法}

{p 8 12 2}
{cmd:cforest_predict} {it:newvar} {ifin}, {cmd:[}{cmd:model:(}{it:filename}{cmd:)}
{cmd:level:(}{it:#}{cmd:)} {cmd:lower:(}{it:newvar}{cmd:)} {cmd:upper:(}{it:newvar}{cmd:)}{cmd:]}

{title:cforest_predict 描述}

{pstd}
用因果森林估计的模型，对当前内存中的数据写出预测 CATE {it:newvar}。默认复用本会话最近一次
{cmd:cforest} 的模型；也可用 {cmd:model(}{it:filename}{cmd:)} 载入经 {cmd:cforest, saving()}
保存的模型。当前数据须含与拟合时同名的协变量；{cmd:lower()}/{cmd:upper()} 写出置信界。

{title:cforest_blp 语法}

{p 8 12 2}
{cmd:cforest_blp} {it:[indepvars]} {cmd:[,} {cmd:level:(}{it:#}{cmd:)}{cmd:]}

{title:cforest_blp 描述}

{pstd}
对 {cmd:cforest} 估计的 CATE（{cmd:cforest_tau}）关于协变量做 OLS（稳健 SE），即 GRF 的
最优线性投影，用于刻画效应如何随协变量变化。若省略 {it:indepvars}，则使用最近一次
{cmd:cforest} 的协变量，因此需紧接其后运行。返回 {cmd:r(blp)}（系数向量）。

{title:cforest_plot 语法}

{p 8 12 2}
{cmd:cforest_plot,} {cmd:over(}{it:varname}{cmd:)}
{cmd:[}{cmd:bins:(}{it:#}{cmd:)} {cmd:level:(}{it:#}{cmd:)}
{cmd:title:(}{it:string}{cmd:)} {cmd:saving:(}{it:filename}{cmd:)}{cmd:]}

{title:cforest_plot 描述}

{pstd}
把协变量 {it:varname} 分成等频分箱，绘制各箱平均 CATE（{cmd:cforest_tau}）的连线与逐点
置信带。{cmd:saving()} 可将图导出为文件。

{title:示例}

{p 8 8 2}{cmd:. cforest y x1 x2 x3, treat(w) numtrees(2000) seed(12345) saving(mymodel.joblib)}
{p 8 8 2}{cmd:. cforest_blp}
{p 8 8 2}{cmd:. cforest_plot, over(x1) saving(cate.png)}
{p 8 8 2}{cmd:. cforest_predict tauhat, model(mymodel.joblib) lower(tau_lo) upper(tau_hi)}

{title:参考文献}

{pstd}
Wager, S., and S. Athey. 2018. Estimation and inference of heterogeneous treatment
effects using random forests. {it:JASA} 113(523): 1228-1242.

{pstd}
Athey, S., J. Tibshirani, and S. Wager. 2019. Generalized random forests.
{it:Annals of Statistics} 47(2): 1148-1178.

{title:另见}

{p 4 4 2}
英文帮助：{help cforest}、{help cforest_predict}、{help cforest_blp}、{help cforest_plot}
