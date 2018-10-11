clear
set more off
 cd "C:\Users\AyakaNakamura\Dropbox\materials\Works\Master\program\Submittion"
 adopath + "C:\Users\AyakaNakamura\Dropbox\materials\Works\Master\program\Submittion"
 adopath + "C:\Users\AyakaNakamura\Dropbox\materials\Works\Master\program\Submittion\OriginalData"
 adopath + "C:\Users\AyakaNakamura\Dropbox\materials\Works\Master\program\Submittion\Intermediate"
 adopath + "C:\Users\AyakaNakamura\Dropbox\materials\Works\Master\program\Submittion\Output"
 adopath + "C:\Users\AyakaNakamura\Dropbox\materials\Works\Master\program\Submittion\Intput"
 adopath + "C:\Users\AyakaNakamura\Dropbox\materials\Works\Master\program\Submittion\coefplot"

* Data Correction
** 1. 変数名を付ける
** 2. 配偶者データを抽出して元データにバインド
** 3. cohort dummyデータを作成
** 8. データクリーニング/欠損値の修正・賃金データ作成・失業率のマージ
** 4. 全ての年で共通する変数のみバインドし1つのデータセットにする
** 5. 学歴と勤続履歴データを抽出
** 6. 全てのサンプルに学歴と勤続履歴データをマージ
** 7. データに入った年のサンプルにのみ労働経験年数を作成
** 9. テニュア変数の作成
** 10. サンプルの制限

/* idについて
** JHPSのid=元のid
** JHPSの配偶者のid=元のid+10000
** KHPSのid=元のid+20000
** KHPSの配偶者(含new_cohort)のid=元のid+30000
** KHPSのnew_cohortのid=元のid+40000
*/
** cohort dummy: JHPS2009=9, KHPS2004=4, KHPS2007=7, KHPS2012=12

log using "C:\Users\AyakaNakamura\Dropbox\materials\Works\Master\program\Submittion\Output\DataCorrection.smcl", replace

* 1--4
** new cohort: データ整理+学歴勤務履歴データの抽出
{
** JHPS2009
{
* 変数名の変更
** 本人
import delimited "C:\Users\AyakaNakamura\Dropbox\materials\Works\Master\program\Submittion\OriginalData\JHPS2009.csv", clear 
rename (v1 v4 v5 v6 v7 v101 v102 v103 v142 v146 ///
v153 v154 v155 v156 v159 v160 ///
v167 v168 v169 ///
v173 v174 v175 v176 v177 v178 ///
v180 v181 v182) ///
(id marital sex byear bmonth head earnif earnmost edbg workstatus ///
occ owner ind size employed regular ///
empsinceyear empsincemonth union ///
paymethod monthlypaid dailypaid hourlypaid yearlypaid bonus ///
workdaypermonth workhourperweek overworkperweek)
* 世帯主ダミー作成
** 世帯主ですか
replace head=0 if head!=1
** 主たる生計維持者
replace earnmost=1 if head==1&earnif==2
replace earnmost=0 if earnmost!=1
* switch dummy
gen switch=0
* 使わない変数を落とす
drop earnif v*
save "C:\Users\AyakaNakamura\Dropbox\materials\Works\Master\program\Submittion\Intermediate\JHPS2009_pr.dta", replace

** 配偶者
import delimited "C:\Users\AyakaNakamura\Dropbox\materials\Works\Master\program\Submittion\OriginalData\JHPS2009.csv", clear 
rename (v1 v4  v12 v13 v14 v101 v102 v103 v274 v279 ///
v286 v287 v288 v289 v292 v293 ///
v300 v301 v302 ///
v306 v307 v308 v309 v310 v311 ///
v313 v314 v315) ///
(id marital sex byear bmonth head earnif earnmost edbg workstatus ///
occ owner ind size employed regular ///
empsinceyear empsincemonth union ///
paymethod monthlypaid dailypaid hourlypaid yearlypaid bonus ///
workdaypermonth workhourperweek overworkperweek)
* 続柄が配偶者のサンプルのみ残す
keep if marital==1
* 世帯主ダミー作成
** 世帯主ですか
replace head=0 if head!=2
replace head=1 if head==2
** 主たる生計維持者
replace earnmost=1 if earnmost==2|head==1&earnif==2
replace earnmost=0 if earnmost!=1
* switch dummy
gen switch=0
* 使わない変数を落とす
drop earnif v*
* idを+10000
replace id=id+10000
save "C:\Users\AyakaNakamura\Dropbox\materials\Works\Master\program\Submittion\Intermediate\JHPS2009_sp.dta", replace

** 本人と配偶者サンプルをバインド
use "C:\Users\AyakaNakamura\Dropbox\materials\Works\Master\program\Submittion\Intermediate\JHPS2009_pr.dta", clear
append using "C:\Users\AyakaNakamura\Dropbox\materials\Works\Master\program\Submittion\Intermediate\JHPS2009_sp.dta"
gen year=2009
* ageを作成
mvdecode byear, mv(9999) /* 欠損値を作成 */
mvdecode bmonth, mv(99)
replace byear=2020 if byear==. /* 欠損値をあり得ない値に変更 */
replace bmonth=0 if bmonth==.
replace bmonth=bmonth+10 /* 誕生月を+10 */
tostring byear bmonth, replace /* 誕生年月を文字列に変更 */
gen bday=byear+bmonth+"15" /* 生年月日の文字列を作成(誕生日は15日と仮定) */
destring bday, replace /* 文字列を数字に戻す */
replace bday=bday-1000 /* 誕生月を+10した分を戻す */
gen age=round((20090130-bday)/10000) /* 調査日時点での年齢を計算 */
replace age=. if age<0 /* 欠損値だったサンプルの年齢を欠損値に */
drop byear bmonth bday
* emptenureを作成
for num 8888 9999: mvdecode empsinceyear, mv(X)
for num 88 99: mvdecode empsincemonth, mv(X)
replace empsinceyear=2020 if empsinceyear==.
replace empsincemonth=0 if empsincemonth==.
replace empsincemonth=empsincemonth+10
tostring empsinceyear empsincemonth, replace
gen eday=empsinceyear+empsincemonth+"15"
destring eday, replace
replace eday=eday-1000
gen emptenure=(20090130-eday)/10000
replace emptenure=. if emptenure<0
drop empsinceyear empsincemonth eday
save "C:\Users\AyakaNakamura\Dropbox\materials\Works\Master\program\Submittion\Intermediate\JHPS2009.dta", replace

* cohort dummy
keep id
gen cohort=9
save "C:\Users\AyakaNakamura\Dropbox\materials\Works\Master\program\Submittion\Intermediate\Cohort.dta", replace
}

** JHPS2010
{
* 変数名の変更
** 本人
import delimited "C:\Users\AyakaNakamura\Dropbox\materials\Works\Master\program\Submittion\OriginalData\JHPS2010.csv", clear 
rename (v1 v4 v5 v6 v7 v101 v102 v103 v175 ///
v182 v183 v184 v185 v188 v189 ///
v231 v196 ///
v198 v199 v200 v201 v202 v203 ///
v205 v206 v207) ///
(id marital sex byear bmonth head earnif earnmost workstatus ///
occ owner ind size employed regular ///
switch union ///
paymethod monthlypaid dailypaid hourlypaid yearlypaid bonus ///
workdaypermonth workhourperweek overworkperweek)
*** 就業履歴データの変数名変更
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
* 世帯主ダミー作成
** 世帯主ですか
replace head=0 if head!=1
** 主たる生計維持者
replace earnmost=1 if head==1&earnif==2
replace earnmost=0 if earnmost!=1
* 使わない変数を落とす
drop earnif v*
save "C:\Users\AyakaNakamura\Dropbox\materials\Works\Master\program\Submittion\Intermediate\JHPS2010_pr.dta", replace

** 配偶者
import delimited "C:\Users\AyakaNakamura\Dropbox\materials\Works\Master\program\Submittion\OriginalData\JHPS2010.csv", clear 
rename (v1 v4  v12 v13 v14 v101 v102 v103 v796 ///
v803 v804 v805 v806 v809 v810 ///
v852 v817 ///
v819 v820 v821 v822 v823 v824 ///
v826 v827 v828) ///
(id marital sex byear bmonth head earnif earnmost workstatus ///
occ owner ind size employed regular ///
switch union ///
paymethod monthlypaid dailypaid hourlypaid yearlypaid bonus ///
workdaypermonth workhourperweek overworkperweek)
* 続柄が配偶者のサンプルのみ残す
keep if marital==1
*** 就業履歴データの変数名変更
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
save "C:\Users\AyakaNakamura\Dropbox\materials\Works\Master\program\Submittion\Intermediate\JHPS2010_sp.dta", replace

** 本人と配偶者サンプルをバインド
use "C:\Users\AyakaNakamura\Dropbox\materials\Works\Master\program\Submittion\Intermediate\JHPS2010_pr.dta", clear
append using "C:\Users\AyakaNakamura\Dropbox\materials\Works\Master\program\Submittion\Intermediate\JHPS2010_sp.dta"
gen year=2010
* ageを作成
mvdecode byear, mv(9999)
mvdecode bmonth, mv(99)
replace byear=2020 if byear==.
replace bmonth=0 if bmonth==.
replace bmonth=bmonth+10
tostring byear bmonth, replace
gen bday=byear+bmonth+"15"
destring bday, replace
replace bday=bday-1000
gen age=round((20100130-bday)/10000)
replace age=. if age<0
drop byear bmonth bday
save "C:\Users\AyakaNakamura\Dropbox\materials\Works\Master\program\Submittion\Intermediate\JHPS2010.dta", replace

* cohort dummy
keep id
gen cohort=9
append using "C:\Users\AyakaNakamura\Dropbox\materials\Works\Master\program\Submittion\Intermediate\Cohort.dta"
duplicates drop id, force
save "C:\Users\AyakaNakamura\Dropbox\materials\Works\Master\program\Submittion\Intermediate\Cohort.dta", replace
}

** JHPS2011
{
* 変数名の変更
** 本人
import delimited "C:\Users\AyakaNakamura\Dropbox\materials\Works\Master\program\Submittion\OriginalData\JHPS2011.csv", clear 
rename (v1 v4 v5 v6 v7 v101 v102 v103 v169 ///
v176 v177 v178 v179 v182 v183 ///
v219 v190 ///
v192 v193 v194 v195 v196 v197 ///
v199 v200 v201) ///
(id marital sex byear bmonth head earnif earnmost workstatus ///
occ owner ind size employed regular ///
switch union ///
paymethod monthlypaid dailypaid hourlypaid yearlypaid bonus ///
workdaypermonth workhourperweek overworkperweek)
* 世帯主ダミー作成
** 世帯主ですか
replace head=0 if head!=1
** 主たる生計維持者
replace earnmost=1 if head==1&earnif==2
replace earnmost=0 if earnmost!=1
* 使わない変数を落とす
drop earnif v*
save "C:\Users\AyakaNakamura\Dropbox\materials\Works\Master\program\Submittion\Intermediate\JHPS2011_pr.dta", replace

** 配偶者
import delimited "C:\Users\AyakaNakamura\Dropbox\materials\Works\Master\program\Submittion\OriginalData\JHPS2011.csv", clear 
rename (v1 v4  v12 v13 v14 v101 v102 v103 v382 ///
v389 v390 v391 v392 v395 v396 ///
v432 v403 ///
v405 v406 v407 v408 v409 v410 ///
v412 v413 v414) ///
(id marital sex byear bmonth head earnif earnmost workstatus ///
occ owner ind size employed regular ///
switch union ///
paymethod monthlypaid dailypaid hourlypaid yearlypaid bonus ///
workdaypermonth workhourperweek overworkperweek)
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
save "C:\Users\AyakaNakamura\Dropbox\materials\Works\Master\program\Submittion\Intermediate\JHPS2011_sp.dta", replace

** 本人と配偶者サンプルをバインド
use "C:\Users\AyakaNakamura\Dropbox\materials\Works\Master\program\Submittion\Intermediate\JHPS2011_pr.dta", clear
append using "C:\Users\AyakaNakamura\Dropbox\materials\Works\Master\program\Submittion\Intermediate\JHPS2011_sp.dta"
gen year=2011
* ageを作成
mvdecode byear, mv(9999)
mvdecode bmonth, mv(99)
replace byear=2020 if byear==.
replace bmonth=0 if bmonth==.
replace bmonth=bmonth+10
tostring byear bmonth, replace
gen bday=byear+bmonth+"15"
destring bday, replace
replace bday=bday-1000
gen age=round((20110130-bday)/10000)
replace age=. if age<0
drop byear bmonth bday
save "C:\Users\AyakaNakamura\Dropbox\materials\Works\Master\program\Submittion\Intermediate\JHPS2011.dta", replace

* cohort dummy
keep id
gen cohort=9
append using "C:\Users\AyakaNakamura\Dropbox\materials\Works\Master\program\Submittion\Intermediate\Cohort.dta"
duplicates drop id, force
save "C:\Users\AyakaNakamura\Dropbox\materials\Works\Master\program\Submittion\Intermediate\Cohort.dta", replace
}

** JHPS2012
{
* 変数名の変更
** 本人
import delimited "C:\Users\AyakaNakamura\Dropbox\materials\Works\Master\program\Submittion\OriginalData\JHPS2012.csv", clear 
rename (v1 v4 v5 v6 v7 v101 v102 v103 v190 ///
v197 v198 v199 v200 v203 v204 ///
v240 v211 ///
v213 v214 v215 v216 v217 v218 ///
v220 v221 v222) ///
(id marital sex byear bmonth head earnif earnmost workstatus ///
occ owner ind size employed regular ///
switch union ///
paymethod monthlypaid dailypaid hourlypaid yearlypaid bonus ///
workdaypermonth workhourperweek overworkperweek)
* 世帯主ダミー作成
** 世帯主ですか
replace head=0 if head!=1
** 主たる生計維持者
replace earnmost=1 if head==1&earnif==2
replace earnmost=0 if earnmost!=1
* 使わない変数を落とす
drop earnif v*
save "C:\Users\AyakaNakamura\Dropbox\materials\Works\Master\program\Submittion\Intermediate\JHPS2012_pr.dta", replace

** 配偶者
import delimited "C:\Users\AyakaNakamura\Dropbox\materials\Works\Master\program\Submittion\OriginalData\JHPS2012.csv", clear 
rename (v1 v4  v12 v13 v14 v101 v102 v103 v420 ///
v427 v428 v429 v430 v433 v434 ///
v470 v441 ///
v443 v444 v445 v446 v447 v448 ///
v450 v451 v452) ///
(id marital sex byear bmonth head earnif earnmost workstatus ///
occ owner ind size employed regular ///
switch union ///
paymethod monthlypaid dailypaid hourlypaid yearlypaid bonus ///
workdaypermonth workhourperweek overworkperweek)
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
save "C:\Users\AyakaNakamura\Dropbox\materials\Works\Master\program\Submittion\Intermediate\JHPS2012_sp.dta", replace

** 本人と配偶者サンプルをバインド
use "C:\Users\AyakaNakamura\Dropbox\materials\Works\Master\program\Submittion\Intermediate\JHPS2012_pr.dta", clear
append using "C:\Users\AyakaNakamura\Dropbox\materials\Works\Master\program\Submittion\Intermediate\JHPS2012_sp.dta"
gen year=2012
* ageを作成
mvdecode byear, mv(9999)
mvdecode bmonth, mv(99)
replace byear=2020 if byear==.
replace bmonth=0 if bmonth==.
replace bmonth=bmonth+10
tostring byear bmonth, replace
gen bday=byear+bmonth+"15"
destring bday, replace
replace bday=bday-1000
gen age=round((20120130-bday)/10000)
replace age=. if age<0
drop byear bmonth bday
save "C:\Users\AyakaNakamura\Dropbox\materials\Works\Master\program\Submittion\Intermediate\JHPS2012.dta", replace

* cohort dummy
keep id
gen cohort=9
append using "C:\Users\AyakaNakamura\Dropbox\materials\Works\Master\program\Submittion\Intermediate\Cohort.dta"
duplicates drop id, force
save "C:\Users\AyakaNakamura\Dropbox\materials\Works\Master\program\Submittion\Intermediate\Cohort.dta", replace
}

** JHPS2013
{
* 変数名の変更
** 本人
import delimited "C:\Users\AyakaNakamura\Dropbox\materials\Works\Master\program\Submittion\OriginalData\JHPS2013.csv", clear 
rename (v1 v4 v5 v6 v7 v101 v102 v103 v184 ///
v191 v192 v193 v194 v197 v198 ///
v234 v205 ///
v207 v208 v209 v210 v211 v212 ///
v214 v215 v216) ///
(id marital sex byear bmonth head earnif earnmost workstatus ///
occ owner ind size employed regular ///
switch union ///
paymethod monthlypaid dailypaid hourlypaid yearlypaid bonus ///
workdaypermonth workhourperweek overworkperweek)
* 世帯主ダミー作成
** 世帯主ですか
replace head=0 if head!=1
** 主たる生計維持者
replace earnmost=1 if head==1&earnif==2
replace earnmost=0 if earnmost!=1
* 使わない変数を落とす
drop earnif v*
save "C:\Users\AyakaNakamura\Dropbox\materials\Works\Master\program\Submittion\Intermediate\JHPS2013_pr.dta", replace

** 配偶者
import delimited "C:\Users\AyakaNakamura\Dropbox\materials\Works\Master\program\Submittion\OriginalData\JHPS2013.csv", clear 
rename (v1 v4  v12 v13 v14 v101 v102 v103 v449 ///
v456 v457 v458 v459 v462 v463 ///
v499 v470 ///
v472 v473 v474 v475 v476 v477 ///
v479 v480 v481) ///
(id marital sex byear bmonth head earnif earnmost workstatus ///
occ owner ind size employed regular ///
switch union ///
paymethod monthlypaid dailypaid hourlypaid yearlypaid bonus ///
workdaypermonth workhourperweek overworkperweek)
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
save "C:\Users\AyakaNakamura\Dropbox\materials\Works\Master\program\Submittion\Intermediate\JHPS2013_sp.dta", replace

** 本人と配偶者サンプルをバインド
use "C:\Users\AyakaNakamura\Dropbox\materials\Works\Master\program\Submittion\Intermediate\JHPS2013_pr.dta", clear
append using "C:\Users\AyakaNakamura\Dropbox\materials\Works\Master\program\Submittion\Intermediate\JHPS2013_sp.dta"
gen year=2013
* ageを作成
mvdecode byear, mv(9999)
mvdecode bmonth, mv(99)
replace byear=2020 if byear==.
replace bmonth=0 if bmonth==. 
replace bmonth=bmonth+10
tostring byear bmonth, replace
gen bday=byear+bmonth+"15"
destring bday, replace
replace bday=bday-1000
gen age=round((20130130-bday)/10000)
replace age=. if age<0
drop byear bmonth bday
save "C:\Users\AyakaNakamura\Dropbox\materials\Works\Master\program\Submittion\Intermediate\JHPS2013.dta", replace

* cohort dummy
keep id
gen cohort=9
append using "C:\Users\AyakaNakamura\Dropbox\materials\Works\Master\program\Submittion\Intermediate\Cohort.dta"
duplicates drop id, force
save "C:\Users\AyakaNakamura\Dropbox\materials\Works\Master\program\Submittion\Intermediate\Cohort.dta", replace
}

** JHPS2014
{
* 変数名の変更
** 本人
import delimited "C:\Users\AyakaNakamura\Dropbox\materials\Works\Master\program\Submittion\OriginalData\JHPS2014.csv", clear 
rename (v1 v4 v5 v6 v7 v101 v102 v103 v220 ///
v227 v228 v229 v230 v233 v234 ///
v265 v242 ///
v244 v245 v246 v247 v248 v249 ///
v251 v252 v253) ///
(id marital sex byear bmonth head earnif earnmost workstatus ///
occ owner ind size employed regular ///
switch union ///
paymethod monthlypaid dailypaid hourlypaid yearlypaid bonus ///
workdaypermonth workhourperweek overworkperweek)
* 世帯主ダミー作成
** 世帯主ですか
replace head=0 if head!=1
** 主たる生計維持者
replace earnmost=1 if head==1&earnif==2
replace earnmost=0 if earnmost!=1
* 使わない変数を落とす
drop earnif v*
save "C:\Users\AyakaNakamura\Dropbox\materials\Works\Master\program\Submittion\Intermediate\JHPS2014_pr.dta", replace

** 配偶者
import delimited "C:\Users\AyakaNakamura\Dropbox\materials\Works\Master\program\Submittion\OriginalData\JHPS2014.csv", clear 
rename (v1 v4  v12 v13 v14 v101 v102 v103 v498 ///
v505 v506 v507 v508 v511 v512 ///
v543 v520 ///
v522 v523 v524 v525 v526 v527 ///
v529 v530 v531) ///
(id marital sex byear bmonth head earnif earnmost workstatus ///
occ owner ind size employed regular ///
switch union ///
paymethod monthlypaid dailypaid hourlypaid yearlypaid bonus ///
workdaypermonth workhourperweek overworkperweek)
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
save "C:\Users\AyakaNakamura\Dropbox\materials\Works\Master\program\Submittion\Intermediate\JHPS2014_sp.dta", replace

** 本人と配偶者サンプルをバインド
use "C:\Users\AyakaNakamura\Dropbox\materials\Works\Master\program\Submittion\Intermediate\JHPS2014_pr.dta", clear
append using "C:\Users\AyakaNakamura\Dropbox\materials\Works\Master\program\Submittion\Intermediate\JHPS2014_sp.dta"
gen year=2014
* ageを作成
mvdecode byear, mv(9999)
mvdecode bmonth, mv(99)
replace byear=2020 if byear==.
replace bmonth=0 if bmonth==.
replace bmonth=bmonth+10
tostring byear bmonth, replace
gen bday=byear+bmonth+"15"
destring bday, replace
replace bday=bday-1000
gen age=round((20140130-bday)/10000)
replace age=. if age<0
drop byear bmonth bday
save "C:\Users\AyakaNakamura\Dropbox\materials\Works\Master\program\Submittion\Intermediate\JHPS2014.dta", replace

* cohort dummy
keep id
gen cohort=9
append using "C:\Users\AyakaNakamura\Dropbox\materials\Works\Master\program\Submittion\Intermediate\Cohort.dta"
duplicates drop id, force
save "C:\Users\AyakaNakamura\Dropbox\materials\Works\Master\program\Submittion\Intermediate\Cohort.dta", replace
}

** KHPS2004
{
* 変数名の変更
** 本人
import delimited "C:\Users\AyakaNakamura\Dropbox\materials\Works\Master\program\Submittion\OriginalData\KHPS2004.csv", clear 
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
** 主たる生計維持者
replace earnmost=0 if earnmost!=1
* 世帯主ダミー作成
** 世帯主ですか (*) only 主たる生計維持者 asked in this survey
gen head=earnmost
* switch dummy
gen switch=0
* 使わない変数を落とす
drop v*
* idを+20000
replace id=id+20000
save "C:\Users\AyakaNakamura\Dropbox\materials\Works\Master\program\Submittion\Intermediate\KHPS2004_pr.dta", replace

** 配偶者
import delimited "C:\Users\AyakaNakamura\Dropbox\materials\Works\Master\program\Submittion\OriginalData\KHPS2004.csv", clear 
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
** 主たる生計維持者
replace earnmost=100 if earnmost==relno
replace earnmost=0 if earnmost!=100
replace earnmost=1 if earnmost==100
* 世帯主ダミー作成
** 世帯主ですか (*) only 主たる生計維持者 asked in this survey
gen head=earnmost
* switch dummy
gen switch=0
* 使わない変数を落とす
drop v* rel*
* idを+30000
replace id=id+30000
save "C:\Users\AyakaNakamura\Dropbox\materials\Works\Master\program\Submittion\Intermediate\KHPS2004_sp.dta", replace

** 本人と配偶者サンプルをバインド
use "C:\Users\AyakaNakamura\Dropbox\materials\Works\Master\program\Submittion\Intermediate\KHPS2004_pr.dta", clear
append using "C:\Users\AyakaNakamura\Dropbox\materials\Works\Master\program\Submittion\Intermediate\KHPS2004_sp.dta"
gen year=2004
* ageを作成
mvdecode byear, mv(9999)
mvdecode bmonth, mv(99)
replace byear=2020 if byear==.
replace bmonth=0 if bmonth==.
replace bmonth=bmonth+10
tostring byear bmonth, replace
gen bday=byear+bmonth+"15"
destring bday, replace
replace bday=bday-1000
gen age=round((20040130-bday)/10000)
replace age=. if age<0
drop byear bmonth bday
* emptenureを作成
for num 8888 9999: mvdecode empsinceyear, mv(X)
for num 88 99: mvdecode empsincemonth, mv(X)
replace empsinceyear=2020 if empsinceyear==.
replace empsincemonth=0 if empsincemonth==.
replace empsincemonth=empsincemonth+10
tostring empsinceyear empsincemonth, replace
gen eday=empsinceyear+empsincemonth+"15"
destring eday, replace
replace eday=eday-1000
gen emptenure=(20040130-eday)/10000
replace emptenure=. if emptenure<0
drop empsinceyear empsincemonth eday
save "C:\Users\AyakaNakamura\Dropbox\materials\Works\Master\program\Submittion\Intermediate\KHPS2004.dta", replace

* cohort dummy
keep id
gen cohort=4
append using "C:\Users\AyakaNakamura\Dropbox\materials\Works\Master\program\Submittion\Intermediate\Cohort.dta"
duplicates drop id, force
save "C:\Users\AyakaNakamura\Dropbox\materials\Works\Master\program\Submittion\Intermediate\Cohort.dta", replace
}

** KHPS2005
{
* 変数名の変更
** 本人
import delimited "C:\Users\AyakaNakamura\Dropbox\materials\Works\Master\program\Submittion\OriginalData\KHPS2005.csv", clear 
rename (v1 v4 v5 v6 v7 v76 v139 ///
v171 v159 v160 v161 v164 v165 ///
v207 v183 ///
v185 v186 v187 v188 v189 v190 ///
v203 v204 v205) ///
(id marital sex byear bmonth earnmost workstatus ///
occ owner ind size employed regular ///
switch union ///
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
save "C:\Users\AyakaNakamura\Dropbox\materials\Works\Master\program\Submittion\Intermediate\KHPS2005_pr.dta", replace

** 配偶者
import delimited "C:\Users\AyakaNakamura\Dropbox\materials\Works\Master\program\Submittion\OriginalData\KHPS2005.csv", clear 
rename (v1 v4 v76 v392 ///
v424 v412 v413 v414 v417 v418 ///
v460 v436 ///
v438 v439 v440 v441 v442 v443 ///
v456 v457 v458) ///
(id marital earnmost workstatus ///
occ owner ind size employed regular ///
switch union ///
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
save "C:\Users\AyakaNakamura\Dropbox\materials\Works\Master\program\Submittion\Intermediate\KHPS2005_sp.dta", replace

** 本人と配偶者サンプルをバインド
use "C:\Users\AyakaNakamura\Dropbox\materials\Works\Master\program\Submittion\Intermediate\KHPS2005_pr.dta", clear
append using "C:\Users\AyakaNakamura\Dropbox\materials\Works\Master\program\Submittion\Intermediate\KHPS2005_sp.dta"
gen year=2005
* ageを作成
mvdecode byear, mv(9999)
mvdecode bmonth, mv(99)
replace byear=2020 if byear==.
replace bmonth=0 if bmonth==.
replace bmonth=bmonth+10
tostring byear bmonth, replace
gen bday=byear+bmonth+"15"
destring bday, replace
replace bday=bday-1000
gen age=round((20050130-bday)/10000)
replace age=. if age<0
drop byear bmonth bday
save "C:\Users\AyakaNakamura\Dropbox\materials\Works\Master\program\Submittion\Intermediate\KHPS2005.dta", replace

* cohort dummy
keep id
gen cohort=4
append using "C:\Users\AyakaNakamura\Dropbox\materials\Works\Master\program\Submittion\Intermediate\Cohort.dta"
duplicates drop id, force
save "C:\Users\AyakaNakamura\Dropbox\materials\Works\Master\program\Submittion\Intermediate\Cohort.dta", replace
}

** KHPS2006
{
* 変数名の変更
** 本人
import delimited "C:\Users\AyakaNakamura\Dropbox\materials\Works\Master\program\Submittion\OriginalData\KHPS2006.csv", clear 
rename (v1 v4 v5 v6 v7 v76 v132 ///
v152 v153 v154 v155 v158 v159 ///
v195 v169 ///
v171 v172 v173 v174 v175 v176 ///
v189 v190 v191) ///
(id marital sex byear bmonth earnmost workstatus ///
occ owner ind size employed regular ///
switch union ///
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
save "C:\Users\AyakaNakamura\Dropbox\materials\Works\Master\program\Submittion\Intermediate\KHPS2006_pr.dta", replace

** 配偶者
import delimited "C:\Users\AyakaNakamura\Dropbox\materials\Works\Master\program\Submittion\OriginalData\KHPS2006.csv", clear 
rename (v1 v4 v76 v348 ///
v368 v369 v370 v371 v374 v375 ///
v411 v385 ///
v387 v388 v389 v390 v391 v392 ///
v405 v406 v407) ///
(id marital earnmost workstatus ///
occ owner ind size employed regular ///
switch union ///
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
save "C:\Users\AyakaNakamura\Dropbox\materials\Works\Master\program\Submittion\Intermediate\KHPS2006_sp.dta", replace

** 本人と配偶者サンプルをバインド
use "C:\Users\AyakaNakamura\Dropbox\materials\Works\Master\program\Submittion\Intermediate\KHPS2006_pr.dta", clear
append using "C:\Users\AyakaNakamura\Dropbox\materials\Works\Master\program\Submittion\Intermediate\KHPS2006_sp.dta"
gen year=2006
* ageを作成
mvdecode byear, mv(9999)
mvdecode bmonth, mv(99)
replace byear=2020 if byear==.
replace bmonth=0 if bmonth==.
replace bmonth=bmonth+10
tostring byear bmonth, replace
gen bday=byear+bmonth+"15"
destring bday, replace
replace bday=bday-1000
gen age=round((20060130-bday)/10000)
replace age=. if age<0
drop byear bmonth bday
save "C:\Users\AyakaNakamura\Dropbox\materials\Works\Master\program\Submittion\Intermediate\KHPS2006.dta", replace

* cohort dummy
keep id
gen cohort=4
append using "C:\Users\AyakaNakamura\Dropbox\materials\Works\Master\program\Submittion\Intermediate\Cohort.dta"
duplicates drop id, force
save "C:\Users\AyakaNakamura\Dropbox\materials\Works\Master\program\Submittion\Intermediate\Cohort.dta", replace
}

** KHPS2007
{
* 変数名の変更
** 本人
import delimited "C:\Users\AyakaNakamura\Dropbox\materials\Works\Master\program\Submittion\OriginalData\KHPS2007.csv", clear 
rename (v1 v4 v5 v6 v7 v76 v138 ///
v158 v159 v160 v161 v164 v165 ///
v201 v175 ///
v177 v178 v179 v180 v181 v182 ///
v195 v196 v197) ///
(id marital sex byear bmonth earnmost workstatus ///
occ owner ind size employed regular ///
switch union ///
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
save "C:\Users\AyakaNakamura\Dropbox\materials\Works\Master\program\Submittion\Intermediate\KHPS2007_pr.dta", replace

** 配偶者
import delimited "C:\Users\AyakaNakamura\Dropbox\materials\Works\Master\program\Submittion\OriginalData\KHPS2007.csv", clear 
rename (v1 v4 v76 v309 ///
v329 v330 v331 v332 v335 v336 ///
v372 v346 ///
v348 v349 v350 v351 v352 v353 ///
v366 v367 v368) ///
(id marital earnmost workstatus ///
occ owner ind size employed regular ///
switch union ///
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
save "C:\Users\AyakaNakamura\Dropbox\materials\Works\Master\program\Submittion\Intermediate\KHPS2007_sp.dta", replace

** 本人と配偶者サンプルをバインド
use "C:\Users\AyakaNakamura\Dropbox\materials\Works\Master\program\Submittion\Intermediate\KHPS2007_pr.dta", clear
append using "C:\Users\AyakaNakamura\Dropbox\materials\Works\Master\program\Submittion\Intermediate\KHPS2007_sp.dta"
gen year=2007
* ageを作成
mvdecode byear, mv(9999)
mvdecode bmonth, mv(99)
replace byear=2020 if byear==.
replace bmonth=0 if bmonth==.
replace bmonth=bmonth+10
tostring byear bmonth, replace
gen bday=byear+bmonth+"15"
destring bday, replace
replace bday=bday-1000
gen age=round((20070130-bday)/10000)
replace age=. if age<0
drop byear bmonth bday
save "C:\Users\AyakaNakamura\Dropbox\materials\Works\Master\program\Submittion\Intermediate\KHPS2007.dta", replace

* cohort dummy
keep id
gen cohort=4
append using "C:\Users\AyakaNakamura\Dropbox\materials\Works\Master\program\Submittion\Intermediate\Cohort.dta"
duplicates drop id, force
save "C:\Users\AyakaNakamura\Dropbox\materials\Works\Master\program\Submittion\Intermediate\Cohort.dta", replace
}

** KHPS2007_new
{
* 変数名の変更
** 本人
import delimited "C:\Users\AyakaNakamura\Dropbox\materials\Works\Master\program\Submittion\OriginalData\KHPS2007_new.csv", clear 
rename (v1 v4 v5 v6 v7 v76 v135 v156 ///
v203 v204 v205 v206 v209 v210 ///
v222 v223 v224 ///
v228 v229 v230 v231 v232 v233 ///
v246 v247 v248) ///
(id marital sex byear bmonth earnmost edbg workstatus ///
occ owner ind size employed regular ///
empsinceyear empsincemonth union ///
paymethod monthlypaid dailypaid hourlypaid yearlypaid bonus ///
workdaypermonth workhourperweek overworkperweek)
*** 就業履歴データの変数名変更
**** temporal employee
for X in num 420/473 \ Y in num 15/68: ///
rename vX casY
**** regular employee
for X in num 474/527 \ Y in num 15/68: ///
rename vX regY
**** self employed
for X in num 528/581 \ Y in num 15/68: ///
rename vX selfY
**** 内職
for X in num 582/635 \ Y in num 15/68: ///
rename vX sideY
**** family worker
for X in num 636/689 \ Y in num 15/68: ///
rename vX fmwY
** 主たる生計維持者
replace earnmost=0 if earnmost!=1
* 世帯主ダミー作成
** 世帯主ですか (*) only 主たる生計維持者 asked in this survey
gen head=earnmost
* switch dummy
gen switch=0
* 使わない変数を落とす
drop v*
* idを+40000
replace id=id+40000
save "C:\Users\AyakaNakamura\Dropbox\materials\Works\Master\program\Submittion\Intermediate\KHPS2007_new_pr.dta", replace

** 配偶者
import delimited "C:\Users\AyakaNakamura\Dropbox\materials\Works\Master\program\Submittion\OriginalData\KHPS2007_new.csv", clear 
rename (v1 v4 v14 v15 v16 v76 v813 v834 ///
v881 v882 v823 v824 v887 v888 ///
v900 v901 v902 ///
v906 v907 v908 v909 v910 v911 ///
v924 v925 v926) ///
(id marital sex byear bmonth earnmost edbg workstatus ///
occ owner ind size employed regular ///
empsinceyear empsincemonth union ///
paymethod monthlypaid dailypaid hourlypaid yearlypaid bonus ///
workdaypermonth workhourperweek overworkperweek)
* 続柄が配偶者のサンプルのみ残す
keep if marital==1
*** 就業履歴データの変数名変更
**** temporal employee
for X in num 1098/1151 \ Y in num 15/68: ///
rename vX casY
**** regular employee
for X in num 1152/1205 \ Y in num 15/68: ///
rename vX regY
**** self employed
for X in num 1206/1259 \ Y in num 15/68: ///
rename vX selfY
**** 内職
for X in num 1260/1313 \ Y in num 15/68: ///
rename vX sideY
**** family worker
for X in num 1314/1367 \ Y in num 15/68: ///
rename vX fmwY
** 主たる生計維持者
replace earnmost=100 if earnmost==2
replace earnmost=0 if earnmost!=100
replace earnmost=1 if earnmost==100
* 世帯主ダミー作成
** 世帯主ですか (*) only 主たる生計維持者 asked in this survey
gen head=earnmost
* switch dummy
gen switch=0
* 使わない変数を落とす
drop v*
* idを+30000
replace id=id+30000
save "C:\Users\AyakaNakamura\Dropbox\materials\Works\Master\program\Submittion\Intermediate\KHPS2007_new_sp.dta", replace

** 本人と配偶者サンプルをバインド
use "C:\Users\AyakaNakamura\Dropbox\materials\Works\Master\program\Submittion\Intermediate\KHPS2007_new_pr.dta", clear
append using "C:\Users\AyakaNakamura\Dropbox\materials\Works\Master\program\Submittion\Intermediate\KHPS2007_new_sp.dta"
gen year=2007
* ageを作成
mvdecode byear, mv(9999)
mvdecode bmonth, mv(99)
replace byear=2020 if byear==.
replace bmonth=0 if bmonth==.
replace bmonth=bmonth+10
tostring byear bmonth, replace
gen bday=byear+bmonth+"15"
destring bday, replace
replace bday=bday-1000
gen age=round((20070130-bday)/10000)
replace age=. if age<0
drop byear bmonth bday
* emptenureを作成
for num 8888 9999: mvdecode empsinceyear, mv(X)
for num 88 99: mvdecode empsincemonth, mv(X)
replace empsinceyear=2020 if empsinceyear==.
replace empsincemonth=0 if empsincemonth==.
replace empsincemonth=empsincemonth+10
tostring empsinceyear empsincemonth, replace
gen eday=empsinceyear+empsincemonth+"15"
destring eday, replace
replace eday=eday-1000
gen emptenure=(20070130-eday)/10000
replace emptenure=. if emptenure<0
drop empsinceyear empsincemonth eday
save "C:\Users\AyakaNakamura\Dropbox\materials\Works\Master\program\Submittion\Intermediate\KHPS2007_new.dta", replace

* cohort dummy
keep id
gen cohort=7
append using "C:\Users\AyakaNakamura\Dropbox\materials\Works\Master\program\Submittion\Intermediate\Cohort.dta"
save "C:\Users\AyakaNakamura\Dropbox\materials\Works\Master\program\Submittion\Intermediate\Cohort.dta", replace
}

** KHPS2008
{
* 変数名の変更
** 本人
import delimited "C:\Users\AyakaNakamura\Dropbox\materials\Works\Master\program\Submittion\OriginalData\KHPS2008.csv", clear 
rename (v1 v4 v5 v6 v7 v85 v148 ///
v168 v169 v170 v171 v174 v175 ///
v215 v188 ///
v190 v191 v192 v193 v194 v195 ///
v209 v210 v211) ///
(id marital sex byear bmonth earnmost workstatus ///
occ owner ind size employed regular ///
switch union ///
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
save "C:\Users\AyakaNakamura\Dropbox\materials\Works\Master\program\Submittion\Intermediate\KHPS2008_pr.dta", replace

** 配偶者
import delimited "C:\Users\AyakaNakamura\Dropbox\materials\Works\Master\program\Submittion\OriginalData\KHPS2008.csv", clear 
rename (v1 v4 v85 v376 ///
v396 v397 v398 v399 v402 v403 ///
v443 v416 ///
v418 v419 v420 v421 v422 v423 ///
v437 v438 v439) ///
(id marital earnmost workstatus ///
occ owner ind size employed regular ///
switch union ///
paymethod monthlypaid dailypaid hourlypaid yearlypaid bonus ///
workdaypermonth workhourperweek overworkperweek)
* 続柄が配偶者のサンプルのみ残す
keep if marital==1
* 続柄の変数名変更->配偶者の情報を抽出
rename (v13 v14 v15 v16 ///
v21 v22 v23 v24 ///
v29 v30 v31 v32 ///
v37 v38 v39 v40 ///
v45 v46 v47 v48 ///
v53 v54 v55 v56 ///
v61 v62 v63 v64 ///
v69 v70 v71 v72 ///
v77 v78 v79 v80) ///
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
save "C:\Users\AyakaNakamura\Dropbox\materials\Works\Master\program\Submittion\Intermediate\KHPS2008_sp.dta", replace

** 本人と配偶者サンプルをバインド
use "C:\Users\AyakaNakamura\Dropbox\materials\Works\Master\program\Submittion\Intermediate\KHPS2008_pr.dta", clear
append using "C:\Users\AyakaNakamura\Dropbox\materials\Works\Master\program\Submittion\Intermediate\KHPS2008_sp.dta"
gen year=2008
* ageを作成
mvdecode byear, mv(9999)
mvdecode bmonth, mv(99)
replace byear=2020 if byear==.
replace bmonth=0 if bmonth==.
replace bmonth=bmonth+10
tostring byear bmonth, replace
gen bday=byear+bmonth+"15"
destring bday, replace
replace bday=bday-1000
gen age=round((20080130-bday)/10000)
replace age=. if age<0
drop byear bmonth bday
save "C:\Users\AyakaNakamura\Dropbox\materials\Works\Master\program\Submittion\Intermediate\KHPS2008.dta", replace

* cohort dummy
keep id
merge 1:1 id using "C:\Users\AyakaNakamura\Dropbox\materials\Works\Master\program\Submittion\Intermediate\Cohort.dta"
replace cohort=4 if cohort==.
drop _merge
save "C:\Users\AyakaNakamura\Dropbox\materials\Works\Master\program\Submittion\Intermediate\Cohort.dta", replace
}

** KHPS2009
{
* 変数名の変更
** 本人
import delimited "C:\Users\AyakaNakamura\Dropbox\materials\Works\Master\program\Submittion\OriginalData\KHPS2009.csv", clear 
rename (v1 v4 v5 v6 v7 v85 v86 v87 v160 ///
v180 v181 v182 v183 v186 v187 ///
v238 v195 ///
v197 v198 v199 v200 v201 v202 ///
v216 v217 v218) ///
(id marital sex byear bmonth head earnif earnmost workstatus ///
occ owner ind size employed regular ///
switch union ///
paymethod monthlypaid dailypaid hourlypaid yearlypaid bonus ///
workdaypermonth workhourperweek overworkperweek)
* 世帯主ダミー作成
** 世帯主ですか
replace head=0 if head!=1
** 主たる生計維持者
replace earnmost=1 if head==1&earnif==2
replace earnmost=0 if earnmost!=1
* 使わない変数を落とす
drop earnif v*
* idを+20000
replace id=id+20000
save "C:\Users\AyakaNakamura\Dropbox\materials\Works\Master\program\Submittion\Intermediate\KHPS2009_pr.dta", replace

** 配偶者
import delimited "C:\Users\AyakaNakamura\Dropbox\materials\Works\Master\program\Submittion\OriginalData\KHPS2009.csv", clear 
rename (v1 v4  v14 v15 v16 v86 v87 v88 v429 ///
v449 v450 v451 v452 v455 v456 ///
v507 v464 ///
v466 v467 v468 v469 v470 v471 ///
v485 v486 v487) ///
(id marital sex byear bmonth head earnif earnmost workstatus ///
occ owner ind size employed regular ///
switch union ///
paymethod monthlypaid dailypaid hourlypaid yearlypaid bonus ///
workdaypermonth workhourperweek overworkperweek)
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
* idを+30000
replace id=id+30000
save "C:\Users\AyakaNakamura\Dropbox\materials\Works\Master\program\Submittion\Intermediate\KHPS2009_sp.dta", replace

** 本人と配偶者サンプルをバインド
use "C:\Users\AyakaNakamura\Dropbox\materials\Works\Master\program\Submittion\Intermediate\KHPS2009_pr.dta", clear
append using "C:\Users\AyakaNakamura\Dropbox\materials\Works\Master\program\Submittion\Intermediate\KHPS2009_sp.dta"
gen year=2009
* ageを作成
mvdecode byear, mv(9999)
mvdecode bmonth, mv(99)
replace byear=2020 if byear==.
replace bmonth=0 if bmonth==.
replace bmonth=bmonth+10
tostring byear bmonth, replace
gen bday=byear+bmonth+"15"
destring bday, replace
replace bday=bday-1000
gen age=round((20090130-bday)/10000)
replace age=. if age<0
drop byear bmonth bday
save "C:\Users\AyakaNakamura\Dropbox\materials\Works\Master\program\Submittion\Intermediate\KHPS2009.dta", replace

* cohort dummy
keep id
merge 1:1 id using "C:\Users\AyakaNakamura\Dropbox\materials\Works\Master\program\Submittion\Intermediate\Cohort.dta"
replace cohort=4 if cohort==.
drop _merge
save "C:\Users\AyakaNakamura\Dropbox\materials\Works\Master\program\Submittion\Intermediate\Cohort.dta", replace
}

** KHPS2010
{
* 変数名の変更
** 本人
import delimited "C:\Users\AyakaNakamura\Dropbox\materials\Works\Master\program\Submittion\OriginalData\KHPS2010.csv", clear 
rename (v1 v4 v5 v6 v7 v85 v86 v87 v161 ///
v181 v182 v183 v184 v187 v188 ///
v243 v196 ///
v198 v199 v200 v201 v202 v203 ///
v217 v218 v219) ///
(id marital sex byear bmonth head earnif earnmost workstatus ///
occ owner ind size employed regular ///
switch union ///
paymethod monthlypaid dailypaid hourlypaid yearlypaid bonus ///
workdaypermonth workhourperweek overworkperweek)
* 世帯主ダミー作成
** 世帯主ですか
replace head=0 if head!=1
** 主たる生計維持者
replace earnmost=1 if head==1&earnif==2
replace earnmost=0 if earnmost!=1
* 使わない変数を落とす
drop earnif v*
* idを+20000
replace id=id+20000
save "C:\Users\AyakaNakamura\Dropbox\materials\Works\Master\program\Submittion\Intermediate\KHPS2010_pr.dta", replace

** 配偶者
import delimited "C:\Users\AyakaNakamura\Dropbox\materials\Works\Master\program\Submittion\OriginalData\KHPS2010.csv", clear 
rename (v1 v4  v14 v15 v16 v85 v86 v87 v426 ///
v446 v447 v448 v449 v452 v453 ///
v508 v461 ///
v463 v464 v465 v466 v467 v468 ///
v482 v483 v484) ///
(id marital sex byear bmonth head earnif earnmost workstatus ///
occ owner ind size employed regular ///
switch union ///
paymethod monthlypaid dailypaid hourlypaid yearlypaid bonus ///
workdaypermonth workhourperweek overworkperweek)
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
replace id=id+30000
save "C:\Users\AyakaNakamura\Dropbox\materials\Works\Master\program\Submittion\Intermediate\KHPS2010_sp.dta", replace

** 本人と配偶者サンプルをバインド
use "C:\Users\AyakaNakamura\Dropbox\materials\Works\Master\program\Submittion\Intermediate\KHPS2010_pr.dta", clear
append using "C:\Users\AyakaNakamura\Dropbox\materials\Works\Master\program\Submittion\Intermediate\KHPS2010_sp.dta"
gen year=2010
* ageを作成
mvdecode byear, mv(9999)
mvdecode bmonth, mv(99)
replace byear=2020 if byear==.
replace bmonth=0 if bmonth==.
replace bmonth=bmonth+10
tostring byear bmonth, replace
gen bday=byear+bmonth+"15"
destring bday, replace
replace bday=bday-1000
gen age=round((20100130-bday)/10000)
replace age=. if age<0
drop byear bmonth bday
save "C:\Users\AyakaNakamura\Dropbox\materials\Works\Master\program\Submittion\Intermediate\KHPS2010.dta", replace

* cohort dummy
keep id
merge 1:1 id using "C:\Users\AyakaNakamura\Dropbox\materials\Works\Master\program\Submittion\Intermediate\Cohort.dta"
replace cohort=4 if cohort==.
drop _merge
save "C:\Users\AyakaNakamura\Dropbox\materials\Works\Master\program\Submittion\Intermediate\Cohort.dta", replace
}

** KHPS2011
{
* 変数名の変更
** 本人
import delimited "C:\Users\AyakaNakamura\Dropbox\materials\Works\Master\program\Submittion\OriginalData\KHPS2011.csv", clear 
rename (v1 v4 v5 v6 v7 v85 v86 v87 v173 ///
v193 v194 v195 v196 v199 v200 ///
v249 v208 ///
v210 v211 v212 v213 v214 v215 ///
v229 v230 v231) ///
(id marital sex byear bmonth head earnif earnmost workstatus ///
occ owner ind size employed regular ///
switch union ///
paymethod monthlypaid dailypaid hourlypaid yearlypaid bonus ///
workdaypermonth workhourperweek overworkperweek)
* 世帯主ダミー作成
** 世帯主ですか
replace head=0 if head!=1
** 主たる生計維持者
replace earnmost=1 if head==1&earnif==2
replace earnmost=0 if earnmost!=1
* 使わない変数を落とす
drop earnif v*
* idを+20000
replace id=id+20000
save "C:\Users\AyakaNakamura\Dropbox\materials\Works\Master\program\Submittion\Intermediate\KHPS2011_pr.dta", replace

** 配偶者
import delimited "C:\Users\AyakaNakamura\Dropbox\materials\Works\Master\program\Submittion\OriginalData\KHPS2011.csv", clear 
rename (v1 v4  v14 v15 v16 v85 v86 v87 v431 ///
v451 v452 v453 v454 v457 v458 ///
v507 v466 ///
v468 v469 v470 v471 v472 v473 ///
v487 v488 v489) ///
(id marital sex byear bmonth head earnif earnmost workstatus ///
occ owner ind size employed regular ///
switch union ///
paymethod monthlypaid dailypaid hourlypaid yearlypaid bonus ///
workdaypermonth workhourperweek overworkperweek)
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
replace id=id+30000
save "C:\Users\AyakaNakamura\Dropbox\materials\Works\Master\program\Submittion\Intermediate\KHPS2011_sp.dta", replace

** 本人と配偶者サンプルをバインド
use "C:\Users\AyakaNakamura\Dropbox\materials\Works\Master\program\Submittion\Intermediate\KHPS2011_pr.dta", clear
append using "C:\Users\AyakaNakamura\Dropbox\materials\Works\Master\program\Submittion\Intermediate\KHPS2011_sp.dta"
gen year=2011
* ageを作成
mvdecode byear, mv(9999)
mvdecode bmonth, mv(99)
replace byear=2020 if byear==.
replace bmonth=0 if bmonth==.
replace bmonth=bmonth+10
tostring byear bmonth, replace
gen bday=byear+bmonth+"15"
destring bday, replace
replace bday=bday-1000
gen age=round((20110130-bday)/10000)
replace age=. if age<0
drop byear bmonth bday
save "C:\Users\AyakaNakamura\Dropbox\materials\Works\Master\program\Submittion\Intermediate\KHPS2011.dta", replace

* cohort dummy
keep id
merge 1:1 id using "C:\Users\AyakaNakamura\Dropbox\materials\Works\Master\program\Submittion\Intermediate\Cohort.dta"
replace cohort=4 if cohort==.
drop _merge
save "C:\Users\AyakaNakamura\Dropbox\materials\Works\Master\program\Submittion\Intermediate\Cohort.dta", replace
}

** KHPS2012
{
* 変数名の変更
** 本人
import delimited "C:\Users\AyakaNakamura\Dropbox\materials\Works\Master\program\Submittion\OriginalData\KHPS2012.csv", clear 
rename (v1 v4 v5 v6 v7 v85 v86 v87 v167 ///
v187 v188 v189 v190 v193 v194 ///
v228 v202 ///
v204 v205 v206 v207 v208 v209 ///
v214 v215 v216) ///
(id marital sex byear bmonth head earnif earnmost workstatus ///
occ owner ind size employed regular ///
switch union ///
paymethod monthlypaid dailypaid hourlypaid yearlypaid bonus ///
workdaypermonth workhourperweek overworkperweek)
* 世帯主ダミー作成
** 世帯主ですか
replace head=0 if head!=1
** 主たる生計維持者
replace earnmost=1 if head==1&earnif==2
replace earnmost=0 if earnmost!=1
* 使わない変数を落とす
drop earnif v*
* idを+20000
replace id=id+20000
save "C:\Users\AyakaNakamura\Dropbox\materials\Works\Master\program\Submittion\Intermediate\KHPS2012_pr.dta", replace

** 配偶者
import delimited "C:\Users\AyakaNakamura\Dropbox\materials\Works\Master\program\Submittion\OriginalData\KHPS2012.csv", clear 
rename (v1 v4  v14 v15 v16 v85 v86 v87 v405 ///
v425 v426 v427 v428 v431 v432 ///
v466 v440 ///
v442 v443 v444 v445 v446 v447 ///
v452 v453 v454) ///
(id marital sex byear bmonth head earnif earnmost workstatus ///
occ owner ind size employed regular ///
switch union ///
paymethod monthlypaid dailypaid hourlypaid yearlypaid bonus ///
workdaypermonth workhourperweek overworkperweek)
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
replace id=id+30000
save "C:\Users\AyakaNakamura\Dropbox\materials\Works\Master\program\Submittion\Intermediate\KHPS2012_sp.dta", replace

** 本人と配偶者サンプルをバインド
use "C:\Users\AyakaNakamura\Dropbox\materials\Works\Master\program\Submittion\Intermediate\KHPS2012_pr.dta", clear
append using "C:\Users\AyakaNakamura\Dropbox\materials\Works\Master\program\Submittion\Intermediate\KHPS2012_sp.dta"
gen year=2012
* ageを作成
mvdecode byear, mv(9999)
mvdecode bmonth, mv(99)
replace byear=2020 if byear==.
replace bmonth=0 if bmonth==.
replace bmonth=bmonth+10
tostring byear bmonth, replace
gen bday=byear+bmonth+"15"
destring bday, replace
replace bday=bday-1000
gen age=round((20120130-bday)/10000)
replace age=. if age<0
drop byear bmonth bday
save "C:\Users\AyakaNakamura\Dropbox\materials\Works\Master\program\Submittion\Intermediate\KHPS2012.dta", replace

* cohort dummy
keep id
merge 1:1 id using "C:\Users\AyakaNakamura\Dropbox\materials\Works\Master\program\Submittion\Intermediate\Cohort.dta"
replace cohort=4 if cohort==.
drop _merge
save "C:\Users\AyakaNakamura\Dropbox\materials\Works\Master\program\Submittion\Intermediate\Cohort.dta", replace
}

** KHPS2012_new
{
* 変数名の変更
** 本人
import delimited "C:\Users\AyakaNakamura\Dropbox\materials\Works\Master\program\Submittion\OriginalData\KHPS2012_new.csv", clear 
rename (v1 v4 v5 v6 v7 v85 v86 v87 v150 v171 ///
v218 v219 v220 v221 v224 v225 ///
v233 v234 v235 ///
v239 v240 v241 v242 v243 v244 ///
v249 v250 v251) ///
(id marital sex byear bmonth head earnif earnmost edbg workstatus ///
occ owner ind size employed regular ///
empsinceyear empsincemonth union ///
paymethod monthlypaid dailypaid hourlypaid yearlypaid bonus ///
workdaypermonth workhourperweek overworkperweek)
*** 就業履歴データの変数名変更
**** temporal employee
for X in num 427/480 \ Y in num 15/68: ///
rename vX casY
**** regular employee
for X in num 481/534 \ Y in num 15/68: ///
rename vX regY
**** self employed
for X in num 535/588 \ Y in num 15/68: ///
rename vX selfY
**** 内職
for X in num 589/642 \ Y in num 15/68: ///
rename vX sideY
**** family worker
for X in num 643/696 \ Y in num 15/68: ///
rename vX fmwY
* 世帯主ダミー作成
** 世帯主ですか
replace head=0 if head!=1
** 主たる生計維持者
replace earnmost=1 if head==1&earnif==2
replace earnmost=0 if earnmost!=1
* switch dummy
gen switch=0
* 使わない変数を落とす
drop v*
* idを+40000
replace id=id+40000
save "C:\Users\AyakaNakamura\Dropbox\materials\Works\Master\program\Submittion\Intermediate\KHPS2012_new_pr.dta", replace

** 配偶者
import delimited "C:\Users\AyakaNakamura\Dropbox\materials\Works\Master\program\Submittion\OriginalData\KHPS2012_new.csv", clear 
rename (v1 v4 v14 v15 v16 v85 v86 v87 v864 v885 ///
v932 v933 v934 v935 v938 v939 ///
v947 v948 v949 ///
v953 v954 v955 v956 v957 v958 ///
v963 v964 v965) ///
(id marital sex byear bmonth head earnif earnmost edbg workstatus ///
occ owner ind size employed regular ///
empsinceyear empsincemonth union ///
paymethod monthlypaid dailypaid hourlypaid yearlypaid bonus ///
workdaypermonth workhourperweek overworkperweek)
* 続柄が配偶者のサンプルのみ残す
keep if marital==1
*** 就業履歴データの変数名変更
**** temporal employee
for X in num 1141/1194 \ Y in num 15/68: ///
rename vX casY
**** regular employee
for X in num 1195/1248 \ Y in num 15/68: ///
rename vX regY
**** self employed
for X in num 1249/1302 \ Y in num 15/68: ///
rename vX selfY
**** 内職
for X in num 1303/1356 \ Y in num 15/68: ///
rename vX sideY
**** family worker
for X in num 1357/1410 \ Y in num 15/68: ///
rename vX fmwY
* 世帯主ダミー作成
** 世帯主ですか
replace head=0 if head!=2
replace head=1 if head==2
** 主たる生計維持者
replace earnmost=1 if earnmost==2|head==1&earnif==2
replace earnmost=0 if earnmost!=1
* switch dummy
gen switch=0
* 使わない変数を落とす
drop v*
* idを+30000
replace id=id+30000
save "C:\Users\AyakaNakamura\Dropbox\materials\Works\Master\program\Submittion\Intermediate\KHPS2012_new_sp.dta", replace

** 本人と配偶者サンプルをバインド
use "C:\Users\AyakaNakamura\Dropbox\materials\Works\Master\program\Submittion\Intermediate\KHPS2012_new_pr.dta", clear
append using "C:\Users\AyakaNakamura\Dropbox\materials\Works\Master\program\Submittion\Intermediate\KHPS2012_new_sp.dta"
gen year=2012
* ageを作成
mvdecode byear, mv(9999)
mvdecode bmonth, mv(99)
replace byear=2020 if byear==.
replace bmonth=0 if bmonth==.
replace bmonth=bmonth+10
tostring byear bmonth, replace
gen bday=byear+bmonth+"15"
destring bday, replace
replace bday=bday-1000
gen age=round((20120130-bday)/10000)
replace age=. if age<0
drop byear bmonth bday
* emptenureを作成
for num 8888 9999: mvdecode empsinceyear, mv(X)
for num 88 99: mvdecode empsincemonth, mv(X)
replace empsinceyear=2020 if empsinceyear==.
replace empsincemonth=0 if empsincemonth==.
replace empsincemonth=empsincemonth+10
tostring empsinceyear empsincemonth, replace
gen eday=empsinceyear+empsincemonth+"15"
destring eday, replace
replace eday=eday-1000
gen emptenure=(20120130-eday)/10000
replace emptenure=. if emptenure<0
drop empsinceyear empsincemonth eday
save "C:\Users\AyakaNakamura\Dropbox\materials\Works\Master\program\Submittion\Intermediate\KHPS2012_new.dta", replace

* cohort dummy
keep id
gen cohort=12
append using "C:\Users\AyakaNakamura\Dropbox\materials\Works\Master\program\Submittion\Intermediate\Cohort.dta"
save "C:\Users\AyakaNakamura\Dropbox\materials\Works\Master\program\Submittion\Intermediate\Cohort.dta", replace
}

** KHPS2013
{
* 変数名の変更
** 本人
import delimited "C:\Users\AyakaNakamura\Dropbox\materials\Works\Master\program\Submittion\OriginalData\KHPS2013.csv", clear 
rename (v1 v4 v5 v6 v7 v85 v86 v87 v190 ///
v210 v211 v212 v213 v216 v217 ///
v266 v225 ///
v227 v228 v229 v230 v231 v232 ///
v246 v247 v248) ///
(id marital sex byear bmonth head earnif earnmost workstatus ///
occ owner ind size employed regular ///
switch union ///
paymethod monthlypaid dailypaid hourlypaid yearlypaid bonus ///
workdaypermonth workhourperweek overworkperweek)
* 世帯主ダミー作成
** 世帯主ですか
replace head=0 if head!=1
** 主たる生計維持者
replace earnmost=1 if head==1&earnif==2
replace earnmost=0 if earnmost!=1
* 使わない変数を落とす
drop earnif v*
* idを+20000
replace id=id+20000
save "C:\Users\AyakaNakamura\Dropbox\materials\Works\Master\program\Submittion\Intermediate\KHPS2013_pr.dta", replace

** 配偶者
import delimited "C:\Users\AyakaNakamura\Dropbox\materials\Works\Master\program\Submittion\OriginalData\KHPS2013.csv", clear 
rename (v1 v4  v14 v15 v16 v85 v86 v87 v471 ///
v491 v492 v493 v494 v497 v498 ///
v547 v506 ///
v508 v509 v510 v511 v512 v513 ///
v527 v528 v529) ///
(id marital sex byear bmonth head earnif earnmost workstatus ///
occ owner ind size employed regular ///
switch union ///
paymethod monthlypaid dailypaid hourlypaid yearlypaid bonus ///
workdaypermonth workhourperweek overworkperweek)
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
replace id=id+30000
save "C:\Users\AyakaNakamura\Dropbox\materials\Works\Master\program\Submittion\Intermediate\KHPS2013_sp.dta", replace

** 本人と配偶者サンプルをバインド
use "C:\Users\AyakaNakamura\Dropbox\materials\Works\Master\program\Submittion\Intermediate\KHPS2013_pr.dta", clear
append using "C:\Users\AyakaNakamura\Dropbox\materials\Works\Master\program\Submittion\Intermediate\KHPS2013_sp.dta"
gen year=2013
* ageを作成
mvdecode byear, mv(9999)
mvdecode bmonth, mv(99)
replace byear=2020 if byear==.
replace bmonth=0 if bmonth==.
replace bmonth=bmonth+10
tostring byear bmonth, replace
gen bday=byear+bmonth+"15"
destring bday, replace
replace bday=bday-1000
gen age=round((20130130-bday)/10000)
replace age=. if age<0
drop byear bmonth bday
save "C:\Users\AyakaNakamura\Dropbox\materials\Works\Master\program\Submittion\Intermediate\KHPS2013.dta", replace

* cohort dummy
keep id
merge 1:1 id using "C:\Users\AyakaNakamura\Dropbox\materials\Works\Master\program\Submittion\Intermediate\Cohort.dta"
replace cohort=4 if cohort==.
drop _merge
save "C:\Users\AyakaNakamura\Dropbox\materials\Works\Master\program\Submittion\Intermediate\Cohort.dta", replace
}

** KHPS2014
{
* 変数名の変更
** 本人
import delimited "C:\Users\AyakaNakamura\Dropbox\materials\Works\Master\program\Submittion\OriginalData\KHPS2014.csv", clear 
rename (v1 v4 v5 v6 v7 v101 v102 v103 v220 ///
v227 v228 v229 v230 v233 v234 ///
v265 v242 ///
v244 v245 v246 v247 v248 v249 ///
v251 v252 v253) ///
(id marital sex byear bmonth head earnif earnmost workstatus ///
occ owner ind size employed regular ///
switch union ///
paymethod monthlypaid dailypaid hourlypaid yearlypaid bonus ///
workdaypermonth workhourperweek overworkperweek)
* 世帯主ダミー作成
** 世帯主ですか
replace head=0 if head!=1
** 主たる生計維持者
replace earnmost=1 if head==1&earnif==2
replace earnmost=0 if earnmost!=1
* 使わない変数を落とす
drop earnif v*
* idを+20000
replace id=id+20000
save "C:\Users\AyakaNakamura\Dropbox\materials\Works\Master\program\Submittion\Intermediate\KHPS2014_pr.dta", replace

** 配偶者
import delimited "C:\Users\AyakaNakamura\Dropbox\materials\Works\Master\program\Submittion\OriginalData\KHPS2014.csv", clear 
rename (v1 v4  v12 v13 v14 v101 v102 v103 v498 ///
v505 v506 v507 v508 v511 v512 ///
v543 v520 ///
v522 v523 v524 v525 v526 v527 ///
v529 v530 v531) ///
(id marital sex byear bmonth head earnif earnmost workstatus ///
occ owner ind size employed regular ///
switch union ///
paymethod monthlypaid dailypaid hourlypaid yearlypaid bonus ///
workdaypermonth workhourperweek overworkperweek)
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
replace id=id+30000
save "C:\Users\AyakaNakamura\Dropbox\materials\Works\Master\program\Submittion\Intermediate\KHPS2014_sp.dta", replace

** 本人と配偶者サンプルをバインド
use "C:\Users\AyakaNakamura\Dropbox\materials\Works\Master\program\Submittion\Intermediate\KHPS2014_pr.dta", clear
append using "C:\Users\AyakaNakamura\Dropbox\materials\Works\Master\program\Submittion\Intermediate\KHPS2014_sp.dta"
gen year=2014
* ageを作成
mvdecode byear, mv(9999)
mvdecode bmonth, mv(99)
replace byear=2020 if byear==.
replace bmonth=0 if bmonth==.
replace bmonth=bmonth+10
tostring byear bmonth, replace
gen bday=byear+bmonth+"15"
destring bday, replace
replace bday=bday-1000
gen age=round((20140130-bday)/10000)
replace age=. if age<0
drop byear bmonth bday
save "C:\Users\AyakaNakamura\Dropbox\materials\Works\Master\program\Submittion\Intermediate\KHPS2014.dta", replace

* cohort dummy
keep id
merge 1:1 id using "C:\Users\AyakaNakamura\Dropbox\materials\Works\Master\program\Submittion\Intermediate\Cohort.dta"
replace cohort=4 if cohort==.
drop _merge
save "C:\Users\AyakaNakamura\Dropbox\materials\Works\Master\program\Submittion\Intermediate\Cohort.dta", replace
}

** 全ての年に共通の変数のみバインドする
{
*** JHPS
use "C:\Users\AyakaNakamura\Dropbox\materials\Works\Master\program\Submittion\Intermediate\JHPS2009.dta",  clear
append using "C:\Users\AyakaNakamura\Dropbox\materials\Works\Master\program\Submittion\Intermediate\JHPS2010.dta"
append using "C:\Users\AyakaNakamura\Dropbox\materials\Works\Master\program\Submittion\Intermediate\JHPS2011.dta"
append using "C:\Users\AyakaNakamura\Dropbox\materials\Works\Master\program\Submittion\Intermediate\JHPS2012.dta"
append using "C:\Users\AyakaNakamura\Dropbox\materials\Works\Master\program\Submittion\Intermediate\JHPS2013.dta"
append using "C:\Users\AyakaNakamura\Dropbox\materials\Works\Master\program\Submittion\Intermediate\JHPS2014.dta"
*** KHPS2004
append using "C:\Users\AyakaNakamura\Dropbox\materials\Works\Master\program\Submittion\Intermediate\KHPS2004.dta"
append using "C:\Users\AyakaNakamura\Dropbox\materials\Works\Master\program\Submittion\Intermediate\KHPS2005.dta"
append using "C:\Users\AyakaNakamura\Dropbox\materials\Works\Master\program\Submittion\Intermediate\KHPS2006.dta"
append using "C:\Users\AyakaNakamura\Dropbox\materials\Works\Master\program\Submittion\Intermediate\KHPS2007.dta"
append using "C:\Users\AyakaNakamura\Dropbox\materials\Works\Master\program\Submittion\Intermediate\KHPS2008.dta"
append using "C:\Users\AyakaNakamura\Dropbox\materials\Works\Master\program\Submittion\Intermediate\KHPS2009.dta"
append using "C:\Users\AyakaNakamura\Dropbox\materials\Works\Master\program\Submittion\Intermediate\KHPS2010.dta"
append using "C:\Users\AyakaNakamura\Dropbox\materials\Works\Master\program\Submittion\Intermediate\KHPS2011.dta"
append using "C:\Users\AyakaNakamura\Dropbox\materials\Works\Master\program\Submittion\Intermediate\KHPS2012.dta"
append using "C:\Users\AyakaNakamura\Dropbox\materials\Works\Master\program\Submittion\Intermediate\KHPS2013.dta"
append using "C:\Users\AyakaNakamura\Dropbox\materials\Works\Master\program\Submittion\Intermediate\KHPS2014.dta"
*** new cohort
append using "C:\Users\AyakaNakamura\Dropbox\materials\Works\Master\program\Submittion\Intermediate\KHPS2007_new.dta"
append using "C:\Users\AyakaNakamura\Dropbox\materials\Works\Master\program\Submittion\Intermediate\KHPS2012_new.dta"
keep id marital sex age head earnmost workstatus year  ///
occ owner ind size employed regular ///
switch union ///
paymethod monthlypaid dailypaid hourlypaid yearlypaid bonus ///
workdaypermonth workhourperweek overworkperweek
save "C:\Users\AyakaNakamura\Dropbox\materials\Works\Master\program\Submittion\Intermediate\JHPSKHPS_2004_2014.dta", replace
}
}

* 5--7
** 学歴と就業履歴をサンプルにマージする
{
** idと学歴データを抽出
{
*** JHPSの学歴
use "C:\Users\AyakaNakamura\Dropbox\materials\Works\Master\program\Submittion\Intermediate\JHPS2009.dta", clear
mvdecode edbg, mv(9)
gen schooling=9 if edbg==1
replace schooling=12 if edbg==2
replace schooling=14 if edbg==3 | edbg==6
replace schooling=16 if edbg==4 | edbg==5
keep id schooling
save "C:\Users\AyakaNakamura\Dropbox\materials\Works\Master\program\Submittion\Intermediate\SchoolingJHPS.dta", replace

*** KHPSの学歴
**** old cohort
use "C:\Users\AyakaNakamura\Dropbox\materials\Works\Master\program\Submittion\Intermediate\KHPS2004.dta", clear
mvdecode edbg, mv(9)
gen schooling=9 if edbg==1
replace schooling=12 if edbg==2
replace schooling=14 if edbg==3 | edbg==6
replace schooling=16 if edbg==4 | edbg==5
keep id schooling
save "C:\Users\AyakaNakamura\Dropbox\materials\Works\Master\program\Submittion\Intermediate\SchoolingKHPS.dta", replace

**** new cohort 2007
use "C:\Users\AyakaNakamura\Dropbox\materials\Works\Master\program\Submittion\Intermediate\KHPS2007_new.dta", clear
mvdecode edbg, mv(9)
gen schooling=9 if edbg==1
replace schooling=12 if edbg==2
replace schooling=14 if edbg==3 | edbg==6
replace schooling=16 if edbg==4 | edbg==5
keep id schooling
save "C:\Users\AyakaNakamura\Dropbox\materials\Works\Master\program\Submittion\Intermediate\SchoolingKHPS_new_2007.dta", replace

**** new cohort 2012
use "C:\Users\AyakaNakamura\Dropbox\materials\Works\Master\program\Submittion\Intermediate\KHPS2012_new.dta", clear
mvdecode edbg, mv(9)
gen schooling=9 if edbg==1
replace schooling=12 if edbg==2
replace schooling=14 if edbg==3 | edbg==6
replace schooling=16 if edbg==4 | edbg==5
keep id schooling
save "C:\Users\AyakaNakamura\Dropbox\materials\Works\Master\program\Submittion\Intermediate\SchoolingKHPS_new_2012.dta", replace

*** bind
use "C:\Users\AyakaNakamura\Dropbox\materials\Works\Master\program\Submittion\Intermediate\SchoolingJHPS.dta", clear
append using "C:\Users\AyakaNakamura\Dropbox\materials\Works\Master\program\Submittion\Intermediate\SchoolingKHPS.dta"
append using "C:\Users\AyakaNakamura\Dropbox\materials\Works\Master\program\Submittion\Intermediate\SchoolingKHPS_new_2007.dta"
append using "C:\Users\AyakaNakamura\Dropbox\materials\Works\Master\program\Submittion\Intermediate\SchoolingKHPS_new_2012.dta"
sort id
save "C:\Users\AyakaNakamura\Dropbox\materials\Works\Master\program\Submittion\Intermediate\Schooling.dta", replace
 }
 
 ** idと労働経験年数を抽出
{
*** JHPS労働経験年数
use "C:\Users\AyakaNakamura\Dropbox\materials\Works\Master\program\Submittion\Intermediate\JHPS2010.dta", clear
for num 18/65: gen weX=0
for num 18/65: mvdecode casX, mv(9)
for num 18/65: mvdecode regX, mv(9)
for num 18/65: mvdecode selfX, mv(9)
for num 18/65: mvdecode sideX, mv(9)
for num 18/65: mvdecode fmwX, mv(9)
for num 18/65: replace weX=1 if casX!=. | regX!=. | selfX!=. | sideX!=. | fmwX!=. 
egen workexp2010=rowtotal(we18-we65)
keep id workexp2010 year
sort id
save "C:\Users\AyakaNakamura\Dropbox\materials\Works\Master\program\Submittion\Intermediate\WorkexpJHPS.dta", replace

*** KHPS労働経験年数
***** old cohort
use "C:\Users\AyakaNakamura\Dropbox\materials\Works\Master\program\Submittion\Intermediate\KHPS2004.dta", clear
for num 18/65: gen weX=0
for num 18/65: mvdecode casX, mv(9)
for num 18/65: mvdecode regX, mv(9)
for num 18/65: mvdecode selfX, mv(9)
for num 18/65: mvdecode sideX, mv(9)
for num 18/65: mvdecode fmwX, mv(9)
for num 18/65: replace weX=1 if casX!=. | regX!=. | selfX!=. | sideX!=. | fmwX!=. 
egen workexp2004=rowtotal(we18-we65)
keep id workexp2004 year
sort id
save "C:\Users\AyakaNakamura\Dropbox\materials\Works\Master\program\Submittion\Intermediate\WorkexpKHPS.dta", replace

***** new cohort 2007
use "C:\Users\AyakaNakamura\Dropbox\materials\Works\Master\program\Submittion\Intermediate\KHPS2007_new.dta", clear
for num 18/65: gen weX=0
for num 18/65: mvdecode casX, mv(9)
for num 18/65: mvdecode regX, mv(9)
for num 18/65: mvdecode selfX, mv(9)
for num 18/65: mvdecode sideX, mv(9)
for num 18/65: mvdecode fmwX, mv(9)
for num 18/65: replace weX=1 if casX!=. | regX!=. | selfX!=. | sideX!=. | fmwX!=. 
egen workexp2007=rowtotal(we18-we65)
keep id workexp2007 year
sort id
save "C:\Users\AyakaNakamura\Dropbox\materials\Works\Master\program\Submittion\Intermediate\WorkexpKHPS_new_2007.dta", replace

***** new cohort 2012
use "C:\Users\AyakaNakamura\Dropbox\materials\Works\Master\program\Submittion\Intermediate\KHPS2012_new.dta", clear
for num 18/65: gen weX=0
for num 18/65: mvdecode casX, mv(9)
for num 18/65: mvdecode regX, mv(9)
for num 18/65: mvdecode selfX, mv(9)
for num 18/65: mvdecode sideX, mv(9)
for num 18/65: mvdecode fmwX, mv(9)
for num 18/65: replace weX=1 if casX!=. | regX!=. | selfX!=. | sideX!=. | fmwX!=. 
egen workexp2012=rowtotal(we18-we65)
keep id workexp2012 year
sort id
save "C:\Users\AyakaNakamura\Dropbox\materials\Works\Master\program\Submittion\Intermediate\WorkexpKHPS_new_2012.dta", replace
}

** idと勤続年数を抽出
{
** JHPS勤続年数
use "C:\Users\AyakaNakamura\Dropbox\materials\Works\Master\program\Submittion\Intermediate\JHPS2009.dta", clear
keep id emptenure
replace emptenure=. if emptenure<0
sort id
save "C:\Users\AyakaNakamura\Dropbox\materials\Works\Master\program\Submittion\Intermediate\EmptenJHPS.dta", replace

** KHPS勤続年数
**** old cohort
use "C:\Users\AyakaNakamura\Dropbox\materials\Works\Master\program\Submittion\Intermediate\KHPS2004.dta", clear
keep id emptenure
replace emptenure=. if emptenure<0
sort id
save "C:\Users\AyakaNakamura\Dropbox\materials\Works\Master\program\Submittion\Intermediate\EmptenKHPS.dta", replace

**** new cohort 2007
use "C:\Users\AyakaNakamura\Dropbox\materials\Works\Master\program\Submittion\Intermediate\KHPS2007_new.dta", clear
keep id emptenure
replace emptenure=. if emptenure<0
sort id
save "C:\Users\AyakaNakamura\Dropbox\materials\Works\Master\program\Submittion\Intermediate\EmptenKHPS_new_2007.dta", replace

**** new cohort 2012
use "C:\Users\AyakaNakamura\Dropbox\materials\Works\Master\program\Submittion\Intermediate\KHPS2012_new.dta", clear
keep id emptenure
replace emptenure=. if emptenure<0
sort id
save "C:\Users\AyakaNakamura\Dropbox\materials\Works\Master\program\Submittion\Intermediate\EmptenKHPS_new_2012.dta", replace

}

** 学歴と就業履歴をサンプルにマージ
{
** idで学歴データをマージ
use "C:\Users\AyakaNakamura\Dropbox\materials\Works\Master\program\Submittion\Intermediate\JHPSKHPS_2004_2014.dta", clear
sort id year
merge m:1 id using "C:\Users\AyakaNakamura\Dropbox\materials\Works\Master\program\Submittion\Intermediate\Schooling.dta"
drop _merge

** idでサンプルに入ったときの労働経験をマージ
merge m:1 id using "C:\Users\AyakaNakamura\Dropbox\materials\Works\Master\program\Submittion\Intermediate\Cohort.dta"
drop _merge
merge m:1 id using "C:\Users\AyakaNakamura\Dropbox\materials\Works\Master\program\Submittion\Intermediate\WorkexpJHPS.dta"
drop _merge
merge m:1 id using "C:\Users\AyakaNakamura\Dropbox\materials\Works\Master\program\Submittion\Intermediate\WorkexpKHPS.dta"
drop _merge
merge m:1 id using "C:\Users\AyakaNakamura\Dropbox\materials\Works\Master\program\Submittion\Intermediate\WorkexpKHPS_new_2007.dta"
drop _merge
merge m:1 id using "C:\Users\AyakaNakamura\Dropbox\materials\Works\Master\program\Submittion\Intermediate\WorkexpKHPS_new_2012.dta"
drop _merge

** idでサンプルに入ったときの勤続年数をマージ
merge m:1 id using "C:\Users\AyakaNakamura\Dropbox\materials\Works\Master\program\Submittion\Intermediate\EmptenJHPS.dta"
drop _merge
rename emptenure empten2009
merge m:1 id using "C:\Users\AyakaNakamura\Dropbox\materials\Works\Master\program\Submittion\Intermediate\EmptenKHPS.dta"
drop _merge
rename emptenure empten2004
merge m:1 id using "C:\Users\AyakaNakamura\Dropbox\materials\Works\Master\program\Submittion\Intermediate\EmptenKHPS_new_2007.dta"
drop _merge
rename emptenure empten2007
merge m:1 id using "C:\Users\AyakaNakamura\Dropbox\materials\Works\Master\program\Submittion\Intermediate\EmptenKHPS_new_2012.dta"
drop _merge
rename emptenure empten2012

** データに入った年のサンプルにのみ労働経験年数を作成(他の年はworkexp=0)
*** experience
gen intexp=workexp2004 if workexp2004!=.
for num 2007 2010 2012: replace intexp=workexpX if workexpX!=.
sort id year
by id: gen workexp = intexp if _n==1&cohort!=9
replace workexp=intexp if cohort==9&year==2010
replace workexp=0 if workexp==.

*** emptenure
gen intten=empten2004 if empten2004!=.
for num 2007 2009 2012: replace intten=emptenX if emptenX!=.
sort id year
by id: gen emptenure = intten if _n==1
by id: replace emptenure=0 if emptenure==.&_n>1

*** 年間労働時間 = workhourperweek*52
gen workinghour=workhourperweek*52

*** 労働時間800時間以上ダミー作成
gen morethan800=0 if workinghour<800|workinghour==.
replace morethan800=1 if morethan800==.

*** パネル化
tsset id year

*** JHPSは2010の労働経験年数をもとに2009の労働経験年数を作成
replace workexp=workexp2010-1 if morethan800==1&cohort==9&year==2009
replace workexp=workexp2010 if morethan800==0&cohort==9&year==2009
}
}

* 8
** データクリーニング/欠損値の修正・賃金データ作成・失業率のマージ
{
** 欠損値の修正
{
*marital
replace marital=0 if marital==2
*empstlmonth　先月の勤務状況 0=仕事してない/1=仕事した
mvdecode workstatus, mv(9)
replace workstatus=1 if workstatus<=3
replace workstatus=0 if workstatus>3
*occ
for num 88 99: mvdecode occ, mv(X)
*owner
for num 8 9: mvdecode owner, mv(X)
*ind
for num 88 99: mvdecode ind, mv(X)
*size
** 1=1~4, 2=5~29, 3=30~99, 4=100~499, 5=500~, 6: 官公庁
** 大企業=500~, 中小企業=~499
replace size=1 if (size==1|size==2)&(year==2004)
replace size=2 if (size==3|size==4)&(year==2004)
replace size=3 if (size==5|size==6)&(year==2004)
replace size=4 if (size==7|size==8)&(year==2004)
replace size=5 if (size==9|size==10)&(year==2004)
replace size=6 if (size==11)&(year==2004)
replace size=0 if size<5
replace size=1 if size==5
for num  8 9 88 99: mvdecode size, mv(X)
*switch
for num 88 99: mvdecode switch, mv(X)
replace switch=0 if switch<=3 | switch==7 | switch==8
replace switch=1 if switch>=4&switch<=6
replace switch=0 if switch==.
*employed 1=勤め人
for num 8 9: mvdecode employed, mv(X)
replace employed=0 if employed<=4 | employed==6
replace employed=1 if employed==5
*regular 0=非正規/1=正規
for num 8 9: mvdecode regular, mv(X)
replace regular=0 if regular>=4 & regular!=.
replace regular=1 if regular!=0 & regular!=.
*union
replace union=0 if union<=2 | union==5
replace union=1 if union>1
for num 8 9: mvdecode union, mv(X)
*paymethod
for num 8 9: mvdecode paymethod, mv(X)
*monthlypaid
for num 88888 99999: mvdecode monthlypaid, mv(X)
*dailypaid
for num 888888 999999: mvdecode dailypaid, mv(X)
*hourlypaid
for num 888888 999999: mvdecode hourlypaid, mv(X)
*yearlypaid
for num 88888 99999: mvdecode yearlypaid, mv(X)
*bonus
for num 88888 99999: mvdecode bonus, mv(X)
*workdaypermonth
for num 88 99: mvdecode workdaypermonth, mv(X)
*workhourperweek
for num 888 999: mvdecode workhourperweek, mv(X)
*overworkperweek
for num 888 999: mvdecode overworkperweek, mv(X)
}

** 賃金データ作成
{
*** 賃金データの単位を合わせる(円)
replace monthlypaid=monthlypaid*1000
replace bonus=bonus*10000
replace yearlypaid=yearlypaid*10000

** 働き方に応じた年収を作成
gen income=0
*** 月給: monthlypaid*12+bonus
replace income=monthlypaid*12+bonus if paymethod==1|paymethod==2
*** 日給: dailypaid*workdaypermonth*12+bonus
replace income=dailypaid*workdaypermonth*12+bonus if paymethod==3
*** 時給: hourlypaid*workhourperweek*52+bonus
replace income=hourlypaid*workhourperweek*52+bonus if paymethod==4
*** 年俸: yearlypaid+bonus
replace income=yearlypaid+bonus
*** 支払い方法不明: 4パターンの年収のうちの最大値
replace income=max(monthlypaid*12+bonus, dailypaid*workdaypermonth*12+bonus, ////
hourlypaid*workhourperweek*52+bonus, yearlypaid+bonus)

** 時給を算出: income/workinghour
gen wage=income/workinghour

** 時給を実質化+失業率とインフレ率をマージ
gen realwage=0
merge m:1 year using "C:\Users\AyakaNakamura\Dropbox\materials\Works\Master\program\Submittion\Intermediate\InflateUnempRate.dta"
replace realwage=wage/infrate*100
drop _merge lagunemprate infrate
*** 時給250円以下を欠損値にする
replace realwage=. if realwage<250
*** 実質時給をlog化
replace realwage=log(realwage)
}
}

save  "C:\Users\AyakaNakamura\Dropbox\materials\Works\Master\program\Submittion\Input\jhps_hc_TenureCheck.dta", replace

* 9
** テニュア変数の作成
{
*** テニュア変数の基準
**** 労働時間が年間800時間以上&転職していない -> +1
***** サンプルが落ちている期間も就業を継続していたと仮定する
**** 労働時間が年間800時間未満- > stay
**** 転職した -> 0

*** パネル化
tsset id year

*** emptenure
forvalues X = 2005(1)2014{ 
	**** 労働時間800時間以上&転職してない->+1
	replace emptenure=emptenure[_n-1]+(year-year[_n-1]) ///
		if morethan800==1 & switch==0 & year==`X'
	**** 労働時間800時間未満&転職してない->+-0
	replace emptenure=emptenure[_n-1] ///
		if morethan800==0 & switch==0 & year==`X'
	**** 転職した->0
	replace emptenure=0 ///
		if switch==1 & year==`X'
	**** 最初のobservationは変更しない
	bysort id (year): replace emptenure=intten if _n==1
}
drop empten2* intten

*** workexp
forvalues X = 2005(1)2014{ 
	**** 労働時間800時間以上->+1
	bysort id (year): replace workexp=workexp[_n-1]+(year-year[_n-1]) ///
		if morethan800==1 & _n!=1 & year==`X'
	**** 労働時間800時間未満->+-0
	bysort id (year): replace workexp=workexp[_n-1] ///
		if morethan800==0 & _n!=1 & year==`X'
	**** 最初のobservationは変更しない
	bysort id (year): replace workexp=intexp if _n==1
}
drop workexp2* intexp

*** occtenure
gen occtenure = emptenure if _n==1
replace occtenure=0 if occtenure==.
bysort id (year): gen occswitch=0 if occ==occ[_n-1] | occ==. | occ[_n-1]==. | _n==1
replace occswitch=1 if occswitch==.

forvalues X = 2005(1)2014{ 
	**** 労働時間800時間以上&転職してない->+1
	replace occtenure=occtenure[_n-1]+(year-year[_n-1]) ///
		if morethan800==1 & occswitch==0 & year==`X'
	**** 労働時間800時間未満&転職してない->+-0
	replace occtenure=occtenure[_n-1] ///
		if morethan800==0 & occswitch==0 & year==`X' 
	**** 転職した->0
	replace occtenure=0 ///
		if occswitch==1 & occ!=. & occ[_n-1]!=. & year==`X'
	**** 最初のobservationは変更しない
	bysort id (year): replace occtenure=emptenure if _n==1
}

/*
gen indtenure = emptenure

*** indtenure
bysort id (year): gen indswitch=0 if ind==ind[_n-1] | ind==. | ind[_n-1]==. | _n==1
replace indswitch=1 if indswitch==.
forvalues X = 2005(1)2014{ 
	**** 労働時間800時間以上&転職してない->+1
	replace indtenure=indtenure[_n-1]+1 ///
		if morethan800==1 & indswitch==0 & year==`X'
	**** 労働時間800時間未満&転職してない->+-0
	replace indtenure=indtenure[_n-1] ///
		if morethan800==0 & indswitch==0 & year==`X' 
	**** 転職した->0
	replace indtenure=0 ///
		if indswitch==1 & ind!=. & ind[_n-1]!=. & year==`X'
	**** 最初のobservationは変更しない
	bysort id (year): replace indtenure=workexp if _n==1
}
*/

**** Old job dummy
*gen oj=1 if emptenure>0
*gen oj=1 if switch==0&emptenure>0
gen oj=1 if switch==0
replace oj=0 if oj==.

*** empidの作成
sort id year
by id: gen empid = 1 if _n==1|switch==1|emptenure<emptenure[_n-1]
replace empid=sum(empid)
}

save  "C:\Users\AyakaNakamura\Dropbox\materials\Works\Master\program\Submittion\Input\jhps_hc_AllSample.dta", replace

* 10
** サンプルの制限
{
*** 18歳～64歳のみ残す
keep if age>=18 & age<=64
*** 世帯主のみ残す
**** headは「世帯主はだれか?」に対する回答
**** earnmostは「家計で1番収入が多い人は?」に対する回答
* keep if head==1
keep if earnmost==1
*** 女性を落とす
drop if sex==2
drop sex
*** 雇用されていない人を落とす
drop if employed==0
drop employed
*** 官公庁を落とす
drop if size==6
keep if owner==1 | owner==2 | owner==3
drop owner
*** テニュア変数がマイナスのもの, 変な値のものを欠損値にする
replace emptenure=. if emptenure<0| emptenure>workexp
replace workexp=. if workexp<0
replace occtenure=. if occtenure<0
*** 年間労働時間500時間未満の時給を欠損値にする
replace realwage=. if workinghour<500
drop paymethod-overworkperweek cohort workinghour-wage
*** 配偶者サンプルのフラグを作成
gen sp =1 if (id>=10000&id<20000)|id>=30000
replace sp=0 if sp==.
*** 配偶者を落とす
drop if sp==1
/*
*** new_cohortのフラグを作成
gen new =1 if id>=40000
replace new=0 if new==.
*** new_cohortを落とす
drop if new==1
*/
}


save "C:\Users\AyakaNakamura\Dropbox\materials\Works\Master\program\Submittion\Input\jhps_hc.dta", replace

log close
