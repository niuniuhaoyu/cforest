version 16
clear all
set more off
adopath + "D:\OpenCode\cforest"
use "data/cforest_sim.dta", clear

cforest y x1 x2 x3, treat(w) numtrees(500) seed(12345) level(95)
local ate  = r(ate)
local catt = r(catt)

qui correlate cforest_tau x1
local rho = r(rho)

* CI must bracket the point estimate
qui count if cforest_tau_lb > cforest_tau - 1e-9 | cforest_tau_ub < cforest_tau + 1e-9
assert r(N) == 0
qui count if cforest_tau_ub <= cforest_tau_lb
assert r(N) == 0

di as result "corr(tau_hat, x1) = " %6.4f `rho'
di as result "ATE  = " %7.4f `ate' " (true 0)"
assert `rho' > 0.5
assert abs(`ate') < 0.3
di as result "CFOREST STAGE-A (with CI) TEST PASS"
