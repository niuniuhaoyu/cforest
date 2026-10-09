*! cforest: Causal Forests for Heterogeneous Treatment Effects
*! version 0.3.0  2026-10-08  Haoyu Niu
*! Stage A: drives econml.grf.CausalForest through Stata's Python integration.
*! Reference: Wager & Athey (2018); Athey, Tibshirani & Wager (2019).

program define cforest, rclass
    version 16

    syntax varlist(min=2 numeric) [if] [in], ///
        treat(varname numeric) ///           binary treatment
        [numtrees(integer 2000) ///          number of trees
         minnodesize(integer 5) ///          minimum leaf size
         seed(integer 12345) ///             RNG seed
         level(real 95) ///                  confidence level
         saving(string) ///                  save fitted model to file
         graph]                              // variable-importance graph

    local dep : word 1 of `varlist'
    local indep ""
    forvalues i = 2/`: word count `varlist'' {
        local indep "`indep' `: word `i' of `varlist''"
    }

    marksample touse
    foreach v in cforest_tau cforest_tau_lb cforest_tau_ub cforest_tau_oob {
        capture drop `v'
    }

    * ---------- pass to Python ----------
    local _xvars "`indep'"
    local _wvar  "`treat'"
    local _yvar  "`dep'"
    local _touse "`touse'"
    local _ntrees "`numtrees'"
    local _minsize "`minnodesize'"
    local _seed "`seed'"
    local _level "`level'"
    local _saving "`saving'"
    local _session "`c(tmpdir)'cforest_session.joblib"

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
    di as text "  CATE `cforest_tau' (+ lb/ub, + oob) added"

    * ---------- variable-importance graph ----------
    if "`graph'" != "" {
        preserve
        quietly {
            svmat double _cforest_imp, names(imp)
            keep imp1
            gen str32 covariate = ""
            local i = 0
            foreach v of local indep {
                local ++i
                replace covariate = "`v'" in `i'
            }
            keep in 1/`: word count `indep''
        }
        graph hbar imp1, over(covariate, label(angle(0))) ///
            ytitle("Variable importance") ///
            title("cforest: variable importance") ///
            scheme(s2color) name(cforest_imp, replace)
        restore
    }

    return scalar ate = scalar(cf_ate)
    return scalar catt = scalar(cf_catt)
    return scalar ate_oob = scalar(cf_ate_oob)
    return scalar numtrees = `numtrees'
    return matrix importance = _cforest_imp
    return local tauvar "cforest_tau"
    return local oobvar "cforest_tau_oob"
    return local covariates "`indep'"
    return local depvar "`dep'"
end
