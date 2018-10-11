*****************************************************************
*Title: Master
*Date: Oct 6th, 2018
*Written by Nobu Kikuchi
*
*This file runs the following files:
******************************************************************

global Path "C:\Users\AyakaNakamura\Dropbox\materials\Works\Master\program\Submittion\"
global Original "C:\Users\AyakaNakamura\Dropbox\materials\Works\Master\program\Submittion\OriginalData\"
global Input "C:\Users\AyakaNakamura\Dropbox\materials\Works\Master\program\Submittion\Input\"
global Output "C:\Users\AyakaNakamura\Dropbox\materials\Works\Master\program\Submittion\Output\"
global Inter "C:\Users\AyakaNakamura\Dropbox\materials\Works\Master\program\Submittion\Intermediate\"

*Create Analysis Data sets
forvalues n=2009/2014{
	global SVYY `n'
	*do "$Path\Code\DataCreationJHPS.do"
}
do "$Path\do\merge_2015.do"

*Create Figures
do "$STATAPATH\do\histogram.do"
do "$STATAPATH\do\boxplot.do"
do "$STATAPATH\do\scatter.do"
