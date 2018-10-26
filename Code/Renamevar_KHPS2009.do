*******************************************************
* Title: Renamevar_VarlistKHPS2009
* Date: Oct 6th, 2018
* Written by Ayaka Nakamura
* 
* This file shows variables to be named in KHPS 2009
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
				v160 ///
				v180 v181 v182 v183 v186 v187 ///
				v238 v195 ///
				v197 v198 v199 v200 v201 v202 ///
				v216 v217 v218
sum $RenameListPri

** variable number of spouse
global RenameListSpo ///
				v1 v4  v14 v15 v16 ///
				v86 v87 v88 ///
				v429 ///
				v449 v450 v451 v452 v455 v456 ///
				v507 v464 ///
				v466 v467 v468 v469 v470 v471 ///
				v485 v486 v487
sum $RenameListSpo

** variable list to be convert to matrix
global MatVarList $VarList dhead dearnmost


* rename varname and make head dummy
do "$Path\Code\Renamevar.do"
