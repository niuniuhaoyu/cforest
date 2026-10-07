version 16
clear
set obs 5
gen x = _n
python:
import numpy as np
from sfi import Data, Matrix, Scalar
Data.addVarDouble("tau")
Data.store("tau", None, [10.0, 20, 30, 40, 50])
Matrix.store("M", np.array([[1.0, 2.0], [3.0, 4.0]]))
Scalar.setValue("ate", 1.5)
end
list x tau
matrix list M
di "ate = " scalar(ate)
