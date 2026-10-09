*! _run_all_tests.do - run the full cforest Stage A test suite
*! Usage (from the package root): StataMP-64.exe /e do examples/_run_all_tests.do
version 16
do "examples/_test_cforest.do"
do "examples/_test_predict.do"
do "examples/_test_extras.do"
do "examples/_test_cforest_grf.do"
di as result _n "ALL STATA CFOREST TESTS PASS"
