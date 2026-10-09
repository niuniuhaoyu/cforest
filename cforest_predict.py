# cforest_predict.py - out-of-sample CATE prediction for cforest (Stage A)
# Loads a fitted econml.grf.CausalForest saved by `cforest` and predicts
# tau(x) for the data currently in memory.
# Reference: Wager & Athey (2018); Athey, Tibshirani & Wager (2019).
import os
import numpy as np
import joblib
from sfi import Data, Macro, Scalar

_using = Macro.getLocal("_using")
if _using in ("", ".", None):
    raise RuntimeError(
        "cforest_predict: no model given; run cforest first or pass using(<file>)."
    )
if not os.path.exists(_using):
    raise RuntimeError(
        "cforest_predict: no fitted model found at '%s'; run cforest first, "
        "or pass using(<file>) for a model saved with cforest, saving()." % _using
    )

obj = joblib.load(_using)
model = obj["model"]
xv = [str(v) for v in obj["xvars"]]

try:
    X = np.column_stack([np.asarray(Data.get(v), dtype=float) for v in xv])
except Exception as exc:
    raise RuntimeError(
        "cforest_predict: cannot read the training covariates %s from the current "
        "data; load variables with these names before predicting (%s)." % (xv, exc)
    )

level = float(Macro.getLocal("_level"))
alpha = 1.0 - level / 100.0
tv = Macro.getLocal("_touse")

keep = np.asarray(Data.get(tv), dtype=float) > 0
Xs = X[keep]
tau, lb, ub = model.predict(Xs, interval=True, alpha=alpha)
tau = np.asarray(tau).ravel()
lb = np.asarray(lb).ravel()
ub = np.asarray(ub).ravel()

n = X.shape[0]


def _put(name, vals):
    if name in ("", ".", None):
        return
    Data.addVarDouble(name)
    full = np.full(n, np.nan)
    full[keep] = vals
    Data.store(name, None, full.tolist())


_put(Macro.getLocal("_newvar"), tau)
_put(Macro.getLocal("_lbvar"), lb)
_put(Macro.getLocal("_ubvar"), ub)

Scalar.setValue("cfp_n", float(Xs.shape[0]))
Scalar.setValue("cfp_mean", float(tau.mean()))
