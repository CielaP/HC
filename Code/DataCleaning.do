*******************************************************
*Title: DataCleaning
*Date: Oct 12th, 2018
*Written by Ayaka Nakamura
* 
* This file creates data cleaned by year
* 
* 1. Rename variable names
* 2. Generate main variables
********************************************************

clear all
set more off
set trace off
pause off

* Define folder location
local path $Path
local original $Original
local input $Input
local output $Output
local inter $Inter
disp "`path', `original', `input', `output', `inter' "

* Open Log file
cap log close /* close any log files that accidentally have been left open. */
*log using "`path'\Log\DataCleaning.log", replace

*qui{

* Set survey year
local SvyY=$SVYY
local currentData $CurrentData
disp "Current data set is `currentData'`SvyY'"

* Read original data files
disp "`original'/`currentData'`SvyY'.csv"
import delimited "`original'/`currentData'`SvyY'.csv", clear 
count


* 1. Rename variable names
do "`path'\Code\Renamevar_Varlist`currentData'`SvyY'.do"
do "`path'\Code\Renamevar.do"
tab sex   /* Check that data are read correctly */


* 2. Generate main variables
** Survey year & month
ge year=`SvyY'
sum year /* check that correct variable are generated */
ge month = 1
gen svyym=ym(year, month) /* date and time function */
/* format of the survey date = 1, SvyY */
format svyym %tmM,_CY
qui sum
/* comfirm: min and max of the survey date -> must be SvyY/1 */
disp %tm r(min)
disp %tm r(max)

** Age
/* Recode missing values */
mvdecode byear, mv(9999)
mvdecode bmonth, mv(99)
sum byear
gen bym=ym(byear, bmonth)
format bym %tmM,_CY
qui sum bym
disp %tm r(min)
disp %tm r(max)

ge age = floor((svyym-bym)/12) /* Assumed birth day is 1st. */
sum age, de

** Recode missing values and make dummy variables
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
for num 88 99: mvdecode occ, mv(X)
sum occ

*owner
for num 8 9: mvdecode owner, mv(X)
tab owner

*ind
for num 88 99: mvdecode ind, mv(X)
sum ind

*size
** 1=1~4, 2=5~29, 3=30~99, 4=100~499, 5=500~, 6: government
** large firm=500~, small firm=~499
for num  8 9 88 99: mvdecode size, mv(X)
gen dsize=size
replace dsize=0 if size<5
replace dsize=1 if size==5
tab size dsize

*switch
for num 88 99: mvdecode switch, mv(X)
gen dswitch=switch
replace dswitch=0 if switch<=3 | switch>=7
replace dswitch=1 if switch>=4&switch<=6
tab switch dswitch

*employed
for num 8 9: mvdecode employed, mv(X)
gen demployed=employed
replace demployed=0 if employed<=4 | employed>=6
replace demployed=1 if employed==5
tab employed demployed

*regular /* 0=non-regular/1=regular */
for num 8 9: mvdecode regular, mv(X)
gen dregular=regular
replace dregular=0 if regular>=4 & regular!=.
replace dregular=1 if regular<=3 & regular!=.
tab regular dregular

*union
for num 8 9: mvdecode union, mv(X)
gen dunion=union
replace dunion=0 if union<=2 | union==5
replace dunion=1 if union==3 | union==4
tab union dunion

*paymethod
for num 8 9: mvdecode paymethod, mv(X)
tab paymethod

*monthlypaid
for num 88888 99999: mvdecode monthlypaid, mv(X)
sum monthlypaid

*dailypaid
for num 888888 999999: mvdecode dailypaid, mv(X)
sum dailypaid

*hourlypaid
for num 888888 999999: mvdecode hourlypaid, mv(X)
sum hourlypaid

*yearlypaid
for num 88888 99999: mvdecode yearlypaid, mv(X)
sum yearlypaid

*bonus
for num 88888 99999: mvdecode bonus, mv(X)
sum bonus

*workdaypermonth
for num 88 99: mvdecode workdaypermonth, mv(X)
sum workdaypermonth

*workhourperweek
for num 888 999: mvdecode workhourperweek, mv(X)
sum workhourperweek

*overworkperweek
for num 888 999: mvdecode overworkperweek, mv(X)
sum overworkperweek
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


* Save Data
save "`inter'/`currentData'`SvyY'.dta", replace

*}
*log close 
