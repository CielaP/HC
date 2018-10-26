*******************************************************
* Title: Renamevar_OldKHPS
* Date: Oct 6th, 2018
* Written by Ayaka Nakamura
* 
* This file rename variables and save cleaned data as dta,
* applied for KHPS before 2008
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

* Define folder location
local path $Path
local inter $Inter
disp "`path', `inter' "

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
	
	if `i'==1 {
		dis " replace id of principle "
		** replace id (KHPS)
		replace id = id+20000
	}
	else {
		dis " replace id of spouse and drop not married "
		** replace id (spouse)
		replace id = id+10000
		** keep sample of spouse
		keep if marital==1
		count
	}
	
	dis " make household head dummy  "
	** make breadwinner dummy
	gen dearnmost=.
	replace dearnmost=1 if earnmost==`i'
	replace dearnmost=0 if dearnmost!=1
	label var dearnmost "Breadwinner dummy"
	tab earnmost marital, sum(dearnmost) mean miss
	
	** make household head dummy
	gen dhead=.
	replace dhead=dearnmost
	label var dhead "HH head dummy"
	
	sum id
	
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
