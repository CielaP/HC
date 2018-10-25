*******************************************************
* Title: Renamevar_VarlistJHPS2010
* Date: Oct 6th, 2018
* Written by Ayaka Nakamura
* 
* This file shows variables to be named in JHPS 2010
********************************************************
set mat 11000

* set list of variables
** list of variable name to be changed
*** common variable with other years
global VarList ///
				id marital sex byear bmonth ///
				head earnif earnmost ///
				workstatus ///
				occ owner ind size employed regular ///
				switch union ///
				paymethod monthlypaid dailypaid hourlypaid yearlypaid bonus ///
				workdaypermonth workhourperweek overworkperweek
*** variables of working experience
global ExpList ///
				cas* regu* self* side* fmw*	
disp "$VarList" "$ExpList"

** variable number of principal
*** common variable with other years
global RenameListPri ///
				v1 v4 v5 v6 v7 ///
				v101 v102 v103 ///
				v175 ///
				v182 v183 v184 v185 v188 v189 ///
				v231 v196 ///
				v198 v199 v200 v201 v202 v203 ///
				v205 v206 v207
*** variables of working experience
global CasPri v368-v420
global ReguPri v421-v473
global SelfPri v474-v526
global SidePri v527-v579
global FmwPri v580-v632
sum $RenameListPri $CasPri $ReguPri $SelfPri $SidePri $FmwPri

** variable number of spouse
*** common variable with other years
global RenameListSpo ///
				v1 v4  v12 v13 v14 ///
				v101 v102 v103 ///
				v796 ///
				v803 v804 v805 v806 v809 v810 ///
				v852 v817 ///
				v819 v820 v821 v822 v823 v824 ///
				v826 v827 v828
*** variables of working experience
global CasSpo v989-v1041
global ReguSpo v1042-v1094
global SelfSpo v1095-v1147
global SideSpo v1148-v1200
global FmwSpo v1201-v1253
sum $RenameListSpo $CasSpo $ReguSpo $SelfSpo $SideSpo $FmwSpo

** variable list to be convert to matrix
global MatVarList $VarList dhead dearnmost $ExpList
