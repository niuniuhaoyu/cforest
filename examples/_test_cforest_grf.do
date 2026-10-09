*! _test_cforest_grf.do - export cforest tau for the R grf cross-check (Task 4)
*! Run this, then: Rscript examples/reference/run_grf_check.R
version 16
clear all
set more off
adopath + "D:\OpenCode\cforest"
use "data/cforest_sim.dta", clear

cforest y x1 x2 x3, treat(w) numtrees(500) seed(12345)

keep y x1 x2 x3 w cforest_tau
export delimited using "examples/reference/cforest_out.csv", replace
di as result "EXPORT DONE: examples/reference/cforest_out.csv"
di as result "now run: Rscript examples/reference/run_grf_check.R"
