/* Title: Estimation */
/// Date: Oct 29th, 2018
/// Written by Ayaka Nakamura
/// 
/// This file is for estimation
/// 
/// 1. OLS->AS / 1-4 dimenational polynomial
/// 2. OLS->AS / ability*tenure
/// 3. OLS->AS / under 60-year-old, firm size, non-specialist, regular employee
/// 4. OLS->AS / tenure as dummy
/// 5. Topel / 1-4 dimenational polynomial

*  0. Preparation
qui {
	* Set Directories
	local path "C:\Users\AyakaNakamura\Dropbox\materials\Works\Master\program\Submittion"
	local original "C:\Users\AyakaNakamura\Dropbox\materials\Works\Master\program\Submittion\OriginalData"
	local inputfd "C:\Users\AyakaNakamura\Dropbox\materials\Works\Master\program\Submittion\Input"
	local output "C:\Users\AyakaNakamura\Dropbox\materials\Works\Master\program\Submittion\Output"
	local inter "C:\Users\AyakaNakamura\Dropbox\materials\Works\Master\program\Submittion\Intermediate"
	
	cd `path'
	adopath + `original'
	adopath + `inputfd'
	adopath + `output'
	adopath + `inter'
	
	* set variable list for estimation
	** list of common variable
	local commonVar realwage i.occ i.ind i.dunion i.dmarital ///
								i.year i.schooling i.dsize i.dregular
	** list of tenure
	local emp1 c.emptenure oj c.workexp
	local emp2 c.emptenure##c.emptenure oj c.workexp##c.workexp
	local emp3 c.emptenure##c.emptenure##c.emptenure oj ///
						c.workexp##c.workexp##c.workexp
	local emp4 c.emptenure##c.emptenure##c.emptenure##c.emptenure oj ///
						c.workexp##c.workexp##c.workexp##c.workexp
	** list of tenure (including occupation tenure)
	local empocc1 c.emptenure oj c.workexp c.occtenure
	local empocc2 c.emptenure##c.emptenure oj c.workexp##c.workexp ///
							c.occtenure##c.occtenure
	local empocc3 c.emptenure##c.emptenure##c.emptenure oj ///
							c.workexp##c.workexp##c.workexp ///
							c.occtenure##c.occtenure##c.occtenure
	local empocc4 c.emptenure##c.emptenure##c.emptenure##c.emptenure oj ///
							c.workexp##c.workexp##c.workexp##c.workexp ///
							c.occtenure##c.occtenure##c.occtenure##c.occtenure
}

* 1. OLS->AS / 1-4 dimenational polynomial


*** OLS
qui {
	use "`inputfd'\jhps_hc.dta", clear
	destring, replace
	tsset id year
}

forvalues x=2/4{
	reg `commonVar' ///
			`emp`x'' ///
			, vce(r)
	est sto olsemp`x'
}

**** empten+occten
{
***** 2nd
reg realwage i.occ i.ind i.union i.marital i.year i.schooling i.size i.regular ///
c.emptenure##c.emptenure oj c.occtenure##c.occtenure c.workexp##c.workexp, vce(r)
est sto olsempocc2
***** 3rd
reg realwage i.occ i.ind i.union i.marital i.year i.schooling i.size i.regular ///
c.emptenure##c.emptenure##c.emptenure oj ///
c.occtenure##c.occtenure##c.occtenure c.workexp##c.workexp##c.workexp, vce(r)
est sto olsempocc3
***** 4th
reg realwage i.occ i.ind i.union i.marital i.year i.schooling i.size i.regular ///
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
ivregress 2sls realwage i.occ i.ind i.union i.marital i.year i.schooling i.size i.regular ///
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
ivregress 2sls realwage i.occ i.ind i.union i.marital i.year i.schooling i.size i.regular ///
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
ivregress 2sls realwage i.occ i.ind i.union i.marital i.year i.schooling i.size i.regular ///
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
ivregress 2sls realwage i.occ i.ind i.union i.marital i.year i.schooling i.size i.regular ///
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
ivregress 2sls realwage i.occ i.ind i.union i.marital i.year i.schooling i.size i.regular ///
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
ivregress 2sls realwage i.occ i.ind i.union i.marital i.year i.schooling i.size i.regular ///
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
ivregress 2sls realwage i.occ i.ind i.union i.marital i.year i.schooling i.size i.regular ///
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
ivregress 2sls realwage i.occ i.ind i.union i.marital i.year i.schooling i.size i.regular ///
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
ivregress 2sls realwage i.occ i.ind i.union i.marital i.year i.schooling i.size i.regular ///
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
ivregress 2sls realwage i.occ i.ind i.union i.marital i.year i.schooling i.size i.regular ///
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
ivregress 2sls realwage i.occ i.ind i.union i.marital i.year i.schooling i.size i.regular ///
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
ivregress 2sls realwage i.occ i.ind i.union i.marital i.year i.schooling i.size i.regular ///
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
yline(0) rescale(100) ////
title("Using All Samples, Occupation Tenure is not Controlled, Quadratic Form of Tenure.")
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
yline(0) rescale(100) ////
title("Using All Samples, Occupation Tenure is not Controlled, Cubic Form of Tenure.")
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
yline(0) rescale(100) ////
title("Using All Samples, Occupation Tenure is not Controlled, Quartic Form of Tenure.")
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
yline(0) rescale(100) ////
title("Using All Samples, Occupation Tenure is Controlled, Quadratic Form of Tenure.")
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
yline(0) rescale(100) ////
title("Using All Samples, Occupation Tenure is Controlled, Cubic Form of Tenure.")
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
yline(0) rescale(100) ////
title("Using All Samples, Occupation Tenure is Controlled, Quartic Form of Tenure.")
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
oj workexp c.workexp#c.workexp c.workexp#c.workexp#c.workexp ///
c.workexp#c.workexp#c.workexp#c.workexp) ///
order(emptenure c.emptenure#c.emptenure c.emptenure#c.emptenure#c.emptenure ///
c.emptenure#c.emptenure#c.emptenure#c.emptenure ///
oj workexp c.workexp#c.workexp c.workexp#c.workexp#c.workexp ///
c.workexp#c.workexp#c.workexp#c.workexp) ///
coeflabel(emptenure "Employer tenure" ///
c.emptenure#c.emptenure "Emp.ten.$^{2}\times 100$" ///
c.emptenure#c.emptenure#c.emptenure "Emp.ten.$^{3}\times 100$" ///
c.emptenure#c.emptenure#c.emptenure#c.emptenure "Emp.ten.$^{4}\times 1000$" ///
oj "Old job" workexp "Total experience" c.workexp#c.workexp "Experience$^{2}$" ///
c.workexp#c.workexp#c.workexp "Exp.$^{3}\times 100$" ///
c.workexp#c.workexp#c.workexp#c.workexp "Exp.$^{4}\times 1000$") ///
transform(c.emptenure#c.emptenure 100*@ 100 ///
c.emptenure#c.emptenure#c.emptenure 100*@ 100 ///
c.emptenure#c.emptenurec.emptenure#c.emptenure 1000*@ 1000 ///
c.occtenure#c.occtenure 100*@ 100 ///
c.occtenure#c.occtenure#c.occtenure 100*@ 100 ///
c.workexp#c.workexp#c.workexp 100*@ 100 ///
c.workexp#c.workexp#c.workexp 1000*@ 1000) ///
nodep nonote nomtitles ///
title(Earnings Function Estimates, using Sample up to 64-year-old, ///
including Non-regular Workers and Specialists, ///
Variables of Occupation Tenure are not Controlled.) ///
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
c.occtenure#c.occtenure#c.occtenure#c.occtenure ///
oj workexp c.workexp#c.workexp c.workexp#c.workexp#c.workexp ///
c.workexp#c.workexp#c.workexp#c.workexp) ///
order(emptenure c.emptenure#c.emptenure c.emptenure#c.emptenure#c.emptenure ///
c.emptenure#c.emptenure#c.emptenure#c.emptenure ///
occtenure c.occtenure#c.occtenure c.occtenure#c.occtenure#c.occtenure ///
c.occtenure#c.occtenure#c.occtenure#c.occtenure ///
oj workexp c.workexp#c.workexp c.workexp#c.workexp#c.workexp ///
c.workexp#c.workexp#c.workexp#c.workexp) ///
coeflabel(emptenure "Employer tenure" ///
c.emptenure#c.emptenure "Emp.ten.$^{2}\times 100$" ///
c.emptenure#c.emptenure#c.emptenure "Emp.ten.$^{3}\times 100$" ///
c.emptenure#c.emptenure#c.emptenure#c.emptenure "Emp.ten.$^{4}\times 1000$" ///
occtenure "Occupation tenure" c.occtenure#c.occtenure "Occ.ten.$^{2}\times 100$" ///
c.occtenure#c.occtenure#c.occtenure "Occ.ten.$^{3}\times 100$" ///
c.occtenure#c.occtenure#c.occtenure#c.occtenure "Occ.ten.$^{4}\times 1000$" ///
oj "Old job" workexp "Total experience" c.workexp#c.workexp "Experience$^{2}$" ///
c.workexp#c.workexp#c.workexp "Exp.$^{3}\times 100$" ///
c.workexp#c.workexp#c.workexp#c.workexp "Exp.$^{4}\times 1000$") ///
transform(c.emptenure#c.emptenure 100*@ 100 ///
c.emptenure#c.emptenure#c.emptenure 100*@ 100 ///
c.emptenure#c.emptenurec.emptenure#c.emptenure 1000*@ 1000 ///
c.occtenure#c.occtenure 100*@ 100 ///
c.occtenure#c.occtenure#c.occtenure 100*@ 100 ///
c.occtenure#c.occtenure#c.occtenure#c.occtenure 1000*@ 1000 ///
c.workexp#c.workexp#c.workexp 100*@ 100 ///
c.workexp#c.workexp#c.workexp#c.workexp 1000*@ 1000) ///
nodep nonote nomtitles ///
title(Earnings Function Estimates, using Sample up to 64-year-old, ///
including Non-regular Workers and Specialists, ///
Variables of Occupation Tenure are Controlled.) ///
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
title(Earnings Function Estimates, using Sample up to 64-year-old, ///
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
title(Estimated Returns to Employer Tenure, using Sample up to 64-year-old, ///
including Non-regular Workers and Specialists.) ///
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
for X in num 1/4 \ Y in num 9 12 14 16: rename eduX eduY
sort empid year
for X in num 9 12 14 16: egen avgempscX=mean(eduX*emptenure), by(empid)
for X in num 9 12 14 16: gen empscivX=emptenure*eduX-avgempscX
* 推定
ivregress 2sls realwage i.occ i.ind i.union i.marital i.year i.regular i.schooling i.size ///
(c.emptenure##c.emptenure ///
c.emptenure#i.schooling oj ///
c.workexp##c.workexp = ///
emptenureiv emptenureiv2 ///
empsciv9 empsciv12 empsciv14 empsciv16 ojiv ///
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
sort empid year
for X in num 9 12 14 16: egen avgempscX=mean(eduX*emptenure), by(empid)
for X in num 9 12 14 16: gen empscivX=emptenure*eduX-avgempscX
}
* 再推定
ivregress 2sls realwage i.occ i.ind i.union i.marital i.year i.regular i.schooling i.size ///
(c.emptenure##c.emptenure ///
c.emptenure#i.schooling oj ///
c.workexp##c.workexp = ///
emptenureiv emptenureiv2 ///
empsciv9 empsciv12 empsciv14 empsciv16 ojiv ///
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
tabulate regular, generate(rg)
rename (rg1 rg2) (rg0 rg1)
sort empid year
for X in num 0/1 : egen avgemprgX=mean(rgX*emptenure), by(empid)
for X in num 0/1 : gen emprgivX=emptenure*rgX-avgemprgX
ivregress 2sls realwage i.occ i.ind i.union i.marital i.year i.regular i.schooling i.size ///
(c.emptenure##c.emptenure ///
c.emptenure#i.regular oj ///
c.workexp##c.workexp = ///
emptenureiv emptenureiv2 ///
emprgiv0 emprgiv1 ojiv ///
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
sort empid year
for X in num 0/1 : egen avgemprgX=mean(rgX*emptenure), by(empid)
for X in num 0/1 : gen emprgivX=emptenure*rgX-avgemprgX
}
 * 再推定
ivregress 2sls realwage i.occ i.ind i.union i.marital i.year i.regular i.schooling i.size ///
(c.emptenure##c.emptenure ///
c.emptenure#i.regular oj ///
c.workexp##c.workexp = ///
emptenureiv emptenureiv2 ///
emprgiv0 emprgiv1 ojiv ///
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
for X in num 1/2 \ Y in num 0/1: rename siX siY
sort empid year
for X in num 0/1 : egen avgempsX=mean(siX*emptenure), by(empid)
for X in num 0/1 : gen empscivX=emptenure*siX-avgempsX
ivregress 2sls realwage i.occ i.ind i.union i.marital i.year i.regular i.schooling i.size ///
(c.emptenure##c.emptenure ///
c.emptenure#i.size oj ///
c.workexp##c.workexp = ///
emptenureiv emptenureiv2 ///
empsciv0 empsciv1 ojiv ///
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
sort empid year
for X in num 0/1 : egen avgempsX=mean(siX*emptenure), by(empid)
for X in num 0/1 : gen empscivX=emptenure*siX-avgempsX
}
* 再推定
ivregress 2sls realwage i.occ i.ind i.union i.marital i.year i.regular i.schooling i.size ///
(c.emptenure##c.emptenure ///
c.emptenure#i.size oj ///
c.workexp##c.workexp = ///
emptenureiv emptenureiv2 ///
empsciv0 empsciv1 ojiv ///
workexpiv workexpiv2), vce(r)
est sto isvempsi
}

*** culc. return
 {
**** schooling
{
***** =9
est res olsempsc
margins, exp(_b[oj]+emptenure*_b[emptenure]+ ///
c.emptenure#c.emptenure*_b[c.emptenure#c.emptenure]) ///
at(emptenure=(0(1)25)) noe post
est sto olsempnsc9
est res isvempsc
margins, exp(_b[oj]+emptenure*_b[emptenure]+ ///
c.emptenure#c.emptenure*_b[c.emptenure#c.emptenure]) ///
at(emptenure=(0(1)25)) noe post
est sto isvempnsc9

***** =12
est res olsempsc
margins, exp(_b[oj]+emptenure*_b[emptenure]+ ///
c.emptenure#c.emptenure*_b[c.emptenure#c.emptenure]+ ///
emptenure*_b[12.schooling#c.emptenure]) ///
at(emptenure=(0(1)25)) noe post
est sto olsempnsc12
est res isvempsc
margins, exp(_b[oj]+emptenure*_b[emptenure]+ ///
c.emptenure#c.emptenure*_b[c.emptenure#c.emptenure]+ ///
emptenure*_b[12.schooling#c.emptenure]) ///
at(emptenure=(0(1)25)) noe post
est sto isvempnsc12

***** =14
est res olsempsc
margins, exp(_b[oj]+emptenure*_b[emptenure]+ ///
c.emptenure#c.emptenure*_b[c.emptenure#c.emptenure]+ ///
emptenure*_b[14.schooling#c.emptenure]) ///
at(emptenure=(0(1)25)) noe post
est sto olsempnsc14
est res isvempsc
margins, exp(_b[oj]+emptenure*_b[emptenure]+ ///
c.emptenure#c.emptenure*_b[c.emptenure#c.emptenure]+ ///
emptenure*_b[14.schooling#c.emptenure]) ///
at(emptenure=(0(1)25)) noe post
est sto isvempnsc14

***** =16
est res olsempsc
margins, exp(_b[oj]+emptenure*_b[emptenure]+ ///
c.emptenure#c.emptenure*_b[c.emptenure#c.emptenure]+ ///
emptenure*_b[16.schooling#c.emptenure]) ///
at(emptenure=(0(1)25)) noe post
est sto olsempnsc16
est res isvempsc
margins, exp(_b[oj]+emptenure*_b[emptenure]+ ///
c.emptenure#c.emptenure*_b[c.emptenure#c.emptenure]+ ///
emptenure*_b[16.schooling#c.emptenure]) ///
at(emptenure=(0(1)25)) noe post
est sto isvempnsc16

***** plot
coefplot (olsempnsc9, label(OLS)) (isvempnsc9, label(IV)), bylabel(Junior High School) ///
|| (olsempnsc12, label(OLS)) (isvempnsc12, label(IV)), bylabel(High School) ///
|| (olsempnsc14, label(OLS)) (isvempnsc14, label(IV)), bylabel(Some College) ///
|| (olsempnsc16, label(OLS)) (isvempnsc16, label(IV)), bylabel(College) ///
||, at ciopts(recast(rline) lpattern(dash)) recast(connected) ///
xtitle("Employer Tenure") ytitle("Returns to Tenure on Earnings (%)") ///
yline(0) rescale(100)
graph export "C:\Users\AyakaNakamura\Dropbox\materials\Works\Master\program\Submittion\Output\plot_as_emp_sc.pdf", replace
}
 
**** regular
{
***** =0
est res olsregular
margins, exp(_b[oj]+emptenure*_b[emptenure]+ ///
c.emptenure#c.emptenure*_b[c.emptenure#c.emptenure]) ///
at(emptenure=(0(1)25)) noe post
est sto olsempnst0
est res isvregular
margins, exp(_b[oj]+emptenure*_b[emptenure]+ ///
c.emptenure#c.emptenure*_b[c.emptenure#c.emptenure]) ///
at(emptenure=(0(1)25)) noe post
est sto isvempnst0

***** =1
est res olsregular
margins, exp(_b[oj]+emptenure*_b[emptenure]+ ///
c.emptenure#c.emptenure*_b[c.emptenure#c.emptenure]+ ///
emptenure*_b[1.regular#c.emptenure]) ///
at(emptenure=(0(1)25)) noe post
est sto olsempnst1
est res isvregular
margins, exp(_b[oj]+emptenure*_b[emptenure]+ ///
c.emptenure#c.emptenure*_b[c.emptenure#c.emptenure]+ ///
emptenure*_b[1.regular#c.emptenure]) ///
at(emptenure=(0(1)25)) noe post
est sto isvempnst1

***** plot
coefplot (olsempnst0, label(OLS)) (isvempnst0, label(IV)), bylabel(Non-Regular) ///
|| (olsempnst1, label(OLS)) (isvempnst1, label(IV)), bylabel(Regular) ///
||, at ciopts(recast(rline) lpattern(dash)) recast(connected) ///
xtitle("Employer Tenure") ytitle("Returns to Tenure on Earnings (%)") ///
yline(0) rescale(100)
graph export "C:\Users\AyakaNakamura\Dropbox\materials\Works\Master\program\Submittion\Output\plot_as_emp_rg.pdf", replace
}

**** size
{
***** =0
est res olsempsi
margins, exp(_b[oj]+emptenure*_b[emptenure]+ ///
c.emptenure#c.emptenure*_b[c.emptenure#c.emptenure]) ///
at(emptenure=(0(1)25)) noe post
est sto olsempnsi0
est res isvempsi
margins, exp(_b[oj]+emptenure*_b[emptenure]+ ///
c.emptenure#c.emptenure*_b[c.emptenure#c.emptenure]) ///
at(emptenure=(0(1)25)) noe post
est sto isvempnsi0

***** =1
est res olsempsi
margins, exp(_b[oj]+emptenure*_b[emptenure]+ ///
c.emptenure#c.emptenure*_b[c.emptenure#c.emptenure]+ ///
emptenure*_b[1.size#c.emptenure]) ///
at(emptenure=(0(1)25)) noe post
est sto olsempnsi1
est res isvempsi
margins, exp(_b[oj]+emptenure*_b[emptenure]+ ///
c.emptenure#c.emptenure*_b[c.emptenure#c.emptenure]+ ///
emptenure*_b[1.size#c.emptenure]) ///
at(emptenure=(0(1)25)) noe post
est sto isvempnsi1

***** plot
coefplot (olsempnsi0, label(OLS)) (isvempnsi0, label(IV)), bylabel(size<500) ///
|| (olsempnsi1, label(OLS)) (isvempnsi1, label(IV)), bylabel(size>=500) ///
||, at ciopts(recast(rline) lpattern(dash)) recast(connected) ///
xtitle("Employer Tenure") ytitle("Returns to Tenure on Earnings (%)") ///
yline(0) rescale(100)
graph export "C:\Users\AyakaNakamura\Dropbox\materials\Works\Master\program\Submittion\Output\plot_as_emp_si.pdf", replace
}
}
 
*** output tex all results
{
**** coefficients 
quietly {
esttab olsempsc isvempsc olsregular isvregular olsempsi isvempsi ///
using "C:\Users\AyakaNakamura\Dropbox\materials\Works\Master\program\Submittion\Output\as_emp_ab.tex", ///
se star(* 0.1 ** 0.05 *** 0.01) b(4) ///
keep(emptenure c.emptenure#c.emptenure ///
oj workexp c.workexp#c.workexp ///
12.schooling#c.emptenure 14.schooling#c.emptenure ///
16.schooling#c.emptenure ///
1.regular#c.emptenure  ///
1.size#c.emptenure) ///
order(emptenure c.emptenure#c.emptenure ///
oj workexp c.workexp#c.workexp ///
12.schooling#c.emptenure 14.schooling#c.emptenure ///
16.schooling#c.emptenure ///
1.regular#c.emptenure  ///
1.size#c.emptenure) ///
coeflabel(emptenure "Employer tenure" ///
c.emptenure#c.emptenure "Emp.ten.$^{2}\times 100$" ///
oj "Old job" workexp "Total experience" c.workexp#c.workexp "Experience$^{2}$" ///
12.schooling#c.emptenure "High School" ///
14.schooling#c.emptenure "Some College" ///
16.schooling#c.emptenure "College" ///
1.regular#c.emptenure "Regular Employee" ///
1.size#c.emptenure "$500\leq$ size") ///
transform(c.emptenure#c.emptenure 100*@ 100) ///
nodep nonote nomtitles ///
title(Earnings Function Estimates, using Sample up to 64-year-old, ///
including Non-regular Workers and Specialists, ///
the Interactions of Employer Tenure and Proxies of Ability are Added to e.q. (1).) ///
mgroups("Years of Education" "Regular Employee" "Firm Size" ///
pattern(1 0 1 0 1 0) ///
prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) ///
replace
}

**** return
quietly {
esttab olsempnsc9 isvempnsc9 olsempnsc12 isvempnsc12 ///
olsempnsc14 isvempnsc14 olsempnsc16 isvempnsc16 ///
using "C:\Users\AyakaNakamura\Dropbox\materials\Works\Master\program\Submittion\Output\as_teturn_ab1.tex", ///
se star(* 0.1 ** 0.05 *** 0.01) b(4) ///
keep(3._at 6._at 11._at 16._at 21._at 26._at) ///
coeflabel(3._at "2 Years" ///
6._at "5 Years" 11._at "10 Years" ///
16._at "15 Years" ///
21._at "20 Years" 26._at "25 Years") ///
nodep nonote nomtitles ///
title(Estimated Returns to Employer Tenure, using Sample up to 64-year-old, ///
including Non-regular Workers and Specialists, ///
the Interactions of Employer Tenure and Proxies of Ability are Added to e.q. (1).) ///
mgroups("Years of Education" ///
pattern(1 0 0 0 0 0 0 0) ///
prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) ///
replace

esttab olsempnst0 isvempnst0 olsempnst1 isvempnst1 ///
olsempnsi0 isvempnsi0 olsempnsi1 isvempnsi1 ///
using "C:\Users\AyakaNakamura\Dropbox\materials\Works\Master\program\Submittion\Output\as_teturn_ab2.tex", ///
se star(* 0.1 ** 0.05 *** 0.01) b(4) ///
keep(3._at 6._at 11._at 16._at 21._at 26._at) ///
coeflabel(3._at "2 Years" ///
6._at "5 Years" 11._at "10 Years" ///
16._at "15 Years" ///
21._at "20 Years" 26._at "25 Years") ///
nodep nonote nomtitles ///
title(Estimated Returns to Employer Tenure, using Sample up to 64-year-old, ///
including Non-regular Workers and Specialists, ///
the Interactions of Employer Tenure and Proxies of Ability are Added to e.q. (1).) ///
mgroups("Regular Employee" "Firm Size" ///
pattern(1 0 0 0 1 0 0 0) ///
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
reg realwage i.occ i.ind i.union i.marital i.year i.schooling i.size i.regular ///
c.emptenure##c.emptenure oj c.workexp##c.workexp, vce(r)
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
ivregress 2sls realwage i.occ i.ind i.union i.marital i.year i.schooling i.size i.regular ///
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
ivregress 2sls realwage i.occ i.ind i.union i.marital i.year i.schooling i.size i.regular ///
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
reg realwage i.occ i.ind i.union i.marital i.year i.schooling i.size i.regular ///
c.emptenure##c.emptenure oj c.workexp##c.workexp, vce(r)
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
ivregress 2sls realwage i.occ i.ind i.union i.marital i.year i.schooling i.size i.regular ///
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
ivregress 2sls realwage i.occ i.ind i.union i.marital i.year i.schooling i.size i.regular ///
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
drop if size<1
}
reg realwage i.occ i.ind i.union i.marital i.year i.schooling i.size i.regular ///
c.emptenure##c.emptenure oj c.workexp##c.workexp, vce(r) l(90)
est sto olsempLa
}

**** AS
{
quietly {
use "C:\Users\AyakaNakamura\Dropbox\materials\Works\Master\program\Submittion\Input\jhps_hc.dta", clear
destring, replace
tsset id year
drop if size<1
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
ivregress 2sls realwage i.occ i.ind i.union i.marital i.year i.schooling i.size i.regular ///
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
ivregress 2sls realwage i.occ i.ind i.union i.marital i.year i.schooling i.size i.regular ///
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
drop if size==1
}
reg realwage i.occ i.ind i.union i.marital i.year i.schooling i.size i.regular ///
c.emptenure##c.emptenure oj c.workexp##c.workexp, vce(r)
est sto olsempSm
}

**** AS
{
quietly {
use "C:\Users\AyakaNakamura\Dropbox\materials\Works\Master\program\Submittion\Input\jhps_hc.dta", clear
destring, replace
tsset id year
drop if size==1
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
ivregress 2sls realwage i.occ i.ind i.union i.marital i.year i.schooling i.size i.regular ///
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
ivregress 2sls realwage i.occ i.ind i.union i.marital i.year i.schooling i.size i.regular ///
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
 }
 }

*** regular employee
{
**** OLS
{
quietly {
use "C:\Users\AyakaNakamura\Dropbox\materials\Works\Master\program\Submittion\Input\jhps_hc.dta", clear
destring, replace
tsset id year
drop if regular==0
}
reg realwage i.occ i.ind i.union i.marital i.year i.schooling i.size i.regular ///
c.emptenure##c.emptenure oj c.workexp##c.workexp, vce(r)
est sto olsempRg
}

**** AS
{
quietly {
use "C:\Users\AyakaNakamura\Dropbox\materials\Works\Master\program\Submittion\Input\jhps_hc.dta", clear
destring, replace
tsset id year
drop if regular==0
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
ivregress 2sls realwage i.occ i.ind i.union i.marital i.year i.schooling i.size i.regular ///
(c.emptenure##c.emptenure oj ///
c.workexp##c.workexp = ///
emptenureiv emptenureiv2 ojiv workexpiv workexpiv2), vce(r)
est sto isvempRg
drop if _est_isvempRg==0
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
ivregress 2sls realwage i.occ i.ind i.union i.marital i.year i.schooling i.size i.regular ///
(c.emptenure##c.emptenure oj ///
c.workexp##c.workexp = ///
emptenureiv emptenureiv2 ojiv workexpiv workexpiv2), vce(r)
est sto isvempRg
}

**** culc. return
{
est res olsempRg
margins, exp(_b[oj]+emptenure*_b[emptenure]+ ///
c.emptenure#c.emptenure*_b[c.emptenure#c.emptenure]) ///
at(emptenure=(0(1)25)) noe post
est sto olsempnRg
est res isvempRg
margins, exp(_b[oj]+emptenure*_b[emptenure]+ ///
c.emptenure#c.emptenure*_b[c.emptenure#c.emptenure]) ///
at(emptenure=(0(1)25)) noe post
est sto isvempnRg
}
}

*** non-regular employee
{
**** OLS
{
quietly {
use "C:\Users\AyakaNakamura\Dropbox\materials\Works\Master\program\Submittion\Input\jhps_hc.dta", clear
destring, replace
tsset id year
drop if regular==1
}
reg realwage i.occ i.ind i.union i.marital i.year i.schooling i.size i.regular ///
c.emptenure##c.emptenure oj c.workexp##c.workexp, vce(r)
est sto olsempNrg
}

**** AS
{
quietly {
use "C:\Users\AyakaNakamura\Dropbox\materials\Works\Master\program\Submittion\Input\jhps_hc.dta", clear
destring, replace
tsset id year
drop if regular==1
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
ivregress 2sls realwage i.occ i.ind i.union i.marital i.year i.schooling i.size i.regular ///
(c.emptenure##c.emptenure oj ///
c.workexp##c.workexp = ///
emptenureiv emptenureiv2 ojiv workexpiv workexpiv2), vce(r)
est sto isvempNrg
drop if _est_isvempNrg==0
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
ivregress 2sls realwage i.occ i.ind i.union i.marital i.year i.schooling i.size i.regular ///
(c.emptenure##c.emptenure oj ///
c.workexp##c.workexp = ///
emptenureiv emptenureiv2 ojiv workexpiv workexpiv2), vce(r)
est sto isvempNrg
}

**** culc. return
{
est res olsempNrg
margins, exp(_b[oj]+emptenure*_b[emptenure]+ ///
c.emptenure#c.emptenure*_b[c.emptenure#c.emptenure]) ///
at(emptenure=(0(1)25)) noe post
est sto olsempnNrg
est res isvempNrg
margins, exp(_b[oj]+emptenure*_b[emptenure]+ ///
c.emptenure#c.emptenure*_b[c.emptenure#c.emptenure]) ///
at(emptenure=(0(1)25)) noe post
est sto isvempnNrg
}
}

*** output tex all results
{
**** plot
coefplot (olsempn59, label(OLS)) (isvempn59, label(IV)), bylabel(Under 60-year-old) ///
|| (olsempnRg, label(OLS)) (isvempnRg, label(IV)), bylabel(Regular Employee) ///
|| (olsempnPr, label(OLS)) (isvempnPr, label(IV)), bylabel(Non-Professional) ///
|| (olsempnLa, label(OLS)) (isvempnLa, label(IV)), bylabel(Large Firm (Size>=500)) ///
|| (olsempnSm, label(OLS)) (isvempnSm, label(IV)), bylabel(Small Firm (Size<500)) ///
||, at ciopts(recast(rline) lpattern(dash)) recast(connected) ///
xtitle("Employer Tenure") ytitle("Returns to Tenure on Earnings (%)") ///
yline(0) rescale(100)
graph export "C:\Users\AyakaNakamura\Dropbox\materials\Works\Master\program\Submittion\Output\plot_as_emp_rob.pdf", replace

**** coefficients
quietly {
esttab olsemp59 isvemp59 olsempLa isvempLa ///
olsempSm isvempSm olsempPr isvempPr olsempRg isvempRg ///
using "C:\Users\AyakaNakamura\Dropbox\materials\Works\Master\program\Submittion\Output\as_emp_rob.tex", ///
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
title(Earnings Function Estimates, using Various Subsamples.) ///
mgroups("Under 59-year-old" "Large firms ($\geq500$)" ///
"Small Firms ($<500$)" "Non-Professional" ///
pattern(1 0 1 0 1 0 1 01 0) ///
prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) ///
replace
}

**** return
quietly {
esttab olsempn59 isvempn59 olsempnLa isvempnLa ///
olsempSm isvempSm olsempPr isvempPr olsempRg isvempRg ///
using "C:\Users\AyakaNakamura\Dropbox\materials\Works\Master\program\Submittion\Output\as_return_rob.tex", ///
se star(* 0.1 ** 0.05 *** 0.01) b(4) ///
keep(3._at 6._at 11._at 16._at 21._at 26._at) ///
coeflabel(3._at "2 Years" ///
6._at "5 Years" 11._at "10 Years" ///
16._at "15 Years" ///
21._at "20 Years" 26._at "25 Years") ///
nodep nonote nomtitles ///
title(Estimated Returns to Employer Tenure, using Various Subsamples.) ///
mgroups("Under 59-year-old" "Large firms ($\geq500$)" ///
"Small Firms ($<500$)" "Non-Professional" ///
pattern(1 0 1 0 1 0 1 0) ///
prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) ///
replace
}
}

}

* 4
** OLS->AS / テニュアをダミーで
*** tenure>=1, >=3, >=5, >=10, >=15
{
*** OLS
{
**** 基本の式との比較用
quietly {
use "C:\Users\AyakaNakamura\Dropbox\materials\Works\Master\program\Submittion\Input\jhps_hc.dta", clear
destring, replace
tsset id year
sort empid year
replace emptenure=40 if emptenure>=40
}
reg realwage i.occ i.ind i.union i.marital i.year i.schooling i.size i.regular ///
i.emptenure c.workexp##c.workexp, vce(r)
est sto Dm

**** IVと同じ式
quietly {
use "C:\Users\AyakaNakamura\Dropbox\materials\Works\Master\program\Submittion\Input\jhps_hc.dta", clear
destring, replace
tsset id year
sort empid year
* emptenureをダミーに変更
gen emp1=1 if emptenure>=1&emptenure<2
replace emp1=0 if emp1==.
gen emp2=1 if emptenure>=2&emptenure<5
replace emp2=0 if emp2==.
gen emp5=1 if emptenure>=5&emptenure<10
replace emp5=0 if emp5==.
gen emp10=1 if emptenure>=10&emptenure<15
replace emp10=0 if emp10==.
gen emp15=1 if emptenure>=15&emptenure<20
replace emp15=0 if emp15==.
gen emp20=1 if emptenure>=20&emptenure<25
replace emp20=0 if emp20==.
gen emp25=1 if emptenure>=25&emptenure<30
replace emp25=0 if emp25==.
gen emp30=1 if emptenure>=30
replace emp30=0 if emp30==.
}
reg realwage i.occ i.ind i.union i.marital i.year i.schooling i.size i.regular ///
emp1 emp2 emp5 emp10 emp15 emp20 emp25 emp30 ///
c.workexp##c.workexp, vce(r)
est sto olsempD
}

*** AS
{
quietly {
use "C:\Users\AyakaNakamura\Dropbox\materials\Works\Master\program\Submittion\Input\jhps_hc.dta", clear
destring, replace
tsset id year
sort empid year
* emptenureをダミーに変更
gen emp1=1 if emptenure>=1&emptenure<2
replace emp1=0 if emp1==.
gen emp2=1 if emptenure>=2&emptenure<5
replace emp2=0 if emp2==.
gen emp5=1 if emptenure>=5&emptenure<10
replace emp5=0 if emp5==.
gen emp10=1 if emptenure>=10&emptenure<15
replace emp10=0 if emp10==.
gen emp15=1 if emptenure>=15&emptenure<20
replace emp15=0 if emp15==.
gen emp20=1 if emptenure>=20&emptenure<25
replace emp20=0 if emp20==.
gen emp25=1 if emptenure>=25&emptenure<30
replace emp25=0 if emp25==.
gen emp30=1 if emptenure>=30
replace emp30=0 if emp30==.
* 操作変数を作成
for X in num 1 2 5 10 15 20 25 30: egen avgempX=mean(empX), by(empid)
for X in num 1 2 5 10 15 20 25 30: gen empivX=empX-avgempX
egen avgworkexp=mean(workexp), by(id)
egen avgworkexp2=mean(workexp^2), by(id)
egen avgworkexp3=mean(workexp^3), by(id)
gen workexpiv=workexp-avgworkexp
gen workexpiv2=workexp^2-avgworkexp2
gen workexpiv3=workexp^3-avgworkexp3
ivregress 2sls realwage i.occ i.ind i.union i.marital i.year i.schooling i.size i.regular ///
(emp1 emp2 emp5 emp10 emp15 emp20 emp25 emp30 ///
c.workexp##c.workexp = ///
empiv1 empiv2 empiv5 empiv10 empiv15 empiv20 empiv25 empiv30 ///
workexpiv workexpiv2), vce(r)
est sto isvempD
drop if _est_isvempD==0
drop *iv* avg*
* 必要な変数を再作成
for X in num 1 2 5 10 15 20 25 30: egen avgempX=mean(empX), by(empid)
for X in num 1 2 5 10 15 20 25 30: gen empivX=empX-avgempX
egen avgworkexp=mean(workexp), by(id)
egen avgworkexp2=mean(workexp^2), by(id)
egen avgworkexp3=mean(workexp^3), by(id)
gen workexpiv=workexp-avgworkexp
gen workexpiv2=workexp^2-avgworkexp2
gen workexpiv3=workexp^3-avgworkexp3
}
* 再推定
ivregress 2sls realwage i.occ i.ind i.union i.marital i.year i.schooling i.size i.regular ///
(emp1 emp2 emp5 emp10 emp15 emp20 emp25 emp30 ///
c.workexp##c.workexp = ///
empiv1 empiv2 empiv5 empiv10 empiv15 empiv20 empiv25 empiv30 ///
workexpiv workexpiv2), vce(r)
est sto isvempD
}
 
*** output tex all results
{
**** 基本の式とダミーの比較
{
est res Dm
coefplot, vertical yline(0) nolabel keep(*.emptenure) ///
ciopts(recast(rline) lpattern(dash)) recast(connected)  rescale(100) ///
xtitle("Employer Tenure") ytitle("Returns to Tenure on Earnings (%)") ///
rename(1.emptenure=1 2.emptenure=2 3.emptenure=3 4.emptenure=4 5.emptenure=5 ///
6.emptenure=6 7.emptenure=7 8.emptenure=8 9.emptenure=9 10.emptenure=10 ///
11.emptenure=11 12.emptenure=12 13.emptenure=13 14.emptenure=14 15.emptenure=15 ///
16.emptenure=16 17.emptenure=17 18.emptenure=18 19.emptenure=19 20.emptenure=20 ///
21.emptenure=21 22.emptenure=22 23.emptenure=23 24.emptenure=24 25.emptenure=25 ///
26.emptenure=26 27.emptenure=27 28.emptenure=28 29.emptenure=29 30.emptenure=30 ///
31.emptenure=31 32.emptenure=32 33.emptenure=33 34.emptenure=34 35.emptenure=35 ///
36.emptenure=36 37.emptenure=37 38.emptenure=38 39.emptenure=39 40.emptenure=40)  ///
title("Estimated Returns to Employer Tenure, Employer Tenure is Treated as Dummy Variables")
graph export "C:\Users\AyakaNakamura\Dropbox\materials\Works\Master\program\Submittion\Output\plot_as_dm.pdf", replace
}

**** OLSとIVの比較
quietly {
esttab olsempD isvempD ///
using "C:\Users\AyakaNakamura\Dropbox\materials\Works\Master\program\Submittion\Output\as_emp_dm.tex", ///
se star(* 0.1 ** 0.05 *** 0.01) b(4) ///
keep(emp1 emp2 emp5 emp10 emp15 emp20 emp25 emp30 ///
workexp c.workexp#c.workexp) ///
order(emp1 emp2 emp5 emp10 emp15 emp20 emp25 emp30 ///
workexp c.workexp#c.workexp) ///
coeflabel(emp1 "$1\leq T_{ij} < 2$" emp2 "$2\leq T_{ij} < 5$" ///
emp5 "$5\leq T_{ij} < 10$" emp10 "$10\leq T_{ij} < 15$" ///
emp15 "$15\leq T_{ij} < 20$" emp20 "$20\leq T_{ij} < 25$" ///
emp25 "$25\leq T_{ij} < 30$" emp30 "$30\leq T_{ij}$" ///
workexp "Total experience" c.workexp#c.workexp "Experience$^{2}$") ///
nodep nonote nomtitles ///
title(Estimated Returns to Employer Tenure, Employer Tenure is Treated as Dummy Variables) ///
mgroups("OLS" "IV" ///
pattern(1 1) ///
prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) ///
replace
}
}
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
** 1st stageに使うサンプルにフラグを立てて賃金とテニュアの差の変数を作成
bysort empid (year): gen fst=1 ///
if _n!=1&emptenure>=1
replace fst=0 if fst==.
gen emptendif2=2*emptenure-1 if fst==1
gen emptendif3=3*(emptenure^2)-3*emptenure+1 if fst==1
gen empexpdif2=2*workexp-1 if fst==1
gen empexpdif3=3*(workexp^2)-3*workexp+1 if fst==1
bysort empid (year): gen empwagedif=realwage-realwage[_n-1] if fst==1
drop if initialemp<0
tabulate year, generate(y)
for X in num 1/11 \ Y in num 2004/2014 : rename yX yY
drop if occ==1
replace fst=0 if fst==.|emptendif2==.
}

**** 1st step
reg empwagedif i.year if fst==1
est sto fst1
gen coefsum1=_b[_cons]
gen emptenB1=emptenure*_b[_cons] ///
+y2005*_b[2005b.year]+y2006*_b[2006.year]+y2007*_b[2007.year] ///
+y2008*_b[2008.year]+y2009*_b[2009.year]+y2010*_b[2010.year] ///
+y2011*_b[2011.year]+y2012*_b[2012.year]+y2013*_b[2013.year] ///
+y2014*_b[2014.year]
gen intwemp1=realwage-emptenB

**** 2nd step
reg intwemp1 i.union i.marital i.schooling i.regular ///
i.occ i.ind i.size ///
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
** 1st stageに使うサンプルにフラグを立てて賃金とテニュアの差の変数を作成
bysort empid (year): gen fst=1 ///
if _n!=1&emptenure>=1
replace fst=0 if fst==.
gen emptendif2=2*emptenure-1 if fst==1
gen emptendif3=3*(emptenure^2)-3*emptenure+1 if fst==1
gen empexpdif2=2*workexp-1 if fst==1
gen empexpdif3=3*(workexp^2)-3*workexp+1 if fst==1
bysort empid (year): gen empwagedif=realwage-realwage[_n-1] if fst==1
drop if initialemp<0
tabulate year, generate(y)
for X in num 1/11 \ Y in num 2004/2014 : rename yX yY
drop if occ==1
}
 
**** 1st step
reg empwagedif emptendif2 empexpdif2 i.year if fst==1
est sto fst2
gen emptenB2=emptenure*_b[_cons] ///
+_b[emptendif2]*emptenure^2+_b[empexpdif2]*workexp^2 ///
+y2005*_b[2005b.year]+y2006*_b[2006.year]+y2007*_b[2007.year] ///
+y2008*_b[2008.year]+y2009*_b[2009.year]+y2010*_b[2010.year] ///
+y2011*_b[2011.year]+y2012*_b[2012.year]+y2013*_b[2013.year] ///
+y2014*_b[2014.year]
gen intwemp2=realwage-emptenB2

**** 2nd step
reg intwemp2 i.union i.marital i.schooling i.regular ///
i.occ i.ind i.size ///
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

*** cubic
 {
quietly {
use "C:\Users\AyakaNakamura\Dropbox\materials\Works\Master\program\Submittion\Input\jhps_hc.dta", clear
destring, replace
tsset id year
* 変数を作る
sort empid year
gen initialemp=workexp-emptenure
** 1st stageに使うサンプルにフラグを立てて賃金とテニュアの差の変数を作成
bysort empid (year): gen fst=1 ///
if switch==0&_n!=1&emptenure>=1
replace fst=0 if fst==.
gen emptendif2=2*emptenure-1 if fst==1
gen emptendif3=3*(emptenure^2)-3*emptenure+1 if fst==1
gen empexpdif2=2*workexp-1 if fst==1
gen empexpdif3=3*(workexp^2)-3*workexp+1 if fst==1
bysort empid (year): gen empwagedif=realwage-realwage[_n-1] if fst==1
drop if initialemp<0
tabulate year, generate(y)
for X in num 1/11 \ Y in num 2004/2014 : rename yX yY
drop if occ==1
}
 
**** 1st step
reg empwagedif emptendif2 empexpdif2 emptendif3 empexpdif3 i.year
est sto fst3
gen emptenB3=emptenure*_b[_cons] ///
+_b[emptendif2]*emptenure^2+_b[empexpdif2]*workexp^2 ///
+_b[emptendif3]*emptenure^3+_b[empexpdif3]*workexp^3 ///
+y2005*_b[2005b.year]+y2006*_b[2006.year]+y2007*_b[2007.year] ///
+y2008*_b[2008.year]+y2009*_b[2009.year]+y2010*_b[2010.year] ///
+y2011*_b[2011.year]+y2012*_b[2012.year]+y2013*_b[2013.year] ///
+y2014*_b[2014.year]
gen intwemp3=realwage-emptenB3

**** 2nd step
reg intwemp3 i.union i.marital i.schooling i.regular ///
i.occ i.ind i.size ///
initialemp, nocons
est sto snd3
gen coefexp3=_b[initialemp]

**** culc return
{
capture program drop coef
program coef, rclass
	suest fst3 snd3
	lincom [fst3_mean]_b[_cons]-[snd3_mean]_b[initialemp]
	return scalar diffse =r(se)
end
coef
capture program drop emprtn
program emprtn, rclass
suest fst3 snd3
	foreach X of numlist 2 5 10 15 20 25 {
	lincom ([fst3_mean]_b[_cons]-[snd3_mean]_b[initialemp])*`X'+ ///
	[fst3_mean]_b[emptendif2]*`X'*`X'+[fst3_mean]_b[emptendif3]*`X'*`X'*`X'
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
esttab fst1 fst2 fst3 ///
using "C:\Users\AyakaNakamura\Dropbox\materials\Works\Master\program\Submittion\Output\topel_emp.tex", ///
se star(* 0.1 ** 0.05 *** 0.01) b(4) ///
keep(_cons emptendif2 emptendif3 ///
empexpdif2 empexpdif3) ///
order(_cons emptendif2 emptendif3 ///
empexpdif2 empexpdif3) ///
coeflabel(_cons "Constant" ///
emptendif2 "Emp.ten.$^{2}\times 100$" ///
emptendif3 "Emp.ten.$^{3}\times 1000$" ///
empexpdif2 "Experience$^{2}\times 100$" ///
empexpdif3 "Experience$^{3}\times 1000$") ///
transform(emptendif2 100*@ 100 ///
emptendif3 1000*@ 1000 ///
empexpdif2 100*@ 100 ///
empexpdif3 1000*@ 1000) ///
nodep nonote nomtitles ///
title(Estimation Results, using the Method of 2SFD Estimation.) ///
replace
}
}
}
 
 
* 6
** 戸田さんとの比較
{
*** Sampleを作る
{
**** male, employed, 2004--2007, 20--60, regularのみ
use  "C:\Users\AyakaNakamura\Dropbox\materials\Works\Master\program\Submittion\Input\jhps_hc_TenureCheck.dta", clear
*** パネル化
tsset id year
*** emptenure
forvalues X = 2005(1)2014{ 
	**** 転職してない->+1
	replace emptenure=emptenure[_n-1]+(year-year[_n-1]) ///
		if switch==0 & year==`X'
	**** 転職した->0.5
	replace emptenure=0.5 ///
		if switch==1 & year==`X'
	**** 最初のobservationは変更しない
	bysort id (year): replace emptenure=intten if _n==1
}
drop empten2* intten
*** workexp
replace workexp=age-schooling-6
drop workexp2* intexp
*** empidの作成
sort id year
by id: gen empid = 1 if _n==1|switch==1|emptenure<emptenure[_n-1]
replace empid=sum(empid)
*** 2004--2007のみ残す
keep if year<=2007
*** regularのみ残す
keep if regular==1
*** 18歳～64歳のみ残す
keep if age>=20 & age<=60
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
replace emptenure=. if emptenure<0|emptenure>age|emptenure>workexp
replace workexp=. if workexp<0

save  "C:\Users\AyakaNakamura\Dropbox\materials\Works\Master\program\Submittion\Input\jhps_toda.dta", replace
}
/*
mean(推定に使ったもの)
サンプル数: 4456
勤続年数: 14.277
労働経験: 23.117
対数賃金: 7.638
勤続年数だけ2年も違う, その他の変数は概ね戸田さんと同じ
*/

*** AS
{
*** OLS
{
quietly {
use "C:\Users\AyakaNakamura\Dropbox\materials\Works\Master\program\Submittion\Input\jhps_toda.dta", clear
destring, replace
tsset id year
}

***** 1st
reg realwage i.occ i.ind i.union schooling i.size ///
c.emptenure c.workexp, vce(r)
est sto olsemp1
***** 2nd
reg realwage i.occ i.ind i.union schooling i.size ///
c.emptenure##c.emptenure c.workexp##c.workexp, vce(r)
est sto olsemp2
***** 3rd
reg realwage i.occ i.ind i.union schooling i.size ///
c.emptenure##c.emptenure##c.emptenure c.workexp##c.workexp##c.workexp, vce(r)
est sto olsemp3
***** 4th
reg realwage i.occ i.ind i.union schooling i.size ///
c.emptenure##c.emptenure##c.emptenure##c.emptenure ///
c.workexp##c.workexp##c.workexp##c.workexp, vce(r)
est sto olsemp4
}

*** AS
{
***** 1st
quietly {
use "C:\Users\AyakaNakamura\Dropbox\materials\Works\Master\program\Submittion\Input\jhps_toda.dta", clear
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
ivregress 2sls realwage i.occ i.ind i.union schooling i.size ///
(c.emptenure c.workexp = ///
emptenureiv workexpiv), vce(r)
est sto isvemp1
drop if _est_isvemp1==0
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
}
* 再推定
ivregress 2sls realwage i.occ i.ind i.union schooling i.size ///
(c.emptenure c.workexp = ///
emptenureiv workexpiv), vce(r)
est sto isvemp1

***** 2nd
quietly {
use "C:\Users\AyakaNakamura\Dropbox\materials\Works\Master\program\Submittion\Input\jhps_toda.dta", clear
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
ivregress 2sls realwage i.occ i.ind i.union schooling i.size ///
(c.emptenure##c.emptenure c.workexp##c.workexp = ///
emptenureiv emptenureiv2 workexpiv workexpiv2), vce(r)
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
}
* 再推定
ivregress 2sls realwage i.occ i.ind i.union schooling i.size ///
(c.emptenure##c.emptenure c.workexp##c.workexp = ///
emptenureiv emptenureiv2 workexpiv workexpiv2), vce(r)
est sto isvemp2

***** 3rd
quietly {
use "C:\Users\AyakaNakamura\Dropbox\materials\Works\Master\program\Submittion\Input\jhps_toda.dta", clear
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
ivregress 2sls realwage i.occ i.ind i.union schooling i.size ///
(c.emptenure##c.emptenure##c.emptenure c.workexp##c.workexp##c.workexp = ///
emptenureiv emptenureiv2 emptenureiv3 workexpiv workexpiv2 workexpiv3), vce(r)
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
}
* 再推定
ivregress 2sls realwage i.occ i.ind i.union schooling i.size ///
(c.emptenure##c.emptenure##c.emptenure c.workexp##c.workexp##c.workexp = ///
emptenureiv emptenureiv2 emptenureiv3 workexpiv workexpiv2 workexpiv3), vce(r)
est sto isvemp3

***** 4th
quietly {
use "C:\Users\AyakaNakamura\Dropbox\materials\Works\Master\program\Submittion\Input\jhps_toda.dta", clear
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
ivregress 2sls realwage i.occ i.ind i.union schooling i.size ///
(c.emptenure##c.emptenure##c.emptenure##c.emptenure ///
c.workexp##c.workexp##c.workexp##c.workexp = ///
emptenureiv emptenureiv2 emptenureiv3 emptenureiv4 ///
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
}
* 再推定
ivregress 2sls realwage i.occ i.ind i.union schooling i.size ///
(c.emptenure##c.emptenure##c.emptenure##c.emptenure ///
c.workexp##c.workexp##c.workexp##c.workexp = ///
emptenureiv emptenureiv2 emptenureiv3 emptenureiv4 ///
workexpiv workexpiv2 workexpiv3 workexpiv4), vce(r)
est sto isvemp4
}

*** return
{
***** 2nd
est res olsemp2
margins, exp(emptenure*_b[emptenure]+ ///
c.emptenure#c.emptenure*_b[c.emptenure#c.emptenure]) ///
at(emptenure=(0(1)25)) noe post
est sto olsempr2
est res isvemp2
margins, exp(emptenure*_b[emptenure]+ ///
c.emptenure#c.emptenure*_b[c.emptenure#c.emptenure]) ///
at(emptenure=(0(1)25)) noe post
est sto isvempr2
 
***** 3rd
est res olsemp3
margins, exp(emptenure*_b[emptenure]+ ///
c.emptenure#c.emptenure*_b[c.emptenure#c.emptenure] ///
+c.emptenure#c.emptenure#c.emptenure*_b[c.emptenure#c.emptenure#c.emptenure]) ///
at(emptenure=(0(1)25)) noe post
est sto olsempr3
est res isvemp3
margins, exp(emptenure*_b[emptenure]+ ///
c.emptenure#c.emptenure*_b[c.emptenure#c.emptenure] ///
+c.emptenure#c.emptenure#c.emptenure*_b[c.emptenure#c.emptenure#c.emptenure]) ///
at(emptenure=(0(1)25)) noe post
est sto isvempr3

***** 4th
est res olsemp4
margins, exp(emptenure*_b[emptenure]+ ///
c.emptenure#c.emptenure*_b[c.emptenure#c.emptenure] ///
+c.emptenure#c.emptenure#c.emptenure*_b[c.emptenure#c.emptenure#c.emptenure] ///
+c.emptenure#c.emptenure#c.emptenure#c.emptenure* ///
_b[c.emptenure#c.emptenure#c.emptenure#c.emptenure]) ///
at(emptenure=(0(1)25)) noe post
est sto olsempr4
est res isvemp4
margins, exp(emptenure*_b[emptenure]+ ///
c.emptenure#c.emptenure*_b[c.emptenure#c.emptenure] ///
+c.emptenure#c.emptenure#c.emptenure*_b[c.emptenure#c.emptenure#c.emptenure] ///
+c.emptenure#c.emptenure#c.emptenure#c.emptenure* ///
_b[c.emptenure#c.emptenure#c.emptenure#c.emptenure]) ///
at(emptenure=(0(1)25)) noe post
est sto isvempr4
}
/*
OLSは係数リターンともに比較的戸田さんと似ている
IVは係数, 有意水準が付くタイミング, リターンどれも似ているとは言い難い
*/

*** Topel
{
*** linear
{
quietly {
use "C:\Users\AyakaNakamura\Dropbox\materials\Works\Master\program\Submittion\Input\jhps_toda.dta", clear
destring, replace
tsset id year
* 変数を作る
sort empid year
gen initialemp=workexp-emptenure
** 1st stageに使うサンプルにフラグを立てて賃金とテニュアの差の変数を作成
bysort empid (year): gen fst=1 ///
if _n!=1&emptenure>=1
replace fst=0 if fst==.
gen emptendif2=2*emptenure-1 if fst==1
gen emptendif3=3*(emptenure^2)-3*emptenure+1 if fst==1
gen empexpdif2=2*workexp-1 if fst==1
gen empexpdif3=3*(workexp^2)-3*workexp+1 if fst==1
bysort empid (year): gen empwagedif=realwage-realwage[_n-1] if fst==1
drop if initialemp<0
tabulate year, generate(y)
for X in num 1/4 \ Y in num 2004/2007 : rename yX yY
drop if occ==1
replace fst=0 if fst==.|emptendif2==.
}

**** 1st step
reg empwagedif if fst==1
est sto fst1
gen coefsum1=_b[_cons]
gen emptenB1=emptenure*_b[_cons]
gen intwemp1=realwage-emptenB

**** 2nd step
reg intwemp1 i.union ///
i.occ i.ind i.size ///
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
use "C:\Users\AyakaNakamura\Dropbox\materials\Works\Master\program\Submittion\Input\jhps_toda.dta", clear
destring, replace
tsset id year
* 変数を作る
sort empid year
gen initialemp=workexp-emptenure
** 1st stageに使うサンプルにフラグを立てて賃金とテニュアの差の変数を作成
bysort empid (year): gen fst=1 ///
if _n!=1&emptenure>=1
replace fst=0 if fst==.
gen emptendif2=2*emptenure-1 if fst==1
gen emptendif3=3*(emptenure^2)-3*emptenure+1 if fst==1
gen empexpdif2=2*workexp-1 if fst==1
gen empexpdif3=3*(workexp^2)-3*workexp+1 if fst==1
bysort empid (year): gen empwagedif=realwage-realwage[_n-1] if fst==1
drop if initialemp<0
tabulate year, generate(y)
for X in num 1/4 \ Y in num 2004/2007 : rename yX yY
drop if occ==1
}
 
**** 1st step
reg empwagedif emptendif2 empexpdif2 if fst==1
est sto fst2
gen emptenB2=emptenure*_b[_cons] ///
+_b[emptendif2]*emptenure^2+_b[empexpdif2]*workexp^2
gen intwemp2=realwage-emptenB2

**** 2nd step
reg intwemp2 i.union ///
i.occ i.ind i.size ///
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

*** cubic
 {
quietly {
use "C:\Users\AyakaNakamura\Dropbox\materials\Works\Master\program\Submittion\Input\jhps_toda.dta", clear
destring, replace
tsset id year
* 変数を作る
sort empid year
gen initialemp=workexp-emptenure
** 1st stageに使うサンプルにフラグを立てて賃金とテニュアの差の変数を作成
bysort empid (year): gen fst=1 ///
if switch==0&_n!=1&emptenure>=1
replace fst=0 if fst==.
gen emptendif2=2*emptenure-1 if fst==1
gen emptendif3=3*(emptenure^2)-3*emptenure+1 if fst==1
gen empexpdif2=2*workexp-1 if fst==1
gen empexpdif3=3*(workexp^2)-3*workexp+1 if fst==1
bysort empid (year): gen empwagedif=realwage-realwage[_n-1] if fst==1
drop if initialemp<0
tabulate year, generate(y)
for X in num 1/4 \ Y in num 2004/2007 : rename yX yY
drop if occ==1
}
 
**** 1st step
reg empwagedif emptendif2 empexpdif2 emptendif3 empexpdif3
est sto fst3
gen emptenB3=emptenure*_b[_cons] ///
+_b[emptendif2]*emptenure^2+_b[empexpdif2]*workexp^2 ///
+_b[emptendif3]*emptenure^3+_b[empexpdif3]*workexp^3
gen intwemp3=realwage-emptenB3

**** 2nd step
reg intwemp3 i.union ///
i.occ i.ind i.size ///
initialemp, nocons
est sto snd3
gen coefexp3=_b[initialemp]

**** culc return
{
capture program drop coef
program coef, rclass
	suest fst3 snd3
	lincom [fst3_mean]_b[_cons]-[snd3_mean]_b[initialemp]
	return scalar diffse =r(se)
end
coef
capture program drop emprtn
program emprtn, rclass
suest fst3 snd3
	foreach X of numlist 2 5 10 15 20 25 {
	lincom ([fst3_mean]_b[_cons]-[snd3_mean]_b[initialemp])*`X'+ ///
	[fst3_mean]_b[emptendif2]*`X'*`X'+[fst3_mean]_b[emptendif3]*`X'*`X'*`X'
	return scalar rtn`X' =r(se)
	}
end
emprtn
}
}
}
/*
本当に教育年数コントロールしていないのか疑問
(してもしなくても結果はほぼ変わらない)
戸田さんとはtenureの係数について異なる: 有意にならない, 大きすぎる
勤続年数10年以降でリターンがかなり違う
*/


}
