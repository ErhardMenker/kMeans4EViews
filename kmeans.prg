'*********************************************************************************************************************************
' MOTIVATION: execute k-means clustering on a cross section or time series collection of series
' http://cs229.stanford.edu/notes/cs229-notes7a.pdf

' ARGUMENTS:

' 1) Mandatory -
'	a. k = the # of clusters to be generated

' 2) Optional -
'	a. quiet = shut off log messages (log messages left on if not specified)
'	b. inits = the number of full solution random centroid initializations to run (defaults to 3)
'	c. max_iters = the max allowed number of cluster moves for a given initialization (defaults to 10)
'		setting argument to NONE means that # of times clusters may move is not capped
'	d. series = a space delimited string of series included in analysis (defaults to all series)
'	e. smpl = the sample to execute the procedure over (defaults to the current sample)
'		NOTE: can pass in standalone "all" or "@all" to change sample to all
'	f. impute | interpolate = whether to interpolate missing values (defaults to not linearly interpolating)
'		For time series, execute linear interpolation
'		For cross section, fill in any NAs with the median of the series
'*********************************************************************************************************************************

' *****************************************************************************
' *** EXTRACT PASSED IN ARGUMENTS & KEY PARAMETERS ***
' *****************************************************************************

logmode logmsg

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
%ORIG_PAGE = @pagename

' 4) determine the sample
' a. extract the original sample
%ORIG_SMPL = @pagesmpl
' b. extract the passed in sample
%SMPL = @equaloption("smpl")
	' vet validity if user passed in own sample
	if %SMPL <> "" then
		' i) user must communicate sample with 2 periods indicating the start & end of sample
		if @wcount(%SMPL) <> 2 then
			seterr "ERROR: Inputted sample must have length 2 (start & end of sample bound, respectively)"
		endif
		!smpl_start_error = @dtoo(@word(%SMPL, 1)) < @dtoo(@word(@pagerange, 1))
		!smpl_end_error = @dtoo(@word(%SMPL, 2)) > @dtoo(@word(@pagerange, 2))
		' ii) passed-in sample starts both before range starts & after range ends
		if !smpl_start_error and !smpl_end_error then
			seterr "ERROR: User inputted sample start & end dates are outside bounds of range"
		else 
			' iii) passed-in sample starts before range begins
			if !smpl_start_error then
				seterr "ERROR: User inputted sample start is before start of range"
			else
			' iv) passed-in sample ends after range ends
				if !smpl_end_error then
					seterr "ERROR: User inputted sample end is after end of range"
				endif
			endif
		endif
	endif
' if user wants sample as all, set sample equivalent to page range at time of add-in call
if @hasoption("all") or @hasoption("@all") or @lower(%SMPL) = "all" or @lower(%SMPL) = "@all" then
	%SMPL = @pagerange
endif
' if no sample is passed in, set the sample to what the workfile's page is at time of k-means call
if %SMPL = NA then
	%SMPL = %ORIG_SMPL
endif

' 5) find out how many clusters are being generated
!K = @val(@equaloption("k"))
if !K = NA then
	seterr "ERROR: User has not inputted a numeric argument for k in call to k-means clustering utility"
endif
if !K <= 0 or @mod(!K, 1) <> 0 then
	seterr "ERROR: K must be a positive integer"
endif

' 6) find out how many random centroid initializations are to be solved
!INITS = @val(@equaloption("inits"))
if !INITS = NA then
	!INITS = 3

	logmsg ----- Setting # of k-means random init solves to default of 3
	logmsg
endif
if !INITS <= 0 or @mod(!INITS, 1) <> 0 then
	seterr "ERROR: # of initializations must be a positive integer"
endif

' 7) find the max # of iterations of cluster moves for a given random centroid initialization
%MAX_ITERS = @equaloption("max_iters")
' if max_iters is not specified, default it to 10
if %MAX_ITERS = "" then
	!MAX_ITERS = 10

	logmsg ----- Setting max # of iterations for given cluster init to default of 10
	logmsg
else
	' if max_iters is set to NONE, set !MAX_ITERS to NA	
	if @upper(%MAX_ITERS) = "NONE" then
		!MAX_ITERS = NA
	else
		' find out what positive integer max_iters was set equal to
		!MAX_ITERS = @val(%MAX_ITERS)
		if !MAX_ITERS <= 0 or @mod(!MAX_ITERS, 1) <> 0 then
			seterr "ERROR: # of maximum allowable iterations must be a positive integer"
		endif
	endif
endif

' 8) find out the series that are to be included in the analysis
%SERIES_LIST = @equaloption("series")
' if series argument was not passed in, set arg equal to all series (excluding residuals)
if %SERIES_LIST = "" then
	%SERIES_LIST = @wlookup("*", "series")
	
	logmsg ----- No series argument passed in, defaulting to include all series
	logmsg
endif
if @wcount(%SERIES_LIST) = 0 then
	seterr "ERROR: no usable series available for cluster analysis!"
endif

for %srs {%SERIES_LIST}
	' throw an error if user inputted a series into series argument that does not exist
	if @isobject(%srs) = 0 then
		%msg = "ERROR: " + %srs  + " does not exist! Check add-in call series argument"
		seterr %msg
	endif

	' drop series that were passed in that are all NAs
	if @obs({%srs}) = 0 then
		%msg = %srs + " is all NA; dropping " + %srs + " from the k-means clustering process"
		logmsg ----- %msg
		logmsg
		%SERIES_LIST = @replace(%SERIES_LIST, %srs, "")
	else
		' drop series that have no variability to them
		if @stdev({%srs}) = 0 then
			%msg = %srs + " has no variability; dropping " + %srs + " from the k-means clustering process"
			logmsg ----- %msg
			logmsg
			%SERIES_LIST = @replace(%SERIES_LIST, %srs, "")
		endif
	endif
next
if @wcount(%SERIES_LIST) = 0 then
	seterr "ERROR: no usable series available for cluster analysis!"
endif

' 9) find out whether interpolation/imputation of series will occur 
!IMPUTE = 0
if @hasoption("impute") or @hasoption("interpolate") then
	!IMPUTE = 1
endif

'***************************************
' *** SETUP WORKFILE PAGE ***
'***************************************

' create a new workfile page to execute work on
%work_page = @getnextname("scratch")
while @pageexist(%work_page)
	%work_page = %work_page + "0"
wend
pagecreate(page={%work_page}) {%FREQ} {%SMPL}

for %srs {%SERIES_LIST}
	' 1) move the series to the  working page
	copy {%ORIG_PAGE}\{%srs} {%work_page}\{%srs}

	' 2) impute time series (if requested)
	if !IMPUTE then
		' case 1: unstructured wf
		if %FREQ = "U" then
			{%srs} = @nan({%srs}, @median({%srs}))
		' case 2: time series wf
		else
			{%srs}.ipolate(type=lin) {%srs}_dlt
			delete {%srs}
			rename {%srs}_dlt {%srs} 
		endif
	endif

	' 3) normalize the series (to prevent differently scaled series from having disproportionate impacts on cluster centroids)
	{%srs} = ({%srs} - @mean({%srs})) / @stdev({%srs})	
next
pageselect {%work_page}

' tabulate an index of complete observations in the cluster sample
%g_norm_srs_list = @getnextname("g_series_list")
	group {%g_norm_srs_list} {%SERIES_LIST}
%is_row_na = @getnextname("is_row_na")
	series {%is_row_na} = @rnas({%g_norm_srs_list})
	delete {%g_norm_srs_list}
%complete_idxs = ""
for !obs = 1 to @rows({%is_row_na})
	' if no NAs in this row, append it to the complete observations
	if {%is_row_na}(!obs) = 0 then
		%complete_idxs = %complete_idxs + " " + @str(!obs)
	endif
next
delete {%is_row_na}
' throw an error if there are no all non-NA observations for series to be clustered
if @wcount(%complete_idxs) = 0 then
	seterr "ERROR: no period has no NAs for all the series to be clustered"
endif

' create a matrix housing the series (dropping any obs with NAs)
%g_norm_srs = @getnextname("g_srs")
	group {%g_norm_srs} {%SERIES_LIST}
%m_norm_srs = @getnextname("m_srs")
stom({%g_norm_srs}, {%m_norm_srs}) ' stom will drop any row with at least 1 NA
	delete {%g_norm_srs}
	{%m_norm_srs}.setcollabels {%SERIES_LIST}
	{%m_norm_srs}.setrowlabels {%complete_idxs}

' throw an error if the # of clusters is greater than or equal to the # of observations
!obs = @rows({%m_norm_srs})
if !K >= !obs then
	seterr "ERROR: the # of complete observations does NOT exceed the # of clusters" 
endif

' remove the observation's series values into their own vector
for !obs = 1 to @rows({%m_norm_srs})
	%obs = "v_obs" + @str(!obs)
	 ' extract the observation's values
	vector {%obs} = {%m_norm_srs}.@row(!obs)
next

' figure out which observations will be randomly initialized as centroids for each init of k-means to be done
%m_init = @getnextname("m_init")
	matrix(!K, !INITS) {%m_init}
%idxs_all = @getnextname("v_idxs")
	vector(@rows({%m_norm_srs})) {%idxs_all} = NA
' fill in the k-means initialization vector where each element is its index in the vector
for !obs_iter = 1 to @rows({%m_norm_srs})
	{%idxs_all}(!obs_iter) = !obs_iter
next
' continuously scatter the vector's elements and take the 1st K entries as that init's seed 
for !init = 1 to !INITS
	' scatter the vector's entries (set a seed to ensure reproducibility)
	rndseed !init
	{%idxs_all} = @permute({%idxs_all})
	%idxs_init = @getnextname("v_idxs_init")
	vector(!K) {%idxs_init}
	' fill in the seeded vector with the 1st K values of the scattered list of indices
	for !idx = 1 to !K
		{%idxs_init}(!idx) = {%idxs_all}(!idx)
	next
	' sort to more easily compare different initialization indices
	{%idxs_init} = @sort({%idxs_init})
	' place the solve's initialized centroid observations into the appropriate initialization matrix column
	colplace({%m_init}, {%idxs_init}, !init)
	delete {%idxs_init}
next

'**************************************************
' *** EXECUTE K-MEANS CLUSTERING ***
'**************************************************
logmsg ----- Executing k-means clustering with !K clusters over !INITS iterations
logmsg

' define the cost variable to be minimized 
!cost_min = NA 
' execute k-means clustering across each random centroid initialization
for !init = 1 to !INITS
	logmsg ----- solving k-means random initialization #!init
	tic

	' extract centroids from the respective randomly initialized matrix column	
	%centr_idxs = @getnextname("v_centr_idxs")
	vector {%centr_idxs} = {%m_init}.@col(!init)
	' create k vectors with the initialized indexed coordinates
	for !centr = 1 to !K
		!centr_idx = {%centr_idxs}(!centr)
		%centr = "v_centr" + @str(!centr) + "_old"
		vector {%centr} = {%m_norm_srs}.@row(!centr_idx)
		' initialize assoc_obs attribute to blank for this random init solve
		{%centr}.setattr("assoc_obs") 
	next
	delete {%centr_idxs}

	' only exit while loop when the clusters have reached their optima
	!iter_count = 0
	while 1

		' iterate through each observation & find its closest centroid
		%centrs = @wlookup("v_centr*old", "vector")
		for !obs = 1 to @rows({%m_norm_srs})
			%obs = "v_obs" + @str(!obs)
			'  find the centroid the observation is closest to
			!min_dist = NA
			for %centr {%centrs} 
				' distance is the Euclidean distance in n dimensional space (# of series) 
				!dist = @sqrt(@sum(@epow({%obs} - {%centr}, 2)))
				' if this centroid is the closest centroid so far, take note
				if !min_dist = NA or !dist < !min_dist then
					!min_dist = !dist
					%min_centr = %centr
				endif
			next 
			' indicate in the obs' closest centroid that this obs is closest to particular centroid
			%assoc_obs = {%min_centr}.@attr("assoc_obs") + " " + @str(!obs)
			{%min_centr}.setattr("assoc_obs") %assoc_obs
		next 

		' if the max # of allowable movement of clusters has not been reached, move them
		if !MAX_ITERS = NA or (!iter_count <> !MAX_ITERS) then
			' go thru each cluster centroid & recalculate it as the mean of each of the newest closest centroids
			' init a series indicating which centroid the observation currently belongs to 
			series obs_cluster = NA
			for !i = 1 to !K
				%centr = "V_CENTR" + @str(!i) + "_OLD"
				%obs_idxs = {%centr}.@attr("assoc_obs")
				' fill in iterated centroid's observations with that centroid #
				for %obs_idx {%obs_idxs}
					obs_cluster(@val(@word(%complete_idxs, @val(%obs_idx)))) = !i
				next
				%g_centr = @replace(%centr, "V_", "G_")
				' go to the sample of the associated obs to the centroid & take the new mean
				smpl @all if obs_cluster = !i
					group {%g_centr} {%SERIES_LIST}
				%m_centr = @replace(%centr, "V_", "M_")
					stom({%g_centr}, {%m_centr})
				' store the mean in the new vector
				%centr_new = @replace(%centr, "_OLD", "_NEW")
					vector {%centr_new} = @cmean({%m_centr})
				' vector of new centroid coords is all that is needed (matrix & group just needed to calculate it)
				delete {%g_centr} {%m_centr}
			next
			smpl @all

			' determine if it definitively can be concluded that an optimum is reached
			!optimum_reached = 1
			%centrs_old = @wlookup("v_centr*_old", "vector")
			for %centr_old {%centrs_old}
				%centr_new = @replace(%centr_old, "_OLD", "_NEW")
				if {%centr_old} <> {%centr_new} then
					!optimum_reached = 0
					exitloop
				endif
			next		
		endif

		' a solution has analytically been reached or max allowed iterations achieved, vet results
		if !optimum_reached or (!iter_count = !MAX_ITERS) then
			delete v_centr*_new ' if a full solve, just used vectors to verify that cluster solution converged
			' calculate the cost function of the randomly initialized solution
			!cost_init = 0
			%centrs = @wlookup("v_centr*_old", "vector")
			for %centr {%centrs}
				%clust_obs = {%centr}.@attr("assoc_obs")
				for %clust_ob {%clust_obs}
					%clust_ob = "v_obs" + %clust_ob
					!obs_cost = @sum(@epow({%clust_ob} - {%centr}, 2))
					!cost_init = !cost_init + !obs_cost
				next
			next 
			' if this cost function is less than the current best (or on 1st init), store its centroids as current optimal 1s
			if !cost_min = NA or !cost_init < !cost_min then
				!cost_min = !cost_init
				' clear out the previous optimal vectors & rename the current iterated 1s
				if @wcount(@wlookup("v_centr*_opt", "vector")) > 0 then
					delete v_centr*_opt 
				endif 
				rename v_centr*_old v_centr*_opt
				' note the fact that the associated cluster with each obs is the optimal classification (thus far)
				if @isobject("obs_cluster_opt") then
					delete obs_cluster_opt
				endif
				rename obs_cluster obs_cluster_opt
				obs_cluster_opt.setattr(Description) "Denotes which cluster each observation is associated with"
				%K = @str(!K)
					obs_cluster_opt.setattr(# of Centroids) %K
			endif 
			exitloop 
		' if optimal clustering is not achieved, prep for another iteration
		else
			delete v_centr*_old 
			rename v_centr*_new v_centr*_old
		endif

		' an iteration is clocked when the means of the clusters have been moved
		!iter_count = !iter_count + 1
	wend ' next move of current cluster centroids

	' remove this if it exists - the needed values are in obs_cluster_opt
	if @isobject("obs_cluster") then
		delete obs_cluster
	endif

	!time = @toc
	logmsg ------ !iter_count iterations [!time seconds]
	logmsg
next ' next random init of cluster centroids

' ************************************************
' *** CLEAN UP & PRESENT RESULTS ***
' ************************************************
logmsg ----- Presenting results & cleaning up
logmsg

' NOTE: all cluster summary stats are recalculated, because the calculations were done on normalized series to avoid scaling issues

' with series obs_cluster saying which obs belongs to which cluster, differences between cluster & overall means can be calculated

' move the observation-cluster classifier to the original page
copy {%work_page}\obs_cluster_opt {%ORIG_PAGE}\obs_cluster

pageselect {%work_page}
' create a text file to present the results
%results = @getnextname("kmeans_results")
text {%results}
{%results}.append "*******************************************************************"
{%results}.append "*** ANALYSIS OF K-MEANS CLUSTERING RESULTS ***"
{%results}.append "*******************************************************************"
{%results}.append
{%results}.append "***************************************************************************************"
{%results}.append " *** USER SELECTED PARAMETERS ***"
{%results}.append
%k_num_msg = "# of clusters: " + @str(!K)
	{%results}.append %k_num_msg
%iter_msg = "# of iterations used: " + @str(!INITS)
	{%results}.append %iter_msg
' place a comma between each series for presentation's sake
%srs_list_text = @replace(@trim(%SERIES_LIST), " ", ", ")
%srs_msg = "Series included in clusters: " + %srs_list_text
	{%results}.append %srs_msg
{%results}.append "***************************************************************************************"
{%results}.append

' replace each series on the add-in page with the non-normalized version of the series
for %srs {%SERIES_LIST}
	copy {%ORIG_PAGE}\{%srs} {%work_page}\{%srs}
	' calculate the mean over all observations in the sample
	pageselect {%work_page}
	' constrain sample to obs that were included in cluster output
	smpl @all if obs_cluster_opt <> NA
		!{%srs}_all_mean = @mean({%srs})
	smpl @all
next


' iterate through each centroid & calculate the mean over its sample for each series
pageselect {%work_page}
for !i = 1 to !K
	' introduce centroid # to the text file
	{%results}.append "***************************************************************************************"
	%k_msg = "CLUSTER " + @str(!i) + ":"
		{%results}.append %k_msg
	{%results}.append

	smpl @all if obs_cluster_opt = !i
	' iterate through the series & present difference in means for cluster compared to general
	for %srs {%SERIES_LIST}
		!{%srs}_k_mean = @mean({%srs})
		!{%srs}_k_mean_round = @round(1000 * !{%srs}_k_mean) / 1000
		%srs_msg = %srs + " cluster mean is " + @str(!{%srs}_k_mean_round)
			{%results}.append %srs_msg
		' calculate absolute & pct differences compared to general mean
		!{%srs}_abs_diff = @round(1000 * (!{%srs}_k_mean - !{%srs}_all_mean)) / 1000
		' cannot calculate pct difference if general mean is a 0
		!{%srs}_pct_diff = NA
		if !{%srs}_all_mean <> 0 then
			!{%srs}_pct_diff = @round(1000 * 100 * (!{%srs}_k_mean - !{%srs}_all_mean) / !{%srs}_all_mean) / 1000
		endif
		%{%srs}_abs_diff = @str(@abs(!{%srs}_abs_diff))
		%{%srs}_pct_diff = @str(@abs(!{%srs}_pct_diff))			
		' a. centroid mean is larger than overall mean
		if !{%srs}_abs_diff > 0 then
			%abs_diff_msg = "    i) " + %{%srs}_abs_diff + " units greater than overall " + %srs + " mean"
				{%results}.append %abs_diff_msg
			if !{%srs}_pct_diff <> NA then
				%pct_diff_msg = "    ii) " + %{%srs}_pct_diff + "% greater than overall " + %srs + " mean" 
				{%results}.append %pct_diff_msg
			endif
		' b. centroid mean is lesser than overall mean
		else
			%abs_diff_msg = "    i) " + %{%srs}_abs_diff + " units lesser than overall " + %srs + " mean"
				{%results}.append %abs_diff_msg
			if !{%srs}_pct_diff <> NA then
				%pct_diff_msg = "    ii) " + %{%srs}_pct_diff  + "% lesser than overall " + %srs + " mean" 
				{%results}.append %pct_diff_msg
			endif
		endif
		{%results}.append
	next
next
{%results}.append "***************************************************************************************"
{%results}.append 

' move the results text file to the output page
copy {%work_page}\{%results} {%ORIG_PAGE}\{%results}

' clean up - delete the scratch work page
pagedelete {%work_page}
pageselect {%ORIG_PAGE}

' show the text file & series mapping observation to centroid
show obs_cluster
show {%results}


