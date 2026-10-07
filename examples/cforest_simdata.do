*! cforest_simdata.do - DGP with known CATE: tau(x) = x1
version 16
clear all
set seed 20261007
set obs 2000
gen double x1 = rnormal(0, 1)
gen double x2 = rnormal(0, 1)
gen double x3 = rnormal(0, 1)
gen byte w = runiform() < 0.5
gen double tau = x1
gen double y = tau*w + x2 + 0.5*x3 + rnormal(0, 1)
keep y x1 x2 x3 w
save "data/cforest_sim.dta", replace
display "wrote data/cforest_sim.dta"
