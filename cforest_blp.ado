*! cforest_blp: best linear projection of the CATE on covariates after cforest
*! version 0.3.0  2026-10-08  Haoyu Niu
*! OLS of the estimated CATE (cforest_tau) on the covariates, with robust SE.
*! This is the standard GRF heterogeneity summary
*! (cf. R grf::best_linear_projection).

program define cforest_blp, rclass
    version 16

    syntax [varlist(numeric)] [, level(real 95)]

    if "`varlist'" == "" {
        if "`r(covariates)'" != "" {
            local varlist "`r(covariates)'"
        }
        else {
            di as error "cforest_blp: specify covariates (cforest_blp x1 x2 ...) or run it right after cforest"
            exit 198
        }
    }
    confirm variable cforest_tau

    di as text _n "Best linear projection of the conditional average treatment effect"
    di as text "  regress cforest_tau on `varlist' (robust SE)"
    regress cforest_tau `varlist', level(`level') vce(robust)

    tempname B
    matrix `B' = e(b)
    return matrix blp = `B'
    return scalar N = e(N)
end
