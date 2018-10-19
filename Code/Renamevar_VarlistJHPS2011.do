*******************************************************
* Title: Renamevar_VarlistJHPS2011
* Date: Oct 6th, 2018
* Written by Ayaka Nakamura
* 
* This file shows variables to be named in JHPS 2011
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
				v169 ///
				v176 v177 v178 v179 v182 v183 ///
				v219 v190 ///
				v192 v193 v194 v195 v196 v197 ///
				v199 v200 v201
sum $RenameListPri

** variable number of spouse
global RenameListSpo ///
				v1 v4  v12 v13 v14 //
				v101 v102 v103 ///
				v382 ///
				v389 v390 v391 v392 v395 v396 ///
				v432 v403 ///
				v405 v406 v407 v408 v409 v410 ///
				v412 v413 v414
sum $RenameListSpo

** variable list to be convert to matrix
global MatVarList $VarList dhead dearnmost
