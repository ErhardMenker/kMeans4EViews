'***********************************************************************************************************************
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
'***********************************************************************************************************************

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
if @hasoption("all") or @hasoption("@all") or @lower(%SMPL) = "all" then
	%SMPL = "@all"
endif
if %SMPL = NA then
	%SMPL = @pagesmpl
endif

' 5) find out how many clusters are being generated
!K = @val(@equaloption("k"))
if !K = NA then
	seterr "ERROR: User has not inputted a numeric argument for k in call to kMeans utility"
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

'**************************************************
' *** EXECUTE K-MEANS CLUSTERING ***
'**************************************************
logmsg ----- Executing k-means clustering with !K clusters over !ITERS iterations
logmsg

' create a new page & move needed series there to do work
%page_work = @getnextname("scratch")
if @pageexist(%page_work) = 0 then
	pagecreate(page={%page_work}) {%FREQ} {%SMPL}
endif
for %srs {%SERIES}
	copy {%PAGE_CALLED}\{%srs} {%page_work}\{%srs}
next
pageselect {%page_work}

' create a matrix housing the series (dropping any obs with NAs)
%g_srs = @getnextname("g_")
	group {%g_srs} {%SERIES}
%m_srs = @getnextname("m_")
	stomna({%g_srs}, {%m_srs})











