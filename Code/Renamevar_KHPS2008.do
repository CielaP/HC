*******************************************************
* Title: Renamevar_VarlistKHPS2008
* Date: Oct 6th, 2018
* Written by Ayaka Nakamura
* 
* This file rename variables in KHPS2008
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
				v85 ///
				v148 ///
				v168 v169 v170 v171 v174 v175 ///
				v215 v188 ///
				v190 v191 v192 v193 v194 v195 ///
				v209 v210 v211
sum $RenameListPri

** variable number of spouse
gen relno=.
gen dsex=.
gen bYear=.
gen bMonth=.
global RenameListSpo ///
				v1 v4 v14 v15 v16 ///
				v85 ///
				v376 ///
				v396 v397 v398 v399 v402 v403 ///
				v443 v416 ///
				v418 v419 v420 v421 v422 v423 ///
				v437 v438 v439
sum $RenameListSpo

** variable list to be convert to matrix
global MatVarList $VarList dhead dearnmost


* rename varname and make head dummy
do "$Path\Code\Renamevar_OldKHPS.do"
