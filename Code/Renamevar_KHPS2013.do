*******************************************************
* Title: Renamevar_VarlistKHPS2013
* Date: Oct 6th, 2018
* Written by Ayaka Nakamura
* 
* This file shows variables to be named in KHPS 2013
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
				v190 ///
				v210 v211 v212 v213 v216 v217 ///
				v266 v225 ///
				v227 v228 v229 v230 v231 v232 ///
				v246 v247 v248
sum $RenameListPri

** variable number of spouse
global RenameListSpo ///
				v1 v4  v14 v15 v16 ///
				v85 v86 v87 ///
				v471 ///
				v491 v492 v493 v494 v497 v498 ///
				v547 v506 ///
				v508 v509 v510 v511 v512 v513 ///
				v527 v528 v529
sum $RenameListSpo

** variable list to be convert to matrix
global MatVarList $VarList dhead dearnmost


* rename varname and make head dummy
do "$Path\Code\Renamevar.do"
