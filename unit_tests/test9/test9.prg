' will unstructured interpolation be done?

' kmeans was halted after imputation to verify

wf u 1 6

series sp_gold = NA
sp_gold(1) = 250
sp_gold(2) = NA ' should be 250 after interpolation 
sp_gold(3) = 200 
sp_gold(4) = 180
sp_gold(5) = 320
sp_gold(6) = 340

series sp_oil = NA
sp_oil(1) = 50
sp_oil(2) = 55
sp_oil(3) = 35
sp_oil(4) = 30
sp_oil(5) = 70
sp_oil(6) = 75

series ur = NA
ur(1) = 10
ur(2) = 9
ur(3) = 14
ur(4) = 15
ur(5) = 7
ur(6) = 6

exec .\..\..\kmeans.prg(k = 3, impute)
