' MOTIVATION: can k-means handle time series interpolation?

wf a 2005 2011

series sp_gold = NA
sp_gold(1) = 250
sp_gold(2) = NA
sp_gold(3) = 270
sp_gold(4) = 200
sp_gold(5) = 180
sp_gold(6) = 320
sp_gold(7) = 340

series sp_oil = NA
sp_oil(1) = 50
sp_oil(2) = 52.5
sp_oil(3) = 55
sp_oil(4) = 35
sp_oil(5) = 30
sp_oil(6) = 70
sp_oil(7) = 75

series ur = NA
ur(1) = 10
ur(2) = 9.5
ur(3) = 9
ur(4) = 14
ur(5) = 15
ur(6) = 7
ur(7) = 6

exec .\..\..\kmeans.prg(k = 3, interpolate)
