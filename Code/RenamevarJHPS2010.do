*******************************************************
*Title: RenamevarJHPS2010
*Date: Oct 6th, 2018
*Written by Ayaka Nakamura
*
*This file changes variables' name in 2010 survey
* 
* 1. rename varname of repondent
* 2. rename varname of spouse
* 3. bind 1 and 2
* 
********************************************************
set mat 11000

* Set survey year
local SvyY=$SVYY
local currentData $CurrentData
disp "Current data set is `currentData'`SvyY'"

* set list of variables
local varList ///
				id marital sex byear bmonth ///
				head earnif earnmost ///
				workstatus ///
				occ owner ind size employed regular ///
				switch union ///
				paymethod monthlypaid dailypaid hourlypaid yearlypaid bonus ///
				workdaypermonth workhourperweek overworkperweek
disp "`varList'"


* 1. rename varname of repondent
rename ( ///
				v1 v4 v5 v6 v7 ///
				v101 v102 v103 ///
				v175 ///
				v182 v183 v184 v185 v188 v189 ///
				v231 v196 ///
				v198 v199 v200 v201 v202 v203 ///
				v205 v206 v207 ///
				) ///
			  ( `varList' )

** rename variables of working experience
qui{
*** temporal employee
for X in num 368/420 \ Y in num 18/70: ///
rename vX casY
*** regular employee
for X in num 421/473 \ Y in num 18/70: ///
rename vX reguY
*** self employed
for X in num 474/526 \ Y in num 18/70: ///
rename vX selfY
*** home industry
for X in num 527/579 \ Y in num 18/70: ///
rename vX sideY
*** family worker
for X in num 580/632 \ Y in num 18/70: ///
rename vX fmwY
}
local varExp cas* regu* self* side* fmw*
sum `varList' `varExp'

** make household head dummy
do "$Path\Code\HeadDummy_pri.do"

** save as matrix
mkmat `varList' dhead dearnmost `varExp', matrix(pri)

** restore variable names
rename ( `varList' ) ///
				( ///
				v1 v4 v5 v6 v7 ///
				v101 v102 v103 ///
				v175 ///
				v182 v183 v184 v185 v188 v189 ///
				v231 v196 ///
				v198 v199 v200 v201 v202 v203 ///
				v205 v206 v207 ///
				)
drop dhead dearnmost
** restore variables of working experience
qui{
*** temporal employee
for X in num 368/420 \ Y in num 18/70: ///
rename casY vX
*** regular employee
for X in num 421/473 \ Y in num 18/70: ///
rename reguY vX
*** self employed
for X in num 474/526 \ Y in num 18/70: ///
rename selfY vX
*** home industry
for X in num 527/579 \ Y in num 18/70: ///
rename sideY vX
*** family worker
for X in num 580/632 \ Y in num 18/70: ///
rename fmwY vX
}

* 2. rename varname of spouse
rename ( ///
				v1 v4  v12 v13 v14 ///
				v101 v102 v103 ///
				v796 ///
				v803 v804 v805 v806 v809 v810 ///
				v852 v817 ///
				v819 v820 v821 v822 v823 v824 ///
				v826 v827 v828) ///
			  ( `varList' )

** rename variables of working experience
qui{
*** temporal employee
for X in num 989/1041 \ Y in num 18/70: ///
rename vX casY
*** regular employee
for X in num 1042/1094 \ Y in num 18/70: ///
rename vX reguY
*** self employed
for X in num 1095/1147 \ Y in num 18/70: ///
rename vX selfY
*** home industry
for X in num 1148/1200 \ Y in num 18/70: ///
rename vX sideY
*** family worker
for X in num 1201/1253 \ Y in num 18/70: ///
rename vX fmwY
}
local varExp cas* regu* self* side* fmw*
sum `varList' `varExp'

** replace id
replace id = id+10000
sum id
* keep sample of spouse
keep if marital==1
count
* make household head dummy
do "$Path\Code\HeadDummy_spo.do"

** save as matrix
mkmat `varList' dhead dearnmost `varExp', matrix(spo)

* 3. bind 1 and 2
mat ps = pri \ spo
mat dir

* save matrix as dta
drop _all
svmat double ps, name(col)
qui sum
save "$Inter/`currentData'`SvyY'.dta", replace
mat drop _all
