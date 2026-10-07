*! cforest: Causal Forests for Heterogeneous Treatment Effects
*! version 0.1.0  2026-10-07  Haoyu Niu
*! Stage A: drives econml.grf.CausalForest through Stata's Python integration.
*! Reference: Wager & Athey (2018); Athey, Tibshirani & Wager (2019).

program define cforest, rclass
    version 16

    syntax varlist(min=2 numeric) [if] [in], ///
        treat(varname numeric) ///           binary treatment
        [numtrees(integer 2000) ///          number of trees
         minnodesize(integer 5) ///          minimum leaf size
         seed(integer 12345) ///             RNG seed
         level(real 95)]                     // confidence level

    local dep : word 1 of `varlist'
    local indep ""
    forvalues i = 2/`: word count `varlist'' {
        local indep "`indep' `: word `i' of `varlist''"
    }

    marksample touse
    capture drop cforest_tau

    * ---------- pass to Python ----------
    local _xvars "`indep'"
    local _wvar  "`treat'"
    local _yvar  "`dep'"
    local _touse "`touse'"
    local _ntrees "`numtrees'"
    local _minsize "`minnodesize'"
    local _seed "`seed'"

    findfile "cforest.py"
    local _pyfile "`r(fn)'"
    python: import sfi
    python: exec(open(sfi.Macro.getLocal("_pyfile"), encoding="utf-8").read())

    * ---------- display ----------
    di as text _n "Causal forest: conditional average treatment effects"
    di as text "  observations   = " %9.0f scalar(cf_n)
    di as text "  trees          = " %9.0f `numtrees'
    di as text "  ATE            = " %9.4f scalar(cf_ate)
    di as text "  CATT           = " %9.4f scalar(cf_catt)
    di as text "  CATE `cforest_tau' (per-observation tau-hat) added"

    return scalar ate = scalar(cf_ate)
    return scalar catt = scalar(cf_catt)
    return scalar numtrees = `numtrees'
    return local tauvar "cforest_tau"
end
