# cforest.py - Stage A Python driver for cforest.ado
# Reads Stata locals via sfi, fits a causal forest, writes results back.
# Reference: Wager & Athey (2018); Athey, Tibshirani & Wager (2019).
import numpy as np
import joblib
from sfi import Data, Macro, Scalar, Matrix
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

# out-of-bag CATE (leave-one-out style, from the honest splitting)
try:
    tau_oob = np.asarray(cf.oob_predict(Xs)).ravel()
except Exception:
    tau_oob = np.full(Xs.shape[0], np.nan)

# variable importance
try:
    imp = np.asarray(cf.feature_importances_, dtype=float).ravel()
except Exception:
    imp = np.full(len(xv), np.nan)


def _add(name):
    try:
        Data.addVarDouble(name)
    except Exception:
        pass


def _store(name, vals):
    Data.store(name, None, vals.tolist())


n = X.shape[0]
for _v in ("cforest_tau", "cforest_tau_lb", "cforest_tau_ub", "cforest_tau_oob"):
    _add(_v)

full_t = np.full(n, np.nan); full_t[keep] = tau
full_l = np.full(n, np.nan); full_l[keep] = lb
full_u = np.full(n, np.nan); full_u[keep] = ub
full_o = np.full(n, np.nan); full_o[keep] = tau_oob
_store("cforest_tau", full_t)
_store("cforest_tau_lb", full_l)
_store("cforest_tau_ub", full_u)
_store("cforest_tau_oob", full_o)

Scalar.setValue("cf_ate", float(tau.mean()))
Scalar.setValue("cf_catt", float(tau[Ws == 1].mean()))
Scalar.setValue("cf_n", float(Xs.shape[0]))
Scalar.setValue("cf_ate_oob", float(np.nanmean(tau_oob)))

# variable importance -> global Stata matrix (the ado returns it as r(importance))
Matrix.store("_cforest_imp", [[float(v)] for v in imp])
Scalar.setValue("cf_nimp", float(len(imp)))

# ---- always persist the fitted model so cforest_predict can reuse it ----
_payload = {"model": cf, "xvars": xv, "yvar": yv, "wvar": wv, "level": level}
joblib.dump(_payload, Macro.getLocal("_session"))
_saving = Macro.getLocal("_saving")
if _saving not in ("", ".", None):
    joblib.dump(_payload, _saving)
