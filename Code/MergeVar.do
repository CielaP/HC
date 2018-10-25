*******************************************************
*Title: MergeVar
*Date: Oct 24th, 2018
*Written by Ayaka Nakamura
* 
* This file merges schooling and experience
* 
* 1. Select id, schooling and experience variable from initial survey
* 2. Merge 1 to other survey years
********************************************************

* Define folder location
local path $Path
local original $Original
local input $Input
local output $Output
local inter $Inter
disp "`path', `original', `input', `output', `inter' "


* 1. Select id, schooling and experience variable from initial survey
** schooling
local schoolingData JHPS2009 KHPS2004 KHPS2007_new KHPS2012_new
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
mvdecode edbg, mv(9)
gen schooling=9 if edbg==1
replace schooling=12 if edbg==2
replace schooling=14 if edbg==3 | edbg==6
replace schooling=16 if edbg==4 | edbg==5
tab edbg schooling
keep id schooling
save "`inter'\Schooling.dta", replace

/* 労働経験を聞いている年の変数名変更ファイルを作らないと回らない */
** working experience
local expData JHPS2010 KHPS2004 KHPS2007_new KHPS2012_new
local empStatus cas regu self side fmw
local num_k: word count `expData'
local num_m: word count `empStatus'

forvalues data_i = 1/`num_k' { /* loop within data set */
	local currentExpData: word `data_i' of `expData'
	use "`inter'/`currentExpData'.dta", clear
	for num 18/65: gen weX=0
	
	forvalues status_j = 1/`num_m'{
		local currentEmpStatus: word `status_j' of `empStatus'
		recode `currentEmpStatus'* (9 = 0)
	}
	
	forvalues X=18/65{
		replace weX=1 if cas`X'+regu`X'+self`X'+side`X'+fmw`X'>=1
	}
	sum we*
	
	egen intexp=rowtotal(we18-we65)
	keep id intexp
	
	** save data
	qui sum
	save "$Inter\Workexp`currentExpData'.dta", replace
}

*** bind all data
use "`inter'/WorkexpJHPS2010.dta", clear
forvalues data_i = 2/`num_k' { /* loop within data set */
	local currentExpData: word `data_i' of `expData'
	append using "`inter'/Workexp`currentExpData'.dta"
}
sort id
save "`inter'\Workexp.dta", replace

** employer tenure
local empData JHPS2009 KHPS2004 KHPS2007_new KHPS2012_new
local num_k: word count `empData'

forvalues data_i = 1/`num_k' { /* loop within data set */
	local currentEmpData: word `data_i' of `empData'
	use "`inter'/`currentEmpData'.dta", clear
	keep id emptenure
	replace emptenure=. if emptenure<0
	sort id
	*** save data
	qui sum
	save "$Inter\Empten`currentEmpData'.dta", replace
}


* 2. Merge 1 to other survey years
use "`inter'\JHPSKHPS_2004_2014.dta", clear

** make data into panel
sort id year
tsset id year

** merge schooling using id
merge m:1 id using "`inter'\Schooling.dta"
drop _merge

** merge experience using id
merge m:1 id using "`inter'\Workexp.dta"
drop _merge

** merge employer tenure using id

 
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


** 学歴と就業履歴をサンプルにマージ
{
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

*** 労働時間800時間以上ダミー作成
gen morethan800=0 if workinghour<800|workinghour==.
replace morethan800=1 if morethan800==.

*** パネル化
tsset id year

*** JHPSは2010の労働経験年数をもとに2009の労働経験年数を作成
replace workexp=workexp2010-1 if morethan800==1&cohort==9&year==2009
replace workexp=workexp2010 if morethan800==0&cohort==9&year==2009
}
