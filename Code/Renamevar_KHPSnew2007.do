*******************************************************
* Title: Renamevar_KHPSnew2007
* Date: Oct 6th, 2018
* Written by Ayaka Nakamura
* 
* This file shows variables to be named in KHPSnew 2007
********************************************************
set mat 11000

* set list of variables
** list of variable name to be changed
*** common variable with other years
local varList ///
				id marital sex byear bmonth ///
				earnmost ///
				edbg workstatus ///
				occ owner ind size employed regular ///
				empsinceyear empsincemonth union ///
				paymethod monthlypaid dailypaid hourlypaid yearlypaid bonus ///
				workdaypermonth workhourperweek overworkperweek
*** variables of working experience
global ExpList ///
				cas* full* self* side* fmw*	
disp "`varList'" "$ExpList"

** variable number of principal
*** common variable with other years
local renameListPri ///
				v1 v4 v5 v6 v7 ///
				v76 ///
				v135 v156 ///
				v203 v204 v205 v206 v209 v210 ///
				v222 v223 v224 ///
				v228 v229 v230 v231 v232 v233 ///
				v246 v247 v248
*** variables of working experience
global CasPri v420-v473
global FullPri v474-v527
global SelfPri v528-v581
global SidePri v582-v635
global FmwPri v636-v689
sum `renameListPri' $CasPri $FullPri $SelfPri $SidePri $FmwPri

** variable number of spouse
*** common variable with other years
gen relno=.
gen dsex=.
gen bYear=.
gen bMonth=.
local renameListSpo ///
				v1 v4 v14 v15 v16 ///
				v76 ///
				v813 v834 ///
				v881 v882 v823 v824 v887 v888 ///
				v900 v901 v902 ///
				v906 v907 v908 v909 v910 v911 ///
				v924 v925 v926
*** variables of working experience
global CasSpo v1098-v1151
global FullSpo v1152-v1205
global SelfSpo v1206-v1259
global SideSpo v1260-v1313
global FmwSpo v1314-v1367
sum `renameListSpo' $CasSpo $FullSpo $SelfSpo $SideSpo $FmwSpo

** variable list to be convert to matrix
local matVarList `varList' dhead dearnmost $ExpList

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
	
	** rename variable of experience
	dis " rename variable of experience "
	global Resp_i `i'
	global Age_t 15
	do "$Path\Code\Renamevar_Exp.do"
	
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
