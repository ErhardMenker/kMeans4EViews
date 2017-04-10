'****************************************************************************
' generate a few small time series to verify accuracy
'****************************************************************************

logmode logmsg
logmsg

' initialize a workfile
wfcreate(wf=TEST2, page=DATA_A) a 2010 2016

' make 3 series
series p_oil$ = NA
p_oil$(1) = 50 
p_oil$(2) = 45
p_oil$(3) = 55
p_oil$(4) = 60
p_oil$(5) = 60
p_oil$(6) = 70
p_oil$(7) = 70

series p_gold$ = NA
p_gold$(1) = 510
p_gold$(2) = 550
p_gold$(3) = 470
p_gold$(4) = 433
p_gold$(5) = 428
p_gold$(6) = 393
p_gold$(7) = 338

series ur = NA
ur(1) = 5
ur(2) = 4.5
ur(3) = 5.5
ur(4) = NA
ur(5) = 6
ur(6) = 6.5
ur(7) = 6.5

' call the k-means utility
exec ./../kMeans(k=3, iters=3)


