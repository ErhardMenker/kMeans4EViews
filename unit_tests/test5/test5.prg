' MOTIVATION: can k-means handle a time series with NAs?
' will produce same answer as test1 for the all non-NA obs

wf a 2005 2011

series sp_gold = NA
sp_gold(1) = 250
sp_gold(2) = 270
sp_gold(3) = 200
sp_gold(4) = 190
sp_gold(5) = 180
sp_gold(6) = 320
sp_gold(7) = 340

series sp_oil = NA
sp_oil(1) = 50
sp_oil(2) = 55
sp_oil(3) = 35
sp_oil(4) = NA
sp_oil(5) = 30
sp_oil(6) = 70
sp_oil(7) = 75

series ur = NA
ur(1) = 10
ur(2) = 9
ur(3) = 14
ur(4) = NA
ur(5) = 15
ur(6) = 7
ur(7) = 6

exec .\..\..\kmeans.prg(k = 3, iters = 5)


