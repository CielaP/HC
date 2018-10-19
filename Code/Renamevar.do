*******************************************************
*Title: Renamevar
*Date: Oct 19th, 2018
*Written by Ayaka Nakamura
*
*This file rename variables and save cleaned data as dta
* 
* 1. rename varname of repondent and make head dummy
* 2. rename varname of spouse and make head dummy
* 3. bind 1 and 2
********************************************************

/* definition of id
** JHPS(principal): id=original id
** JHPS(spouse): id=original id+10000
** KHPS(principal): id=original id+20000
** KHPS(spouse,including new_cohort): id=original id+30000
** KHPS(new_cohort): id=original id+40000
*/

* set survey year
local SvyY=$SVYY
local currentData KHPS
disp "Current data set is `currentData'`SvyY'"

* set list of variables
local varList $VarList
local renameListPri $RenameListPri
local renameListSpo $RenameListSpo
local matVarList $MatVarList


* 1. rename varname of repondent
rename ( `renameListPri') ( `varList' )
sum `varList'

** replace id
if "`currentData'"=="KHPS"{
	replace id = id+20000
}
sum id

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
label var dearnmost "Breadwinner dummy"
tab earnmost marital, sum(dearnmost) mean miss

** save variable as matrix
mkmat `matVarList', matrix(pri)

** restore variable names
rename ( `varList' ) ( `renameListPri' )
drop dhead dearnmost


* 2. rename varname of spouse
rename (  `renameListSpo' ) ( `varList' )
sum `varList'

** replace id
replace id = id+10000
sum id
* keep sample of spouse
keep if marital==1
count

* make household head dummy
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

** save variable as matrix
mkmat `matVarList', matrix(spo)


* 3. bind 1 and 2
mat ps = pri \ spo
mat dir

** save matrix as dta
drop _all
svmat double ps, name(col)
qui sum
save "$Inter/`currentData'`SvyY'.dta", replace
