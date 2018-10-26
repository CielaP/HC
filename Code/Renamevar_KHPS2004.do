*******************************************************
* Title: Renamevar_VarlistKHPS2004
* Date: Oct 6th, 2018
* Written by Ayaka Nakamura
* 
* This file shows variables to be named in KHPS 2004
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
local expList ///
				cas* regu* self* side* fmw*	
disp "`varList'" "`expList'"

** variable number of principal
*** common variable with other years
local renameListPri ///
				v1 v4 v5 v6 v7 ///
				v76 ///
				v106 v170 ///
				v228 v215 v216 v217 v218 v219 ///
				v238 v239 v240 ///
				v244 v245 v246 v247 v248 v249 ///
				v262 v263 v264
*** variables of working experience
global CasPri v419-v469
global ReguPri v470-v520
global SelfPri v521-v571
global SidePri v572-v622
global FmwPri v623-v673
sum `renameListPri' $CasPri $ReguPri $SelfPri $SidePri $FmwPri

** variable number of spouse
*** common variable with other years
gen relno=.
gen dsex=.
gen bYear=.
gen bMonth=.
global RenameListSpo ///
				v1 v4 dsex bYear bMonth ///
				v76 ///
				v803 v867 ///
				v925 v912 v913 v914 v915 v916 ///
				v935 v936 v937 ///
				v941 v942 v943 v944 v945 v946 ///
				v959 v960 v961
sum $RenameListSpo
*** variables of working experience
global CasSpo v1116-v1166
global ReguSpo v1167-v1217
global SelfSpo v1218-v1268
global SideSpo v1269-v1319
global FmwSpo v1320-v1370
sum `renameListSpo' $CasSpo $ReguSpo $SelfSpo $SideSpo $FmwSpo

** variable list to be convert to matrix
local matVarList `varList' dhead dearnmost `expList'

* set survey year
local SvyY=$SVYY
local currentData $CurrentData
disp "Current data set is `currentData'`SvyY'"

*** rename info. of spouse
rename ( ///
				v13 v14 v15 v16 ///
				v20 v21 v22 v23 ///
				v27 v28 v29 v30 ///
				v34 v35 v36 v37 ///
				v41 v42 v43 v44 ///
				v48 v49 v50 v51 ///
				v55 v56 v57 v58 ///
				v62 v63 v64 v65 ///
				v69 v70 v71 v72 ///
				) ///
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
