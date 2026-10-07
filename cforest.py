# cforest.py - Stage A Python driver for cforest.ado
# Reads Stata locals via sfi, fits a causal forest, writes results back.
# Reference: Wager & Athey (2018); Athey, Tibshirani & Wager (2019).
import numpy as np
from sfi import Data, Macro, Scalar
from econml.grf import CausalForest

xv = Macro.getLocal("_xvars").split()
wv = Macro.getLocal("_wvar")
yv = Macro.getLocal("_yvar")
tv = Macro.getLocal("_touse")
level = float(Macro.getLocal("_level"))
alpha = 1.0 - level / 100.0

X = np.column_stack([np.asarray(Data.get(v), dtype=float) for v in xv])
W = np.asarray(Data.get(wv), dtype=float)
Y = np.asarray(Data.get(yv), dtype=float)
keep = np.asarray(Data.get(tv), dtype=float) > 0
Xs, Ws, Ys = X[keep], W[keep], Y[keep]

cf = CausalForest(
    n_estimators=int(Macro.getLocal("_ntrees")),
    min_samples_leaf=int(Macro.getLocal("_minsize")),
    random_state=int(Macro.getLocal("_seed")),
)
cf.fit(Xs, Ws, Ys)

tau, lb, ub = cf.predict(Xs, interval=True, alpha=alpha)
tau = np.asarray(tau).ravel()
lb = np.asarray(lb).ravel()
ub = np.asarray(ub).ravel()

n = X.shape[0]
Data.addVarDouble("cforest_tau")
Data.addVarDouble("cforest_tau_lb")
Data.addVarDouble("cforest_tau_ub")
full_t = np.full(n, np.nan); full_t[keep] = tau
full_l = np.full(n, np.nan); full_l[keep] = lb
full_u = np.full(n, np.nan); full_u[keep] = ub
Data.store("cforest_tau", None, full_t.tolist())
Data.store("cforest_tau_lb", None, full_l.tolist())
Data.store("cforest_tau_ub", None, full_u.tolist())

Scalar.setValue("cf_ate", float(tau.mean()))
Scalar.setValue("cf_catt", float(tau[Ws == 1].mean()))
Scalar.setValue("cf_n", float(Xs.shape[0]))
