*******************************************************
*Title: RenamevarJHPS2011
*Date: Oct 6th, 2018
*Written by Ayaka Nakamura
*
*This file changes variables' name in 2011 survey
* 
* 1. rename varname of repondent
* 2. rename varname of spouse
* 3. bind 1 and 2
* 
********************************************************
set mat 11000

* Set survey year
local SvyY=$SVYY
local currentData $CurrentData
disp "Current data set is `currentData'`SvyY'"

* set list of variables
local varList ///
				id marital sex byear bmonth ///
				head earnif earnmost ///
				workstatus ///
				occ owner ind size employed regular ///
				switch union ///
				paymethod monthlypaid dailypaid hourlypaid yearlypaid bonus ///
				workdaypermonth workhourperweek overworkperweek
disp "`varList'"


* 1. rename varname of repondent
rename ( ///
				v1 v4 v5 v6 v7 ///
				v101 v102 v103 ///
				v169 ///
				v176 v177 v178 v179 v182 v183 ///
				v219 v190 ///
				v192 v193 v194 v195 v196 v197 ///
				v199 v200 v201) ///
				( `varList' )
sum `varList'

** make household head dummy
*** Q = Are you head of household?
gen dhead=head
replace dhead=0 if head!=1
label var dhead "HH head dummy"
tab head marital, sum(dhead) mean miss

*** Q = Are you main breadwinner?
ge dearnmost=.
replace earnmost=1 if dhead==1&earnif==2
replace dearnmost=1 if earnmost==1
replace dearnmost=0 if dearnmost!=1
label var dearnmost "Beradwinner dummy"
tab earnmost marital, sum(dearnmost) mean miss

** save as matrix
mkmat `varList' dhead dearnmost, matrix(pri)

** restore variable names
rename ( `varList' ) ///
				( ///
				v1 v4 v5 v6 v7 ///
				v101 v102 v103 ///
				v169 ///
				v176 v177 v178 v179 v182 v183 ///
				v219 v190 ///
				v192 v193 v194 v195 v196 v197 ///
				v199 v200 v201)
drop dhead dearnmost

* 2. rename varname of spouse
rename rename ( ///
				v1 v4  v12 v13 v14 ///
				v101 v102 v103 ///
				v382 ///
				v389 v390 v391 v392 v395 v396 ///
				v432 v403 ///
				v405 v406 v407 v408 v409 v410 ///
				v412 v413 v414) ///
				( `varList' )
sum `varList'

** replace id
replace id = id+10000
sum id
* keep sample of spouse
keep if marital==1
count
** make household head dummy
*** Q = Are you head of household?
gen dhead=head
replace dhead=0 if head!=2
replace dhead=1 if head==2
label var dhead "HH head dummy"
tab head marital, sum(dhead) mean miss

*** Q = Are you main breadwinner?
ge dearnmost=.
replace earnmost=2 if dhead==1&earnif==2
replace dearnmost=1 if earnmost==2
replace dearnmost=0 if dearnmost!=1
label var dearnmost "Beradwinner dummy"
tab earnmost marital, sum(dearnmost) mean miss

** save as matrix
mkmat `varList' dhead dearnmost, matrix(spo)

* 3. bind 1 and 2
mat ps = pri \ spo
mat dir

* save matrix as dta
drop _all
svmat double ps, name(col)
qui sum
save "$Inter/`currentData'`SvyY'.dta", replace
