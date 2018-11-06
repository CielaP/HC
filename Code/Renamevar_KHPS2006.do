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
global RenameListSpo ///
				v1 v4 v14 v15 v16 ///
				v76 ///
				v348 ///
				v368 v369 v370 v371 v374 v375 ///
				v411 v385 ///
				v387 v388 v389 v390 v391 v392 ///
				v405 v406 v407
sum $RenameListSpo

** variable list to be convert to matrix
global MatVarList $VarList dhead dearnmost


* rename varname and make head dummy
do "$Path\Code\Renamevar_OldKHPS.do"
