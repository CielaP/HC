*******************************************************
* Title: Renamevar_VarlistJHPS2012
* Date: Oct 6th, 2018
* Written by Ayaka Nakamura
* 
* This file shows variables to be named in JHPS 2012
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
				v190 ///
				v197 v198 v199 v200 v203 v204 ///
				v240 v211 ///
				v213 v214 v215 v216 v217 v218 ///
				v220 v221 v222
sum $RenameListPri

** variable number of spouse
global RenameListSpo ///
				v1 v4  v12 v13 v14 ///
				v101 v102 v103 ///
				v420 ///
				v427 v428 v429 v430 v433 v434 ///
				v470 v441 ///
				v443 v444 v445 v446 v447 v448 ///
				v450 v451 v452
sum $RenameListSpo

** variable list to be convert to matrix
global MatVarList $VarList dhead dearnmost
