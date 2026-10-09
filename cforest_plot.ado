*! cforest_plot: binned CATE curve after cforest
*! version 0.3.0  2026-10-08  Haoyu Niu

program define cforest_plot
    version 16

    syntax, over(varname numeric) ///
        [bins(integer 20) ///               number of equal-count bins
         level(real 95) ///                 confidence level
         title(string) ///                  graph title
         saving(string)]                    // export the graph to a file

    confirm variable cforest_tau
    if "`title'" == "" local title "cforest: CATE by `over'"

    tempvar grp
    preserve
    quietly {
        xtile `grp' = `over', nq(`bins')
        collapse (mean) cforest_tau `over' ///
                 (sd) _sd = cforest_tau (count) _nn = cforest_tau, by(`grp')
        gen double _se = _sd / sqrt(_nn)
        gen double _lb = cforest_tau - invttail(_nn - 1, (100 - `level')/200) * _se
        gen double _ub = cforest_tau + invttail(_nn - 1, (100 - `level')/200) * _se
    }
    twoway (rarea _lb _ub `over', color(gs13%50) lwidth(none)) ///
           (connected cforest_tau `over', sort lcolor(navy) mcolor(navy) msymbol(circle)), ///
        title("`title'") xtitle("`over'") ytitle("CATE") ///
        legend(order(1 "`level'% CI" 2 "binned CATE") rows(1) size(small)) ///
        scheme(s2color)
    if "`saving'" != "" {
        graph export "`saving'", replace width(1400)
        di as result "wrote `saving'"
    }
    restore
end
