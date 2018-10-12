*******************************************************
*Title: DataCleaning
*Date: Oct 12th, 2018
*Written by Ayaka Nakamura
*
*This file creates analysis data for ...
*
* Step 1:  (base)
* Step 2: 
* Step 3: 
********************************************************

*version 14 /*if needed*/
clear all
set more off
set trace off
*set mem 1g /*not requiered after version 12*/
pause off

* Define folder location
local path $Path
local original $Original
local input $Input
local output $Output
local inter $Inter
disp "`path', `original', `input', `output', `inter'"

* Open Log file
cap log close /* close any log files that accidentally have been left open. */
*log using "`path'\log\DataCleaning.log", replace

*qui{

* Set survey year
local SvyY=$SVYY
disp "Survey year is `SvyY'"

* Read original data files
disp "`original'\JHPS`SvyY'.csv"
import delimited "`original'\JHPS`SvyY'.csv", clear 
count

***** ***** ***** ***** ***** ***** kokokara ***** ***** ***** ***** ***** ***** 
* Rename variable names
do "$path\Code\Renamevar`SvyY'.do"
tab sex   /*Check that data are read correctly*/
sum byear

* Generate main variables
** Survey year & month
ge year=`SvyY'
sum year /* check that correct variable are generated */
ge month = 1
gen svyym=ym(year, month) /* date and time function */
format svyym %tmM,_CY /* format of the survey date = 1, SvyY */
qui sum
disp %tm r(min) /* comfirm: min of the survey date -> must be SvyY/1 */
disp %tm r(max) /* comfirm: max of the survey date -> must be SvyY/1 */

* Switch dummy
gen switch=0

* Age
mvdecode byear, mv(9999) /* Recode missing values */
mvdecode bmonth, mv(99)
gen bym=ym(byear, bmonth)
format bym %tmM,_CY
qui sum bym
disp %tm r(min)
disp %tm r(max)

ge age = floor((svyym-bym)/12) /* Assumed birth day is 1st. */
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
