*******************************************************
* Title: Renamevar_KHPSnew2012
* Date: Oct 6th, 2018
* Written by Ayaka Nakamura
* 
* This file shows variables to be named in KHPSnew 2012
********************************************************
set mat 11000

* set list of variables
** list of variable name to be changed
*** common variable with other years
local varList ///
				id marital sex byear bmonth ///
				head earnif earnmost ///
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
				v85 v86 v87 ///
				v150 v171 ///
				v218 v219 v220 v221 v224 v225 ///
				v233 v234 v235 ///
				v239 v240 v241 v242 v243 v244 ///
				v249 v250 v251
*** variables of working experience
global CasPri v427-v480
global FullPri v481-v534
global SelfPri v535-v588
global SidePri v589-v642
global FmwPri v643-v696
sum `renameListPri' $CasPri $FullPri $SelfPri $SidePri $FmwPri

** variable number of spouse
*** common variable with other years
gen relno=.
gen dsex=.
gen bYear=.
gen bMonth=.
local renameListSpo ///
				v1 v4 v14 v15 v16 ///
				v85 v86 v87 ///
				v864 v885 ///
				v932 v933 v934 v935 v938 v939 ///
				v947 v948 v949 ///
				v953 v954 v955 v956 v957 v958 ///
				v963 v964 v965
*** variables of working experience
global CasSpo v1141-v1194
global FullSpo v1195-v1248
global SelfSpo v1249-v1302
global SideSpo v1303-v1356
global FmwSpo v1357-v1410
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
