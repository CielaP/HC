*****************************************************************
* Title: Master
* Date: Oct 6th, 2018
* Written by Ayaka Nakamura
* 
* This file runs the following files:
* - DataCleaning.do: 
* 		- Renamevar`currentData'.do: 
* 			- HeadDummy_pri.do
* 			- HeadDummy_spo.do
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
 
* 1: Data cleaning
** tent
global SVYY 2009
global CurrentData JHPS

** set the lists of data set and corresponding year lists
global DataSet "JHPS KHPS" /* list of the data set */
global YearList JHPSyear KHPSyear /* list of the name of year lists */
numlist "2009/2014"
global JHPSyear "`r(numlist)'" /* list of year of JHPS */
numlist "2004/2014"
global KHPSyear "`r(numlist)'" /* list of year of KHPS */
local n: word count $data /* set counter */
disp "data list: $DataSet, year list: $YearList"

forvalues m = 1/`n' {
	global CurrentData: word `m' of $DataSet /* select data set */
	local currentYearList: word `m' of $YearList /* select year list according to data set */
	local numyear: word count $`currentYearList'  /* set counter */
	dis "Current data: $CurrentData, year list: `currentYearList', number of year: `numyear' "
		forvalues k = 1/`numyear'{ /* loop reading do-file within year list */
			global SVYY: word `k' of $`currentYearList' /* set a survey year */
			disp "Current survey year: $SVYY"
			*do "$Path\Code\DataCleaning.do"
		}
}

***** ***** ***** ***** ***** ***** kokokara ***** ***** ***** ***** ***** ***** 
* 2: Bind data of the all years
/* kokomo loop dekirukamo? */
use "$Inter\JHPS2009.dta",  clear
*** JHPS
forvalues n = 2010/2014{
	append using "$Inter\JHPS`n'.dta"
}
*** KHPS
forvalues n = 2004/2014{
	append using "$Inter\KHPS`n'.dta"
}
*** new cohort
forvalues n = 2007 2012{
	append using "$Inter\KHPS`n'_new.dta"
}


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
