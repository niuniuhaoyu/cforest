*! cforest_figures.do - produce the README figures (importance + CATE curve)
version 16
clear all
set more off
adopath + "D:\OpenCode\cforest"
use "data/cforest_sim.dta", clear

cforest y x1 x2 x3, treat(w) numtrees(1000) seed(12345) graph
graph export "examples/cforest_importance.png", replace width(1400)

cforest_plot, over(x1) bins(20) title("CATE by x1 (truth: tau = x1)") ///
    saving("examples/cforest_cate.png")

di as result "wrote examples/cforest_importance.png and examples/cforest_cate.png"
