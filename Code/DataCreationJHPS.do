*******************************************************
*Title: DataCreationJHPS
*Date: Oct 6th, 2018
*Written by "YOUR NAME"
*
*
*This file creates analysis data for ...
*
* Step 1:  (base)
* Step 2: 
* Step 3: 
********************************************************

version 14 /*if needed*/
clear all
set more off
set trace off
*set mem 1g /*not requiered after version 12*/
pause off


*Define folder location
local Original $Original
local Input $Input
local Output $Output
local Inter $Inter

*Open Log file
cap log close /* close any log files that accidentally have been left open. */
*log using "`StataPath'\log\createdata.log", replace

*qui{

*Set survey year
local SvyY=$SVYY
disp "Survey year is `SvyY'"

*Read original data files
disp "`Original'JHPS`SvyY'.csv"
import delimited "`Original'JHPS`SvyY'.csv", clear 
count

*Generate main variables**************

**Survey year & month
ge year=`SvyY'
sum year
ge month = 1
gen svyym=ym(year, month) /* date and time function */
format svyym %tmM,_CY /* format of the survey date = 1, SvyY */
qui sum
disp %tm r(min) /* comfirm: min of the survey date -> must be SvyY/1 */
disp %tm r(max) /* comfirm: max of the survey date -> must be SvyY/1 */

***** ***** ***** ***** ***** ***** kokokara ***** ***** ***** ***** ***** ***** 
**Rename variable names
do Renamevar`SvyY'.do
tab sex   /*Check that data are read correctly*/
sum byear


**Household head dummy
gen dhead=head 
replace dhead=0 if head >2 & head <. 
replace dhead=1 if head==2 & marital==1 /*Is this correct?*/
label var dhead "HH head dummy"
tab head marital, sum(dhead) mean miss

**Main Breadwinner 
ge dearnmost=.
replace dearnmost=0 if earnmost>1&earnmost<.
replace dearnmost=1 if head==1&earnif==2
replace dearnmost=1 if earnmost==2&marital==1 /*Is this correct?*/
replace dearnmost=1 if earnmost==1&marital!=1
label var dearnmost "Beradwinner dummy"
tab earnmost marital, sum(dearnmost) mean miss

*Switch dummy
gen switch=0


*Age
mvdecode byear, mv(9999) /*Recode missing values*/
mvdecode bmonth, mv(99)
gen bym=ym(byear, bmonth)
format bym %tmM,_CY
qui sum bym
disp %tm r(min)
disp %tm r(max)

ge age = floor((svyym-bym)/12) /*Assumed birth day is 1st.*/
sum age, de


*Employment tenure
forvalues X of numlist 8888 9999{
	mvdecode empsinceyear, mv(`X')
}

forvalues X of numlist 88 99{
	mvdecode empsincemonth, mv(`X')
}

gen empym=ym(empsinceyear,empsincemonth)
format empym %tmM,_CY
label var empym "Employment start year, month"
qui sum empym
disp %tm r(min)
disp %tm r(max)

gen emptenure=(svyym-empym)
label var emptenure "Tenure months" 
sum emptenure, de


**New ID for spose
replace id=id+10000 if marital==1 /*Is this really correct?*/

*Drop other variables
keep id-bonus year-emptenure
des, simple

*Save Data
save "`StataPath'\Intermediate\JHPS`SvyY'.dta", replace


*}
log close 

set more on
