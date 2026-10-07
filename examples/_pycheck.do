version 16
clear all
capture python query
di "=== python query rc = " _rc
capture python: import sys
di "=== python: import sys rc = " _rc
capture python: print("PYOK", sys.version)
di "=== python print rc = " _rc
