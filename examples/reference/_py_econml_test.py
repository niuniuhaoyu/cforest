import numpy as np
from econml.grf import CausalForest

rng = np.random.default_rng(0)
n, p = 2000, 5
X = rng.normal(size=(n, p))
W = rng.binomial(1, 0.5, n)
tau = X[:, 0]                      # true CATE = x1
Y = tau * W + X[:, 1] + rng.normal(size=n)

cf = CausalForest(n_estimators=500, random_state=0)
cf.fit(X, W, Y)
tau_hat = cf.predict(X)
print("type:", type(cf).__name__)
print("tau_hat mean:", round(float(tau_hat.mean()), 4))
print("corr(tau_hat, x1):", round(float(np.corrcoef(tau_hat, X[:, 0])[0, 1]), 4))
print("OK")
