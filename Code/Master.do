*****************************************************************
* Title: Master
* Date: Oct 6th, 2018
* Written by Nobu Kikuchi
* Modified by Ayaka Nakamura
* 
* This file runs the following files:
* - DataCreation.do: 
* - RenamevarYYYY.do: 
* - Mergevar.do: 
* - 
******************************************************************

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

** set the lists of data set and corresponding year lists
global data "JHPS KHPS" /* list of the data set */
global ylist jy ky /* list of the name of year lists */
numlist "2009/2014"
global jy "`r(numlist)'" /* list of year of JHPS */
numlist "2004/2014"
global ky "`r(numlist)'" /* list of year of KHPS */
local n: word count $data /* set counter */
disp "data list: $data, year list: $ylist"

forvalues m = 1/`n' {
	global cdata: word `m' of $data /* select data set */
	disp "$cdata"
	local cylist: word `m' of $ylist /* select year list according to data set */
	disp "`cylist'"
	local numyear: word count $`cylist'  /* set counter */
	disp "`numyear'"
		forvalues k = 1/`numyear'{ /* loop reading do-file within year list */
			global SVYY: word `k' of $`cylist' /* set a survey year */
			disp $SVYY
			*do "$Path\Code\DataCleaning.do"
		}
}

* 2: Bind data of the all years
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
do "$Path\Code\ConstructVar.do"


* 5: Sample selection and save data
do "$Path\Code\SampleSelection.do"

* Create Figures
do "$STATAPATH\do\histogram.do"
do "$STATAPATH\do\boxplot.do"
do "$STATAPATH\do\scatter.do"
