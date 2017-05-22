' MOTIVATION: can k-means handle a base time series structure?

wf a 2005 2010

series sp_gold = NA
sp_gold(1) = 250
sp_gold(2) = 270
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

series dropMeAllNA = NA ' this series should get dropped because it's all NA
series excludeMe = NA ' exclude this series in the add-in spec 
excludeMe(2) = 2

series dropMeNoVar = 3

exec .\..\..\kmeans.prg(k = 3, inits = 5, series = sp_gold sp_oil ur dropMeAllNA dropMeNoVar, max_iters = 1)


