clear
set more off
 cd "C:\Users\AyakaNakamura\Dropbox\materials\Works\Master\program\Submittion"
 adopath + "C:\Users\AyakaNakamura\Dropbox\materials\Works\Master\program\Submittion"
 adopath + "C:\Users\AyakaNakamura\Dropbox\materials\Works\Master\program\Submittion\OriginalData"
 adopath + "C:\Users\AyakaNakamura\Dropbox\materials\Works\Master\program\Submittion\Intermediate"
 adopath + "C:\Users\AyakaNakamura\Dropbox\materials\Works\Master\program\Submittion\Output"
 adopath + "C:\Users\AyakaNakamura\Dropbox\materials\Works\Master\program\Submittion\Intput"
 adopath + "C:\Users\AyakaNakamura\Dropbox\materials\Works\Master\program\Submittion\coefplot"
 adopath + "C:\Users\AyakaNakamura\Dropbox\materials\Works\Master\program\coefplot"
 adopath + "C:\Users\AyakaNakamura\Dropbox\materials\Works\Master\program\estout"

* Estimation
** 1. OLS->AS / 基本の推定式1-4次項まで
** 2. OLS->AS / ability*tenure
** 3. OLS->AS / 60歳以下, 大企業, 中小企業, 専門職以外
** 4. OLS->AS / テニュアをダミーで
** 5. Topel / 基本の推定式1-4次項まで

* 1
** OLS->AS / 基本の推定式1-4次項まで
{
*** OLS
{
**** sample selection
quietly {
use "C:\Users\AyakaNakamura\Dropbox\materials\Works\Master\program\Submittion\Input\jhps_hc.dta", clear
destring, replace
tsset id year
}

**** empten
{
***** 2nd
reg realwage i.occ i.ind i.union i.marital i.year i.schooling i.size ///
c.emptenure##c.emptenure oj c.workexp##c.workexp, vce(r)
est sto olsemp2
***** 3rd
reg realwage i.occ i.ind i.union i.marital i.year i.schooling i.size ///
c.emptenure##c.emptenure##c.emptenure oj c.workexp##c.workexp##c.workexp, vce(r)
est sto olsemp3
***** 4th
reg realwage i.occ i.ind i.union i.marital i.year i.schooling i.size ///
c.emptenure##c.emptenure##c.emptenure##c.emptenure oj ///
c.workexp##c.workexp##c.workexp##c.workexp, vce(r)
est sto olsemp4
}

**** empten+occten
{
***** 2nd
reg realwage i.occ i.ind i.union i.marital i.year i.schooling i.size ///
c.emptenure##c.emptenure oj c.occtenure##c.occtenure c.workexp##c.workexp, vce(r)
est sto olsempocc2
***** 3rd
reg realwage i.occ i.ind i.union i.marital i.year i.schooling i.size ///
c.emptenure##c.emptenure##c.emptenure oj ///
c.occtenure##c.occtenure##c.occtenure c.workexp##c.workexp##c.workexp, vce(r)
est sto olsempocc3
***** 4th
reg realwage i.occ i.ind i.union i.marital i.year i.schooling i.size ///
c.emptenure##c.emptenure##c.emptenure##c.emptenure oj ///
c.occtenure##c.occtenure##c.occtenure##c.occtenure ///
c.workexp##c.workexp##c.workexp##c.workexp, vce(r)
est sto olsempocc4
}
}

*** AS
{
**** empten
{
***** 2nd
quietly {
use "C:\Users\AyakaNakamura\Dropbox\materials\Works\Master\program\Submittion\Input\jhps_hc.dta", clear
destring, replace
tsset id year
* 操作変数を作成
sort empid year
egen avgemptenure=mean(emptenure), by(empid)
egen avgemptenure2=mean(emptenure^2), by(empid)
egen avgemptenure3=mean(emptenure^3), by(empid)
gen emptenureiv=emptenure-avgemptenure
gen emptenureiv2=emptenure^2-avgemptenure2
gen emptenureiv3=emptenure^3-avgemptenure3
egen avgworkexp=mean(workexp), by(id)
egen avgworkexp2=mean(workexp^2), by(id)
egen avgworkexp3=mean(workexp^3), by(id)
gen workexpiv=workexp-avgworkexp
gen workexpiv2=workexp^2-avgworkexp2
gen workexpiv3=workexp^3-avgworkexp3
egen avgoj=mean(oj), by(empid)
gen ojiv=oj-avgoj
ivregress 2sls realwage i.occ i.ind i.union i.marital i.year i.schooling i.size ///
(c.emptenure##c.emptenure oj c.workexp##c.workexp = ///
emptenureiv emptenureiv2 ojiv workexpiv workexpiv2), vce(r)
est sto isvemp2
drop if _est_isvemp2==0
drop *iv *iv? avg*
* 必要な変数を再作成
egen avgemptenure=mean(emptenure), by(empid)
egen avgemptenure2=mean(emptenure^2), by(empid)
egen avgemptenure3=mean(emptenure^3), by(empid)
gen emptenureiv=emptenure-avgemptenure
gen emptenureiv2=emptenure^2-avgemptenure2
gen emptenureiv3=emptenure^3-avgemptenure3
egen avgworkexp=mean(workexp), by(id)
egen avgworkexp2=mean(workexp^2), by(id)
egen avgworkexp3=mean(workexp^3), by(id)
gen workexpiv=workexp-avgworkexp
gen workexpiv2=workexp^2-avgworkexp2
gen workexpiv3=workexp^3-avgworkexp3
egen avgoj=mean(oj), by(empid)
gen ojiv=oj-avgoj
}
* 再推定
ivregress 2sls realwage i.occ i.ind i.union i.marital i.year i.schooling i.size ///
(c.emptenure##c.emptenure oj c.workexp##c.workexp = ///
emptenureiv emptenureiv2 ojiv workexpiv workexpiv2), vce(r)
est sto isvemp2

***** 3rd
quietly {
use "C:\Users\AyakaNakamura\Dropbox\materials\Works\Master\program\Submittion\Input\jhps_hc.dta", clear
destring, replace
tsset id year
* 操作変数を作成
sort empid year
egen avgemptenure=mean(emptenure), by(empid)
egen avgemptenure2=mean(emptenure^2), by(empid)
egen avgemptenure3=mean(emptenure^3), by(empid)
gen emptenureiv=emptenure-avgemptenure
gen emptenureiv2=emptenure^2-avgemptenure2
gen emptenureiv3=emptenure^3-avgemptenure3
egen avgworkexp=mean(workexp), by(id)
egen avgworkexp2=mean(workexp^2), by(id)
egen avgworkexp3=mean(workexp^3), by(id)
gen workexpiv=workexp-avgworkexp
gen workexpiv2=workexp^2-avgworkexp2
gen workexpiv3=workexp^3-avgworkexp3
egen avgoj=mean(oj), by(empid)
gen ojiv=oj-avgoj
ivregress 2sls realwage i.occ i.ind i.union i.marital i.year i.schooling i.size ///
(c.emptenure##c.emptenure##c.emptenure oj c.workexp##c.workexp##c.workexp = ///
emptenureiv emptenureiv2 emptenureiv3 ojiv workexpiv workexpiv2 workexpiv3), vce(r)
est sto isvemp3
drop if _est_isvemp3==0
drop *iv *iv? avg*
* 必要な変数を再作成
egen avgemptenure=mean(emptenure), by(empid)
egen avgemptenure2=mean(emptenure^2), by(empid)
egen avgemptenure3=mean(emptenure^3), by(empid)
gen emptenureiv=emptenure-avgemptenure
gen emptenureiv2=emptenure^2-avgemptenure2
gen emptenureiv3=emptenure^3-avgemptenure3
egen avgworkexp=mean(workexp), by(id)
egen avgworkexp2=mean(workexp^2), by(id)
egen avgworkexp3=mean(workexp^3), by(id)
gen workexpiv=workexp-avgworkexp
gen workexpiv2=workexp^2-avgworkexp2
gen workexpiv3=workexp^3-avgworkexp3
egen avgoj=mean(oj), by(empid)
gen ojiv=oj-avgoj
}
* 再推定
ivregress 2sls realwage i.occ i.ind i.union i.marital i.year i.schooling i.size ///
(c.emptenure##c.emptenure##c.emptenure oj c.workexp##c.workexp##c.workexp = ///
emptenureiv emptenureiv2 emptenureiv3 ojiv workexpiv workexpiv2 workexpiv3), vce(r)
est sto isvemp3

***** 4th
quietly {
use "C:\Users\AyakaNakamura\Dropbox\materials\Works\Master\program\Submittion\Input\jhps_hc.dta", clear
destring, replace
tsset id year
* 操作変数を作成
sort empid year
egen avgemptenure=mean(emptenure), by(empid)
egen avgemptenure2=mean(emptenure^2), by(empid)
egen avgemptenure3=mean(emptenure^3), by(empid)
egen avgemptenure4=mean(emptenure^4), by(empid)
gen emptenureiv=emptenure-avgemptenure
gen emptenureiv2=emptenure^2-avgemptenure2
gen emptenureiv3=emptenure^3-avgemptenure3
gen emptenureiv4=emptenure^4-avgemptenure4
egen avgworkexp=mean(workexp), by(id)
egen avgworkexp2=mean(workexp^2), by(id)
egen avgworkexp3=mean(workexp^3), by(id)
egen avgworkexp4=mean(workexp^4), by(id)
gen workexpiv=workexp-avgworkexp
gen workexpiv2=workexp^2-avgworkexp2
gen workexpiv3=workexp^3-avgworkexp3
gen workexpiv4=workexp^4-avgworkexp4
egen avgoj=mean(oj), by(empid)
gen ojiv=oj-avgoj
ivregress 2sls realwage i.occ i.ind i.union i.marital i.year i.schooling i.size ///
(c.emptenure##c.emptenure##c.emptenure##c.emptenure oj ///
c.workexp##c.workexp##c.workexp##c.workexp = ///
emptenureiv emptenureiv2 emptenureiv3 emptenureiv4 ojiv ///
workexpiv workexpiv2 workexpiv3 workexpiv4), vce(r)
est sto isvemp4
drop if _est_isvemp4==0
drop *iv *iv? avg*
* 必要な変数を再作成
egen avgemptenure=mean(emptenure), by(empid)
egen avgemptenure2=mean(emptenure^2), by(empid)
egen avgemptenure3=mean(emptenure^3), by(empid)
egen avgemptenure4=mean(emptenure^4), by(empid)
gen emptenureiv=emptenure-avgemptenure
gen emptenureiv2=emptenure^2-avgemptenure2
gen emptenureiv3=emptenure^3-avgemptenure3
gen emptenureiv4=emptenure^4-avgemptenure4
egen avgworkexp=mean(workexp), by(id)
egen avgworkexp2=mean(workexp^2), by(id)
egen avgworkexp3=mean(workexp^3), by(id)
egen avgworkexp4=mean(workexp^4), by(id)
gen workexpiv=workexp-avgworkexp
gen workexpiv2=workexp^2-avgworkexp2
gen workexpiv3=workexp^3-avgworkexp3
gen workexpiv4=workexp^4-avgworkexp4
egen avgoj=mean(oj), by(empid)
gen ojiv=oj-avgoj
}
* 再推定
ivregress 2sls realwage i.occ i.ind i.union i.marital i.year i.schooling i.size ///
(c.emptenure##c.emptenure##c.emptenure##c.emptenure oj ///
c.workexp##c.workexp##c.workexp##c.workexp = ///
emptenureiv emptenureiv2 emptenureiv3 emptenureiv4 ojiv ///
workexpiv workexpiv2 workexpiv3 workexpiv4), vce(r)
est sto isvemp4
}

**** empten+occten
{
***** 2nd
quietly {
use "C:\Users\AyakaNakamura\Dropbox\materials\Works\Master\program\Submittion\Input\jhps_hc.dta", clear
destring, replace
tsset id year
* 操作変数を作成
sort empid year
egen avgemptenure=mean(emptenure), by(empid)
egen avgemptenure2=mean(emptenure^2), by(empid)
egen avgemptenure3=mean(emptenure^3), by(empid)
gen emptenureiv=emptenure-avgemptenure
gen emptenureiv2=emptenure^2-avgemptenure2
gen emptenureiv3=emptenure^3-avgemptenure3
egen avgocctenure=mean(occtenure), by(id occ)
egen avgocctenure2=mean(occtenure^2), by(id occ)
egen avgocctenure3=mean(occtenure^3), by(id occ)
gen occtenureiv=occtenure-avgocctenure
gen occtenureiv2=occtenure^2-avgocctenure2
gen occtenureiv3=occtenure^3-avgocctenure3
egen avgworkexp=mean(workexp), by(id)
egen avgworkexp2=mean(workexp^2), by(id)
egen avgworkexp3=mean(workexp^3), by(id)
gen workexpiv=workexp-avgworkexp
gen workexpiv2=workexp^2-avgworkexp2
gen workexpiv3=workexp^3-avgworkexp3
egen avgoj=mean(oj), by(empid)
gen ojiv=oj-avgoj
ivregress 2sls realwage i.occ i.ind i.union i.marital i.year i.schooling i.size ///
(c.emptenure##c.emptenure oj ///
c.occtenure##c.occtenure c.workexp##c.workexp = ///
emptenureiv emptenureiv2 ojiv ///
occtenureiv occtenureiv2 workexpiv workexpiv2), vce(r)
est sto isvempocc2
drop if _est_isvempocc2==0
drop *iv *iv? avg*
* 必要な変数を再作成
egen avgemptenure=mean(emptenure), by(empid)
egen avgemptenure2=mean(emptenure^2), by(empid)
egen avgemptenure3=mean(emptenure^3), by(empid)
gen emptenureiv=emptenure-avgemptenure
gen emptenureiv2=emptenure^2-avgemptenure2
gen emptenureiv3=emptenure^3-avgemptenure3
egen avgocctenure=mean(occtenure), by(id occ)
egen avgocctenure2=mean(occtenure^2), by(id occ)
egen avgocctenure3=mean(occtenure^3), by(id occ)
gen occtenureiv=occtenure-avgocctenure
gen occtenureiv2=occtenure^2-avgocctenure2
gen occtenureiv3=occtenure^3-avgocctenure3
egen avgworkexp=mean(workexp), by(id)
egen avgworkexp2=mean(workexp^2), by(id)
egen avgworkexp3=mean(workexp^3), by(id)
gen workexpiv=workexp-avgworkexp
gen workexpiv2=workexp^2-avgworkexp2
gen workexpiv3=workexp^3-avgworkexp3
egen avgoj=mean(oj), by(empid)
gen ojiv=oj-avgoj
}
* 再推定
ivregress 2sls realwage i.occ i.ind i.union i.marital i.year i.schooling i.size ///
(c.emptenure##c.emptenure oj ///
c.occtenure##c.occtenure c.workexp##c.workexp = ///
emptenureiv emptenureiv2 ojiv ///
occtenureiv occtenureiv2 workexpiv workexpiv2), vce(r)
est sto isvempocc2

***** 3rd
quietly {
use "C:\Users\AyakaNakamura\Dropbox\materials\Works\Master\program\Submittion\Input\jhps_hc.dta", clear
destring, replace
tsset id year
* 操作変数を作成
sort empid year
egen avgemptenure=mean(emptenure), by(empid)
egen avgemptenure2=mean(emptenure^2), by(empid)
egen avgemptenure3=mean(emptenure^3), by(empid)
gen emptenureiv=emptenure-avgemptenure
gen emptenureiv2=emptenure^2-avgemptenure2
gen emptenureiv3=emptenure^3-avgemptenure3
egen avgocctenure=mean(occtenure), by(id occ)
egen avgocctenure2=mean(occtenure^2), by(id occ)
egen avgocctenure3=mean(occtenure^3), by(id occ)
gen occtenureiv=occtenure-avgocctenure
gen occtenureiv2=occtenure^2-avgocctenure2
gen occtenureiv3=occtenure^3-avgocctenure3
egen avgworkexp=mean(workexp), by(id)
egen avgworkexp2=mean(workexp^2), by(id)
egen avgworkexp3=mean(workexp^3), by(id)
gen workexpiv=workexp-avgworkexp
gen workexpiv2=workexp^2-avgworkexp2
gen workexpiv3=workexp^3-avgworkexp3
egen avgoj=mean(oj), by(empid)
gen ojiv=oj-avgoj
ivregress 2sls realwage i.occ i.ind i.union i.marital i.year i.schooling i.size ///
(c.emptenure##c.emptenure##c.emptenure oj ///
c.occtenure##c.occtenure##c.occtenure c.workexp##c.workexp##c.workexp = ///
emptenureiv emptenureiv2 emptenureiv3 ojiv ///
occtenureiv occtenureiv2 occtenureiv3 workexpiv workexpiv2 workexpiv3), vce(r)
est sto isvempocc3
drop if _est_isvempocc3==0
drop *iv *iv? avg*
* 必要な変数を再作成
egen avgemptenure=mean(emptenure), by(empid)
egen avgemptenure2=mean(emptenure^2), by(empid)
egen avgemptenure3=mean(emptenure^3), by(empid)
gen emptenureiv=emptenure-avgemptenure
gen emptenureiv2=emptenure^2-avgemptenure2
gen emptenureiv3=emptenure^3-avgemptenure3
egen avgocctenure=mean(occtenure), by(id occ)
egen avgocctenure2=mean(occtenure^2), by(id occ)
egen avgocctenure3=mean(occtenure^3), by(id occ)
gen occtenureiv=occtenure-avgocctenure
gen occtenureiv2=occtenure^2-avgocctenure2
gen occtenureiv3=occtenure^3-avgocctenure3
egen avgworkexp=mean(workexp), by(id)
egen avgworkexp2=mean(workexp^2), by(id)
egen avgworkexp3=mean(workexp^3), by(id)
gen workexpiv=workexp-avgworkexp
gen workexpiv2=workexp^2-avgworkexp2
gen workexpiv3=workexp^3-avgworkexp3
egen avgoj=mean(oj), by(empid)
gen ojiv=oj-avgoj
}
ivregress 2sls realwage i.occ i.ind i.union i.marital i.year i.schooling i.size ///
(c.emptenure##c.emptenure##c.emptenure oj ///
c.occtenure##c.occtenure##c.occtenure c.workexp##c.workexp##c.workexp = ///
emptenureiv emptenureiv2 emptenureiv3 ojiv ///
occtenureiv occtenureiv2 occtenureiv3 workexpiv workexpiv2 workexpiv3), vce(r)
est sto isvempocc3

***** 4th
quietly {
use "C:\Users\AyakaNakamura\Dropbox\materials\Works\Master\program\Submittion\Input\jhps_hc.dta", clear
destring, replace
tsset id year
* 操作変数を作成
sort empid year
egen avgemptenure=mean(emptenure), by(empid)
egen avgemptenure2=mean(emptenure^2), by(empid)
egen avgemptenure3=mean(emptenure^3), by(empid)
egen avgemptenure4=mean(emptenure^4), by(empid)
gen emptenureiv=emptenure-avgemptenure
gen emptenureiv2=emptenure^2-avgemptenure2
gen emptenureiv3=emptenure^3-avgemptenure3
gen emptenureiv4=emptenure^4-avgemptenure4
egen avgocctenure=mean(occtenure), by(id occ)
egen avgocctenure2=mean(occtenure^2), by(id occ)
egen avgocctenure3=mean(occtenure^3), by(id occ)
egen avgocctenure4=mean(occtenure^4), by(id occ)
gen occtenureiv=occtenure-avgocctenure
gen occtenureiv2=occtenure^2-avgocctenure2
gen occtenureiv3=occtenure^3-avgocctenure3
gen occtenureiv4=occtenure^4-avgocctenure4
egen avgworkexp=mean(workexp), by(id)
egen avgworkexp2=mean(workexp^2), by(id)
egen avgworkexp3=mean(workexp^3), by(id)
egen avgworkexp4=mean(workexp^4), by(id)
gen workexpiv=workexp-avgworkexp
gen workexpiv2=workexp^2-avgworkexp2
gen workexpiv3=workexp^3-avgworkexp3
gen workexpiv4=workexp^4-avgworkexp4
egen avgoj=mean(oj), by(empid)
gen ojiv=oj-avgoj
ivregress 2sls realwage i.occ i.ind i.union i.marital i.year i.schooling i.size ///
(c.emptenure##c.emptenure##c.emptenure##c.emptenure oj ///
c.occtenure##c.occtenure##c.occtenure##c.occtenure ///
c.workexp##c.workexp##c.workexp##c.workexp = ///
emptenureiv emptenureiv2 emptenureiv3 emptenureiv4 ojiv ///
occtenureiv occtenureiv2 occtenureiv3 occtenureiv4 ///
workexpiv workexpiv2 workexpiv3 workexpiv4), vce(r)
est sto isvempocc4
drop if _est_isvempocc4==0
drop *iv *iv? avg*
egen avgemptenure=mean(emptenure), by(empid)
egen avgemptenure2=mean(emptenure^2), by(empid)
egen avgemptenure3=mean(emptenure^3), by(empid)
egen avgemptenure4=mean(emptenure^4), by(empid)
gen emptenureiv=emptenure-avgemptenure
gen emptenureiv2=emptenure^2-avgemptenure2
gen emptenureiv3=emptenure^3-avgemptenure3
gen emptenureiv4=emptenure^4-avgemptenure4
egen avgocctenure=mean(occtenure), by(id occ)
egen avgocctenure2=mean(occtenure^2), by(id occ)
egen avgocctenure3=mean(occtenure^3), by(id occ)
egen avgocctenure4=mean(occtenure^4), by(id occ)
gen occtenureiv=occtenure-avgocctenure
gen occtenureiv2=occtenure^2-avgocctenure2
gen occtenureiv3=occtenure^3-avgocctenure3
gen occtenureiv4=occtenure^4-avgocctenure4
egen avgworkexp=mean(workexp), by(id)
egen avgworkexp2=mean(workexp^2), by(id)
egen avgworkexp3=mean(workexp^3), by(id)
egen avgworkexp4=mean(workexp^4), by(id)
gen workexpiv=workexp-avgworkexp
gen workexpiv2=workexp^2-avgworkexp2
gen workexpiv3=workexp^3-avgworkexp3
gen workexpiv4=workexp^4-avgworkexp4
egen avgoj=mean(oj), by(empid)
gen ojiv=oj-avgoj
}
* 再推定
ivregress 2sls realwage i.occ i.ind i.union i.marital i.year i.schooling i.size ///
(c.emptenure##c.emptenure##c.emptenure##c.emptenure oj ///
c.occtenure##c.occtenure##c.occtenure##c.occtenure ///
c.workexp##c.workexp##c.workexp##c.workexp = ///
emptenureiv emptenureiv2 emptenureiv3 emptenureiv4 ojiv ///
occtenureiv occtenureiv2 occtenureiv3 occtenureiv4 ///
workexpiv workexpiv2 workexpiv3 workexpiv4), vce(r)
est sto isvempocc4
}

}

 *** culc. return
 {
**** empten
{
***** 2nd
est res olsemp2
margins, exp(_b[oj]+emptenure*_b[emptenure]+ ///
c.emptenure#c.emptenure*_b[c.emptenure#c.emptenure]) ///
at(emptenure=(0(1)25)) noe post
est sto olsempr2
est res isvemp2
margins, exp(_b[oj]+emptenure*_b[emptenure]+ ///
c.emptenure#c.emptenure*_b[c.emptenure#c.emptenure]) ///
at(emptenure=(0(1)25)) noe post
est sto isvempr2
coefplot (olsempr2, label(OLS)) (isvempr2, label(IV)), ///
at ciopts(recast(rline) lpattern(dash)) recast(connected) ///
xtitle("Employer Tenure") ytitle("Returns to Tenure on Earnings (%)") ///
title("Earnings Function Estimation.") yline(0) rescale(100)
graph export "C:\Users\AyakaNakamura\Dropbox\materials\Works\Master\program\Submittion\Output\plot_as_emp_2.pdf", replace
 
***** 3rd
est res olsemp3
margins, exp(_b[oj]+emptenure*_b[emptenure]+ ///
c.emptenure#c.emptenure*_b[c.emptenure#c.emptenure] ///
+c.emptenure#c.emptenure#c.emptenure*_b[c.emptenure#c.emptenure#c.emptenure]) ///
at(emptenure=(0(1)25)) noe post
est sto olsempr3
est res isvemp3
margins, exp(_b[oj]+emptenure*_b[emptenure]+ ///
c.emptenure#c.emptenure*_b[c.emptenure#c.emptenure] ///
+c.emptenure#c.emptenure#c.emptenure*_b[c.emptenure#c.emptenure#c.emptenure]) ///
at(emptenure=(0(1)25)) noe post
est sto isvempr3
coefplot (olsempr3, label(OLS)) (isvempr3, label(IV)), ///
at ciopts(recast(rline) lpattern(dash)) recast(connected) ///
xtitle("Employer Tenure") ytitle("Returns to Tenure on Earnings (%)") ///
title("Earnings Function Estimation.") yline(0) rescale(100)
graph export "C:\Users\AyakaNakamura\Dropbox\materials\Works\Master\program\Submittion\Output\plot_as_emp_3.pdf", replace

***** 4th
est res olsemp4
margins, exp(_b[oj]+emptenure*_b[emptenure]+ ///
c.emptenure#c.emptenure*_b[c.emptenure#c.emptenure] ///
+c.emptenure#c.emptenure#c.emptenure*_b[c.emptenure#c.emptenure#c.emptenure] ///
+c.emptenure#c.emptenure#c.emptenure#c.emptenure* ///
_b[c.emptenure#c.emptenure#c.emptenure#c.emptenure]) ///
at(emptenure=(0(1)25)) noe post
est sto olsempr4
est res isvemp4
margins, exp(_b[oj]+emptenure*_b[emptenure]+ ///
c.emptenure#c.emptenure*_b[c.emptenure#c.emptenure] ///
+c.emptenure#c.emptenure#c.emptenure*_b[c.emptenure#c.emptenure#c.emptenure] ///
+c.emptenure#c.emptenure#c.emptenure#c.emptenure* ///
_b[c.emptenure#c.emptenure#c.emptenure#c.emptenure]) ///
at(emptenure=(0(1)25)) noe post
est sto isvempr4
coefplot (olsempr4, label(OLS)) (isvempr4, label(IV)), ///
at ciopts(recast(rline) lpattern(dash)) recast(connected) ///
xtitle("Employer Tenure") ytitle("Returns to Tenure on Earnings (%)") ///
title("Earnings Function Estimation.") yline(0) rescale(100)
graph export "C:\Users\AyakaNakamura\Dropbox\materials\Works\Master\program\Submittion\Output\plot_as_emp_4.pdf", replace
 }
 
**** empten+occten
{
***** 2nd
est res olsempocc2
margins, exp(_b[oj]+emptenure*_b[emptenure]+ ///
c.emptenure#c.emptenure*_b[c.emptenure#c.emptenure]) ///
at(emptenure=(0(1)25)) noe post
est sto olsempoccr2
est res isvempocc2
margins, exp(_b[oj]+emptenure*_b[emptenure]+ ///
c.emptenure#c.emptenure*_b[c.emptenure#c.emptenure]) ///
at(emptenure=(0(1)25)) noe post
est sto isvempoccr2
coefplot (olsempr2, label(OLS)) (isvempr2, label(IV)), ///
at ciopts(recast(rline) lpattern(dash)) recast(connected) ///
xtitle("Employer Tenure") ytitle("Returns to Tenure on Earnings (%)") ///
title("Earnings Function Estimation.") yline(0) rescale(100)
graph export "C:\Users\AyakaNakamura\Dropbox\materials\Works\Master\program\Submittion\Output\plot_as_empocc_2.pdf", replace

***** 3rd
est res olsempocc3
margins, exp(_b[oj]+emptenure*_b[emptenure]+ ///
c.emptenure#c.emptenure*_b[c.emptenure#c.emptenure] ///
+c.emptenure#c.emptenure#c.emptenure*_b[c.emptenure#c.emptenure#c.emptenure]) ///
at(emptenure=(0(1)25)) noe post
est sto olsempoccr3
est res isvempocc3
margins, exp(_b[oj]+emptenure*_b[emptenure]+ ///
c.emptenure#c.emptenure*_b[c.emptenure#c.emptenure] ///
+c.emptenure#c.emptenure#c.emptenure*_b[c.emptenure#c.emptenure#c.emptenure]) ///
at(emptenure=(0(1)25)) noe post
est sto isvempoccr3
coefplot (olsempr3, label(OLS)) (isvempr3, label(IV)), ///
at ciopts(recast(rline) lpattern(dash)) recast(connected) ///
xtitle("Employer Tenure") ytitle("Returns to Tenure on Earnings (%)") ///
title("Earnings Function Estimation.") yline(0) rescale(100)
graph export "C:\Users\AyakaNakamura\Dropbox\materials\Works\Master\program\Submittion\Output\plot_as_empocc_3.pdf", replace

***** 4th
est res olsempocc4
margins, exp(_b[oj]+emptenure*_b[emptenure]+ ///
c.emptenure#c.emptenure*_b[c.emptenure#c.emptenure] ///
+c.emptenure#c.emptenure#c.emptenure*_b[c.emptenure#c.emptenure#c.emptenure] ///
+c.emptenure#c.emptenure#c.emptenure#c.emptenure* ///
_b[c.emptenure#c.emptenure#c.emptenure#c.emptenure]) ///
at(emptenure=(0(1)25)) noe post
est sto olsempoccr4
est res isvempocc4
margins, exp(_b[oj]+emptenure*_b[emptenure]+ ///
c.emptenure#c.emptenure*_b[c.emptenure#c.emptenure] ///
+c.emptenure#c.emptenure#c.emptenure*_b[c.emptenure#c.emptenure#c.emptenure] ///
+c.emptenure#c.emptenure#c.emptenure#c.emptenure* ///
_b[c.emptenure#c.emptenure#c.emptenure#c.emptenure]) ///
at(emptenure=(0(1)25)) noe post
est sto isvempoccr4
coefplot (olsempr4, label(OLS)) (isvempr4, label(IV)), ///
at ciopts(recast(rline) lpattern(dash)) recast(connected) ///
xtitle("Employer Tenure") ytitle("Returns to Tenure on Earnings (%)") ///
title("Earnings Function Estimation.") yline(0) rescale(100)
graph export "C:\Users\AyakaNakamura\Dropbox\materials\Works\Master\program\Submittion\Output\plot_as_empocc_4.pdf", replace
}
}
 
*** output tex all results
{
**** coefficients / emptenure
quietly {
esttab olsemp2 olsemp3 olsemp4 isvemp2 isvemp3 isvemp4 ///
using "C:\Users\AyakaNakamura\Dropbox\materials\Works\Master\program\Submittion\Output\as_emp.tex", ///
se star(* 0.1 ** 0.05 *** 0.01) b(4) ///
keep(emptenure c.emptenure#c.emptenure c.emptenure#c.emptenure#c.emptenure ///
c.emptenure#c.emptenure#c.emptenure#c.emptenure ///
oj workexp c.workexp#c.workexp c.workexp#c.workexp#c.workexp) ///
order(emptenure c.emptenure#c.emptenure c.emptenure#c.emptenure#c.emptenure ///
c.emptenure#c.emptenure#c.emptenure#c.emptenure ///
oj workexp c.workexp#c.workexp c.workexp#c.workexp#c.workexp) ///
coeflabel(emptenure "Employer tenure" ///
c.emptenure#c.emptenure "Emp.ten.$^{2}\times 100$" ///
c.emptenure#c.emptenure#c.emptenure "Emp.ten.$^{3}\times 100$" ///
c.emptenure#c.emptenure#c.emptenure#c.emptenure "Emp.ten.$^{4}\times 1000$" ///
occtenure "Occupation tenure" c.occtenure#c.occtenure "Occ.ten.$^{2}\times 100$" ///
c.occtenure#c.occtenure#c.occtenure "Occ.ten.$^{3}\times 100$" ///
oj "Old job" workexp "Total experience" c.workexp#c.workexp "Experience$^{2}$" ///
c.workexp#c.workexp#c.workexp "Exp.$^{3}\times 100$") ///
transform(c.emptenure#c.emptenure 100*@ 100 ///
c.emptenure#c.emptenure#c.emptenure 100*@ 100 ///
c.emptenure#c.emptenurec.emptenure#c.emptenure 1000*@ 1000 ///
c.occtenure#c.occtenure 100*@ 100 ///
c.occtenure#c.occtenure#c.occtenure 100*@ 100 ///
c.workexp#c.workexp#c.workexp 100*@ 100) ///
nodep nonote nomtitles ///
title(Earnings Function Estimates, using to 64-year-old, ///
including Non-regular Workers and Specialists.) ///
mgroups("OLS" "IV" ///
pattern(1 0 0 1 0 0) ///
prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) ///
replace
}

**** coefficients / emp+occ
quietly {
esttab olsempocc2 olsempocc3 olsempocc4 isvempocc2 isvempocc3 isvempocc4 ///
using "C:\Users\AyakaNakamura\Dropbox\materials\Works\Master\program\Submittion\Output\as_empocc.tex", ///
se star(* 0.1 ** 0.05 *** 0.01) b(4) ///
keep(emptenure c.emptenure#c.emptenure c.emptenure#c.emptenure#c.emptenure ///
c.emptenure#c.emptenure#c.emptenure#c.emptenure ///
occtenure c.occtenure#c.occtenure c.occtenure#c.occtenure#c.occtenure ///
oj workexp c.workexp#c.workexp c.workexp#c.workexp#c.workexp) ///
order(emptenure c.emptenure#c.emptenure c.emptenure#c.emptenure#c.emptenure ///
c.emptenure#c.emptenure#c.emptenure#c.emptenure ///
occtenure c.occtenure#c.occtenure c.occtenure#c.occtenure#c.occtenure ///
oj workexp c.workexp#c.workexp c.workexp#c.workexp#c.workexp) ///
coeflabel(emptenure "Employer tenure" ///
c.emptenure#c.emptenure "Emp.ten.$^{2}\times 100$" ///
c.emptenure#c.emptenure#c.emptenure "Emp.ten.$^{3}\times 100$" ///
c.emptenure#c.emptenure#c.emptenure#c.emptenure "Emp.ten.$^{4}\times 1000$" ///
occtenure "Occupation tenure" c.occtenure#c.occtenure "Occ.ten.$^{2}\times 100$" ///
c.occtenure#c.occtenure#c.occtenure "Occ.ten.$^{3}\times 100$" ///
oj "Old job" workexp "Total experience" c.workexp#c.workexp "Experience$^{2}$" ///
c.workexp#c.workexp#c.workexp "Exp.$^{3}\times 100$") ///
transform(c.emptenure#c.emptenure 100*@ 100 ///
c.emptenure#c.emptenure#c.emptenure 100*@ 100 ///
c.emptenure#c.emptenurec.emptenure#c.emptenure 1000*@ 1000 ///
c.occtenure#c.occtenure 100*@ 100 ///
c.occtenure#c.occtenure#c.occtenure 100*@ 100 ///
c.workexp#c.workexp#c.workexp 100*@ 100) ///
nodep nonote nomtitles ///
title(Earnings Function Estimates, using to 64-year-old, ///
including Non-regular Workers and Specialists.) ///
mgroups("OLS" "IV" ///
pattern(1 0 0 1 0 0) ///
prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) ///
replace
}

**** main table
quietly{
esttab olsemp2 olsempocc2 isvemp2 isvempocc2 ///
using "C:\Users\AyakaNakamura\Dropbox\materials\Works\Master\program\Submittion\Output\as_main.tex", ///
se star(* 0.1 ** 0.05 *** 0.01) b(4) ///
keep(emptenure c.emptenure#c.emptenure ///
occtenure c.occtenure#c.occtenure c.occtenure#c.occtenure#c.occtenure ///
oj workexp c.workexp#c.workexp c.workexp#c.workexp#c.workexp) ///
order(emptenure c.emptenure#c.emptenure ///
occtenure c.occtenure#c.occtenure c.occtenure#c.occtenure#c.occtenure ///
oj workexp c.workexp#c.workexp c.workexp#c.workexp#c.workexp) ///
coeflabel(emptenure "Employer tenure" ///
c.emptenure#c.emptenure "Emp.ten.$^{2}\times 100$" ///
occtenure "Occupation tenure" c.occtenure#c.occtenure "Occ.ten.$^{2}\times 100$" ///
c.occtenure#c.occtenure#c.occtenure "Occ.ten.$^{3}\times 100$" ///
oj "Old job" workexp "Total experience" c.workexp#c.workexp "Experience$^{2}$" ///
c.workexp#c.workexp#c.workexp "Exp.$^{3}\times 100$") ///
transform(c.emptenure#c.emptenure 100*@ 100 ///
c.occtenure#c.occtenure 100*@ 100 ///
c.occtenure#c.occtenure#c.occtenure 100*@ 100 ///
c.workexp#c.workexp#c.workexp 100*@ 100) ///
nodep nonote nomtitles ///
title(Earnings Function Estimates, using to 64-year-old, ///
including Non-regular Workers and Specialists.) ///
mgroups("OLS" "IV" ///
pattern(1 0 1 0) ///
prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) ///
replace
}

**** return
quietly{
esttab olsempr2 olsempoccr2 isvempr2 isvempoccr2 ///
using "C:\Users\AyakaNakamura\Dropbox\materials\Works\Master\program\Submittion\Output\as_return.tex", ///
se star(* 0.1 ** 0.05 *** 0.01) b(4) ///
keep(3._at 6._at 11._at 16._at 21._at 26._at) ///
coeflabel(3._at "2 Years" ///
6._at "5 Years" 11._at "10 Years" ///
16._at "15 Years" ///
21._at "20 Years" 26._at "25 Years") ///
nodep nonote nomtitles ///
title(Estimated Returns to Employer Tenure.) ///
mgroups("OLS" "IV" ///
pattern(1 0 1 0) ///
prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) ///
replace
}
}
}

* 2
** OLS->AS / ability*tenure
 {
*** OLS
 {
**** sample selection
quietly {
use "C:\Users\AyakaNakamura\Dropbox\materials\Works\Master\program\Submittion\Input\jhps_hc.dta", clear
destring, replace
tsset id year
}

**** empten
***** schooling
reg realwage i.occ i.ind i.union i.marital i.year i.regular i.size ///
c.emptenure##i.schooling ///
c.emptenure##c.emptenure oj c.workexp##c.workexp, vce(r)
est sto olsempsc

***** regular
reg realwage i.occ i.ind i.union i.marital i.year i.schooling i.size ///
c.emptenure##i.regular ///
c.emptenure##c.emptenure oj c.workexp##c.workexp, vce(r)
est sto olsregular

***** size
reg realwage i.occ i.ind i.union i.marital i.year i.regular i.schooling ///
c.emptenure##i.size ///
c.emptenure##c.emptenure oj c.workexp##c.workexp, vce(r)
est sto olsempsi
}

*** AS
{
***** schooling
quietly {
use "C:\Users\AyakaNakamura\Dropbox\materials\Works\Master\program\Submittion\Input\jhps_hc.dta", clear
destring, replace
tsset id year
* 操作変数を作成
sort empid year
egen avgemptenure=mean(emptenure), by(empid)
egen avgemptenure2=mean(emptenure^2), by(empid)
egen avgemptenure3=mean(emptenure^3), by(empid)
gen emptenureiv=emptenure-avgemptenure
gen emptenureiv2=emptenure^2-avgemptenure2
gen emptenureiv3=emptenure^3-avgemptenure3
egen avgworkexp=mean(workexp), by(id)
egen avgworkexp2=mean(workexp^2), by(id)
egen avgworkexp3=mean(workexp^3), by(id)
gen workexpiv=workexp-avgworkexp
gen workexpiv2=workexp^2-avgworkexp2
gen workexpiv3=workexp^3-avgworkexp3
egen avgoj=mean(oj), by(empid)
gen ojiv=oj-avgoj
tabulate schooling, generate(edu)
for X in num 1/5 \ Y in num 9 12 14 16 18 : rename eduX eduY
for X in num 9 12 14 16 18 : gen empscivX=emptenureiv*eduX
* 再推定
ivregress 2sls realwage i.occ i.ind i.union i.marital i.year i.regular i.schooling i.size ///
(c.emptenure##c.emptenure ///
c.emptenure#i.schooling oj ///
c.workexp##c.workexp = ///
emptenureiv emptenureiv2 ///
empsciv9 empsciv12 empsciv14 empsciv16 empsciv18 ojiv ///
workexpiv workexpiv2), vce(r)
est sto isvempsc
drop if _est_isvempsc==0
drop *iv *iv* avg*
* 必要な変数を再作成
egen avgemptenure=mean(emptenure), by(empid)
egen avgemptenure2=mean(emptenure^2), by(empid)
egen avgemptenure3=mean(emptenure^3), by(empid)
gen emptenureiv=emptenure-avgemptenure
gen emptenureiv2=emptenure^2-avgemptenure2
gen emptenureiv3=emptenure^3-avgemptenure3
egen avgworkexp=mean(workexp), by(id)
egen avgworkexp2=mean(workexp^2), by(id)
egen avgworkexp3=mean(workexp^3), by(id)
gen workexpiv=workexp-avgworkexp
gen workexpiv2=workexp^2-avgworkexp2
gen workexpiv3=workexp^3-avgworkexp3
egen avgoj=mean(oj), by(empid)
gen ojiv=oj-avgoj
for X in num 9 12 14 16 18 : gen empscivX=emptenureiv*eduX
}
 * 再推定
ivregress 2sls realwage i.occ i.ind i.union i.marital i.year i.regular i.schooling i.size ///
(c.emptenure##c.emptenure ///
c.emptenure#i.schooling oj ///
c.workexp##c.workexp = ///
emptenureiv emptenureiv2 ///
empsciv9 empsciv12 empsciv14 empsciv16 empsciv18 ojiv ///
workexpiv workexpiv2), vce(r)
est sto isvempsc

***** regular
quietly {
use "C:\Users\AyakaNakamura\Dropbox\materials\Works\Master\program\Submittion\Input\jhps_hc.dta", clear
destring, replace
tsset id year
* 操作変数を作成
sort empid year
egen avgemptenure=mean(emptenure), by(empid)
egen avgemptenure2=mean(emptenure^2), by(empid)
egen avgemptenure3=mean(emptenure^3), by(empid)
gen emptenureiv=emptenure-avgemptenure
gen emptenureiv2=emptenure^2-avgemptenure2
gen emptenureiv3=emptenure^3-avgemptenure3
egen avgworkexp=mean(workexp), by(id)
egen avgworkexp2=mean(workexp^2), by(id)
egen avgworkexp3=mean(workexp^3), by(id)
gen workexpiv=workexp-avgworkexp
gen workexpiv2=workexp^2-avgworkexp2
gen workexpiv3=workexp^3-avgworkexp3
egen avgoj=mean(oj), by(empid)
gen ojiv=oj-avgoj
gen regulariv=emptenureiv*regular
ivregress 2sls realwage i.occ i.ind i.union i.marital i.year i.regular i.schooling i.size ///
(c.emptenure##c.emptenure ///
c.emptenure#i.regular oj ///
c.workexp##c.workexp = ///
emptenureiv emptenureiv2 ///
regulariv ojiv ///
workexpiv workexpiv2), vce(r)
est sto isvregular
drop if _est_isvregular==0
drop *iv *iv? avg*
* 必要な変数を再作成
egen avgemptenure=mean(emptenure), by(empid)
egen avgemptenure2=mean(emptenure^2), by(empid)
egen avgemptenure3=mean(emptenure^3), by(empid)
gen emptenureiv=emptenure-avgemptenure
gen emptenureiv2=emptenure^2-avgemptenure2
gen emptenureiv3=emptenure^3-avgemptenure3
egen avgworkexp=mean(workexp), by(id)
egen avgworkexp2=mean(workexp^2), by(id)
egen avgworkexp3=mean(workexp^3), by(id)
gen workexpiv=workexp-avgworkexp
gen workexpiv2=workexp^2-avgworkexp2
gen workexpiv3=workexp^3-avgworkexp3
egen avgoj=mean(oj), by(empid)
gen ojiv=oj-avgoj
gen regulariv=emptenureiv*regular
}
 * 再推定
ivregress 2sls realwage i.occ i.ind i.union i.marital i.year i.regular i.schooling i.size ///
(c.emptenure##c.emptenure ///
c.emptenure#i.regular oj ///
c.workexp##c.workexp = ///
emptenureiv emptenureiv2 ///
regulariv ojiv ///
workexpiv workexpiv2), vce(r)
est sto isvregular

***** size
quietly {
use "C:\Users\AyakaNakamura\Dropbox\materials\Works\Master\program\Submittion\Input\jhps_hc.dta", clear
destring, replace
tsset id year
* 操作変数を作成
sort empid year
egen avgemptenure=mean(emptenure), by(empid)
egen avgemptenure2=mean(emptenure^2), by(empid)
egen avgemptenure3=mean(emptenure^3), by(empid)
gen emptenureiv=emptenure-avgemptenure
gen emptenureiv2=emptenure^2-avgemptenure2
gen emptenureiv3=emptenure^3-avgemptenure3
egen avgworkexp=mean(workexp), by(id)
egen avgworkexp2=mean(workexp^2), by(id)
egen avgworkexp3=mean(workexp^3), by(id)
gen workexpiv=workexp-avgworkexp
gen workexpiv2=workexp^2-avgworkexp2
gen workexpiv3=workexp^3-avgworkexp3
egen avgoj=mean(oj), by(empid)
gen ojiv=oj-avgoj
tabulate size, generate(si)
for X in num 1/5 : gen empscivX=emptenureiv*siX
ivregress 2sls realwage i.occ i.ind i.union i.marital i.year i.regular i.schooling i.size ///
(c.emptenure##c.emptenure ///
c.emptenure#i.size oj ///
c.workexp##c.workexp = ///
emptenureiv emptenureiv2 ///
empsciv1 empsciv2 empsciv3 empsciv4 empsciv5 ojiv ///
workexpiv workexpiv2), vce(r)
est sto isvempsi
drop if _est_isvempsi==0
drop *iv *iv? avg*
* 必要な変数を再作成
egen avgemptenure=mean(emptenure), by(empid)
egen avgemptenure2=mean(emptenure^2), by(empid)
egen avgemptenure3=mean(emptenure^3), by(empid)
gen emptenureiv=emptenure-avgemptenure
gen emptenureiv2=emptenure^2-avgemptenure2
gen emptenureiv3=emptenure^3-avgemptenure3
egen avgworkexp=mean(workexp), by(id)
egen avgworkexp2=mean(workexp^2), by(id)
egen avgworkexp3=mean(workexp^3), by(id)
gen workexpiv=workexp-avgworkexp
gen workexpiv2=workexp^2-avgworkexp2
gen workexpiv3=workexp^3-avgworkexp3
egen avgoj=mean(oj), by(empid)
gen ojiv=oj-avgoj
for X in num 1/5 : gen empscivX=emptenureiv*siX
}
* 再推定
ivregress 2sls realwage i.occ i.ind i.union i.marital i.year i.regular i.schooling i.size ///
(c.emptenure##c.emptenure ///
c.emptenure#i.size oj ///
c.workexp##c.workexp = ///
emptenureiv emptenureiv2 ///
empsciv1 empsciv2 empsciv3 empsciv4 empsciv5 ojiv ///
workexpiv workexpiv2), vce(r)
est sto isvempsi
}

 *** culc. return
 {
**** schooling
est res olsempsc
margins, exp(_b[oj]+emptenure*_b[emptenure]+ ///
c.emptenure#c.emptenure*_b[c.emptenure#c.emptenure]) ///
at(emptenure=(0(1)25)) noe post
est sto olsempnsc
est res isvempsc
margins, exp(_b[oj]+emptenure*_b[emptenure]+ ///
c.emptenure#c.emptenure*_b[c.emptenure#c.emptenure]) ///
at(emptenure=(0(1)25)) noe post
est sto isvempnsc
coefplot (olsempnsc, label(OLS)) (isvempnsc, label(IV)), ///
at ciopts(recast(rline) lpattern(dash)) recast(connected) ///
xtitle("Employer Tenure") ytitle("Returns to Tenure on Earnings (%)") ///
title("Earnings Function Estimation.") yline(0) rescale(100)
graph export "C:\Users\AyakaNakamura\Dropbox\materials\Works\Master\program\Submittion\Output\plot_as_emp_sc.pdf", replace
 
**** regular
est res olsregular
margins, exp(_b[oj]+emptenure*_b[emptenure]+ ///
c.emptenure#c.emptenure*_b[c.emptenure#c.emptenure]) ///
at(emptenure=(0(1)25)) noe post
est sto olsempnst
est res isvregular
margins, exp(_b[oj]+emptenure*_b[emptenure]+ ///
c.emptenure#c.emptenure*_b[c.emptenure#c.emptenure]) ///
at(emptenure=(0(1)25)) noe post
est sto isvempnst
coefplot (olsempnst, label(OLS)) (isvempnst, label(IV)), ///
at ciopts(recast(rline) lpattern(dash)) recast(connected) ///
xtitle("Employer Tenure") ytitle("Returns to Tenure on Earnings (%)") ///
title("Earnings Function Estimation.") yline(0) rescale(100)
graph export "C:\Users\AyakaNakamura\Dropbox\materials\Works\Master\program\Submittion\Output\plot_as_emp_rg.pdf", replace
 
**** size
est res olsempsi
margins, exp(_b[oj]+emptenure*_b[emptenure]+ ///
c.emptenure#c.emptenure*_b[c.emptenure#c.emptenure]) ///
at(emptenure=(0(1)25)) noe post
est sto olsempnsi
est res isvempsi
margins, exp(_b[oj]+emptenure*_b[emptenure]+ ///
c.emptenure#c.emptenure*_b[c.emptenure#c.emptenure]) ///
at(emptenure=(0(1)25)) noe post
est sto isvempnsi
coefplot (olsempnsi, label(OLS)) (isvempnsi, label(IV)), ///
at ciopts(recast(rline) lpattern(dash)) recast(connected) ///
xtitle("Employer Tenure") ytitle("Returns to Tenure on Earnings (%)") ///
title("Earnings Function Estimation.") yline(0) rescale(100)
graph export "C:\Users\AyakaNakamura\Dropbox\materials\Works\Master\program\Submittion\Output\plot_as_emp_si.pdf", replace
 }
 
*** output tex all results
{
**** coefficients 
quietly {
esttab olsempsc isvempsc olsregular isvregular olsempsi isvempsi ///
using "C:\Users\AyakaNakamura\Dropbox\materials\Works\Master\program\Submittion\Output\as_emp_ab.tex", ///
se star(* 0.1 ** 0.05 *** 0.01) b(4) ///
keep(emptenure c.emptenure#c.emptenure ///
oj workexp c.workexp#c.workexp) ///
order(emptenure c.emptenure#c.emptenure ///
oj workexp c.workexp#c.workexp) ///
coeflabel(emptenure "Employer tenure" ///
c.emptenure#c.emptenure "Emp.ten.$^{2}\times 100$" ///
oj "Old job" workexp "Total experience" c.workexp#c.workexp "Experience$^{2}$") ///
transform(c.emptenure#c.emptenure 100*@ 100) ///
nodep nonote nomtitles ///
title(Earnings Function Estimates, adding the Interaction of Employer Tenure and Ability.) ///
mgroups("Years of Education" "Regular Employee" "Firm Size" ///
pattern(1 0 1 0 1 0) ///
prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) ///
replace
}

**** return
quietly {
esttab olsempnsc isvempnsc olsempnst isvempnst olsempnsi isvempnsi ///
using "C:\Users\AyakaNakamura\Dropbox\materials\Works\Master\program\Submittion\Output\as_teturn_ab.tex", ///
se star(* 0.1 ** 0.05 *** 0.01) b(4) ///
keep(3._at 6._at 11._at 16._at 21._at 26._at) ///
coeflabel(3._at "2 Years" ///
6._at "5 Years" 11._at "10 Years" ///
16._at "15 Years" ///
21._at "20 Years" 26._at "25 Years") ///
nodep nonote nomtitles ///
title(Estimated Returns to Employer Tenure.) ///
mgroups("Years of Education" "Regular Employee" "Firm Size" ///
pattern(1 0 1 0 1 0) ///
prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) ///
replace
}
}
}

* 3
** OLS->AS / 60歳以下, 大企業, 中小企業, 専門職以外
{
*** under 60-year-old
{
**** OLS
{
quietly {
use "C:\Users\AyakaNakamura\Dropbox\materials\Works\Master\program\Submittion\Input\jhps_hc.dta", clear
destring, replace
tsset id year
drop if age>=60
}
reg realwage i.occ i.ind i.union i.marital i.year i.schooling i.size ///
c.emptenure##c.emptenure oj c.workexp##c.workexp, vce(r) l(90)
est sto olsemp59
}

**** AS
{
quietly {
use "C:\Users\AyakaNakamura\Dropbox\materials\Works\Master\program\Submittion\Input\jhps_hc.dta", clear
destring, replace
tsset id year
drop if age>=60
* 操作変数を作成
sort empid year
egen avgemptenure=mean(emptenure), by(empid)
egen avgemptenure2=mean(emptenure^2), by(empid)
egen avgemptenure3=mean(emptenure^3), by(empid)
gen emptenureiv=emptenure-avgemptenure
gen emptenureiv2=emptenure^2-avgemptenure2
gen emptenureiv3=emptenure^3-avgemptenure3
egen avgworkexp=mean(workexp), by(id)
egen avgworkexp2=mean(workexp^2), by(id)
egen avgworkexp3=mean(workexp^3), by(id)
gen workexpiv=workexp-avgworkexp
gen workexpiv2=workexp^2-avgworkexp2
gen workexpiv3=workexp^3-avgworkexp3
egen avgoj=mean(oj), by(empid)
gen ojiv=oj-avgoj
ivregress 2sls realwage i.occ i.ind i.union i.marital i.year i.schooling i.size ///
(c.emptenure##c.emptenure oj ///
c.workexp##c.workexp = ///
emptenureiv emptenureiv2 ojiv workexpiv workexpiv2), vce(r)
est sto isvemp59
drop if _est_isvemp59==0
drop *iv *iv? avg*
* 必要な変数を再作成
egen avgemptenure=mean(emptenure), by(empid)
egen avgemptenure2=mean(emptenure^2), by(empid)
egen avgemptenure3=mean(emptenure^3), by(empid)
gen emptenureiv=emptenure-avgemptenure
gen emptenureiv2=emptenure^2-avgemptenure2
gen emptenureiv3=emptenure^3-avgemptenure3
egen avgworkexp=mean(workexp), by(id)
egen avgworkexp2=mean(workexp^2), by(id)
egen avgworkexp3=mean(workexp^3), by(id)
gen workexpiv=workexp-avgworkexp
gen workexpiv2=workexp^2-avgworkexp2
gen workexpiv3=workexp^3-avgworkexp3
egen avgoj=mean(oj), by(empid)
gen ojiv=oj-avgoj
}
* 再推定
ivregress 2sls realwage i.occ i.ind i.union i.marital i.year i.schooling i.size ///
(c.emptenure##c.emptenure oj ///
c.workexp##c.workexp = ///
emptenureiv emptenureiv2 ojiv workexpiv workexpiv2), vce(r)
est sto isvemp59
}

**** culc. return
 {
est res olsemp59
margins, exp(_b[oj]+emptenure*_b[emptenure]+ ///
c.emptenure#c.emptenure*_b[c.emptenure#c.emptenure]) ///
at(emptenure=(0(1)25)) noe post
est sto olsempn59
est res isvemp59
margins, exp(_b[oj]+emptenure*_b[emptenure]+ ///
c.emptenure#c.emptenure*_b[c.emptenure#c.emptenure]) ///
at(emptenure=(0(1)25)) noe post
est sto isvempn59
coefplot (olsempn59, label(OLS)) (isvempn59, label(IV)), ///
at ciopts(recast(rline) lpattern(dash)) recast(connected) ///
xtitle("Employer Tenure") ytitle("Returns to Tenure on Earnings (%)") ///
title("Earnings Function Estimation.") yline(0) rescale(100)
graph export "C:\Users\AyakaNakamura\Dropbox\materials\Works\Master\program\Submittion\Output\plot_as_emp_59.pdf", replace
 }
 }
 
*** large firms
{
**** OLS
{
quietly {
use "C:\Users\AyakaNakamura\Dropbox\materials\Works\Master\program\Submittion\Input\jhps_hc.dta", clear
destring, replace
tsset id year
drop if size<5
}
reg realwage i.occ i.ind i.union i.marital i.year i.schooling i.size ///
c.emptenure##c.emptenure oj c.workexp##c.workexp, vce(r) l(90)
est sto olsempLa
}

**** AS
{
quietly {
use "C:\Users\AyakaNakamura\Dropbox\materials\Works\Master\program\Submittion\Input\jhps_hc.dta", clear
destring, replace
tsset id year
drop if size<5
* 操作変数を作成
sort empid year
egen avgemptenure=mean(emptenure), by(empid)
egen avgemptenure2=mean(emptenure^2), by(empid)
egen avgemptenure3=mean(emptenure^3), by(empid)
gen emptenureiv=emptenure-avgemptenure
gen emptenureiv2=emptenure^2-avgemptenure2
gen emptenureiv3=emptenure^3-avgemptenure3
egen avgworkexp=mean(workexp), by(id)
egen avgworkexp2=mean(workexp^2), by(id)
egen avgworkexp3=mean(workexp^3), by(id)
gen workexpiv=workexp-avgworkexp
gen workexpiv2=workexp^2-avgworkexp2
gen workexpiv3=workexp^3-avgworkexp3
egen avgoj=mean(oj), by(empid)
gen ojiv=oj-avgoj
ivregress 2sls realwage i.occ i.ind i.union i.marital i.year i.schooling i.size ///
(c.emptenure##c.emptenure oj ///
c.workexp##c.workexp = ///
emptenureiv emptenureiv2 ojiv workexpiv workexpiv2), vce(r)
est sto isvempLa
drop if _est_isvempLa==0
drop *iv *iv? avg*
* 必要な変数を再作成
egen avgemptenure=mean(emptenure), by(empid)
egen avgemptenure2=mean(emptenure^2), by(empid)
egen avgemptenure3=mean(emptenure^3), by(empid)
gen emptenureiv=emptenure-avgemptenure
gen emptenureiv2=emptenure^2-avgemptenure2
gen emptenureiv3=emptenure^3-avgemptenure3
egen avgworkexp=mean(workexp), by(id)
egen avgworkexp2=mean(workexp^2), by(id)
egen avgworkexp3=mean(workexp^3), by(id)
gen workexpiv=workexp-avgworkexp
gen workexpiv2=workexp^2-avgworkexp2
gen workexpiv3=workexp^3-avgworkexp3
egen avgoj=mean(oj), by(empid)
gen ojiv=oj-avgoj
}
* 再推定
ivregress 2sls realwage i.occ i.ind i.union i.marital i.year i.schooling i.size ///
(c.emptenure##c.emptenure oj ///
c.workexp##c.workexp = ///
emptenureiv emptenureiv2 ojiv workexpiv workexpiv2), vce(r)
est sto isvempLa
}

**** culc. return
 {
est res olsempLa
margins, exp(_b[oj]+emptenure*_b[emptenure]+ ///
c.emptenure#c.emptenure*_b[c.emptenure#c.emptenure]) ///
at(emptenure=(0(1)25)) noe post
est sto olsempnLa
est res isvempLa
margins, exp(_b[oj]+emptenure*_b[emptenure]+ ///
c.emptenure#c.emptenure*_b[c.emptenure#c.emptenure]) ///
at(emptenure=(0(1)25)) noe post
est sto isvempnLa
coefplot (olsempnLa, label(OLS)) (isvempnLa, label(IV)), ///
at ciopts(recast(rline) lpattern(dash)) recast(connected) ///
xtitle("Employer Tenure") ytitle("Returns to Tenure on Earnings (%)") ///
title("Earnings Function Estimation.") yline(0) rescale(100)
graph export "C:\Users\AyakaNakamura\Dropbox\materials\Works\Master\program\Submittion\Output\plot_as_emp_La.pdf", replace
 }
 }
 
*** small firms
{
**** OLS
{
quietly {
use "C:\Users\AyakaNakamura\Dropbox\materials\Works\Master\program\Submittion\Input\jhps_hc.dta", clear
destring, replace
tsset id year
drop if size==5
}
reg realwage i.occ i.ind i.union i.marital i.year i.schooling i.size ///
c.emptenure##c.emptenure oj c.workexp##c.workexp, vce(r) l(90)
est sto olsempSm
}

**** AS
{
quietly {
use "C:\Users\AyakaNakamura\Dropbox\materials\Works\Master\program\Submittion\Input\jhps_hc.dta", clear
destring, replace
tsset id year
drop if size==5
* 操作変数を作成
sort empid year
egen avgemptenure=mean(emptenure), by(empid)
egen avgemptenure2=mean(emptenure^2), by(empid)
egen avgemptenure3=mean(emptenure^3), by(empid)
gen emptenureiv=emptenure-avgemptenure
gen emptenureiv2=emptenure^2-avgemptenure2
gen emptenureiv3=emptenure^3-avgemptenure3
egen avgworkexp=mean(workexp), by(id)
egen avgworkexp2=mean(workexp^2), by(id)
egen avgworkexp3=mean(workexp^3), by(id)
gen workexpiv=workexp-avgworkexp
gen workexpiv2=workexp^2-avgworkexp2
gen workexpiv3=workexp^3-avgworkexp3
egen avgoj=mean(oj), by(empid)
gen ojiv=oj-avgoj
ivregress 2sls realwage i.occ i.ind i.union i.marital i.year i.schooling i.size ///
(c.emptenure##c.emptenure oj ///
c.workexp##c.workexp = ///
emptenureiv emptenureiv2 ojiv workexpiv workexpiv2), vce(r)
est sto isvempSm
drop if _est_isvempSm==0
drop *iv *iv? avg*
* 必要な変数を再作成
egen avgemptenure=mean(emptenure), by(empid)
egen avgemptenure2=mean(emptenure^2), by(empid)
egen avgemptenure3=mean(emptenure^3), by(empid)
gen emptenureiv=emptenure-avgemptenure
gen emptenureiv2=emptenure^2-avgemptenure2
gen emptenureiv3=emptenure^3-avgemptenure3
egen avgworkexp=mean(workexp), by(id)
egen avgworkexp2=mean(workexp^2), by(id)
egen avgworkexp3=mean(workexp^3), by(id)
gen workexpiv=workexp-avgworkexp
gen workexpiv2=workexp^2-avgworkexp2
gen workexpiv3=workexp^3-avgworkexp3
egen avgoj=mean(oj), by(empid)
gen ojiv=oj-avgoj
}
* 再推定
ivregress 2sls realwage i.occ i.ind i.union i.marital i.year i.schooling i.size ///
(c.emptenure##c.emptenure oj ///
c.workexp##c.workexp = ///
emptenureiv emptenureiv2 ojiv workexpiv workexpiv2), vce(r)
est sto isvempSm
}

**** culc. return
 {
est res olsempSm
margins, exp(_b[oj]+emptenure*_b[emptenure]+ ///
c.emptenure#c.emptenure*_b[c.emptenure#c.emptenure]) ///
at(emptenure=(0(1)25)) noe post
est sto olsempnSm
est res isvempSm
margins, exp(_b[oj]+emptenure*_b[emptenure]+ ///
c.emptenure#c.emptenure*_b[c.emptenure#c.emptenure]) ///
at(emptenure=(0(1)25)) noe post
est sto isvempnSm
coefplot (olsempnSm, label(OLS)) (isvempnSm, label(IV)), ///
at ciopts(recast(rline) lpattern(dash)) recast(connected) ///
xtitle("Employer Tenure") ytitle("Returns to Tenure on Earnings (%)") ///
title("Earnings Function Estimation.") yline(0) rescale(100)
graph export "C:\Users\AyakaNakamura\Dropbox\materials\Works\Master\program\Submittion\Output\plot_as_emp_Sm.pdf", replace
 }
 }

*** non-professional
{
**** OLS
{
quietly {
use "C:\Users\AyakaNakamura\Dropbox\materials\Works\Master\program\Submittion\Input\jhps_hc.dta", clear
destring, replace
tsset id year
drop if occ==10
}
reg realwage i.occ i.ind i.union i.marital i.year i.schooling i.size ///
c.emptenure##c.emptenure oj c.workexp##c.workexp, vce(r) l(90)
est sto olsempPr
}

**** AS
{
quietly {
use "C:\Users\AyakaNakamura\Dropbox\materials\Works\Master\program\Submittion\Input\jhps_hc.dta", clear
destring, replace
tsset id year
drop if occ==10
* 操作変数を作成
sort empid year
egen avgemptenure=mean(emptenure), by(empid)
egen avgemptenure2=mean(emptenure^2), by(empid)
egen avgemptenure3=mean(emptenure^3), by(empid)
gen emptenureiv=emptenure-avgemptenure
gen emptenureiv2=emptenure^2-avgemptenure2
gen emptenureiv3=emptenure^3-avgemptenure3
egen avgworkexp=mean(workexp), by(id)
egen avgworkexp2=mean(workexp^2), by(id)
egen avgworkexp3=mean(workexp^3), by(id)
gen workexpiv=workexp-avgworkexp
gen workexpiv2=workexp^2-avgworkexp2
gen workexpiv3=workexp^3-avgworkexp3
egen avgoj=mean(oj), by(empid)
gen ojiv=oj-avgoj
gen regulariv=emptenureiv*regular
ivregress 2sls realwage i.occ i.ind i.union i.marital i.year i.schooling i.size ///
(c.emptenure##c.emptenure oj ///
c.workexp##c.workexp = ///
emptenureiv emptenureiv2 ojiv workexpiv workexpiv2), vce(r)
est sto isvempPr
drop if _est_isvempPr==0
drop *iv *iv? avg*
* 必要な変数を再作成
egen avgemptenure=mean(emptenure), by(empid)
egen avgemptenure2=mean(emptenure^2), by(empid)
egen avgemptenure3=mean(emptenure^3), by(empid)
gen emptenureiv=emptenure-avgemptenure
gen emptenureiv2=emptenure^2-avgemptenure2
gen emptenureiv3=emptenure^3-avgemptenure3
egen avgworkexp=mean(workexp), by(id)
egen avgworkexp2=mean(workexp^2), by(id)
egen avgworkexp3=mean(workexp^3), by(id)
gen workexpiv=workexp-avgworkexp
gen workexpiv2=workexp^2-avgworkexp2
gen workexpiv3=workexp^3-avgworkexp3
egen avgoj=mean(oj), by(empid)
gen ojiv=oj-avgoj
}
* 再推定
ivregress 2sls realwage i.occ i.ind i.union i.marital i.year i.schooling i.size ///
(c.emptenure##c.emptenure oj ///
c.workexp##c.workexp = ///
emptenureiv emptenureiv2 ojiv workexpiv workexpiv2), vce(r)
est sto isvempPr
}

**** culc. return
{
est res olsempPr
margins, exp(_b[oj]+emptenure*_b[emptenure]+ ///
c.emptenure#c.emptenure*_b[c.emptenure#c.emptenure]) ///
at(emptenure=(0(1)25)) noe post
est sto olsempnPr
est res isvempPr
margins, exp(_b[oj]+emptenure*_b[emptenure]+ ///
c.emptenure#c.emptenure*_b[c.emptenure#c.emptenure]) ///
at(emptenure=(0(1)25)) noe post
est sto isvempnPr
coefplot (olsempnPr, label(OLS)) (isvempnPr, label(IV)), ///
at ciopts(recast(rline) lpattern(dash)) recast(connected) ///
xtitle("Employer Tenure") ytitle("Returns to Tenure on Earnings (%)") ///
title("Earnings Function Estimation.") yline(0) rescale(100)
graph export "C:\Users\AyakaNakamura\Dropbox\materials\Works\Master\program\Submittion\Output\plot_as_emp_Pr.pdf", replace
}
}

*** output tex all results
{
**** coefficients
quietly {
esttab olsemp59 isvemp59 olsempLa isvempLa ///
olsempSm isvempSm olsempPr isvempPr ///
using "C:\Users\AyakaNakamura\Dropbox\materials\Works\Master\program\Submittion\Output\as_emp_rob.tex", ///
se star(* 0.1 ** 0.05 *** 0.01) b(4) ///
keep(emptenure c.emptenure#c.emptenure ///
oj workexp c.workexp#c.workexp c.workexp#c.workexp#c.workexp) ///
order(emptenure c.emptenure#c.emptenure ///
oj workexp c.workexp#c.workexp c.workexp#c.workexp#c.workexp) ///
coeflabel(emptenure "Employer tenure" ///
c.emptenure#c.emptenure "Emp.ten.$^{2}\times 100$" ///
oj "Old job" workexp "Total experience" c.workexp#c.workexp "Experience$^{2}$") ///
transform(c.emptenure#c.emptenure 100*@ 100 ///
c.workexp#c.workexp#c.workexp 100*@ 100) ///
nodep nonote nomtitles ///
title(Earnings Function Estimates, using Various Subsamples.) ///
mgroups("Under 59-year-old" "Large firms ($\geq500$)" ///
"Small Firms ($<500$)" ///
pattern(1 0 1 0 1 0 1 0) ///
prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) ///
replace
}

**** return
quietly {
esttab olsempn59 isvempn59 olsempnLa isvempnLa ///
olsempnSm isvempnSm olsempnPr isvempnPr ///
using "C:\Users\AyakaNakamura\Dropbox\materials\Works\Master\program\Submittion\Output\as_return_rob.tex", ///
se star(* 0.1 ** 0.05 *** 0.01) b(4) ///
keep(3._at 6._at 11._at 16._at 21._at 26._at) ///
coeflabel(3._at "2 Years" ///
6._at "5 Years" 11._at "10 Years" ///
16._at "15 Years" ///
21._at "20 Years" 26._at "25 Years") ///
nodep nonote nomtitles ///
title(Estimated Returns to Employer Tenure.) ///
mgroups("Under 59-year-old" "Large firms ($\geq500$)" ///
"Small Firms ($<500$)" ///
pattern(1 0 1 0 1 0 1 0 1 0) ///
prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) ///
replace
}
}

}

* 4
** OLS->AS / テニュアをダミーで
*** base=0, 1年以降, 3年以降, 5年以降, 10年以降
{
*** OLS
{
**** sample selection
quietly {
use "C:\Users\AyakaNakamura\Dropbox\materials\Works\Master\program\Submittion\Input\jhps_hc.dta", clear
destring, replace
tsset id year
sort empid year
forvalues X=1 3 5 10{
	gen emp`X'=1 if emptenure>=`X'
	replace emp`X'=0 if emp`X'==.
}
sort id year
forvalues X=1 3 5 10{
	gen exp`X'=1 if workexp>=`X'
	replace exp`X'=0 if exp`X'==.
}
forvalues X=1 3 5 10{
	gen occ`X'=1 if occtenure>=`X'
	replace occ`X'=0 if occ`X'==.
}
}

**** empten
{
reg realwage i.occ i.ind i.union i.marital i.year i.schooling i.size ///
emp1 emp3 emp5 emp10 ///
exp1 exp3 exp5 exp10, vce(r)
est sto olsempD
}

**** empten+occten
{
reg realwage i.occ i.ind i.union i.marital i.year i.schooling i.size ///
emp1 emp3 emp5 emp10 ///
occ1 occ3 occ5 occ10
exp1 exp3 exp5 exp10, vce(r)
est sto olsempoccD
}
}

*** AS
{
**** empten
{
quietly {
use "C:\Users\AyakaNakamura\Dropbox\materials\Works\Master\program\Submittion\Input\jhps_hc.dta", clear
destring, replace
tsset id year
* 操作変数を作成
sort empid year
forvalues X=0(5)45{
	gen emp`X'=1 if emptenure>=`X'&emptenure<`X'+5
	replace emp`X'=0 if emp`X'==.
}
for X in num 0(5)45 : egen avgempX=mean(empX), by(empid)
for X in num 0(5)45 : gen empivX=empX-avgempX
sort id year
forvalues X=0(5)45{
	gen exp`X'=1 if workexp>=`X'&workexp<`X'+5
	replace exp`X'=0 if exp`X'==.
}
for X in num 0(5)45 : egen avgexpX=mean(expX), by(id)
for X in num 0(5)45 : gen expivX=expX-avgexpX
ivregress 2sls realwage i.occ i.ind i.union i.marital i.year i.schooling i.size ///
(emp0 emp5 emp10 emp15 emp20 emp25 emp30 emp35 emp40 emp45 ///
exp0 exp5 exp10 exp15 exp20 exp25 exp30 exp35 exp40 exp45 = ///
empiv0 empiv5 empiv10 empiv15 empiv20 ///
empiv25 empiv30 empiv35 empiv40 empiv45 ///
expiv0 expiv5 expiv10 expiv15 expiv20 ///
expiv25 expiv30 expiv35 expiv40 expiv45), vce(r)
est sto isvempD
drop if _est_isvempD==0
drop *iv* avg*
* 必要な変数を再作成
sort empid year
for X in num 0(5)45 : egen avgempX=mean(empX), by(empid)
for X in num 0(5)45 : gen empivX=empX-avgempX
sort id year
for X in num 0(5)45 : egen avgexpX=mean(expX), by(id)
for X in num 0(5)45 : gen expivX=expX-avgexpX
}
* 再推定
ivregress 2sls realwage i.occ i.ind i.union i.marital i.year i.schooling i.size ///
(emp0 emp5 emp10 emp15 emp20 emp25 emp30 emp35 emp40 emp45 ///
exp0 exp5 exp10 exp15 exp20 exp25 exp30 exp35 exp40 exp45 = ///
empiv0 empiv5 empiv10 empiv15 empiv20 ///
empiv25 empiv30 empiv35 empiv40 empiv45 ///
expiv0 expiv5 expiv10 expiv15 expiv20 ///
expiv25 expiv30 expiv35 expiv40 expiv45)
est sto isvempD
}

**** empten+occten
{
quietly {
use "C:\Users\AyakaNakamura\Dropbox\materials\Works\Master\program\Submittion\Input\jhps_hc.dta", clear
destring, replace
tsset id year
* 操作変数を作成
sort id year
by id: gen empid = 1 if _n==1|switch==1
replace empid=sum(empid)
sort empid year
forvalues X=0(5)45{
	gen emp`X'=1 if emptenure>=`X'&emptenure<`X'+5
	replace emp`X'=0 if emp`X'==.
}
for X in num 0(5)45 : egen avgempX=mean(empX), by(empid)
for X in num 0(5)45 : gen empivX=empX-avgempX
sort id year
forvalues X=0(5)45{
	gen exp`X'=1 if workexp>=`X'&workexp<`X'+5
	replace exp`X'=0 if exp`X'==.
}
for X in num 0(5)45 : egen avgexpX=mean(expX), by(id)
for X in num 0(5)45 : gen expivX=expX-avgexpX
sort id year
forvalues X=0(5)45{
	gen occ`X'=1 if occtenure>=`X'&occtenure<`X'+5
	replace occ`X'=0 if occ`X'==.
}
for X in num 0(5)45 : egen avgoccX=mean(occX), by(id occ)
for X in num 0(5)45 : gen occivX=occX-avgoccX
ivregress 2sls realwage i.occ i.ind i.union i.marital i.year i.schooling i.size ///
(emp0 emp5 emp10 emp15 emp20 emp25 emp30 emp35 emp40 emp45 ///
occ0 occ5 occ10 occ15 occ20 occ25 occ30 occ35 occ40 occ45 ///
exp0 exp5 exp10 exp15 exp20 exp25 exp30 exp35 exp40 exp45 = ///
empiv0 empiv5 empiv10 empiv15 empiv20 ///
empiv25 empiv30 empiv35 empiv40 empiv45 ///
occiv0 occiv5 occiv10 occiv15 occiv20 ///
occiv25 occiv30 occiv35 occiv40 occiv45 ///
expiv0 expiv5 expiv10 expiv15 expiv20 ///
expiv25 expiv30 expiv35 expiv40 expiv45), vce(r)
est sto isvempoccD
drop if _est_isvempoccD==0
drop *iv* avg*
* 必要な変数を再作成
sort empid year
for X in num 0(5)45 : egen avgempX=mean(empX), by(empid)
for X in num 0(5)45 : gen empivX=empX-avgempX
sort id year
for X in num 0(5)45 : egen avgexpX=mean(expX), by(id)
for X in num 0(5)45 : gen expivX=expX-avgexpX
for X in num 0(5)45 : egen avgoccX=mean(occX), by(id occ)
for X in num 0(5)45 : gen occivX=occX-avgoccX
}
* 再推定
ivregress 2sls realwage i.occ i.ind i.union i.marital i.year i.schooling i.size ///
(emp0 emp5 emp10 emp15 emp20 emp25 emp30 emp35 emp40 emp45 ///
occ0 occ5 occ10 occ15 occ20 occ25 occ30 occ35 occ40 occ45 ///
exp0 exp5 exp10 exp15 exp20 exp25 exp30 exp35 exp40 exp45 = ///
empiv0 empiv5 empiv10 empiv15 empiv20 ///
empiv25 empiv30 empiv35 empiv40 empiv45 ///
occiv0 occiv5 occiv10 occiv15 occiv20 ///
occiv25 occiv30 occiv35 occiv40 occiv45 ///
expiv0 expiv5 expiv10 expiv15 expiv20 ///
expiv25 expiv30 expiv35 expiv40 expiv45), vce(r)
est sto isvempoccD
}

}

/*
 *** culc. return
 {
**** empten
{
est res olsemp2
margins, exp(_b[oj]+emptenure*_b[emptenure]+ ///
c.emptenure#c.emptenure*_b[c.emptenure#c.emptenure]) ///
at(emptenure=(0(1)25)) noe post
est sto olsempr2
est res isvemp2
margins, exp(_b[oj]+emptenure*_b[emptenure]+ ///
c.emptenure#c.emptenure*_b[c.emptenure#c.emptenure]) ///
at(emptenure=(0(1)25)) noe post
est sto isvempr2
coefplot (olsempr2, label(OLS)) (isvempr2, label(IV)), ///
at ciopts(recast(rline) lpattern(dash)) recast(connected) ///
xtitle("Employer Tenure") ytitle("Returns to Tenure on Earnings (%)") ///
title("Earnings Function Estimation.") yline(0) rescale(100)
graph export "C:\Users\AyakaNakamura\Dropbox\materials\Works\Master\program\Submittion\Output\plot_as_emp_2.pdf", replace
 }
 
**** empten+occten
{
est res olsempocc2
margins, exp(_b[oj]+emptenure*_b[emptenure]+ ///
c.emptenure#c.emptenure*_b[c.emptenure#c.emptenure]) ///
at(emptenure=(0(1)25)) noe post
est sto olsempoccr2
est res isvempocc2
margins, exp(_b[oj]+emptenure*_b[emptenure]+ ///
c.emptenure#c.emptenure*_b[c.emptenure#c.emptenure]) ///
at(emptenure=(0(1)25)) noe post
est sto isvempoccr2
coefplot (olsempr2, label(OLS)) (isvempr2, label(IV)), ///
at ciopts(recast(rline) lpattern(dash)) recast(connected) ///
xtitle("Employer Tenure") ytitle("Returns to Tenure on Earnings (%)") ///
title("Earnings Function Estimation.") yline(0) rescale(100)
graph export "C:\Users\AyakaNakamura\Dropbox\materials\Works\Master\program\Submittion\Output\plot_as_empocc_2.pdf", replace
}
}
 
*** output tex all results
{
**** coefficients
quietly {
esttab olsemp2 olsemp3 olsemp4 isvemp2 isvemp3 isvemp4 ///
using "C:\Users\AyakaNakamura\Dropbox\materials\Works\Master\program\Submittion\Output\as_emp.tex", ///
se star(* 0.1 ** 0.05 *** 0.01) b(4) ///
keep(emptenure c.emptenure#c.emptenure c.emptenure#c.emptenure#c.emptenure ///
c.emptenure#c.emptenure#c.emptenure#c.emptenure ///
oj workexp c.workexp#c.workexp c.workexp#c.workexp#c.workexp) ///
order(emptenure c.emptenure#c.emptenure c.emptenure#c.emptenure#c.emptenure ///
c.emptenure#c.emptenure#c.emptenure#c.emptenure ///
oj workexp c.workexp#c.workexp c.workexp#c.workexp#c.workexp) ///
coeflabel(emptenure "Employer tenure" ///
c.emptenure#c.emptenure "Emp.ten.$^{2}\times 100$" ///
c.emptenure#c.emptenure#c.emptenure "Emp.ten.$^{3}\times 100$" ///
c.emptenure#c.emptenure#c.emptenure#c.emptenure "Emp.ten.$^{4}\times 1000$" ///
occtenure "Occupation tenure" c.occtenure#c.occtenure "Occ.ten.$^{2}\times 100$" ///
c.occtenure#c.occtenure#c.occtenure "Occ.ten.$^{3}\times 100$" ///
oj "Old job" workexp "Total experience" c.workexp#c.workexp "Experience$^{2}$" ///
c.workexp#c.workexp#c.workexp "Exp.$^{3}\times 100$") ///
transform(c.emptenure#c.emptenure 100*@ 100 ///
c.emptenure#c.emptenure#c.emptenure 100*@ 100 ///
c.emptenure#c.emptenurec.emptenure#c.emptenure 1000*@ 1000 ///
c.occtenure#c.occtenure 100*@ 100 ///
c.occtenure#c.occtenure#c.occtenure 100*@ 100 ///
c.workexp#c.workexp#c.workexp 100*@ 100) ///
nodep nonote nomtitles ///
title(Earnings Function Estimates, using to 64-year-old, ///
including Non-regular Workers and Specialists.) ///
mgroups("OLS" "IV" ///
pattern(1 0 0 1 0 0) ///
prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) ///
replace
}

**** main table
quietly{
esttab olsemp2 olsempocc2 isvemp2 isvempocc2 ///
using "C:\Users\AyakaNakamura\Dropbox\materials\Works\Master\program\Submittion\Output\as_main.tex", ///
se star(* 0.1 ** 0.05 *** 0.01) b(4) ///
keep(emptenure c.emptenure#c.emptenure ///
occtenure c.occtenure#c.occtenure c.occtenure#c.occtenure#c.occtenure ///
oj workexp c.workexp#c.workexp c.workexp#c.workexp#c.workexp) ///
order(emptenure c.emptenure#c.emptenure ///
occtenure c.occtenure#c.occtenure c.occtenure#c.occtenure#c.occtenure ///
oj workexp c.workexp#c.workexp c.workexp#c.workexp#c.workexp) ///
coeflabel(emptenure "Employer tenure" ///
c.emptenure#c.emptenure "Emp.ten.$^{2}\times 100$" ///
occtenure "Occupation tenure" c.occtenure#c.occtenure "Occ.ten.$^{2}\times 100$" ///
c.occtenure#c.occtenure#c.occtenure "Occ.ten.$^{3}\times 100$" ///
oj "Old job" workexp "Total experience" c.workexp#c.workexp "Experience$^{2}$" ///
c.workexp#c.workexp#c.workexp "Exp.$^{3}\times 100$") ///
transform(c.emptenure#c.emptenure 100*@ 100 ///
c.occtenure#c.occtenure 100*@ 100 ///
c.occtenure#c.occtenure#c.occtenure 100*@ 100 ///
c.workexp#c.workexp#c.workexp 100*@ 100) ///
nodep nonote nomtitles ///
title(Earnings Function Estimates, using to 64-year-old, ///
including Non-regular Workers and Specialists.) ///
mgroups("OLS" "IV" ///
pattern(1 0 1 0) ///
prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) ///
replace
}

**** return
quietly{
esttab olsempr2 olsempoccr2 isvempr2 isvempoccr2 ///
using "C:\Users\AyakaNakamura\Dropbox\materials\Works\Master\program\Submittion\Output\as_return.tex", ///
se star(* 0.1 ** 0.05 *** 0.01) b(4) ///
keep(3._at 6._at 11._at 16._at 21._at 26._at) ///
coeflabel(3._at "2 Years" ///
6._at "5 Years" 11._at "10 Years" ///
16._at "15 Years" ///
21._at "20 Years" 26._at "25 Years") ///
nodep nonote nomtitles ///
title(Estimated Returns to Employer Tenure.) ///
mgroups("OLS" "IV" ///
pattern(1 0 1 0) ///
prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) ///
replace
}
}
*/
}

* 5
** Topel / 基本の推定式1-4次項まで
{
*** linear
{
 quietly {
use "C:\Users\AyakaNakamura\Dropbox\materials\Works\Master\program\Submittion\Input\jhps_hc.dta", clear
destring, replace
tsset id year
* 変数を作る
sort empid year
gen initialemp=workexp-emptenure
bysort empid: gen emptendif=1 ///
if switch==0&_n!=1&emptenure>=1
gen emptendif2=2*emptenure-1 if emptendif==1
gen emptendif3=3*(emptenure^2)-3*emptenure+1 if emptendif==1
bysort empid: gen empexpdif=1 ///
if switch==0&_n!=1&emptenure>=1
gen empexpdif2=2*workexp-1 if emptendif==1
gen empexpdif3=3*(workexp^2)-3*workexp+1 if emptendif==1
bysort empid: gen ojdif=1 if emptendif==1&emptenure==1
replace ojdif=0 if emptendif==1&emptenure>1
sort id year
gen empwagedif=realwage-l.realwage if emptendif==1
tabulate year, generate(dum)
for X in num 1/11 \ Y in num 2004/2014 : rename dumX yY
for X in num 2004/2014 : egen avgyX=mean(yX), by(id)
for X in num 2004/2014 : gen yivX=yX-avgyX
tabulate schooling, generate(edu)
for X in num 1/5 \ Y in num 9 12 14 16 18 : rename eduX eduY
tabulate size, generate(size)
for X in num 1/5 \ Y in num 1/5 : rename sizeX sizeY
drop if initialemp<0
drop if occ==1
}

**** 1st step
reg empwagedif i.year
est sto fst1
gen coefsum1=_b[_cons]
gen emptenB1=emptenure*_b[_cons] ///
+y2005*_b[2005b.year]+y2006*_b[2006.year]+y2007*_b[2007.year] ///
+y2008*_b[2008.year]+y2009*_b[2009.year]+y2010*_b[2010.year] ///
+y2011*_b[2011.year]+y2012*_b[2012.year]+y2013*_b[2013.year] ///
+y2014*_b[2014.year]
gen intwemp1=realwage-emptenB

**** 2nd step
reg intwemp1 i.marital i.union i.schooling ///
i.size i.ind i.occ ///
initialemp, nocons
est sto snd1
gen coefexp1=_b[initialemp]

**** culc return
{
capture program drop coef
program coef, rclass
	suest fst1 snd1
	lincom [fst1_mean]_b[_cons]-[snd1_mean]_b[initialemp]
	return scalar diffse =r(se)
end
coef
capture program drop emprtn
program emprtn, rclass
suest fst1 snd1
	foreach X of numlist 2 5 10 15 20 25 {
	lincom ([fst1_mean]_b[_cons]-[snd1_mean]_b[initialemp])*`X'
	return scalar rtn`X' =r(se)
	}
end
emprtn
}
}

*** qadratic
 {
quietly {
use "C:\Users\AyakaNakamura\Dropbox\materials\Works\Master\program\Submittion\Input\jhps_hc.dta", clear
destring, replace
tsset id year
* 変数を作る
sort empid year
gen initialemp=workexp-emptenure
bysort empid: gen emptendif=1 ///
if switch==0&_n!=1&emptenure>=1
gen emptendif2=2*emptenure-1 if emptendif==1
gen emptendif3=3*(emptenure^2)-3*emptenure+1 if emptendif==1
bysort empid: gen empexpdif=1 ///
if switch==0&_n!=1&emptenure>=1
gen empexpdif2=2*workexp-1 if emptendif==1
gen empexpdif3=3*(workexp^2)-3*workexp+1 if emptendif==1
bysort empid: gen ojdif=1 if emptendif==1&emptenure==1
replace ojdif=0 if emptendif==1&emptenure>1
sort id year
gen empwagedif=realwage-l.realwage if emptendif==1
tabulate year, generate(dum)
for X in num 1/11 \ Y in num 2004/2014 : rename dumX yY
for X in num 2004/2014 : egen avgyX=mean(yX), by(id)
for X in num 2004/2014 : gen yivX=yX-avgyX
tabulate schooling, generate(edu)
for X in num 1/5 \ Y in num 9 12 14 16 18 : rename eduX eduY
tabulate size, generate(size)
for X in num 1/5 \ Y in num 1/5 : rename sizeX sizeY
drop if initialemp<0
drop if occ==1
}
 
**** 1st step
reg empwagedif emptendif2 empexpdif2 i.year
est sto fst2
gen coefsum2=_b[_cons]
gen coefemp22=_b[emptendif2]
gen emptenB2=emptenure*_b[_cons] ///
+_b[emptendif2]*emptenure^2+_b[empexpdif2]*workexp^2 ///
+y2005*_b[2005b.year]+y2006*_b[2006.year]+y2007*_b[2007.year] ///
+y2008*_b[2008.year]+y2009*_b[2009.year]+y2010*_b[2010.year] ///
+y2011*_b[2011.year]+y2012*_b[2012.year]+y2013*_b[2013.year] ///
+y2014*_b[2014.year]
gen intwemp2=realwage-emptenB2

**** 2nd step
reg intwemp2 i.marital i.union i.schooling ///
i.size i.ind i.occ ///
initialemp, nocons
est sto snd2
gen coefexp2=_b[initialemp]

**** culc return
{
capture program drop coef
program coef, rclass
	suest fst2 snd2
	lincom [fst2_mean]_b[_cons]-[snd2_mean]_b[initialemp]
	return scalar diffse =r(se)
end
coef
capture program drop emprtn
program emprtn, rclass
suest fst2 snd2
	foreach X of numlist 2 5 10 15 20 25 {
	lincom ([fst2_mean]_b[_cons]-[snd2_mean]_b[initialemp])*`X'+[fst2_mean]_b[emptendif2]*`X'*`X'
	return scalar rtn`X' =r(se)
	}
end
emprtn
}
}

*** output tex all results
{
**** coefficients 
quietly {
esttab fst1 fst2 ///
using "C:\Users\AyakaNakamura\Dropbox\materials\Works\Master\program\Submittion\Output\topel_emp.tex", ///
se star(* 0.1 ** 0.05 *** 0.01) b(4) ///
keep(_cons c.emptenure#c.emptenure ///
c.workexp#c.workexp) ///
order(_cons c.emptenure#c.emptenure ///
c.workexp#c.workexp) ///
coeflabel(c.emptenure#c.emptenure "Emp.ten.$^{2}\times 100$" ///
c.workexp#c.workexp "Experience$^{2}$") ///
transform(c.emptenure#c.emptenure 100*@ 100 ///
c.workexp#c.workexp 100*@ 100) ///
nodep nonote nomtitles ///
title(Estimation Results.) ///
replace
}
}
}
  

  
