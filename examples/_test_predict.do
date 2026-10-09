*! _test_predict.do - cforest_predict (out-of-sample CATE) test
version 16
clear all
set more off
adopath + "D:\OpenCode\cforest"
use "data/cforest_sim.dta", clear

gen byte train = (_n <= 1500)

* ---- (1) fit on training rows, save model to disk ----
preserve
keep if train
cforest y x1 x2 x3, treat(w) numtrees(500) seed(12345) ///
    saving("examples/reference/cforest_model.joblib")
restore

* ---- (2) predict from the live in-session model ----
cforest_predict tau_live, lower(live_lo) upper(live_hi)
qui correlate tau_live x1 if train
di as result "in-sample  corr(tau, x1) = " %6.4f r(rho)

* ---- (3) predict from the saved model on the full data ----
cforest_predict tau_hat, model("examples/reference/cforest_model.joblib") ///
    lower(tau_lo) upper(tau_hi)

qui correlate tau_hat x1 if !train
local rho_oos = r(rho)
di as result "out-of-sample corr(tau, x1) = " %6.4f `rho_oos'

* out-of-sample recovery must be strong
assert `rho_oos' > 0.5

* CI must bracket the point estimate
qui count if tau_lo > tau_hat + 1e-9 | tau_hi < tau_hat - 1e-9
assert r(N) == 0
qui count if tau_hi <= tau_lo
assert r(N) == 0

* saved-model predictions must equal the live-model predictions
qui count if !missing(tau_hat) & abs(tau_hat - tau_live) > 1e-6
di as result "mismatch rows (live vs saved model) = " r(N)
assert r(N) == 0

* simple if/in respect: restrict to test rows only
cforest_predict tau_test if !train
qui count if !missing(tau_test)
assert r(N) == 500
qui count if !missing(tau_test) & !train
assert r(N) == 500

di as result "CFOREST PREDICT TEST PASS"
