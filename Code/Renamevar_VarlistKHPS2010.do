*******************************************************
* Title: Renamevar_VarlistKHPS2010
* Date: Oct 6th, 2018
* Written by Ayaka Nakamura
* 
* This file shows variables to be named in KHPS 2010
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
				v161 ///
				v181 v182 v183 v184 v187 v188 ///
				v243 v196 ///
				v198 v199 v200 v201 v202 v203 ///
				v217 v218 v219
sum $RenameListPri

** variable number of spouse
global RenameListSpo ///
				v1 v4  v14 v15 v16 ///
				v85 v86 v87 ///
				v426 ///
				v446 v447 v448 v449 v452 v453 ///
				v508 v461 ///
				v463 v464 v465 v466 v467 v468 ///
				v482 v483 v484
sum $RenameListSpo

** variable list to be convert to matrix
global MatVarList $VarList dhead dearnmost
