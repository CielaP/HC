/* Title: MergeSchooling */
/// Date: Oct 24th, 2018
/// Written by Ayaka Nakamura
/// 
/// This file merges schooling
/// 
/// 1. Select id, schooling from initial survey
/// 2. Merge 1 to other survey years
/// 3. Recode missing values and make dummy variables

* Define folder location
local path $Path
local original $Original
local input $Input
local output $Output
local inter $Inter
disp "`path', `original', `input', `output', `inter' "


* 1. Select id, schooling from initial survey
** schooling
local schoolingData JHPS2009 KHPS2004 KHPSnew2007 KHPSnew2012
local num_k: word count `schoolingData'

forvalues data_i = 1/`num_k' { /* loop within data set */
	local currentSchoolingData: word `data_i' of `schoolingData'
	use "`inter'/`currentSchoolingData'.dta", clear
	keep id edbg
	*** save data
	qui sum
	save "$Inter\Schooling`currentSchoolingData'.dta", replace
}

*** bind all data
use "`inter'/SchoolingJHPS2009.dta", clear
forvalues data_i = 2/`num_k' { /* loop within data set */
	local currentSchoolingData: word `data_i' of `schoolingData'
	append using "`inter'/Schooling`currentSchoolingData'.dta"
}
sort id

*** recod missing variable and make schooling dummies
foreach x of num 9 99 {
	mvdecode edbg, mv(`x')
}
gen schooling=9 if edbg==1
replace schooling=12 if edbg==2
replace schooling=14 if edbg==3 | edbg==6
replace schooling=16 if edbg==4 | edbg==5
tab edbg schooling
keep id schooling
save "`inter'\Schooling.dta", replace


* 2. Merge 1 to other survey years
use "`inter'\JHPSKHPS_2004_2014.dta", clear

** merge schooling using id
merge m:1 id using "`inter'\Schooling.dta"
drop _merge


* 3. Recode missing values and make dummy variables
{
*marital
gen dmarital=marital
replace dmarital=0 if marital==2
tab marital dmarital

*empstlmonth /* Employment situation of last month 0=Not working/1=Worked */
mvdecode workstatus, mv(9)
gen dworkstatus=workstatus
replace dworkstatus=1 if workstatus<=3
replace dworkstatus=0 if workstatus>3
tab workstatus dworkstatus

*occ
foreach x of num 88 99 {
	mvdecode occ, mv(`x')
}
sum occ

*owner
foreach x of num 8 9 {
	mvdecode owner, mv(`x')
}
tab owner

*ind
foreach x of num 88 99 {
	mvdecode ind, mv(`x')
}
sum ind

*size
** 1=1~4, 2=5~29, 3=30~99, 4=100~499, 5=500~, 6: government
** large firm=500~, mediam firm=100~499, small firm=~99
foreach x of num 8 9 88 99 {
	mvdecode size, mv(`x')
}
gen dsize=size
replace dsize=0 if size<4
replace dsize=1 if size==4
replace dsize=2 if size>4
tab size dsize

*switch
foreach x of num 88 99 {
	mvdecode switch, mv(`x')
}
gen dswitch=switch
replace dswitch=0 if switch<=3 | switch>=7
replace dswitch=1 if switch>=4&switch<=6
tab switch dswitch

*employed
foreach x of num 8 9 {
	mvdecode employed, mv(`x')
}
gen demployed=employed
replace demployed=0 if employed<=4 | employed>=6
replace demployed=1 if employed==5
tab employed demployed

*regular /* 0=non-regular/1=regular */
foreach x of num 8 9 {
	mvdecode regular, mv(`x')
}
gen dregular=regular
replace dregular=0 if regular>=4 & regular!=.
replace dregular=1 if regular<=3 & regular!=.
tab regular dregular

*union
foreach x of num 8 9 {
	mvdecode union, mv(`x')
}
gen dunion=union
replace dunion=0 if union<=2 | union==5
replace dunion=1 if union==3 | union==4
tab union dunion

*paymethod
foreach x of num 8 9 {
	mvdecode paymethod, mv(`x')
}
tab paymethod

*monthlypaid
foreach x of num 88888 99999 {
	mvdecode monthlypaid, mv(`x')
}
sum monthlypaid

*dailypaid
foreach x of num 888888 999999 {
	mvdecode dailypaid, mv(`x')
}
sum dailypaid

*hourlypaid
foreach x of num 888888 999999 {
	mvdecode hourlypaid, mv(`x')
}
sum hourlypaid

*yearlypaid
foreach x of num 88888 99999 {
	mvdecode yearlypaid, mv(`x')
}
sum yearlypaid

*bonus
foreach x of num 88888 99999 {
	mvdecode bonus, mv(`x')
}
sum bonus

*workdaypermonth
foreach x of num 88 99 {
	mvdecode workdaypermonth, mv(`x')
}
sum workdaypermonth

*workhourperweek
foreach x of num 888 999 {
	mvdecode workhourperweek, mv(`x')
}
sum workhourperweek

*overworkperweek
foreach x of num 888 999 {
	mvdecode overworkperweek, mv(`x')
}
}

** constract real hourly wage
{
*** annual working hour = workhourperweek*52
gen workinghour=workhourperweek*52
sum workinghour, de

*** working 800 hours or more dummy
gen morethan800=0 if workinghour<800|workinghour==.
replace morethan800=1 if morethan800==.
sum morethan800
tab morethan800, sum(workinghour) miss

*** adjust the unit of wage data (yen)
gen omonthlypaid=monthlypaid
gen obonus=bonus
gen oyearlypaid=yearlypaid
replace monthlypaid=omonthlypaid*1000
replace bonus=obonus*10000
replace oyearlypaid=oyearlypaid*10000
sum monthlypaid omonthlypaid
sum bonus obonus
sum yearlypaid oyearlypaid

** annual income according to the pay method
gen annualIncome=0
*** monthly: monthlypaid*12+bonus
replace annualIncome=monthlypaid*12+bonus if paymethod==1|paymethod==2
sum annualIncome if paymethod==1|paymethod==2
*** daily: dailypaid*workdaypermonth*12+bonus
replace annualIncome=dailypaid*workdaypermonth*12+bonus if paymethod==3
sum annualIncome if paymethod==3
*** hourly: hourlypaid*workhourperweek*52+bonus
replace annualIncome=hourlypaid*workinghour+bonus if paymethod==4
sum annualIncome if paymethod==4
*** yearly: yearlypaid+bonus
replace annualIncome=yearlypaid+bonus if paymethod==5
sum annualIncome if paymethod==5
*** unknown method: missing value
replace annualIncome=. if paymethod==.
misstable sum annualIncome paymethod
sum annualIncome, de

** hourly wage: annualIncome/workinghour
gen hourlywage=annualIncome/workinghour
sum hourlywage, de

** Realize hourly wage + merge unemployment rate and inflation rate
local inter $Inter
gen realwage=0
merge m:1 year using "`inter'\InflateUnempRate.dta"
replace realwage=hourlywage/infrate*100
sum realwage hourlywage annualIncome
drop if _merge==2
drop _merge lagunemprate infrate

*** make missing value if realwage is less than Y250/h
replace realwage=. if realwage<250
sum realwage, de
*** Logarize real hourly wage
gen orealwage=realwage
replace realwage=log(orealwage)
sum orealwage realwage
}

