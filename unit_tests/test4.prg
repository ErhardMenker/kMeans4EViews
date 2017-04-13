'****************************************************************************
' generate a few small cross sections to verify accuracy
'****************************************************************************

logmode logmsg
logmsg

' initialize a workfile
wfcreate(wf=TEST4, page=DATA_U) u 9

' make 4 series
series exports = NA
exports(1) = 200
exports(2) = 210
exports(3) = NA
exports(4) = 160
exports(5) = 150
exports(6) = 140
exports(7) = 250
exports(8) = 260
exports(9) = 270

' make 4 series
series imports = NA
imports(1) = 20 
imports(2) = 30
imports(3) = 40
imports(4) = NA
imports(5) = 100
imports(6) = 110
imports(7) = 160
imports(8) = 170
imports(9) = NA

' PICK UP DEBUGGING HERE! (not all NA series that drop too many obs)
series nurn = NA
nurn(3) = 5

' call the k-means utility
exec ./../kMeans(k=3, iters=10)
