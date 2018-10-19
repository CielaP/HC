*******************************************************
* Title: Renamevar_VarlistJHPS2013
* Date: Oct 6th, 2018
* Written by Ayaka Nakamura
* 
* This file shows variables to be named in JHPS 2013
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
				v184 ///
				v191 v192 v193 v194 v197 v198 ///
				v234 v205 ///
				v207 v208 v209 v210 v211 v212 ///
				v214 v215 v216
sum $RenameListPri

** variable number of spouse
global RenameListSpo ///
				v1 v4  v12 v13 v14 ///
				v101 v102 v103 ///
				v449 ///
				v456 v457 v458 v459 v462 v463 ///
				v499 v470 ///
				v472 v473 v474 v475 v476 v477 ///
				v479 v480 v481
sum $RenameListSpo

** variable list to be convert to matrix
global MatVarList $VarList dhead dearnmost
