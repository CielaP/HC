/* Title: DataCleaning */
/// Date: Oct 12th, 2018
/// Written by Ayaka Nakamura
/// This file creates cleaned data by year
/// 1. Rename variable names
/// 2. Generate main variables

clear all
set more off
set trace off
pause off

* Define folder location
local path $Path
local original $Original
local input $Input
local output $Output
local inter $Inter
disp "`path', `original', `input', `output', `inter' "

* Set survey year
local SvyY $SVYY
local currentData $CurrentData
disp "Current data set is `currentData'`SvyY'"

*qui{

* Read original data files
disp "`original'/`currentData'`SvyY'.csv"
import delimited "`original'/`currentData'`SvyY'.csv", clear 
count


* 1. Rename variable names
do "`path'\Code\Renamevar_`currentData'`SvyY'.do"
tab sex   /* Check that data are read correctly */


* 2. Generate main variables
** Survey year & month
ge year=`SvyY'
sum year /* check that correct variable are generated */
ge month = 1
gen svyym=ym(year, month) /* date and time function */
/* format of the survey date = 1, SvyY */
format svyym %tmM,_CY
qui sum
/* comfirm: min and max of the survey date -> must be SvyY/1 */
disp %tm r(min)
disp %tm r(max)

** Age
/* Recode missing values */
mvdecode byear, mv(9999)
mvdecode bmonth, mv(99)
sum byear
gen bym=ym(byear, bmonth)
format bym %tmM,_CY
qui sum bym
disp %tm r(min)
disp %tm r(max)

ge age = floor((svyym-bym)/12) /* Assumed birth day is 1st. */
sum age, de

** Initial working experience and employer tenure
/// The first year survey creates variables from responses
/// and creates missing values ​​for other years 
local isInitialExp "`currentData'`SvyY'"=="JHPS2010" | ///
								"`currentData'`SvyY'"=="KHPS2004" | ///
								"`currentData'`SvyY'"=="KHPSnew2007" | ///
								"`currentData'`SvyY'"=="KHPSnew2012"
*** working experience
if "`isInitialExp'"{
	/* construct initial workexp for initial survey year */
	**** recode missing value (9) to 0 for each employment status
	local empStatus cas full self side fmw
	local num_m: word count `empStatus'
	dis " recode missing value (9) to 0 for each employment status "
	qui forvalues status_j = 1/`num_m'{
		local currentEmpStatus: word `status_j' of `empStatus'
		recode `currentEmpStatus'* (8 9 = 0)
	}
	
	**** make experience dummy in each year
	/// experience of that year takes 1
	/// if individual takes 1 in at least one employment status that year
	local age_t $Age_t
	qui forvalues x=`age_t'/65{
		gen we`x'=0
	}
	qui forvalues x=`age_t'/65{
		replace we`x'=1 if cas`x'+full`x'+self`x'+side`x'+fmw`x'>=1
	}
	sum we*
	
	**** total experience dummy to make workexp
	egen workexp=rowtotal(we`age_t'-we65)
	sum workexp, de
	drop cas* full* self* side* fmw* we*
}
else { 
	/* making missing value for years other than initial year */
	ge workexp=.
	sum workexp
	}


local isInitialEmp "`currentData'`SvyY'"=="JHPS2009" | ///
								"`currentData'`SvyY'"=="KHPS2004" | ///
								"`currentData'`SvyY'"=="KHPSnew2007" | ///
								"`currentData'`SvyY'"=="KHPSnew2012"
*** employer tenure
if "`isInitialEmp'"{
	/* construct initial emptenure for initial survey year */
	**** recode missing value
	foreach x of num 8888 9999{
		mvdecode empsinceyear, mv(`x')
	}
	foreach x of num 88 99{
		mvdecode empsincemonth, mv(`x')
	}
	
	**** initial employer tenure
	gen empym=ym(empsinceyear,empsincemonth)
	format empym %tmM,_CY
	label var empym "Employment start year, month"
	qui sum empym
	disp %tm r(min)
	disp %tm r(max)
	
	gen emptenure=(svyym-empym)
	label var emptenure "Tenure months" 
	sum emptenure, de
	
	**** generate switch dummy
	gen switch=0
}
else { 
	/* making missing value for years other than initial year */
	ge emptenure=.
	sum emptenure
	}
	

* Save Data
save "`inter'/`currentData'`SvyY'.dta", replace

*}
