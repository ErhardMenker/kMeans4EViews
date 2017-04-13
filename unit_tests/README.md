# Unit-test Explanation

- This folder holds programs that generate series & call the k-means clustering utility (assumed that utility lives 1 level above program)
- Ask project creator @ ejmenker@gmail.com about manual verification of results, if they exist, for each unit test

## Program Breakdown

- test1.prg - TIME SERIES: randomly generate & call program on a few Gaussian time series 
    - Used to test scalability of algorithm on a noisy & hard to differentiate data set (worst case scenario, data distribution wise)
    - Clustering, dates, & iteration numbers changed frequently to test scalability
    - No Excel result verification
    
- test2.prg - TIME SERIES: fabricate 7 observations for 3 series (oil price, gold price, & unemployment rate)
    - Tests utility's ability to calculate different needed clustering values (specifically NA handling abilities, imputing, & sample setting)
    - Excel result verification created but not Git tracked, contact author for more details

- test3.prg - CROSS SECTION: randomly generate & call program on a few Gaussian series
    - Used to test scalability of algorithm on a noisy & hard to differentiate data set (worst case scenario, data distribution wise)
    - Clustering, dates, & iteration numbers changed frequently to test scalability
    - No Excel result verification

- test4.prg - CROSS SECTION: fabricate a small amount of cross section data to manually check accuracy
    - Tests utility's ability to calculate different needed clustering values (specifically NA handling abilities, imputing, & sample setting)
    - Excel result verification created but not Git tracked, contact author for more details