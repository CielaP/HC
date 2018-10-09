*****************************************************************
*Title: Master
*Date: Oct 6th, 2018
*Written by Nobu Kikuchi
*
*This file runs the following files:
******************************************************************

global STATAPATH "C:\Users\AyakaNakamura\Dropbox\materials\Works\Master\program\Submittion"

*Create Analysis Data sets
forvalues n=2009/2014{
	global SVYY `n'
	do "$STATAPATH\Code\DataCreationJHPS.do"
}
do "$STATAPATH\do\merge_2015.do"

*Create Figures
do "$STATAPATH\do\histogram.do"
do "$STATAPATH\do\boxplot.do"
do "$STATAPATH\do\scatter.do"
*/
