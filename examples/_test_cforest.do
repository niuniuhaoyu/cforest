version 16
clear all
set more off
adopath + "D:\OpenCode\cforest"
use "data/cforest_sim.dta", clear

cforest y x1 x2 x3, treat(w) numtrees(500) seed(12345)
local ate  = r(ate)
local catt = r(catt)

qui correlate cforest_tau x1
local rho = r(rho)
di as result "corr(tau_hat, x1) = " %6.4f `rho'
di as result "ATE  = " %7.4f `ate' " (true 0)"
di as result "CATT = " %7.4f `catt'
assert `rho' > 0.5
assert abs(`ate') < 0.3
di as result "CFOREST STAGE-A TEST PASS"
