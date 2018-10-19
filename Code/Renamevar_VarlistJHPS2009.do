*******************************************************
* Title: Renamevar_VarlistJHPS2009
* Date: Oct 6th, 2018
* Written by Ayaka Nakamura
* 
* This file shows variables to be named in JHPS 2009
********************************************************
set mat 11000

* set list of variables
** list of variable name to be changed
global VarList ///
				id marital sex byear bmonth ///
				head earnif earnmost ///
				edbg workstatus ///
				occ owner ind size employed regular ///
				empsinceyear empsincemonth union ///
				paymethod monthlypaid dailypaid hourlypaid yearlypaid bonus ///
				workdaypermonth workhourperweek overworkperweek
disp "$VarList"

** variable number of principal
global RenameListPri ///
				v1 v4 v5 v6 v7 ///
				v101 v102 v103 ///
				v142 v146 ///
				v153 v154 v155 v156 v159 v160 ///
				v167 v168 v169 ///
				v173 v174 v175 v176 v177 v178 ///
				v180 v181 v182
sum $RenameListPri

** variable number of spouse
global RenameListSpo ///
				v1 v4  v12 v13 v14 ///
				v101 v102 v103 ///
				v274 v279 ///
				v286 v287 v288 v289 v292 v293 ///
				v300 v301 v302 ///
				v306 v307 v308 v309 v310 v311 ///
				v313 v314 v315
sum $RenameListSpo

** variable list to be convert to matrix
global MatVarList $VarList dhead dearnmost
