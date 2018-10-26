*******************************************************
* Title: Renamevar_VarlistKHPS2006
* Date: Oct 6th, 2018
* Written by Ayaka Nakamura
* 
* This file rename variables in KHPS2006
********************************************************

* Define folder location
local path $Path
disp "`path' "

* set survey year
local SvyY=$SVYY
local currentData $CurrentData
disp "Current data set is `currentData'`SvyY'"

* set list of variables
** list of variable name to be changed
global VarList ///
				id marital sex byear bmonth ///
				earnmost ///
				workstatus ///
				occ owner ind size employed regular ///
				switch union ///
				paymethod monthlypaid dailypaid hourlypaid yearlypaid bonus ///
				workdaypermonth workhourperweek overworkperweek
disp "$Varlist"

** variable number of principal
global RenameListPri ///
				v1 v4 v5 v6 v7 ///
				v76 ///
				v132 ///
				v152 v153 v154 v155 v158 v159 ///
				v195 v169 ///
				v171 v172 v173 v174 v175 v176 ///
				v189 v190 v191
sum $RenameListPri

** variable number of spouse
gen relno=.
gen dsex=.
gen bYear=.
gen bMonth=.
global RenameListSpo ///
				v1 v4 dsex bYear bMonth ///
				v76 ///
				v348 ///
				v368 v369 v370 v371 v374 v375 ///
				v411 v385 ///
				v387 v388 v389 v390 v391 v392 ///
				v405 v406 v407 ///
sum $RenameListSpo

*** info. of spouse
global RelInfo ///
				v13 v14 v15 v16 ///
				v20 v21 v22 v23 ///
				v27 v28 v29 v30 ///
				v34 v35 v36 v37 ///
				v41 v42 v43 v44 ///
				v48 v49 v50 v51 ///
				v55 v56 v57 v58 ///
				v62 v63 v64 v65 ///
				v69 v70 v71 v72 ///

** variable list to be convert to matrix
global MatVarList $VarList dhead dearnmost


* rename varname and make head dummy
do "$Path\Code\Renamevar_OldKHPS.do"
