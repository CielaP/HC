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
global ExpList ///
				cas* full* self* side* fmw*	
disp "`varList'" "$ExpList"

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
global FullPri v470-v520
global SelfPri v521-v571
global SidePri v572-v622
global FmwPri v623-v673
sum `renameListPri' $CasPri $FullPri $SelfPri $SidePri $FmwPri

** variable number of spouse
*** common variable with other years
gen relno=.
gen dsex=.
gen bYear=.
gen bMonth=.
local renameListSpo ///
				v1 v4 dsex bYear bMonth ///
				v76 ///
				v803 v867 ///
				v925 v912 v913 v914 v915 v916 ///
				v935 v936 v937 ///
				v941 v942 v943 v944 v945 v946 ///
				v959 v960 v961
*** variables of working experience
global CasSpo v1116-v1166
global FullSpo v1167-v1217
global SelfSpo v1218-v1268
global SideSpo v1269-v1319
global FmwSpo v1320-v1370
sum `renameListSpo' $CasSpo $FullSpo $SelfSpo $SideSpo $FmwSpo

** variable list to be convert to matrix
local matVarList `varList' dhead dearnmost $ExpList

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
qui forvalues x=1/9 {
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
	
	** rename variable of experience
	dis " rename variable of experience "
	global Resp_i `i'
	global Age_t 18
	do "$Path\Code\Renamevar_Exp.do"
	
	if `i'==1 {
		dis " replace id of principle "
		** replace id (KHPS)
		replace id = id+20000
		
		dis " make household head dummy  "
		** make breadwinner dummy
		gen dearnmost=.
		replace dearnmost=1 if earnmost==1
		replace dearnmost=0 if dearnmost!=1
	}
	else {
		dis " replace id of spouse and drop not married "
		** replace id (spouse)
		replace id = id+10000
		** keep sample of spouse
		keep if marital==1
		count
		dis " make household head dummy  "
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

*** recode size dummy
gen osize=size
foreach x of num 88 99{
		mvdecode size, mv(`x')
	}
replace size=1 if size<=6
replace size=4 if size==7 | size==8
replace size=5 if size==9 | size==10
replace size=6 if size==11
tab osize size

save "$Inter/`currentData'`SvyY'.dta", replace
mat drop _all
