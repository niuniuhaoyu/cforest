version 16
clear all
adopath + "D:\OpenCode\cforest"
capture which cforest
di "which cforest rc = " _rc
if _rc == 0 di as result "SMOKE PASS: cforest found"
sysuse auto, clear
di as result "SMOKE DONE"
