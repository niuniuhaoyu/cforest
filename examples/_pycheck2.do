version 16
clear all
python query
python:
import sys
with open(r"D:/OpenCode/cforest/examples/_pyout.txt", "w") as f:
    f.write("executable=" + sys.executable + "\n")
    f.write("version=" + sys.version.replace("\n", " ") + "\n")
try:
    import numpy; f.write("numpy=" + numpy.__version__ + "\n")
except Exception as e:
    f.write("numpy=NO (" + str(e) + ")\n")
end
di "done"
