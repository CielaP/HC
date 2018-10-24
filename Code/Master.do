*****************************************************************
* Title: Master
* Date: Oct 6th, 2018
* Written by Ayaka Nakamura
* 
* This file runs the following files:
* - DataCleaning.do: 
* 		- Renamevar_Varlist`currentData'`SvyY'.do: 
* 		- Renamevar.do: 
* - MergeVar.do: 
* - 
* 
* Step
* 1: Data cleaning
* 2: Bind data of the all years
* 3: Merge schooling and experience
* 4: Construct tenure variables
* 5: Sample selection and save data
*****************************************************************

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
 
***************************
/* tent */
global SVYY 2011
global CurrentData JHPS
***************************

** set the lists of data set and corresponding year lists
global DataSet "JHPS KHPS" /* list of the data set */
numlist "2009/2014"
global JHPSyear "`r(numlist)'" /* list of year in JHPS */
numlist "2004/2014"
global KHPSyear "`r(numlist)'" /* list of year in KHPS */
global YearList JHPSyear KHPSyear /* list of the name of year lists */
disp "data list: $DataSet, year list: $YearList"


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
			*do "$Path\Code\DataCleaning.do"
		}
}

***** ***** ***** ***** ***** ***** kokokara ***** ***** ***** ***** ***** ***** 
* 2: Bind data of the all years
use "$Inter\JHPS2009.dta",  clear
*** JHPS
forvalues year = 2010/2014{
	append using "$Inter\JHPS`year'.dta"
}
*** KHPS
forvalues year = 2004/2014{
	append using "$Inter\KHPS`year'.dta"
}
*** new cohort
forvalues year = 2007 2012{
	append using "$Inter\KHPS`year'_new.dta"
}
save "`inter'\JHPSKHPS_2004_2014.dta", replace


* 3: Merge schooling and experience
do "$Path\Code\MergeVar.do"


* 4: Construct tenure variables
do "$Path\Code\ConstructTen.do"


* 5: Sample selection and save data
do "$Path\Code\SampleSelection.do"

save "$Input\jhps_hc.dta", replace

* Create Figures
do "$STATAPATH\do\histogram.do"
do "$STATAPATH\do\boxplot.do"
do "$STATAPATH\do\scatter.do"
