*******************************************************
* Title: Renamevar_VarlistJHPS2010
* Date: Oct 6th, 2018
* Written by Ayaka Nakamura
* 
* This file shows variables to be named in JHPS 2010
********************************************************
set mat 11000

* set list of variables
** list of variable name to be changed
*** common variable with other years
local varList ///
				id marital sex byear bmonth ///
				head earnif earnmost ///
				workstatus ///
				occ owner ind size employed regular ///
				switch union ///
				paymethod monthlypaid dailypaid hourlypaid yearlypaid bonus ///
				workdaypermonth workhourperweek overworkperweek
*** variables of working experience
local expList ///
				cas* regu* self* side* fmw*	
disp "`varList'" "`expList'"

** variable number of principal
*** common variable with other years
local renameListPri ///
				v1 v4 v5 v6 v7 ///
				v101 v102 v103 ///
				v175 ///
				v182 v183 v184 v185 v188 v189 ///
				v231 v196 ///
				v198 v199 v200 v201 v202 v203 ///
				v205 v206 v207
*** variables of working experience
global CasPri v368-v420
global ReguPri v421-v473
global SelfPri v474-v526
global SidePri v527-v579
global FmwPri v580-v632
sum `renameListPri' $CasPri $ReguPri $SelfPri $SidePri $FmwPri

** variable number of spouse
*** common variable with other years
local renameListSpo ///
				v1 v4  v12 v13 v14 ///
				v101 v102 v103 ///
				v796 ///
				v803 v804 v805 v806 v809 v810 ///
				v852 v817 ///
				v819 v820 v821 v822 v823 v824 ///
				v826 v827 v828
*** variables of working experience
global CasSpo v989-v1041
global ReguSpo v1042-v1094
global SelfSpo v1095-v1147
global SideSpo v1148-v1200
global FmwSpo v1201-v1253
sum `renameListSpo' $CasSpo $ReguSpo $SelfSpo $SideSpo $FmwSpo

** variable list to be convert to matrix
local matVarList `varList' dhead dearnmost `expList'

* set survey year
local SvyY=$SVYY
local currentData $CurrentData
disp "Current data set is `currentData'`SvyY'"


* 1. rename varname and make head dummy
local renameList renameListPri renameListSpo
local n: word count `renameList' /* set counter of renameList */
forvalues i = 1/`n' { /* loop within rename list */
	/* select list */
	local currentRenameList: word `i' of `renameList'
	dis " ** Rename variables of `currentRenameList' "
	
	* rename varname
	** rename common variable
	rename ( ``currentRenameList'' ) ( `varList' )
	
	global Resp_i `i'
	do "$Path\Code\Renamevar_Exp.do"
	
	if `i'==2{
		** replace id (spouse)
		replace id = id+10000
		* keep sample of spouse
		keep if marital==1
		count
		}
	sum id
	
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
	drop $ExpList
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
