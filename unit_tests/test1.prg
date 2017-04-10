'*********************************************************************************************
' verify accuracy with 3 randomly generated time series
'*********************************************************************************************

logmode logmsg
logmsg

' initialize a workfile
wfcreate(wf=TEST1, page=DATA_A) m 1960 2000 

rndseed 69

' initialize some series
series x = @nrnd
series y = 100 * @nrnd
series z = 0.2 * @nrnd

z(10) = NA

' call the k-means utility
exec ./../kMeans(k=4, iters=3)


