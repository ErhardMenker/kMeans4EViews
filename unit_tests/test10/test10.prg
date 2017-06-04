' MOTIVATION: can k-means properly understand certain default overwrites:
'	a. setting sample to all when called over a sample less than range
'	b. overwrite max_iters (effectively remove so clusters continue to move until an analytic optimum is reached)
'	c. overwrite inits (just reduce it to 2 from default of 3)

wf m 1900 2000

series x = @nrnd
series y = @nrnd
series z = @nrnd

smpl 1902 1903
x = NA

smpl 1998 1999
y = NA

smpl 1950 1955

exec .\..\..\kmeans.prg(k = 7, max_iters = none, inits = 2, smpl = @all)
