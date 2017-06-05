' create an annual workfile
wfcreate(wf=k_means_example, page=DATA_A) a 1975 2016

' fetch series (accessed via FRED API)
' a) unemployment rate
fetch fred::unrate
' b) gdp yoy
fetch fred::a191ro1q156nbea
	rename a191ro1q156nbea gdp_yoy
' c) cpi yoy
fetch fred::cpiaucns
	series cpi_yoy = @pcy(cpiaucns)
	delete cpiaucns

' calculate 2 cluster centroids between 1975 & 2016
exec .\..\kmeans.prg(k = 2)

' constrain the sample to the recession values
smpl @all if obs_cluster = 2
