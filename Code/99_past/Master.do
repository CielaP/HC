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
 
* Cleaning Analysis Data sets
** tent
global SVYY 2009

/*
forvalues n=2009/2014{
	global SVYY `n'
	do "$Path\Code\DataCreationJHPS.do"
}
*/

* Merge schooling and wokrexp variables
do "$Path\Code\Mergevar.do"

* Create Figures
do "$STATAPATH\do\histogram.do"
do "$STATAPATH\do\boxplot.do"
do "$STATAPATH\do\scatter.do"
