*******************************************************
* Title: Renamevar_VarlistKHPS2011
* Date: Oct 6th, 2018
* Written by Ayaka Nakamura
* 
* This file shows variables to be named in KHPS 2011
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
				v173 ///
				v193 v194 v195 v196 v199 v200 ///
				v249 v208 ///
				v210 v211 v212 v213 v214 v215 ///
				v229 v230 v231
sum $RenameListPri

** variable number of spouse
global RenameListSpo ///
				v1 v4  v14 v15 v16 ///
				v85 v86 v87 ///
				v431 ///
				v451 v452 v453 v454 v457 v458 ///
				v507 v466 ///
				v468 v469 v470 v471 v472 v473 ///
				v487 v488 v489
sum $RenameListSpo

** variable list to be convert to matrix
global MatVarList $VarList dhead dearnmost
