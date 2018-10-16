*******************************************************
*Title: DataCleaning
*Date: Oct 12th, 2018
*Written by Ayaka Nakamura
*
*This file creates analysis data for ...
*
* Step 1:  (base)
* Step 2: 
* Step 3: 
********************************************************

*version 14 /*if needed*/
clear all
set more off
set trace off
*set mem 1g /*not requiered after version 12*/
pause off

* Define folder location
local path $Path
local original $Original
local input $Input
local output $Output
local inter $Inter
disp "`path', `original', `input', `output', `inter'"

* Open Log file
cap log close /* close any log files that accidentally have been left open. */
*log using "`path'\log\DataCleaning.log", replace

*qui{

* Set survey year
local SvyY=$SVYY
disp "Survey year is `SvyY'"

* Read original data files
disp "`original'\JHPS`SvyY'.csv"
import delimited "`original'\JHPS`SvyY'.csv", clear 
count


* Rename variable names
do "`path'\Code\Renamevar`SvyY'.do"
tab sex   /* Check that data are read correctly */


* Generate main variables
** Survey year & month
ge year=`SvyY'
sum year /* check that correct variable are generated */
ge month = 1
gen svyym=ym(year, month) /* date and time function */
format svyym %tmM,_CY /* format of the survey date = 1, SvyY */
qui sum
disp %tm r(min) /* comfirm: min of the survey date -> must be SvyY/1 */
disp %tm r(max) /* comfirm: max of the survey date -> must be SvyY/1 */

** Age
mvdecode byear, mv(9999) /* Recode missing values */
mvdecode bmonth, mv(99)
sum byear
gen bym=ym(byear, bmonth)
format bym %tmM,_CY
qui sum bym
disp %tm r(min)
disp %tm r(max)

ge age = floor((svyym-bym)/12) /* Assumed birth day is 1st. */
sum age, de

** Recode missing values
{
*marital
replace marital=0 if marital==2
sum marital

*empstlmonth /* Employment situation of last month 0=Not working/1=Worked */
mvdecode workstatus, mv(9)
replace workstatus=1 if workstatus<=3
replace workstatus=0 if workstatus>3
sum workstatus

*occ
for num 88 99: mvdecode occ, mv(X)
sum occ

*owner
for num 8 9: mvdecode owner, mv(X)
sum owner

*ind
for num 88 99: mvdecode ind, mv(X)
sum ind

*size
** 1=1~4, 2=5~29, 3=30~99, 4=100~499, 5=500~, 6: government
** large firm=500~, small firm=~499
replace size=0 if size<5
replace size=1 if size==5
for num  8 9 88 99: mvdecode size, mv(X)
tab size

*switch
for num 88 99: mvdecode switch, mv(X)
replace switch=0 if switch<=3 | switch==7 | switch==8
replace switch=1 if switch>=4&switch<=6
replace switch=0 if switch==.
sum switch

*employed
for num 8 9: mvdecode employed, mv(X)
replace employed=0 if employed<=4 | employed>=6
replace employed=1 if employed==5
sum employed

*regular /* 0=non-regular/1=regular */
for num 8 9: mvdecode regular, mv(X)
replace regular=0 if regular>=4 & regular!=.
replace regular=1 if regular!=0 & regular!=.
sum regular

*union
replace union=0 if union<=2 | union==5
replace union=1 if union>1
for num 8 9: mvdecode union, mv(X)
sum union

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

***** ***** ***** ***** ***** ***** kokokara ***** ***** ***** ***** ***** ***** 
** constract wage variable
{
*** adjust the unit of wage data (yen)
gen ymonthlypaid=monthlypaid*1000
gen ybonus=bonus*10000
gen yyearlypaid=yearlypaid*10000
sum ymonthlypaid monthlypaid
sum ybonus bonus
sum yyearlypaid yearlypaid

** annual income according to the pay method
gen income=0
*** monthly: monthlypaid*12+bonus
replace income=ymonthlypaid*12+ybonus if paymethod==1|paymethod==2
*** daily: dailypaid*workdaypermonth*12+bonus
replace income=dailypaid*workdaypermonth*12+ybonus if paymethod==3
*** hourly: hourlypaid*workhourperweek*52+bonus
replace income=hourlypaid*workhourperweek*52+ybonus if paymethod==4
*** yearly: yearlypaid+bonus
replace income=yyearlypaid+ybonus if paymethod==5
*** unknown method: missing value
replace income=. if paymethod==.
sum income, de

*** annual working hour = workhourperweek*52
gen workinghour=workhourperweek*52
sum workinghour

*** working 800 hours or more dummy
gen morethan800=0 if workinghour<800|workinghour==.
replace morethan800=1 if morethan800==.
sum morethan800

** hourly wage: income/workinghour
gen wage=income/workinghour

** Realize hourly wage + merge unemployment rate and inflation rate
gen realwage=0
merge m:1 year using "C:\Users\AyakaNakamura\Dropbox\materials\Works\Master\program\Submittion\Intermediate\InflateUnempRate.dta"
replace realwage=wage/infrate*100
sum realwage wage income

drop _merge lagunemprate infrate
*** 時給250円以下を欠損値にする
replace realwage=. if realwage<250
*** 実質時給をlog化
replace realwage=log(realwage)
}


*Save Data
save "`StataPath'\Intermediate\JHPS`SvyY'.dta", replace


*}
log close 

set more on
