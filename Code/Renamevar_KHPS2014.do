*******************************************************
* Title: Renamevar_VarlistKHPS2014
* Date: Oct 6th, 2018
* Written by Ayaka Nakamura
* 
* This file shows variables to be named in KHPS 2014
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
				v101 v102 v103 ///
				v220 ///
				v227 v228 v229 v230 v233 v234 ///
				v265 v242 ///
				v244 v245 v246 v247 v248 v249 ///
				v251 v252 v253
sum $RenameListPri

** variable number of spouse
global RenameListSpo ///
				v1 v4  v12 v13 v14 ///
				v101 v102 v103 ///
				v498 ///
				v505 v506 v507 v508 v511 v512 ///
				v543 v520 ///
				v522 v523 v524 v525 v526 v527 ///
				v529 v530 v531
sum $RenameListSpo

** variable list to be convert to matrix
global MatVarList $VarList dhead dearnmost


* rename varname and make head dummy
do "$Path\Code\Renamevar.do"
