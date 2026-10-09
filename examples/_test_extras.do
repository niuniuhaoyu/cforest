*! _test_extras.do - cforest variable importance / OOB / best linear projection
version 16
clear all
set more off
adopath + "D:\OpenCode\cforest"
use "data/cforest_sim.dta", clear

cforest y x1 x2 x3, treat(w) numtrees(500) seed(12345)

* capture r() results immediately (later commands overwrite r())
local xv "`r(covariates)'"
matrix imp = r(importance)
local rowofb = rowsof(imp)
assert `rowofb' == 3

* x1 drives the heterogeneity tau(x)=x1, so it should dominate importance
assert imp[1,1] > imp[2,1]
assert imp[1,1] > imp[3,1]
di as result "importance (x1,x2,x3) = " %6.3f imp[1,1] "  " %6.3f imp[2,1] "  " %6.3f imp[3,1]

* out-of-bag CATE recovers the truth
qui correlate cforest_tau_oob x1
local roob = r(rho)
di as result "OOB corr(tau_oob, x1) = " %6.4f `roob'
assert `roob' > 0.4

* best linear projection: slope on x1 ~ 1, slopes on x2/x3 ~ 0
cforest_blp `xv'
local b1 = _b[x1]
local b2 = _b[x2]
local b3 = _b[x3]
di as result "BLP slopes (x1,x2,x3) = " %6.3f `b1' "  " %6.3f `b2' "  " %6.3f `b3'
* x1 carries the effect (positive, near one up to regression dilution); x2/x3 ~ 0
assert abs(`b1' - 1) < 0.4
assert abs(`b2') < 0.2
assert abs(`b3') < 0.2
assert `b1' > `b2' + `b3'

di as result "CFOREST EXTRAS TEST PASS"
