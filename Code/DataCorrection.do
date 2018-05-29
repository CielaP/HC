clear
set more off
 cd "C:\Users\Ayaka Nakamura\Dropbox\materials\Works\Master\program\Submittion"
 adopath + "C:\Users\Ayaka Nakamura\Dropbox\materials\Works\Master\program\Submittion"
 adopath + "C:\Users\Ayaka Nakamura\Dropbox\materials\Works\Master\program\Submittion\OriginalData"
 adopath + "C:\Users\Ayaka Nakamura\Dropbox\materials\Works\Master\program\Submittion\Intermediate"
 adopath + "C:\Users\Ayaka Nakamura\Dropbox\materials\Works\Master\program\Submittion\Output"
 adopath + "C:\Users\Ayaka Nakamura\Dropbox\materials\Works\Master\program\Submittion\Intput"
 adopath + "C:\Users\Ayaka Nakamura\Dropbox\materials\Works\Master\program\Submittion\coefplot"

* Data Correction
** 変数名を付ける
** 配偶者データを抽出して元データにバインド
/*
JHPSのid=元のid(~ab.4000)
** JHPSの配偶者のid=元のid+10000
** KHPSのid=元のid+20000
** KHPSの配偶者のid=元のid+30000
*/
{
** JHPS2009
{
* 変数名の変更
** 本人
import delimited "C:\Users\Ayaka Nakamura\Dropbox\materials\Works\Master\program\Submittion\OriginalData\JHPS2009.csv", clear 
rename (v1 v4 v5 v6 v7 v101 v102 v103 v142 v146 ///
v153 v154 v155 v156 v159 v160 ///
v167 v168 v169 ///
v173 v174 v175 v176 v177 v178 ///
v180 v181 v182 v183) ///
(id marital sex byear bmonth head earnif earnmost edbg workstatus ///
occ owner ind size employed regular ///
empsinceyear empsincemonth union ///
paymethod monthlypaid dailypaid hourlypaid yearlypaid bonus ///
workdaypermonth workhourperweek overworkperweek paidoverworkperweek)
* 世帯主ダミー作成
** 世帯主ですか
replace head=0 if head!=1
** 主たる生計維持者
replace earnmost=1 if head==1&earnif==2
replace earnmost=0 if earnmost!=1
* 使わない変数を落とす
drop earnif v*
save "C:\Users\Ayaka Nakamura\Dropbox\materials\Works\Master\program\Submittion\Intermediate\JHPS2009_pr.dta", replace

** 配偶者
import delimited "C:\Users\Ayaka Nakamura\Dropbox\materials\Works\Master\program\Submittion\OriginalData\JHPS2009.csv", clear 
rename (v1 v4  v12 v13 v14 v101 v102 v103 v274 v279 ///
v286 v287 v288 v289 v292 v293 ///
v300 v301 v302 ///
v306 v307 v308 v309 v310 v311 ///
v313 v314 v315 v316) ///
(id marital sex byear bmonth head earnif earnmost edbg workstatus ///
occ owner ind size employed regular ///
empsinceyear empsincemonth union ///
paymethod monthlypaid dailypaid hourlypaid yearlypaid bonus ///
workdaypermonth workhourperweek overworkperweek paidoverworkperweek)
* 続柄が配偶者のサンプルのみ残す
keep if marital==1
* 世帯主ダミー作成
** 世帯主ですか
replace head=0 if head!=2
replace head=1 if head==2
** 主たる生計維持者
replace earnmost=1 if earnmost==2|head==1&earnif==2
replace earnmost=0 if earnmost!=1
* 使わない変数を落とす
drop earnif v*
* idを+10000
replace id=id+10000
save "C:\Users\Ayaka Nakamura\Dropbox\materials\Works\Master\program\Submittion\Intermediate\JHPS2009_sp.dta", replace

** 本人と配偶者サンプルをバインド
use "C:\Users\Ayaka Nakamura\Dropbox\materials\Works\Master\program\Submittion\Intermediate\JHPS2009_pr.dta", clear
append using "C:\Users\Ayaka Nakamura\Dropbox\materials\Works\Master\program\Submittion\Intermediate\JHPS2009_sp.dta"
gen year=2009
* ageを作成
replace bmonth=bmonth+10
tostring byear bmonth, replace
gen bday=byear+bmonth+"15"
destring bday, replace
replace bday=bday-1000
gen age=floor((20090130-bday)/10000)
drop byear bmonth bday
export delimited "C:\Users\Ayaka Nakamura\Dropbox\materials\Works\Master\program\Submittion\Input\JHPS2009.csv", replace
}

** JHPS2010
{
* 変数名の変更
** 本人
import delimited "C:\Users\Ayaka Nakamura\Dropbox\materials\Works\Master\program\Submittion\OriginalData\JHPS2010.csv", clear 
rename (v1 v4 v5 v6 v7 v101 v102 v103 v146 ///
v182 v183 v184 v185 v188 v189 ///
v196 ///
v198 v199 v200 v201 v202 v203 ///
v205 v206 v207 v208) ///
(id marital sex byear bmonth head earnif earnmost workstatus ///
occ owner ind size employed regular ///
union ///
paymethod monthlypaid dailypaid hourlypaid yearlypaid bonus ///
workdaypermonth workhourperweek overworkperweek paidoverworkperweek)
*** 就業履歴データの変数名変更
**** schooling
for X in num 262/314 \ Y in num 18/70: ///
rename vX schY
**** searching
for X in num 315/367 \ Y in num 18/70: ///
rename vX seekY
**** temporal employee
for X in num 368/420 \ Y in num 18/70: ///
rename vX casY
**** regular employee
for X in num 421/473 \ Y in num 18/70: ///
rename vX regY
**** self employed
for X in num 474/526 \ Y in num 18/70: ///
rename vX selfY
**** 内職
for X in num 527/579 \ Y in num 18/70: ///
rename vX sideY
**** family worker
for X in num 580/632 \ Y in num 18/70: ///
rename vX fmwY
**** switching
for X in num 633/685 \ Y in num 18/70: ///
rename vX swY
* 世帯主ダミー作成
** 世帯主ですか
replace head=0 if head!=1
** 主たる生計維持者
replace earnmost=1 if head==1&earnif==2
replace earnmost=0 if earnmost!=1
* 使わない変数を落とす
drop earnif v*
save "C:\Users\Ayaka Nakamura\Dropbox\materials\Works\Master\program\Submittion\Intermediate\JHPS2010_pr.dta", replace

** 配偶者
import delimited "C:\Users\Ayaka Nakamura\Dropbox\materials\Works\Master\program\Submittion\OriginalData\JHPS2010.csv", clear 
rename (v1 v4  v12 v13 v14 v101 v102 v103 v796 ///
v803 v804 v805 v806 v809 v810 ///
v817 ///
v819 v820 v821 v822 v823 v824 ///
v826 v827 v828 v829) ///
(id marital sex byear bmonth head earnif earnmost workstatus ///
occ owner ind size employed regular ///
union ///
paymethod monthlypaid dailypaid hourlypaid yearlypaid bonus ///
workdaypermonth workhourperweek overworkperweek paidoverworkperweek)
* 続柄が配偶者のサンプルのみ残す
keep if marital==1
*** 就業履歴データの変数名変更
**** schooling
for X in num 883/935 \ Y in num 18/70: ///
rename vX schY
**** searching
for X in num 936/988 \ Y in num 18/70: ///
rename vX seekY
**** temporal employee
for X in num 989/1041 \ Y in num 18/70: ///
rename vX casY
**** regular employee
for X in num 1042/1094 \ Y in num 18/70: ///
rename vX regY
**** self employed
for X in num 1095/1147 \ Y in num 18/70: ///
rename vX selfY
**** 内職
for X in num 1148/1200 \ Y in num 18/70: ///
rename vX sideY
**** family worker
for X in num 1201/1253 \ Y in num 18/70: ///
rename vX fmwY
**** switching
for X in num 1254/1306 \ Y in num 18/70: ///
rename vX swY
* 世帯主ダミー作成
** 世帯主ですか
replace head=0 if head!=2
replace head=1 if head==2
** 主たる生計維持者
replace earnmost=1 if earnmost==2|head==1&earnif==2
replace earnmost=0 if earnmost!=1
* 使わない変数を落とす
drop earnif v*
* idを+10000
replace id=id+10000
save "C:\Users\Ayaka Nakamura\Dropbox\materials\Works\Master\program\Submittion\Intermediate\JHPS2010_sp.dta", replace

** 本人と配偶者サンプルをバインド
use "C:\Users\Ayaka Nakamura\Dropbox\materials\Works\Master\program\Submittion\Intermediate\JHPS2010_pr.dta", clear
append using "C:\Users\Ayaka Nakamura\Dropbox\materials\Works\Master\program\Submittion\Intermediate\JHPS2010_sp.dta"
gen year=2010
* ageを作成
replace bmonth=bmonth+10
tostring byear bmonth, replace
gen bday=byear+bmonth+"15"
destring bday, replace
replace bday=bday-1000
gen age=floor((20100130-bday)/10000)
drop byear bmonth bday
export delimited "C:\Users\Ayaka Nakamura\Dropbox\materials\Works\Master\program\Submittion\Input\JHPS2010.csv", replace
}

** JHPS2011
{
* 変数名の変更
** 本人
import delimited "C:\Users\Ayaka Nakamura\Dropbox\materials\Works\Master\program\Submittion\OriginalData\JHPS2011.csv", clear 
rename (v1 v4 v5 v6 v7 v101 v102 v103 v169 ///
v176 v177 v178 v179 v182 v183 ///
v190 ///
v192 v193 v194 v195 v196 v197 ///
v199 v200 v201 v202) ///
(id marital sex byear bmonth head earnif earnmost workstatus ///
occ owner ind size employed regular ///
union ///
paymethod monthlypaid dailypaid hourlypaid yearlypaid bonus ///
workdaypermonth workhourperweek overworkperweek paidoverworkperweek)
* 世帯主ダミー作成
** 世帯主ですか
replace head=0 if head!=1
** 主たる生計維持者
replace earnmost=1 if head==1&earnif==2
replace earnmost=0 if earnmost!=1
* 使わない変数を落とす
drop earnif v*
save "C:\Users\Ayaka Nakamura\Dropbox\materials\Works\Master\program\Submittion\Intermediate\JHPS2011_pr.dta", replace

** 配偶者
import delimited "C:\Users\Ayaka Nakamura\Dropbox\materials\Works\Master\program\Submittion\OriginalData\JHPS2011.csv", clear 
rename (v1 v4  v12 v13 v14 v101 v102 v103 v382 ///
v389 v390 v391 v392 v395 v396 ///
v403 ///
v405 v406 v407 v408 v409 v410 ///
v412 v413 v414 v415) ///
(id marital sex byear bmonth head earnif earnmost workstatus ///
occ owner ind size employed regular ///
union ///
paymethod monthlypaid dailypaid hourlypaid yearlypaid bonus ///
workdaypermonth workhourperweek overworkperweek paidoverworkperweek)
* 続柄が配偶者のサンプルのみ残す
keep if marital==1
* 世帯主ダミー作成
* 世帯主ダミー作成
** 世帯主ですか
replace head=0 if head!=2
replace head=1 if head==2
** 主たる生計維持者
replace earnmost=1 if earnmost==2|head==1&earnif==2
replace earnmost=0 if earnmost!=1
* 使わない変数を落とす
drop earnif v*
* idを+10000
replace id=id+10000
save "C:\Users\Ayaka Nakamura\Dropbox\materials\Works\Master\program\Submittion\Intermediate\JHPS2011_sp.dta", replace

** 本人と配偶者サンプルをバインド
use "C:\Users\Ayaka Nakamura\Dropbox\materials\Works\Master\program\Submittion\Intermediate\JHPS2011_pr.dta", clear
append using "C:\Users\Ayaka Nakamura\Dropbox\materials\Works\Master\program\Submittion\Intermediate\JHPS2011_sp.dta"
gen year=2011
* ageを作成
replace bmonth=bmonth+10
tostring byear bmonth, replace
gen bday=byear+bmonth+"15"
destring bday, replace
replace bday=bday-1000
gen age=floor((20110130-bday)/10000)
drop byear bmonth bday
export delimited "C:\Users\Ayaka Nakamura\Dropbox\materials\Works\Master\program\Submittion\Input\JHPS2011.csv", replace
}

** JHPS2012
{
* 変数名の変更
** 本人
import delimited "C:\Users\Ayaka Nakamura\Dropbox\materials\Works\Master\program\Submittion\OriginalData\JHPS2012.csv", clear 
rename (v1 v4 v5 v6 v7 v101 v102 v103 v190 ///
v197 v198 v199 v200 v203 v204 ///
v211 ///
v213 v214 v215 v216 v217 v218 ///
v220 v221 v222 v223) ///
(id marital sex byear bmonth head earnif earnmost workstatus ///
occ owner ind size employed regular ///
union ///
paymethod monthlypaid dailypaid hourlypaid yearlypaid bonus ///
workdaypermonth workhourperweek overworkperweek paidoverworkperweek)
* 世帯主ダミー作成
** 世帯主ですか
replace head=0 if head!=1
** 主たる生計維持者
replace earnmost=1 if head==1&earnif==2
replace earnmost=0 if earnmost!=1
* 使わない変数を落とす
drop earnif v*
save "C:\Users\Ayaka Nakamura\Dropbox\materials\Works\Master\program\Submittion\Intermediate\JHPS2012_pr.dta", replace

** 配偶者
import delimited "C:\Users\Ayaka Nakamura\Dropbox\materials\Works\Master\program\Submittion\OriginalData\JHPS2012.csv", clear 
rename (v1 v4  v12 v13 v14 v101 v102 v103 v420 ///
v427 v428 v429 v430 v433 v434 ///
v441 ///
v443 v444 v445 v446 v447 v448 ///
v450 v451 v452 v453) ///
(id marital sex byear bmonth head earnif earnmost workstatus ///
occ owner ind size employed regular ///
union ///
paymethod monthlypaid dailypaid hourlypaid yearlypaid bonus ///
workdaypermonth workhourperweek overworkperweek paidoverworkperweek)
* 続柄が配偶者のサンプルのみ残す
keep if marital==1
* 世帯主ダミー作成
* 世帯主ダミー作成
** 世帯主ですか
replace head=0 if head!=2
replace head=1 if head==2
** 主たる生計維持者
replace earnmost=1 if earnmost==2|head==1&earnif==2
replace earnmost=0 if earnmost!=1
* 使わない変数を落とす
drop earnif v*
* idを+10000
replace id=id+10000
save "C:\Users\Ayaka Nakamura\Dropbox\materials\Works\Master\program\Submittion\Intermediate\JHPS2012_sp.dta", replace

** 本人と配偶者サンプルをバインド
use "C:\Users\Ayaka Nakamura\Dropbox\materials\Works\Master\program\Submittion\Intermediate\JHPS2012_pr.dta", clear
append using "C:\Users\Ayaka Nakamura\Dropbox\materials\Works\Master\program\Submittion\Intermediate\JHPS2012_sp.dta"
gen year=2012
* ageを作成
replace bmonth=bmonth+10
tostring byear bmonth, replace
gen bday=byear+bmonth+"15"
destring bday, replace
replace bday=bday-1000
gen age=floor((20120130-bday)/10000)
drop byear bmonth bday
export delimited "C:\Users\Ayaka Nakamura\Dropbox\materials\Works\Master\program\Submittion\Input\JHPS2012.csv", replace
}

** JHPS2013
{
* 変数名の変更
** 本人
import delimited "C:\Users\Ayaka Nakamura\Dropbox\materials\Works\Master\program\Submittion\OriginalData\JHPS2013.csv", clear 
rename (v1 v4 v5 v6 v7 v101 v102 v103 v184 ///
v191 v192 v193 v194 v197 v198 ///
v205 ///
v207 v208 v209 v210 v211 v212 ///
v214 v215 v216 v217) ///
(id marital sex byear bmonth head earnif earnmost workstatus ///
occ owner ind size employed regular ///
union ///
paymethod monthlypaid dailypaid hourlypaid yearlypaid bonus ///
workdaypermonth workhourperweek overworkperweek paidoverworkperweek)
* 世帯主ダミー作成
** 世帯主ですか
replace head=0 if head!=1
** 主たる生計維持者
replace earnmost=1 if head==1&earnif==2
replace earnmost=0 if earnmost!=1
* 使わない変数を落とす
drop earnif v*
save "C:\Users\Ayaka Nakamura\Dropbox\materials\Works\Master\program\Submittion\Intermediate\JHPS2013_pr.dta", replace

** 配偶者
import delimited "C:\Users\Ayaka Nakamura\Dropbox\materials\Works\Master\program\Submittion\OriginalData\JHPS2013.csv", clear 
rename (v1 v4  v12 v13 v14 v101 v102 v103 v449 ///
v456 v457 v458 v459 v462 v463 ///
v470 ///
v472 v473 v474 v475 v476 v477 ///
v479 v480 v481 v482) ///
(id marital sex byear bmonth head earnif earnmost workstatus ///
occ owner ind size employed regular ///
union ///
paymethod monthlypaid dailypaid hourlypaid yearlypaid bonus ///
workdaypermonth workhourperweek overworkperweek paidoverworkperweek)
* 続柄が配偶者のサンプルのみ残す
keep if marital==1
* 世帯主ダミー作成
* 世帯主ダミー作成
** 世帯主ですか
replace head=0 if head!=2
replace head=1 if head==2
** 主たる生計維持者
replace earnmost=1 if earnmost==2|head==1&earnif==2
replace earnmost=0 if earnmost!=1
* 使わない変数を落とす
drop earnif v*
* idを+10000
replace id=id+10000
save "C:\Users\Ayaka Nakamura\Dropbox\materials\Works\Master\program\Submittion\Intermediate\JHPS2013_sp.dta", replace

** 本人と配偶者サンプルをバインド
use "C:\Users\Ayaka Nakamura\Dropbox\materials\Works\Master\program\Submittion\Intermediate\JHPS2013_pr.dta", clear
append using "C:\Users\Ayaka Nakamura\Dropbox\materials\Works\Master\program\Submittion\Intermediate\JHPS2013_sp.dta"
gen year=2013
* ageを作成
replace bmonth=bmonth+10
tostring byear bmonth, replace
gen bday=byear+bmonth+"15"
destring bday, replace
replace bday=bday-1000
gen age=floor((20130130-bday)/10000)
drop byear bmonth bday
export delimited "C:\Users\Ayaka Nakamura\Dropbox\materials\Works\Master\program\Submittion\Input\JHPS2013.csv", replace
}

** JHPS2014
{
* 変数名の変更
** 本人
import delimited "C:\Users\Ayaka Nakamura\Dropbox\materials\Works\Master\program\Submittion\OriginalData\JHPS2014.csv", clear 
rename (v1 v4 v5 v6 v7 v101 v102 v103 v220 ///
v227 v228 v229 v230 v233 v234 ///
v242 ///
v244 v245 v246 v247 v248 v249 ///
v251 v252 v253 v254) ///
(id marital sex byear bmonth head earnif earnmost workstatus ///
occ owner ind size employed regular ///
union ///
paymethod monthlypaid dailypaid hourlypaid yearlypaid bonus ///
workdaypermonth workhourperweek overworkperweek paidoverworkperweek)
* 世帯主ダミー作成
** 世帯主ですか
replace head=0 if head!=1
** 主たる生計維持者
replace earnmost=1 if head==1&earnif==2
replace earnmost=0 if earnmost!=1
* 使わない変数を落とす
drop earnif v*
save "C:\Users\Ayaka Nakamura\Dropbox\materials\Works\Master\program\Submittion\Intermediate\JHPS2014_pr.dta", replace

** 配偶者
import delimited "C:\Users\Ayaka Nakamura\Dropbox\materials\Works\Master\program\Submittion\OriginalData\JHPS2014.csv", clear 
rename (v1 v4  v12 v13 v14 v101 v102 v103 v498 ///
v505 v506 v507 v508 v511 v512 ///
v520 ///
v522 v523 v524 v525 v526 v527 ///
v529 v530 v531 v532) ///
(id marital sex byear bmonth head earnif earnmost workstatus ///
occ owner ind size employed regular ///
union ///
paymethod monthlypaid dailypaid hourlypaid yearlypaid bonus ///
workdaypermonth workhourperweek overworkperweek paidoverworkperweek)
* 続柄が配偶者のサンプルのみ残す
keep if marital==1
* 世帯主ダミー作成
* 世帯主ダミー作成
** 世帯主ですか
replace head=0 if head!=2
replace head=1 if head==2
** 主たる生計維持者
replace earnmost=1 if earnmost==2|head==1&earnif==2
replace earnmost=0 if earnmost!=1
* 使わない変数を落とす
drop earnif v*
* idを+10000
replace id=id+10000
save "C:\Users\Ayaka Nakamura\Dropbox\materials\Works\Master\program\Submittion\Intermediate\JHPS2014_sp.dta", replace

** 本人と配偶者サンプルをバインド
use "C:\Users\Ayaka Nakamura\Dropbox\materials\Works\Master\program\Submittion\Intermediate\JHPS2014_pr.dta", clear
append using "C:\Users\Ayaka Nakamura\Dropbox\materials\Works\Master\program\Submittion\Intermediate\JHPS2014_sp.dta"
gen year=2014
* ageを作成
replace bmonth=bmonth+10
tostring byear bmonth, replace
gen bday=byear+bmonth+"15"
destring bday, replace
replace bday=bday-1000
gen age=floor((20140130-bday)/10000)
drop byear bmonth bday
export delimited "C:\Users\Ayaka Nakamura\Dropbox\materials\Works\Master\program\Submittion\Input\JHPS2014.csv", replace
}

** KHPS2004
{
* 変数名の変更
** 本人
import delimited "C:\Users\Ayaka Nakamura\Dropbox\materials\Works\Master\program\Submittion\OriginalData\KHPS2004.csv", clear 
rename (v1 v4 v5 v6 v7 v76 v106 v170 ///
v228 v215 v216 v217 v218 v219 ///
v238 v239 v240 ///
v244 v245 v246 v247 v248 v249 ///
v262 v263 v264) ///
(id marital sex byear bmonth earnmost edbg workstatus ///
occ owner ind size employed regular ///
empsinceyear empsincemonth union ///
paymethod monthlypaid dailypaid hourlypaid yearlypaid bonus ///
workdaypermonth workhourperweek overworkperweek)
*** 就業履歴データの変数名変更
**** schooling
for X in num 317/367 \ Y in num 18/68: ///
rename vX schY
**** searching
for X in num 368/418 \ Y in num 18/68: ///
rename vX seekY
**** temporal employee
for X in num 419/469 \ Y in num 18/68: ///
rename vX casY
**** regular employee
for X in num 470/520 \ Y in num 18/68: ///
rename vX regY
**** self employed
for X in num 521/571 \ Y in num 18/68: ///
rename vX selfY
**** 内職
for X in num 572/622 \ Y in num 18/68: ///
rename vX sideY
**** family worker
for X in num 623/673 \ Y in num 18/68: ///
rename vX fmwY
**** switching
for X in num 674/724 \ Y in num 18/68: ///
rename vX swY
** 主たる生計維持者
replace earnmost=0 if earnmost!=1
* 世帯主ダミー作成
** 世帯主ですか (*) only 主たる生計維持者 asked in this survey
gen head=earnmost
* 使わない変数を落とす
drop v*
* idを+20000
replace id=id+20000
save "C:\Users\Ayaka Nakamura\Dropbox\materials\Works\Master\program\Submittion\Intermediate\KHPS2004_pr.dta", replace

** 配偶者
import delimited "C:\Users\Ayaka Nakamura\Dropbox\materials\Works\Master\program\Submittion\OriginalData\KHPS2004.csv", clear 
rename (v1 v4 v76 v803 v867 ///
v925 v912 v913 v914 v915 v916 ///
v935 v936 v937 ///
v941 v942 v943 v944 v945 v946 ///
v959 v960 v961) ///
(id marital earnmost edbg workstatus ///
occ owner ind size employed regular ///
empsinceyear empsincemonth union ///
paymethod monthlypaid dailypaid hourlypaid yearlypaid bonus ///
workdaypermonth workhourperweek overworkperweek)
* 続柄が配偶者のサンプルのみ残す
keep if marital==1
* 続柄の変数名変更->配偶者の情報を抽出
rename (v13 v14 v15 v16 ///
v20 v21 v22 v23 ///
v27 v28 v29 v30 ///
v34 v35 v36 v37 ///
v41 v42 v43 v44 ///
v48 v49 v50 v51 ///
v55 v56 v57 v58 ///
v62 v63 v64 v65 ///
v69 v70 v71 v72) ///
(rel1no rel1sex rel1byear rel1bmonth ///
rel2no rel2sex rel2byear rel2bmonth ///
rel3no rel3sex rel3byear rel3bmonth ///
rel4no rel4sex rel4byear rel4bmonth ///
rel5no rel5sex rel5byear rel5bmonth ///
rel6no rel6sex rel6byear rel6bmonth ///
rel7no rel7sex rel7byear rel7bmonth ///
rel8no rel8sex rel8byear rel8bmonth ///
rel9no rel9sex rel9byear rel9bmonth)
** relation No. of spouse
gen relno=0
for num 1/9: replace relno=X+1 if relXno==1
** sex
gen sex=0
for num 1/9: replace sex=relXsex if relXno==1
** byear
gen byear=0
for num 1/9: replace byear=relXbyear if relXno==1
** bmonth
gen bmonth=0
for num 1/9: replace bmonth=relXbmonth if relXno==1
* 配偶者情報がないサンプルを落とす
drop if relno==0
*** 就業履歴データの変数名変更
**** schooling
for X in num 1014/1064 \ Y in num 18/68: ///
rename vX schY
**** searching
for X in num 1065/1115 \ Y in num 18/68: ///
rename vX seekY
**** temporal employee
for X in num 1116/1166 \ Y in num 18/68: ///
rename vX casY
**** regular employee
for X in num 1167/1217 \ Y in num 18/68: ///
rename vX regY
**** self employed
for X in num 1218/1268 \ Y in num 18/68: ///
rename vX selfY
**** 内職
for X in num 1269/1319 \ Y in num 18/68: ///
rename vX sideY
**** family worker
for X in num 1320/1370 \ Y in num 18/68: ///
rename vX fmwY
**** switching
for X in num 1371/1421 \ Y in num 18/68: ///
rename vX swY
** 主たる生計維持者
replace earnmost=100 if earnmost==relno
replace earnmost=0 if earnmost!=100
replace earnmost=1 if earnmost==100
* 世帯主ダミー作成
** 世帯主ですか (*) only 主たる生計維持者 asked in this survey
gen head=earnmost
* 使わない変数を落とす
drop v* rel*
* idを+30000
replace id=id+30000
save "C:\Users\Ayaka Nakamura\Dropbox\materials\Works\Master\program\Submittion\Intermediate\KHPS2004_sp.dta", replace

** 本人と配偶者サンプルをバインド
use "C:\Users\Ayaka Nakamura\Dropbox\materials\Works\Master\program\Submittion\Intermediate\KHPS2004_pr.dta", clear
append using "C:\Users\Ayaka Nakamura\Dropbox\materials\Works\Master\program\Submittion\Intermediate\KHPS2004_sp.dta"
gen year=2004
* ageを作成
replace bmonth=bmonth+10
tostring byear bmonth, replace
gen bday=byear+bmonth+"15"
destring bday, replace
replace bday=bday-1000
gen age=floor((20040130-bday)/10000)
drop byear bmonth bday
export delimited "C:\Users\Ayaka Nakamura\Dropbox\materials\Works\Master\program\Submittion\Input\KHPS2004.csv", replace
}

** KHPS2005
{
* 変数名の変更
** 本人
import delimited "C:\Users\Ayaka Nakamura\Dropbox\materials\Works\Master\program\Submittion\OriginalData\KHPS2005.csv", clear 
rename (v1 v4 v5 v6 v7 v76 v139 ///
v171 v159 v160 v161 v164 v165 ///
v183 ///
v185 v186 v187 v188 v189 v190 ///
v203 v204 v205) ///
(id marital sex byear bmonth earnmost workstatus ///
occ owner ind size employed regular ///
union ///
paymethod monthlypaid dailypaid hourlypaid yearlypaid bonus ///
workdaypermonth workhourperweek overworkperweek)
** 主たる生計維持者
replace earnmost=0 if earnmost!=1
* 世帯主ダミー作成
** 世帯主ですか (*) only 主たる生計維持者 asked in this survey
gen head=earnmost
* 使わない変数を落とす
drop v*
* idを+20000
replace id=id+20000
save "C:\Users\Ayaka Nakamura\Dropbox\materials\Works\Master\program\Submittion\Intermediate\KHPS2005_pr.dta", replace

** 配偶者
import delimited "C:\Users\Ayaka Nakamura\Dropbox\materials\Works\Master\program\Submittion\OriginalData\KHPS2005.csv", clear 
rename (v1 v4 v76 v392 ///
v424 v412 v413 v414 v417 v418 ///
v436 ///
v438 v439 v440 v441 v442 v443 ///
v456 v457 v458) ///
(id marital earnmost workstatus ///
occ owner ind size employed regular ///
union ///
paymethod monthlypaid dailypaid hourlypaid yearlypaid bonus ///
workdaypermonth workhourperweek overworkperweek)
* 続柄が配偶者のサンプルのみ残す
keep if marital==1
* 続柄の変数名変更->配偶者の情報を抽出
rename (v13 v14 v15 v16 ///
v20 v21 v22 v23 ///
v27 v28 v29 v30 ///
v34 v35 v36 v37 ///
v41 v42 v43 v44 ///
v48 v49 v50 v51 ///
v55 v56 v57 v58 ///
v62 v63 v64 v65 ///
v69 v70 v71 v72) ///
(rel1no rel1sex rel1byear rel1bmonth ///
rel2no rel2sex rel2byear rel2bmonth ///
rel3no rel3sex rel3byear rel3bmonth ///
rel4no rel4sex rel4byear rel4bmonth ///
rel5no rel5sex rel5byear rel5bmonth ///
rel6no rel6sex rel6byear rel6bmonth ///
rel7no rel7sex rel7byear rel7bmonth ///
rel8no rel8sex rel8byear rel8bmonth ///
rel9no rel9sex rel9byear rel9bmonth)
** relation No. of spouse
gen relno=0
for num 1/9: replace relno=X+1 if relXno==1
** sex
gen sex=0
for num 1/9: replace sex=relXsex if relXno==1
** byear
gen byear=0
for num 1/9: replace byear=relXbyear if relXno==1
** bmonth
gen bmonth=0
for num 1/9: replace bmonth=relXbmonth if relXno==1
* 配偶者情報がないサンプルを落とす
drop if relno==0
** 主たる生計維持者
replace earnmost=100 if earnmost==relno
replace earnmost=0 if earnmost!=100
replace earnmost=1 if earnmost==100
* 世帯主ダミー作成
** 世帯主ですか (*) only 主たる生計維持者 asked in this survey
gen head=earnmost
* 使わない変数を落とす
drop v* rel*
* idを+30000
replace id=id+30000
save "C:\Users\Ayaka Nakamura\Dropbox\materials\Works\Master\program\Submittion\Intermediate\KHPS2005_sp.dta", replace

** 本人と配偶者サンプルをバインド
use "C:\Users\Ayaka Nakamura\Dropbox\materials\Works\Master\program\Submittion\Intermediate\KHPS2005_pr.dta", clear
append using "C:\Users\Ayaka Nakamura\Dropbox\materials\Works\Master\program\Submittion\Intermediate\KHPS2005_sp.dta"
gen year=2005
* ageを作成
replace bmonth=bmonth+10
tostring byear bmonth, replace
gen bday=byear+bmonth+"15"
destring bday, replace
replace bday=bday-1000
gen age=floor((20050130-bday)/10000)
drop byear bmonth bday
export delimited "C:\Users\Ayaka Nakamura\Dropbox\materials\Works\Master\program\Submittion\Input\KHPS2005.csv", replace
}

** KHPS2006
{
* 変数名の変更
** 本人
import delimited "C:\Users\Ayaka Nakamura\Dropbox\materials\Works\Master\program\Submittion\OriginalData\KHPS2006.csv", clear 
rename (v1 v4 v5 v6 v7 v76 v132 ///
v152 v153 v154 v155 v158 v159 ///
v169 ///
v171 v172 v173 v174 v175 v176 ///
v189 v190 v191) ///
(id marital sex byear bmonth earnmost workstatus ///
occ owner ind size employed regular ///
union ///
paymethod monthlypaid dailypaid hourlypaid yearlypaid bonus ///
workdaypermonth workhourperweek overworkperweek)
** 主たる生計維持者
replace earnmost=0 if earnmost!=1
* 世帯主ダミー作成
** 世帯主ですか (*) only 主たる生計維持者 asked in this survey
gen head=earnmost
* 使わない変数を落とす
drop v*
* idを+20000
replace id=id+20000
save "C:\Users\Ayaka Nakamura\Dropbox\materials\Works\Master\program\Submittion\Intermediate\KHPS2006_pr.dta", replace

** 配偶者
import delimited "C:\Users\Ayaka Nakamura\Dropbox\materials\Works\Master\program\Submittion\OriginalData\KHPS2006.csv", clear 
rename (v1 v4 v76 v348 ///
v368 v369 v370 v371 v374 v375 ///
v385 ///
v387 v388 v389 v390 v391 v392 ///
v405 v406 v407) ///
(id marital earnmost workstatus ///
occ owner ind size employed regular ///
union ///
paymethod monthlypaid dailypaid hourlypaid yearlypaid bonus ///
workdaypermonth workhourperweek overworkperweek)
* 続柄が配偶者のサンプルのみ残す
keep if marital==1
* 続柄の変数名変更->配偶者の情報を抽出
rename (v13 v14 v15 v16 ///
v20 v21 v22 v23 ///
v27 v28 v29 v30 ///
v34 v35 v36 v37 ///
v41 v42 v43 v44 ///
v48 v49 v50 v51 ///
v55 v56 v57 v58 ///
v62 v63 v64 v65 ///
v69 v70 v71 v72) ///
(rel1no rel1sex rel1byear rel1bmonth ///
rel2no rel2sex rel2byear rel2bmonth ///
rel3no rel3sex rel3byear rel3bmonth ///
rel4no rel4sex rel4byear rel4bmonth ///
rel5no rel5sex rel5byear rel5bmonth ///
rel6no rel6sex rel6byear rel6bmonth ///
rel7no rel7sex rel7byear rel7bmonth ///
rel8no rel8sex rel8byear rel8bmonth ///
rel9no rel9sex rel9byear rel9bmonth)
** relation No. of spouse
gen relno=0
for num 1/9: replace relno=X+1 if relXno==1
** sex
gen sex=0
for num 1/9: replace sex=relXsex if relXno==1
** byear
gen byear=0
for num 1/9: replace byear=relXbyear if relXno==1
** bmonth
gen bmonth=0
for num 1/9: replace bmonth=relXbmonth if relXno==1
* 配偶者情報がないサンプルを落とす
drop if relno==0
** 主たる生計維持者
replace earnmost=100 if earnmost==relno
replace earnmost=0 if earnmost!=100
replace earnmost=1 if earnmost==100
* 世帯主ダミー作成
** 世帯主ですか (*) only 主たる生計維持者 asked in this survey
gen head=earnmost
* 使わない変数を落とす
drop v* rel*
* idを+30000
replace id=id+30000
save "C:\Users\Ayaka Nakamura\Dropbox\materials\Works\Master\program\Submittion\Intermediate\KHPS2006_sp.dta", replace

** 本人と配偶者サンプルをバインド
use "C:\Users\Ayaka Nakamura\Dropbox\materials\Works\Master\program\Submittion\Intermediate\KHPS2006_pr.dta", clear
append using "C:\Users\Ayaka Nakamura\Dropbox\materials\Works\Master\program\Submittion\Intermediate\KHPS2006_sp.dta"
gen year=2006
* ageを作成
replace bmonth=bmonth+10
tostring byear bmonth, replace
gen bday=byear+bmonth+"15"
destring bday, replace
replace bday=bday-1000
gen age=floor((20060130-bday)/10000)
drop byear bmonth bday
export delimited "C:\Users\Ayaka Nakamura\Dropbox\materials\Works\Master\program\Submittion\Input\KHPS2006.csv", replace
}

** KHPS2007
{
* 変数名の変更
** 本人
import delimited "C:\Users\Ayaka Nakamura\Dropbox\materials\Works\Master\program\Submittion\OriginalData\KHPS2007.csv", clear 
rename (v1 v4 v5 v6 v7 v76 v138 ///
v152 v153 v154 v155 v158 v159 ///
v169 ///
v171 v172 v173 v174 v175 v176 ///
v189 v190 v191) ///
(id marital sex byear bmonth earnmost workstatus ///
occ owner ind size employed regular ///
union ///
paymethod monthlypaid dailypaid hourlypaid yearlypaid bonus ///
workdaypermonth workhourperweek overworkperweek)
** 主たる生計維持者
replace earnmost=0 if earnmost!=1
* 世帯主ダミー作成
** 世帯主ですか (*) only 主たる生計維持者 asked in this survey
gen head=earnmost
* 使わない変数を落とす
drop v*
* idを+20000
replace id=id+20000
save "C:\Users\Ayaka Nakamura\Dropbox\materials\Works\Master\program\Submittion\Intermediate\KHPS2007_pr.dta", replace

** 配偶者
import delimited "C:\Users\Ayaka Nakamura\Dropbox\materials\Works\Master\program\Submittion\OriginalData\KHPS2007.csv", clear 
rename (v1 v4 v76 v348 ///
v368 v369 v370 v371 v374 v375 ///
v385 ///
v387 v388 v389 v390 v391 v392 ///
v405 v406 v407) ///
(id marital earnmost workstatus ///
occ owner ind size employed regular ///
union ///
paymethod monthlypaid dailypaid hourlypaid yearlypaid bonus ///
workdaypermonth workhourperweek overworkperweek)
* 続柄が配偶者のサンプルのみ残す
keep if marital==1
* 続柄の変数名変更->配偶者の情報を抽出
rename (v13 v14 v15 v16 ///
v20 v21 v22 v23 ///
v27 v28 v29 v30 ///
v34 v35 v36 v37 ///
v41 v42 v43 v44 ///
v48 v49 v50 v51 ///
v55 v56 v57 v58 ///
v62 v63 v64 v65 ///
v69 v70 v71 v72) ///
(rel1no rel1sex rel1byear rel1bmonth ///
rel2no rel2sex rel2byear rel2bmonth ///
rel3no rel3sex rel3byear rel3bmonth ///
rel4no rel4sex rel4byear rel4bmonth ///
rel5no rel5sex rel5byear rel5bmonth ///
rel6no rel6sex rel6byear rel6bmonth ///
rel7no rel7sex rel7byear rel7bmonth ///
rel8no rel8sex rel8byear rel8bmonth ///
rel9no rel9sex rel9byear rel9bmonth)
** relation No. of spouse
gen relno=0
for num 1/9: replace relno=X+1 if relXno==1
** sex
gen sex=0
for num 1/9: replace sex=relXsex if relXno==1
** byear
gen byear=0
for num 1/9: replace byear=relXbyear if relXno==1
** bmonth
gen bmonth=0
for num 1/9: replace bmonth=relXbmonth if relXno==1
* 配偶者情報がないサンプルを落とす
drop if relno==0
** 主たる生計維持者
replace earnmost=100 if earnmost==relno
replace earnmost=0 if earnmost!=100
replace earnmost=1 if earnmost==100
* 世帯主ダミー作成
** 世帯主ですか (*) only 主たる生計維持者 asked in this survey
gen head=earnmost
* 使わない変数を落とす
drop v* rel*
* idを+30000
replace id=id+30000
save "C:\Users\Ayaka Nakamura\Dropbox\materials\Works\Master\program\Submittion\Intermediate\KHPS2007_sp.dta", replace

** 本人と配偶者サンプルをバインド
use "C:\Users\Ayaka Nakamura\Dropbox\materials\Works\Master\program\Submittion\Intermediate\KHPS2007_pr.dta", clear
append using "C:\Users\Ayaka Nakamura\Dropbox\materials\Works\Master\program\Submittion\Intermediate\KHPS2007_sp.dta"
gen year=2007
* ageを作成
replace bmonth=bmonth+10
tostring byear bmonth, replace
gen bday=byear+bmonth+"15"
destring bday, replace
replace bday=bday-1000
gen age=floor((20070130-bday)/10000)
drop byear bmonth bday
export delimited "C:\Users\Ayaka Nakamura\Dropbox\materials\Works\Master\program\Submittion\Input\KHPS2007.csv", replace
}

}

** 学歴と就業履歴をサンプルにマージする
{
** idと学歴データを抽出
{
*** JHPSの学歴
import delimited "C:\Users\Ayaka Nakamura\Dropbox\materials\Works\Master\program\Submittion\JHPS2009.csv", replace
replace schooling=0 if edbg==9
mvdecode schooling, mv(0)
keep id schooling
save "C:\Users\Ayaka Nakamura\Dropbox\materials\Works\Master\program\Submittion\SchoolingJHPS.dta", replace
*** KHPSの学歴
**** old cohort
import delimited "C:\Users\Ayaka Nakamura\Dropbox\materials\Works\Master\program\Submittion\KHPS2004.csv", replace
replace schooling=0 if edbg==9
mvdecode schooling, mv(0)
keep id schooling
**** new cohort 2007
**** new cohort 2012
*** bind
append using JHPS_schooling.dta
sort id
save "C:\Users\Ayaka Nakamura\Dropbox\materials\Works\Master\program\Submittion\Schooling.dta", replace
 }
 
 ** idと就業履歴を抽出
{
** JHPS就業履歴
import delimited "C:\Users\Ayaka Nakamura\Dropbox\materials\Works\Master\program\Submittion\JHPS2010.csv", replace
for num 18/70: gen weX=0
for num 18/70: replace casX=0 if casX==9
for num 18/70: replace regX=0 if regX==9
for num 18/70: replace selfX=0 if selfX==9
for num 18/70: replace sideX=0 if sideX==9
for num 18/70: replace fmwX=0 if fmwX==9
for num 18/70: replace weX=1 if casX+regX+selfX+sideX+fmwX!=0
egen workexp2010=rowtotal(we18-we70)
keep id workexp2010
sort id
save "C:\Users\Ayaka Nakamura\Dropbox\materials\Works\Master\program\Submittion\WorkexpJHPS.dta", replace
** KHPS就業履歴
**** old cohort
import delimited "C:\Users\Ayaka Nakamura\Dropbox\materials\Works\Master\program\Submittion\KHPS2004.csv", replace
for num 18/70: gen weX=0
for num 18/70: replace casX=0 if casX==9
for num 18/70: replace regX=0 if regX==9
for num 18/70: replace selfX=0 if selfX==9
for num 18/70: replace sideX=0 if sideX==9
for num 18/70: replace fmwX=0 if fmwX==9
for num 18/70: replace weX=1 if casX+regX+selfX+sideX+fmwX!=0
egen workexp2004=rowtotal(we18-we70)
keep id workexp2004
sort id
save "C:\Users\Ayaka Nakamura\Dropbox\materials\Works\Master\program\Submittion\WorkexpKHPS.dta", replace
**** new cohort 2007
**** new cohort 2012
}
}
