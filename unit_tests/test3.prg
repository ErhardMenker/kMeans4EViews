'*********************************************************************************************
' verify accuracy with 3 randomly generated cross section seriers
'*********************************************************************************************

logmode logmsg
logmsg

' initialize a workfile
wfcreate(wf=TEST3, page=DATA_U) u 500 

rndseed 42

' initialize some series
series x3 = @nrnd
series y3 = 24 * @nrnd + 3
series z3 = 0.5 * @nrnd
series w4 = @nrnd ^ 2

z3(10) = NA

' call the k-means utility
exec ./../kMeans(k=2, iters=5)
