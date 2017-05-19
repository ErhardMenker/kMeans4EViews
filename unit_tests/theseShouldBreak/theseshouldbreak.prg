' MOTIVATION: quick issues to test to see if the program breaks immediately from structural call errors

'CALL TEST1 ' CAN'T INTERPOLATE ON AN UNSTRUCTURED FILE
'CALL TEST2 '  MUST HAVE MORE COMPLETE OBS THAN CLUSTERS

SUBROUTINE TEST1
	wf u 1 10
	series x = @nrnd
		x(5) = NA
	series y = @nrnd
	exec .\..\..\kmeans.prg(k = 3, iters = 5, interpolate)
ENDSUB

SUBROUTINE TEST2
	wf a 1900 2000
	series x = @nrnd
	series y = @nrnd
	exec .\..\..\kmeans.prg(k = 101, iters = 5, interpolate)
ENDSUB


