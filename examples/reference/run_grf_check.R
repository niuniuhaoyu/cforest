# run_grf_check.R - cross-check cforest (Stage A, econml.grf) against R grf
# The two are DIFFERENT implementations (grf = C++ kernel; econml.grf = pure
# Python/numba), so agreement is qualitative, not bit-exact. We check that both
# recover the known CATE tau(x) = x1 on the same simulated data.
suppressMessages({
  library(grf)
  library(haven)
})

df <- as.data.frame(haven::read_dta("data/cforest_sim.dta"))
X <- as.matrix(df[, c("x1", "x2", "x3")])
Y <- as.numeric(df$y)
W <- as.numeric(df$w)

# match cforest: numtrees 500, minnodesize 5, seed 12345;
# grf defaults: honesty = TRUE, sample.fraction = 0.5
cf <- causal_forest(
  X, Y, W,
  num.trees = 500, min.node.size = 5, sample.fraction = 0.5,
  honesty = TRUE, mtry = 3, seed = 12345
)
tau_grf <- predict(cf)$predictions
ate <- average_treatment_effect(cf, target.sample = "all")
catt <- average_treatment_effect(cf, target.sample = "treated")

out <- read.csv("examples/reference/cforest_out.csv")
tau_cf <- out$cforest_tau
truth <- as.numeric(df$x1)

r_grf_true <- cor(tau_grf, truth)
r_cf_true <- cor(tau_cf, truth)
r_between <- cor(tau_grf, tau_cf)

cat("=== cforest (Stage A, econml) vs R grf ===\n")
cat(sprintf("n                        = %d\n", nrow(out)))
cat(sprintf("true ATE (tau = x1)      = 0\n"))
cat(sprintf("grf    ATE               = %+.4f (se %.4f)\n", ate[1], ate[2]))
cat(sprintf("grf    CATT              = %+.4f\n", catt[1]))
cat(sprintf("cforest mean tau         = %+.4f\n", mean(tau_cf)))
cat(sprintf("corr(tau_grf , truth)    = %.4f\n", r_grf_true))
cat(sprintf("corr(tau_cf  , truth)    = %.4f\n", r_cf_true))
cat(sprintf("corr(tau_grf , tau_cf)   = %.4f\n", r_between))
cat(sprintf("mean |tau_grf - tau_cf|  = %.4f\n", mean(abs(tau_grf - tau_cf))))

ok <- (r_grf_true > 0.5) && (r_cf_true > 0.5) &&
      (abs(ate[1]) < 0.15) && (r_between > 0.5)
cat(sprintf("GRF CROSS-CHECK %s\n", ifelse(ok, "PASS", "FAIL")))
