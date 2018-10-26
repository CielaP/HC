*******************************************************
* Title: Renamevar_VarlistKHPS2012
* Date: Oct 6th, 2018
* Written by Ayaka Nakamura
* 
* This file shows variables to be named in KHPS 2012
********************************************************
set mat 11000

* set list of variables
** list of variable name to be changed
global VarList ///
				id marital sex byear bmonth ///
				head earnif earnmost ///
				workstatus ///
				occ owner ind size employed regular ///
				switch union ///
				paymethod monthlypaid dailypaid hourlypaid yearlypaid bonus ///
				workdaypermonth workhourperweek overworkperweek
disp "$VarList"

** variable number of principal
global RenameListPri ///
				v1 v4 v5 v6 v7 ///
				v85 v86 v87 ///
				v167 ///
				v187 v188 v189 v190 v193 v194 ///
				v228 v202 ///
				v204 v205 v206 v207 v208 v209 ///
				v214 v215 v216
sum $RenameListPri

** variable number of spouse
global RenameListSpo ///
				v1 v4  v14 v15 v16 ///
				v85 v86 v87 ///
				v405 ///
				v425 v426 v427 v428 v431 v432 ///
				v466 v440 ///
				v442 v443 v444 v445 v446 v447 ///
				v452 v453 v454
sum $RenameListSpo

** variable list to be convert to matrix
global MatVarList $VarList dhead dearnmost


* rename varname and make head dummy
do "$Path\Code\Renamevar.do"
