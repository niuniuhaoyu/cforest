*! cforest: Causal Forests for Heterogeneous Treatment Effects
*! version 0.0.1  2026-10-07  Haoyu Niu
*! Skeleton (Task 1). See docs/specs/2026-10-07-cforest-design.md and
*! docs/plans/2026-10-07-cforest-plan.md.

program define cforest, rclass
    version 16

    syntax varlist(min=2 numeric) [if] [in], ///
        treat(varname numeric) ///           binary treatment
        [numtrees(integer 2000) ///          number of trees
         honesty ///                         honest splitting (default)
         nohonesty ///                       disable honest splitting
         mtry(integer 0) ///                 variables per split (0 = auto)
         minnodesize(integer 5) ///          minimum leaf size
         sampleratio(real 0.5) ///           split/estimation sample ratio
         seed(integer 12345) ///             RNG seed
         level(real 95)]                     // confidence level

    di as error "cforest: not yet implemented (skeleton). See docs/plans/2026-10-07-cforest-plan.md"
    exit 199
end
