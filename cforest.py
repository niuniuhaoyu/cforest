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
tau = np.asarray(cf.predict(Xs)).ravel()

Data.addVarDouble("cforest_tau")
full = np.full(X.shape[0], np.nan)
full[keep] = tau
Data.store("cforest_tau", None, full.tolist())
Scalar.setValue("cf_ate", float(tau.mean()))
Scalar.setValue("cf_catt", float(tau[Ws == 1].mean()))
Scalar.setValue("cf_n", float(Xs.shape[0]))
