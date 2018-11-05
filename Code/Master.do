/* Title: Master */
/// Date: Oct 6th, 2018
/// Written by Ayaka Nakamura
/// 
/// This file runs the following files:
/// - DataCleaning.do: 
/// 		-- Renamevar_`currentData'`SvyY'.do: 
/// 			-- Renamevar.do: 
/// 			-- Renamevar_OldKHPS.do: 
/// 			-- Renamevar_Exp.do: 
/// -- MergeSchooling.do: 
/// -- ConstructTen.do: 
/// -- SampleSelection.do: 
/// 
/// Step
/// 1: Data cleaning
/// 2: Bind data of the all years
/// 3: Merge schooling
/// 4: Construct tenure variables
/// 5: Sample selection and save data

*  0. Preparation
* Set Directories
global Path "C:\Users\AyakaNakamura\Dropbox\materials\Works\Master\program\Submittion"
global Original "C:\Users\AyakaNakamura\Dropbox\materials\Works\Master\program\Submittion\OriginalData"
global Input "C:\Users\AyakaNakamura\Dropbox\materials\Works\Master\program\Submittion\Input"
global Output "C:\Users\AyakaNakamura\Dropbox\materials\Works\Master\program\Submittion\Output"
global Inter "C:\Users\AyakaNakamura\Dropbox\materials\Works\Master\program\Submittion\Intermediate"

cd $Path
adopath + $Original
adopath + $Input
adopath + $Output
adopath + $Inter
 
set mat 11000
/*
***************************
tent 
global SVYY 2004
global CurrentData KHPS
***************************
*/
** set the lists of data set and corresponding year lists
global DataSet "JHPS KHPS KHPSnew" /* list of the data set */
numlist "2009/2014"
global JHPSyear "`r(numlist)'" /* list of year in JHPS */
numlist "2004/2014"
global KHPSyear "`r(numlist)'" /* list of year in KHPS */
global NewKHPSyear 2007 2012
global YearList JHPSyear KHPSyear NewKHPSyear /* list of the name of year lists */
disp "data list: $DataSet, year list: $YearList"


* Open Log file
cap log close /* close any log files that accidentally have been left open. */
log using "$Path\Log\DataCleaning.log", replace

* 1: Data cleaning
local n: word count $DataSet /* set counter of data set */
forvalues m = 1/`n' { /* loop within data set */
	/* select data set */
	global CurrentData: word `m' of $DataSet
	/* select year list according to data set */
	local currentYearList: word `m' of $YearList
	/* set counter of year list */
	local numYear: word count $`currentYearList'
	dis "Current data: $CurrentData, year list: `currentYearList', number of year: `numYear' "
	
	forvalues k = 1/`numYear'{ /* loop reading do-file within year list */
		/* set a survey year */
		global SVYY: word `k' of $`currentYearList'
		disp "Current survey year: $SVYY"
		do "$Path\Code\DataCleaning.do"
	}
}

***** ***** ***** ***** ***** ***** kokokara ***** ***** ***** ***** ***** ***** 
* 2: Bind data of the all years
use "$Inter\JHPS2009.dta",  clear
*** JHPS
forvalues year_t = 2010/2014{
	append using "$Inter\JHPS`year_t'.dta"
}
*** KHPS
forvalues year_t = 2004/2014{
	append using "$Inter\KHPS`year_t'.dta"
}
*** new cohort
foreach year_t of num 2007 2012{
	append using "$Inter\KHPSnew`year_t'.dta"
}

qui sum
save "$Inter\JHPSKHPS_2004_2014.dta", replace

* 3: Merge schooling and clean data
do "$Path\Code\MergeSchooling.do"
log close 


* 4: Construct tenure variables
do "$Path\Code\ConstructTen.do"


* 5: Sample selection and save data
do "$Path\Code\SampleSelection.do"

** keep variable being used for estimation
local estVar id realwage occ ind dunion dmarital ///
					year schooling dsize dregular ///
					emptenure oj occtenure workexp ///
					///
					dswitch empid age
					
sum `estVar'

save "$Input\jhps_hc.dta", replace


/*
* Create Figures
do "$STATAPATH\do\histogram.do"
do "$STATAPATH\do\boxplot.do"
do "$STATAPATH\do\scatter.do"
