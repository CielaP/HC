*******************************************************
* Title: Renamevar_VarlistKHPS2005
* Date: Oct 6th, 2018
* Written by Ayaka Nakamura
* 
* This file rename variables in KHPS2005
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
				v139 ///
				v171 v159 v160 v161 v164 v165 ///
				v207 v183 ///
				v185 v186 v187 v188 v189 v190 ///
				v203 v204 v205
sum $RenameListPri

** variable number of spouse
gen relno=.
gen dsex=.
gen bYear=.
gen bMonth=.
global RenameListSpo ///
				v1 v4 v14 v15 v16 ///
				v76 ///
				v392 ///
				v424 v412 v413 v414 v417 v418 ///
				v460 v436 ///
				v438 v439 v440 v441 v442 v443 ///
				v456 v457 v458
sum $RenameListSpo

** variable list to be convert to matrix
global MatVarList $VarList dhead dearnmost


* rename varname and make head dummy
do "$Path\Code\Renamevar_OldKHPS.do"
