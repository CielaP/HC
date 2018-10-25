*******************************************************
*Title: MergeVar
*Date: Oct 24th, 2018
*Written by Ayaka Nakamura
* 
* This file merges schooling
* 
* 1. Select id, schooling from initial survey
* 2. Merge 1 to other survey years
********************************************************

* Define folder location
local path $Path
local original $Original
local input $Input
local output $Output
local inter $Inter
disp "`path', `original', `input', `output', `inter' "


* 1. Select id, schooling from initial survey
** schooling
local schoolingData JHPS2009 KHPS2004 KHPS2007_new KHPS2012_new
local num_k: word count `schoolingData'

forvalues data_i = 1/`num_k' { /* loop within data set */
	local currentSchoolingData: word `data_i' of `schoolingData'
	use "`inter'/`currentSchoolingData'.dta", clear
	keep id edbg
	*** save data
	qui sum
	save "$Inter\Schooling`currentSchoolingData'.dta", replace
}

*** bind all data
use "`inter'/SchoolingJHPS2009.dta", clear
forvalues data_i = 2/`num_k' { /* loop within data set */
	local currentSchoolingData: word `data_i' of `schoolingData'
	append using "`inter'/Schooling`currentSchoolingData'.dta"
}
sort id

*** recod missing variable and make schooling dummies
mvdecode edbg, mv(9)
gen schooling=9 if edbg==1
replace schooling=12 if edbg==2
replace schooling=14 if edbg==3 | edbg==6
replace schooling=16 if edbg==4 | edbg==5
tab edbg schooling
keep id schooling
save "`inter'\Schooling.dta", replace


* 2. Merge 1 to other survey years
use "`inter'\JHPSKHPS_2004_2014.dta", clear

** merge schooling using id
merge m:1 id using "`inter'\Schooling.dta"
drop _merge
 