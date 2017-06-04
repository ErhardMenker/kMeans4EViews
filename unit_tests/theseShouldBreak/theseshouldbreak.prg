' MOTIVATION: quick issues to test to see if the program breaks immediately from structural call errors

'CALL TEST1 ' NO NON-NA SERIES - HAVE EITHER ALL NAs IN SAMPLE OR NO VARIABILITY
'CALL TEST2 ' MUST HAVE MORE COMPLETE OBS THAN CLUSTERS
'CALL TEST3 ' MUST HAVE MORE COMPLETE OBS THAN CLUSTERS (lose too many obs 1+ NA)

SUBROUTINE TEST1
	wf u 1 10
	series x = @nrnd
	series y = @nrnd
	smpl 2 7
		x = 5 ' no variability
		y = NA ' no values
	smpl @all
	exec .\..\..\kmeans.prg(k = 3, inits = 7, max_iters = NONE, smpl = 3 6) 
ENDSUB

SUBROUTINE TEST2
	wf a 1900 2000
	series x = @nrnd
	series y = @nrnd
	exec .\..\..\kmeans.prg(k = 101, inits = 5, interpolate)
ENDSUB

SUBROUTINE TEST3 
	wf a 2000 2010
	series x = @nrnd
		x(3) = NA
	series y = @nrnd
		y(5) = NA
	exec .\..\..\kmeans.prg(k = 9)
ENDSUB


