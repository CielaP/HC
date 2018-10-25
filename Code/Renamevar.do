*******************************************************
*Title: Renamevar
*Date: Oct 19th, 2018
*Written by Ayaka Nakamura
*
*This file rename variables and save cleaned data as dta
* 
* 1. rename varname and make head dummy
* 2. bind observations of principal and spouse
********************************************************

/* definition of id
** JHPS(principal): id=original id
** JHPS(spouse): id=original id+10000
** KHPS(principal): id=original id+20000
** KHPS(spouse): id=original id+30000 (=(original id +20000)+10000)
** KHPS(new_cohort, principal): id=original id+40000
** KHPS(new_cohort, spouse): id=original id+50000 (=(original id +40000)+10000)
*/

* set survey year
local SvyY=$SVYY
local currentData $CurrentData
disp "Current data set is `currentData'`SvyY'"

* set list of variables
local varList $VarList
local renameListPri $RenameListPri
local renameListSpo $RenameListSpo
local renameList renameListPri renameListSpo
local matVarList $MatVarList


* 1. rename varname and make head dummy
local n: word count `renameList' /* set counter of renameList */
forvalues i = 1/`n' { /* loop within rename list */
	/* select list */
	local currentRenameList: word `i' of `renameList'
	dis " ** Rename variables of `currentRenameList' "
	
	* rename varname
	** rename common variable
	rename ( ``currentRenameList'' ) ( `varList' )
	
	** rename var of experience if data=JHPS2010, KHPS2004
	local isIntSurvey "`currentData'`SvyY'"=="KHPS2004" | ///
								"`currentData'`SvyY'"=="JHPS2010" 
	if "`isIntSurvey'" {
		global Resp_i `i'
		do "$Path\Code\RenamevarExp.do"
	}
	
	** replace id (KHPS)
	if "`currentData'"=="KHPS"&&`i'==1{
		replace id = id+20000
		}
	sum id
	
	if `i'==2{
		** replace id (spouse)
		replace id = id+10000
		sum id
		* keep sample of spouse
		keep if marital==1
		count
		}
	
	** make household head dummy
	*** Q = Are you head of household?
	gen dhead=.
	replace dhead=0 if head!=`i'
	replace dhead=1 if head==`i'
	label var dhead "HH head dummy"
	tab head marital, sum(dhead) mean miss
	
	*** Q = Are you main breadwinner?
	ge dearnmost=.
	replace earnmost=1 if dhead==1&earnif==2
	replace dearnmost=1 if earnmost==`i'
	replace dearnmost=0 if dearnmost!=1
	label var dearnmost "Breadwinner dummy"
	tab earnmost marital, sum(dearnmost) mean miss
	
	** save variable as matrix
	if `i'==1{
		local matName pri
	}
	else {
		local matName spo
	}
	mkmat `matVarList', matrix(`matName')
	mat dir
	
	** restore variable names
	rename ( `varList' ) ( ``currentRenameList'' )
	drop dhead dearnmost
	if "`isIntSurvey'" {
		drop $ExpList
	}
}


* 2. bind observations of principal and spouse
mat ps = pri \ spo
mat dir

** save matrix as dta
drop _all
svmat double ps, name(col)
qui sum
save "$Inter/`currentData'`SvyY'.dta", replace
mat drop _all
