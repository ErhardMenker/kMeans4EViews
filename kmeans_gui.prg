'*********************************************************************************************************************************
' MOTIVATION: Present a GUI to extract arguments that are passed into programmatic k-means call
'*********************************************************************************************************************************

' extract necessary elements from the state of workfile at add-in's call
%pagesmpl = @pagesmpl
' set defaults
%max_iters = "10"
%inits = "3"
!impute = 0
	%impute = "" ' string representation of non-imputing default
!quiet = 0
	%quiet = "" ' string representation of non-quiet default

!result = @uidialog("Edit", %K, "Enter # of Clusters (Mandatory)", _
				"Edit", %series_list, "Enter Series to Cluster (Leave Blank to do All on WF)", 9999, _
				"Edit", %pagesmpl, "Sample (@all to equal range)", _
				"Edit", %inits, "# of Solves", _
				"Edit", %max_iters, "Max # of Cluster Moves (type 'None' to ignore)", _
				"check", !impute, "Impute NAs?", _
				"check", !quiet, "Hide Log Messages?")

' stop program if the user logs out
if !result = -1 then
	stop
endif

' extract arguments that must be interpreted from dialog 
!max_iters = @val(%max_iters)
!inits = @val(%inits)
!K = @val(%K)

' if log message display and/or imputation default are overwritten, communicate this to program call via string representation
if !impute then
	%impute = "impute"
endif
if !quiet then
	%quiet = "quiet"
endif

' call k-means (if %impute or %quiet default behavior not overwritten, just passes in a meaningless empty string)
exec ./kmeans.prg(k = !K, series = %series_list, smpl = %pagesmpl, inits = !inits, max_iters = %max_iters, {%impute}, {%quiet})


