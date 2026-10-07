version 16
clear
python:
from sfi import Data, Matrix, Scalar
with open(r"D:/OpenCode/cforest/examples/_sfiapi.txt", "w") as f:
    f.write("DATA: " + ", ".join(m for m in dir(Data) if not m.startswith("_")) + "\n")
    f.write("MATRIX: " + ", ".join(m for m in dir(Matrix) if not m.startswith("_")) + "\n")
    f.write("SCALAR: " + ", ".join(m for m in dir(Scalar) if not m.startswith("_")) + "\n")
end
di "done"
