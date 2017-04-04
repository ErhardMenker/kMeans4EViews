'*************************************************************************************************************************************************
' MOTIVATION: execute k-means clustering on a cross section or time series collection of series

' ARGUMENTS:

' 1) Mandatory
'	a. k = the # of clusters to be generated

' 2) Optional
'	a. quiet = shut off log messages (log messages left on if not specified)
'	b. iters = the number of full solution iterations to run (defaults to 1)
'	c. series = a space delimited string of series included in analysis (defaults to all series)
'	d. smpl = the sample to execute the procedure over (defaults to the current sample)
'		NOTE: can pass in standalone "all" or "@all" to change sample to all
'	e. impute | interpolate = whether to linearly interpolate missing values (defaults to not linearly interpolating)
'		NOTE: will error if asked to impute on a cross section workfile
'*************************************************************************************************************************************************

' *****************************************************************************
' *** EXTRACT PASSED IN ARGUMENTS & KEY PARAMETERS ***
' *****************************************************************************

' 1) silence log messages if running in quiet mode
if @hasoption("quiet") then
	logmode -logmsg
endif
logmsg ------ Executing k-means clustering!
logmsg

' 2) page frequency of page add-in is called on
if @ispanel then 
	seterr "ERROR: cannot call k means add-in on a panel work structure"
endif
%FREQ = @pagefreq

' 3) name of the current page when add-in is called
%PAGE_CALLED = @pagename

' 4) determine the sample
%SMPL = @equaloption("smpl")
if @hasoption("all") or @hasoption("@all") or @lower(%SMPL) = "all" or @lower(%SMPL) = "@all" then
	%SMPL = "@all"
endif
if %SMPL = NA then
	%SMPL = @pagesmpl
endif

' 5) find out how many clusters are being generated
!K = @val(@equaloption("k"))
if !K = NA then
	seterr "ERROR: User has not inputted a numeric argument for k in call to k-means clustering utility"
endif

' 6) find out how many iterations of k-means are to be done
!ITERS = @val(@equaloption("iters"))
if !ITERS = NA then
	!ITERS = 1 	

	logmsg ----- Setting # of k-means full iteration solutions to default of 1
	logmsg
endif

' 7) find out the series that are to be included in the analysis
%SERIES = @equaloption("SERIES")
' if series argument was not passed in, set arg equal to all series (excluding residuals)
if %SERIES = "" then
	%SERIES = @wlookup("*", "series")
	
	logmsg ----- No series argument passed in, defaulting to include all series
	logmsg
endif

'8) find out whether interpolation/imputation will occur (only valid for time series)
!IMPUTE = 0
if @hasoption("impute") or @hasoption("interpolate") then
	!IMPUTE = 1
endif
if !IMPUTE and %FREQ = "u" then
	seterr "ERROR: cannot impute on an unstructured workfile for k-means clustering add-in"
endif

'***************************************
' *** SETUP WORKFILE PAGE ***
'***************************************

' create a new workfile page to execute work on
%page_work = @getnextname("scratch")
while 1 
	
	' if the name generated is not a workfile page, create the working page with this name
	if @pageexist(%page_work) = 0 then
		pagecreate(page={%page_work}) {%FREQ} {%SMPL}
		exitloop
	' if the name generated is a workfile page, append a 0 to the end of the name and reiterate to see if it exists
	else
		%page_work = %page_work + "0"
	endif
wend

for %srs {%SERIES}
	' 1) move the series to the  working page
	copy {%PAGE_CALLED}\{%srs} {%page_work}\{%srs}

	' 2) impute series (if requested)
	if !IMPUTE then
		{%srs}.ipolate(type=lin) {%srs}_dlt
		delete {%srs}
		rename {%srs}_dlt {%srs}
	endif

	' 3) normalize the series (to prevent differently scaled series from having disproportionate impacts on cluster centroids)
	{%srs} = ({%srs} - @mean({%srs})) / @stdev({%srs})	
next
pageselect {%page_work}

' create a matrix housing the series (dropping any obs with NAs)
%g_srs = @getnextname("g_srs")
	group {%g_srs} {%SERIES}
%m_srs = @getnextname("m_srs")
	stom({%g_srs}, {%m_srs})

{%m_srs}.setcollabels {%SERIES}
' figure out which rows correspond to which observations in the group of series & reset matrix labels accordingly
%complete_idxs = ""
for !row = 1 to @rows({%g_srs})
	!complete_idx = 1 
	for %srs {%SERIES}
		if {%srs}(!row) = NA then
			!complete_idx = 0
			exitloop
		endif
	next
	
	if !complete_idx then
		%complete_idxs = %complete_idxs + " " + @str(!row)
	endif
next
{%m_srs}.setrowlabels {%complete_idxs}

' throw an error if the # of clusters is greater than or equal to the # of observations
!obs = @rows({%m_srs})
if !K >= !obs then
	seterr "ERROR: there are at least as many clusters as there are complete observations"
endif

' figure out which observations will be randomly initialized as centroids for each iteration of k-means to be done
%m_init = @getnextname("m_init")
matrix(!K, !ITERS) {%m_init}
%vec_prev = "" ' tests equality when iterated onto the next vector
for !iter = 1 to !ITERS
	%vec = @getnextname("v_idxs")
	vector(!obs) {%vec} = NA
	' fill in the k-means iteration's vector where each element is the vector's index
	for !obs_iter = 1 to !obs
		{%vec}(!obs_iter) = !obs_iter
	next
	' scatter the vector's entries (set a seed to ensure reproducibility)
	rndseed !iter
	{%vec} = @permute({%vec})
	' drop the rows not in the top !K (not sure how to do this quicker)
	for !row_drop = !K to !obs
		!row_drop0 = !obs - !row_drop ' drop ending elements first to not disrupt indexing
		{%vec} = {%vec}.@droprow(!row_drop0)
	next
	' sort to judge cross vector equality
	{%vec} = @sort({%vec})
	' place the iteration's initialized centroid observations into the appropriate initialization matrix column
	colplace({%m_init}, {%vec}, !iter)
	delete {%vec}
next

'**************************************************
' *** EXECUTE K-MEANS CLUSTERING ***
'**************************************************
logmsg
logmsg ----- Executing k-means clustering with !K clusters over !ITERS iterations
logmsg

' execute k-means clustering across each iteration
for !iter = 1 to !ITERS

next





