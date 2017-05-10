' MOTIVATION: does it generate proper results if I cut off the last observation?

wf a 2002 2011

smpl 2005 2010

series sp_gold = NA
sp_gold(4) = 250
sp_gold(5) = 270
sp_gold(6) = 200
sp_gold(7) = 180
sp_gold(8) = 320
sp_gold(9) = 340

series sp_oil = NA
sp_oil(4) = 50
sp_oil(5) = 55
sp_oil(6) = 35
sp_oil(7) = 30
sp_oil(8) = 70
sp_oil(9) = 75

series ur = NA
ur(4) = 10
ur(5) = 9
ur(6) = 14
ur(7) = 15
ur(8) = 7
ur(9) = 6

exec .\..\..\kmeans.prg(k = 3, iters = 5, smpl = 2006 2010)


