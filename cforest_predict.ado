*! cforest_predict: out-of-sample CATE after cforest
*! version 0.2.0  2026-10-08  Haoyu Niu
*! Predicts tau(x) for the data currently in memory after `cforest`,
*! either from the model still live in this Python session or from a
*! model saved with `cforest, saving(...)`.

program define cforest_predict, rclass
    version 16

    syntax newvarname [if] [in], ///
        [model(string) ///                  saved model file
         level(real 95) ///                 confidence level
         lower(name) ///                    lower CI variable
         upper(name)]                      // upper CI variable

    local predvar "`varlist'"
    marksample touse, novarlist

    if "`lower'" != "" confirm new variable `lower'
    if "`upper'" != "" confirm new variable `upper'

    local _newvar "`predvar'"
    local _lbvar  "`lower'"
    local _ubvar  "`upper'"
    if "`model'" != "" {
        local _using "`model'"
    }
    else {
        local _using "`c(tmpdir)'cforest_session.joblib"
    }
    local _level  "`level'"
    local _touse  "`touse'"

    findfile "cforest_predict.py"
    local _pyfile "`r(fn)'"
    python: import sfi
    python: exec(open(sfi.Macro.getLocal("_pyfile"), encoding="utf-8").read())

    di as text _n "cforest_predict: CATE predicted for " %9.0f scalar(cfp_n) " observations"
    di as text "  mean CATE = " %9.4f scalar(cfp_mean)
    if "`lower'" != "" {
        di as text "  `lower' / `upper' added (level `level')"
    }

    return scalar mean = scalar(cfp_mean)
    return scalar n = scalar(cfp_n)
    return local predvar "`predvar'"
end
