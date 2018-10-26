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

* set list of variables
local varList $VarList
local renameListPri $RenameListPri
local renameListSpo $RenameListSpo
local renameList renameListPri renameListSpo
local matVarList $MatVarList
local relInfo $RelInfo

*** rename info. of spouse
rename ( `relInfo' ) ///
				( ///
				rel1no rel1sex rel1byear rel1bmonth ///
				rel2no rel2sex rel2byear rel2bmonth ///
				rel3no rel3sex rel3byear rel3bmonth ///
				rel4no rel4sex rel4byear rel4bmonth ///
				rel5no rel5sex rel5byear rel5bmonth ///
				rel6no rel6sex rel6byear rel6bmonth ///
				rel7no rel7sex rel7byear rel7bmonth ///
				rel8no rel8sex rel8byear rel8bmonth ///
				rel9no rel9sex rel9byear rel9bmonth ///
				)
forvalues x=1/9 {
	dis "iteration no. is `x'"
	** relation No. of spouse
	replace relno=`x'+1 if rel`x'no==1
	** sex
	replace dsex=rel`x'sex if rel`x'no==1
	** byear
	replace bYear=rel`x'byear if rel`x'no==1
	** bmonth
	replace bMonth=rel`x'bmonth if rel`x'no==1
}

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
		** replace id (KHPS)
		replace id = id+20000
		
		** make breadwinner dummy
		gen dearnmost=.
		replace dearnmost=1 if earnmost==1
		replace dearnmost=0 if dearnmost!=1
	}
	else {
		** replace id (spouse)
		replace id = id+10000
		** keep sample of spouse
		keep if marital==1
		count
		** make breadwinner dummy
		gen dearnmost=.
		replace dearnmost=1 if earnmost==relno
		replace dearnmost=0 if dearnmost==.
	}
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
