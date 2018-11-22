/* Title: Estimation */
/// Date: Oct 29th, 2018
/// Written by Ayaka Nakamura
/// 
/// This file is for estimation
/// 
/// 1. OLS->AS / 1-4 dimenational polynomial
/// 2. OLS->AS / under 60-year-old, firm size, non-specialist, regular employee
/// 3. OLS->AS / tenure as dummy
/// 4. Topel / 1-4 dimenational polynomial
/// 5. Compare with Toda(2009)

*  0. Preparation
qui {
	* Set Directories
	global Path "C:\Users\AyakaNakamura\Dropbox\materials\Works\Master\program\Submittion"
	global Code "C:\Users\AyakaNakamura\Dropbox\materials\Works\Master\program\Submittion\Code"
	global Original "C:\Users\AyakaNakamura\Dropbox\materials\Works\Master\program\Submittion\OriginalData"
	global Inputfd "C:\Users\AyakaNakamura\Dropbox\materials\Works\Master\program\Submittion\Input"
	global Output "C:\Users\AyakaNakamura\Dropbox\materials\Works\Master\program\Submittion\Output"
	global Inter "C:\Users\AyakaNakamura\Dropbox\materials\Works\Master\program\Submittion\Intermediate"
	global Prg "C:\Users\AyakaNakamura\Dropbox\materials\Works\Master\program" 
	
	cd $Code
	adopath + $Original
	adopath + $Inputfd
	adopath + $Output
	adopath + $Inter
	adopath + "$Prg\coefplot"
	adopath + "$Prg\estout"

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
	** list of iv 
	local empiv1 emptenureiv ojiv workexpiv
	local empiv2 emptenureiv emptenureiv2 ojiv ///
						workexpiv workexpiv2
	local empiv3 emptenureiv emptenureiv2 emptenureiv3 ojiv ///
						workexpiv workexpiv2 workexpiv3
	local empiv4 emptenureiv emptenureiv2 emptenureiv3 emptenureiv4 ojiv ///
						workexpiv workexpiv2 workexpiv3 workexpiv4
	** list of iv (including occupation tenure)
	local empocciv1 emptenureiv ojiv workexpiv occtenureiv
	local empocciv2 emptenureiv emptenureiv2 ojiv ///
								workexpiv workexpiv2 ///
								occtenureiv occtenureiv2
	local empocciv3 emptenureiv emptenureiv2 emptenureiv3 ojiv ///
								workexpiv workexpiv2 workexpiv3 ///
								occtenureiv occtenureiv2 occtenureiv3
	local empocciv4 emptenureiv emptenureiv2 emptenureiv3 emptenureiv4 ojiv ///
								workexpiv workexpiv2 workexpiv3 workexpiv4 ///
								occtenureiv occtenureiv2 occtenureiv3 occtenureiv4
	** list of variable list
	local isIncOcc emp empocc
}

* Open Log file
cap log close /* close any log files that accidentally have been left open. */
log using "$Path\Log\Estimation.log", replace



* 1. OLS->AS / 1-4 dimenational polynomial
{
** OLS
*** reading data
do "$Code\ReadData.do"

foreach ten_i of local isIncOcc{
	forvalues poly_x=1/4{
		dis "/* OLS `ten_i' `poly_x'th order */"
		reg ///
				`commonVar' ///
				``ten_i'`poly_x'' ///
				, vce(r)
		est sto ols`ten_i'`poly_x'
	}
}

** AS
foreach ten_i of local isIncOcc{
	forvalues poly_x=1/4{
		qui {
			do "$Code\ReadData.do"
			do "$Code\ConstructIV.do"
			ivregress 2sls ///
						`commonVar' ///
						(``ten_i'`poly_x'' = ``ten_i'iv`poly_x'') ///
						, vce(r)
			est sto isv`ten_i'`poly_x'
			drop if _est_isv`ten_i'`poly_x'==0
			drop *iv *iv? avg*
			**** re-build iv
			do "$Code\ConstructIV.do"
		}
		dis "/* AS's IV `ten_i' `poly_x'th order */"
		ivregress 2sls ///
				`commonVar' ///
				(``ten_i'`poly_x'' = ``ten_i'iv`poly_x'') ///
				, vce(r)
		est sto isv`ten_i'`poly_x'
	}
}

** culc. return
qui{
	local culcemp1 _b[oj]+emptenure*_b[emptenure]
	local culcemp2 _b[oj]+emptenure*_b[emptenure] ///
							+(emptenure^2)*_b[c.emptenure#c.emptenure]
	local culcemp3 _b[oj]+emptenure*_b[emptenure] ///
							+(emptenure^2)*_b[c.emptenure#c.emptenure] ///
							+(emptenure^3)*_b[c.emptenure#c.emptenure#c.emptenure]
	local culcemp4 _b[oj]+emptenure*_b[emptenure] ///
							+(emptenure^2)*_b[c.emptenure#c.emptenure] ///
							+(emptenure^3)*_b[c.emptenure#c.emptenure#c.emptenure] ///
							+(emptenure^4)*_b[c.emptenure#c.emptenure#c.emptenure#c.emptenure]
	local comSetPlot at ciopts(recast(rline) lpattern(dash)) recast(connected) ///
								xtitle("Employer Tenure") ytitle("Returns to Tenure on Earnings (%)") ///
								yline(0) rescale(100)
}

foreach ten_i of local isIncOcc{ /* loop within emp and empocc */
	forvalues poly_x=1/4{ /* loop within ten_inomial */
		*** culculation
		dis "/* `ten_i' `poly_x'th order */"
		est res ols`ten_i'`poly_x'
		margins, exp(`culcemp`poly_x'') ///
		at(emptenure=(0(1)25)) noe post
		est sto ols`ten_i'r`poly_x'
		est res isv`ten_i'`poly_x'
		margins, exp(`culcemp`poly_x'') ///
		at(emptenure=(0(1)25)) noe post
		est sto isv`ten_i'r`poly_x'
		
		*** plot
		qui coefplot (ols`ten_i'r`poly_x', label(OLS)) (isv`ten_i'r`poly_x', label(IV)), ///
		`comSetPlot'
		graph export "$Output\plot_as_`ten_i'_`poly_x'.pdf", replace
	}
}

** output tex all results
{
qui{
local labelVar emptenure "Employer tenure" ///
						c.emptenure#c.emptenure "Emp.ten.$^{2}\times 100$" ///
						c.emptenure#c.emptenure#c.emptenure "Emp.ten.$^{3}\times 100$" ///
						c.emptenure#c.emptenure#c.emptenure#c.emptenure "Emp.ten.$^{4}\times 1000$" ///
						oj "Old job" ///
						workexp "Total experience" c.workexp#c.workexp "Experience$^{2}$" ///
						c.workexp#c.workexp#c.workexp "Exp.$^{3}\times 100$" ///
						c.workexp#c.workexp#c.workexp#c.workexp "Exp.$^{4}\times 10000$"
local transVar c.emptenure#c.emptenure 100*@ 100 ///
						c.emptenure#c.emptenure#c.emptenure 100*@ 100 ///
						c.emptenure#c.emptenurec.emptenure#c.emptenure 10000*@ 10000 ///
						c.workexp#c.workexp#c.workexp 100*@ 100 ///
						c.workexp#c.workexp#c.workexp 10000*@ 10000 ///
						c.occtenure#c.occtenure 100*@ 100 ///
						c.occtenure#c.occtenure#c.occtenure 100*@ 100 ///
						c.occtenure#c.occtenure#c.occtenure#c.occtenure 10000*@ 10000
local comSetTex prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) ///
					se star(* 0.1 ** 0.05 *** 0.01) b(4) ///
					nodep nonote nomtitles ///
					replace

*** coefficients / emp+occ
local keepVar emptenure c.emptenure#c.emptenure ///
						c.emptenure#c.emptenure#c.emptenure ///
						c.emptenure#c.emptenure#c.emptenure#c.emptenure ///
						oj ///
						occtenure c.occtenure#c.occtenure ///
						c.occtenure#c.occtenure#c.occtenure ///
						c.occtenure#c.occtenure#c.occtenure#c.occtenure ///
						workexp c.workexp#c.workexp ///
						c.workexp#c.workexp#c.workexp ///
						c.workexp#c.workexp#c.workexp#c.workexp

esttab olsempocc2 olsempocc3 olsempocc4 isvempocc2 isvempocc3 isvempocc4 ///
using "$Output\as_empocc.tex", ///
keep(`keepVar') ///
order(`keepVar') ///
coeflabel(`labelVar' ///
				occtenure "Occupation tenure" ///
				c.occtenure#c.occtenure "Occ.ten.$^{2}\times 100$" ///
				c.occtenure#c.occtenure#c.occtenure "Occ.ten.$^{3}\times 100$" ///
				c.occtenure#c.occtenure#c.occtenure#c.occtenure "Occ.ten.$^{4}\times 10000$" ///
				) ///
transform(`transVar') ///
title(Earnings Function Estimates, using Sample up to 64-year-old, ///
including Non-regular Workers and Specialists, ///
Variables of Occupation Tenure are Controlled.) ///
mgroups("OLS" "IV" ///
pattern(1 0 0 1 0 0) ///
`comSetTex'

*** coefficients / emptenure
local keepVar emptenure c.emptenure#c.emptenure ///
						c.emptenure#c.emptenure#c.emptenure ///
						c.emptenure#c.emptenure#c.emptenure#c.emptenure ///
						oj workexp c.workexp#c.workexp ///
						c.workexp#c.workexp#c.workexp ///
						c.workexp#c.workexp#c.workexp#c.workexp

esttab olsemp2 olsemp3 olsemp4 isvemp2 isvemp3 isvemp4 ///
using "$Output\as_emp.tex", ///
keep(`keepVar') ///
order(`keepVar') ///
coeflabel(`labelVar') ///
transform(`transVar') ///
title(Earnings Function Estimates, using Sample up to 64-year-old, ///
including Non-regular Workers and Specialists, ///
Variables of Occupation Tenure are not Controlled.) ///
mgroups("OLS" "IV" ///
pattern(1 0 0 1 0 0) ///
`comSetTex'

*** main table
esttab olsemp2 olsempocc2 isvemp2 isvempocc2 ///
using "$Output\as_main.tex", ///
keep(`keepVar') ///
order(`keepVar') ///
coeflabel(`labelVar') ///
transform(`transVar') ///
title(Earnings Function Estimates, using Sample up to 64-year-old, ///
including Non-regular Workers and Specialists.) ///
mgroups("OLS" "IV" ///
pattern(1 0 1 0) ///
`comSetTex'

*** return
esttab olsempr2 olsempoccr2 isvempr2 isvempoccr2 ///
using "$Output\as_return.tex", ///
keep(3._at 6._at 11._at 16._at 21._at 26._at) ///
coeflabel(3._at "2 Years" ///
6._at "5 Years" 11._at "10 Years" ///
16._at "15 Years" ///
21._at "20 Years" 26._at "25 Years") ///
title(Estimated Returns to Employer Tenure, using Sample up to 64-year-old, ///
including Non-regular Workers and Specialists.) ///
mgroups("OLS" "IV" ///
pattern(1 0 1 0) ///
`comSetTex'
}
}
}



* 2. OLS->AS / under 60-year-old, firm size, non-specialist, regular employee
{
local subSample Yn Pr La Sm Rg
foreach sub_i of local subSample{ /* loop within subsample */
	do "$Code\ReadData.do"
	/// criterion for making subsamples
	if "`sub_i'"=="Yn"{ /* under 59-year-old */
		dis "/* under 59-year-old */"
		drop if age>=60
		sum age
	}
	else if "`sub_i'"=="Pr"{ /* non-professional */
		dis "/* non-professional */"
		drop if occ==10
		tab occ
	}
	else if "`sub_i'"=="La"{ /* large firm */
		dis "/* large firm */"
		keep if dsize==2
		tab dsize
	}
	else if "`sub_i'"=="Sm"{ /* small firm */
		dis "/* small firm */"
		drop if dsize==2
		tab dsize
	}
	else if "`sub_i'"=="Rg"{ /* regular employee */
		dis "/* regular employee */"
		drop if dregular==0
	tab dregular
	}
	*** OLS
	reg ///
		`commonVar' ///
		`emp2' ///
		, vce(r)
		est sto olsrob`sub_i'
	
	*** AS
	qui {
		do "$Code\ConstructIV.do"
		ivregress 2sls ///
							`commonVar' ///
							(`emp2' = `empiv2') ///
							, vce(r)
		est sto isvrob`sub_i'
		drop if _est_isvrob`sub_i'==0
		drop *iv *iv? avg*
		**** re-build iv
		do "$Code\ConstructIV.do"
	}
	ivregress 2sls ///
						`commonVar' ///
						(`emp2' = `empiv2') ///
						, vce(r)
	est sto isvrob`sub_i'
	
	*** culculation
	est res olsrob`sub_i'
	margins, exp(`culcemp2') ///
	at(emptenure=(0(1)25)) noe post
	est sto olsrobn`sub_i'
	est res isvrob`sub_i'
	margins, exp(`culcemp2') ///
	at(emptenure=(0(1)25)) noe post
	est sto isvrobn`sub_i'
}
*** plot
qui coefplot (olsrobnYn, label(OLS)) (isvrobnYn, label(IV)), bylabel(Under 60-year-old) ///
|| (olsrobnRg, label(OLS)) (isvrobnRg, label(IV)), bylabel(Regular Employee) ///
|| (olsrobnPr, label(OLS)) (isvrobnPr, label(IV)), bylabel(Non-Professional) ///
|| (olsrobnLa, label(OLS)) (isvrobnLa, label(IV)), bylabel(Large Firm (Size>=500)) ///
|| (olsrobnSm, label(OLS)) (isvrobnSm, label(IV)), bylabel(Small Firm (Size<500)) ///
||, `comSetPlot'
graph export "$Output\plot_as_emp_rob.pdf", replace


** output tex all results
qui{
local keepVar emptenure c.emptenure#c.emptenure ///
						oj workexp c.workexp#c.workexp
** coefficients
esttab olsrobYn isvrobYn olsrobLa isvrobLa ///
olsrobSm isvrobSm olsrobPr isvrobPr olsrobRg isvrobRg ///
using "$Output\as_emp_rob.tex", ///
keep(`keepVar') ///
order(`keepVar') ///
coeflabel(`labelVar') ///
transform(`transVar') ///
title(Earnings Function Estimates, using Various Subsamples.) ///
mgroups("Under 59-year-old" "Large firms ($\geq500$)" ///
"Small Firms ($<500$)" "Non-Professional" "Regular Employee" ///
pattern(1 0 1 0 1 0 1 0 1 0) ///
`comSetTex'

**** return
esttab olsrobnYn isvrobnYn olsrobnLa isvrobnLa ///
olsrobnSm isvrobnSm olsrobnPr isvrobnPr olsrobnRg isvrobnRg ///
using "$Output\as_return_rob.tex", ///
keep(3._at 6._at 11._at 16._at 21._at 26._at) ///
coeflabel(3._at "2 Years" ///
6._at "5 Years" 11._at "10 Years" ///
16._at "15 Years" ///
21._at "20 Years" 26._at "25 Years") ///
title(Estimated Returns to Employer Tenure, using Various Subsamples.) ///
mgroups("Under 59-year-old" "Large firms ($\geq500$)" ///
"Small Firms ($<500$)" "Non-Professional" "Regular Employee" ///
pattern(1 0 1 0 1 0 1 0 1 0) ///
`comSetTex'
}
}



* 3. OLS->AS / tenure as dummy
{
** tenure>=1, >=3, >=5, >=10, >=15
*** simple dummy
do "$Code\ReadData.do"
sort empid year
replace emptenure=40 if emptenure>=40
est sto olsrobRg
dis " /* simple dummy */ "
reg ///
	`commonVar' ///
	i.emptenure c.workexp##c.workexp ///
	, vce(r)
est sto Dm

*** same equation as AS
do "$Code\ReadData.do"
sort empid year
numlist "1 2 5 10 15 20 25 30"
local tendm "`r(numlist)'"
**** make emptenure dummy
foreach i of local tendm {
	gen emp`i'=1 if emptenure>=`i'
	replace emp`i'=0 if emp`i'==.
}
dis " /* OLS dummy */ "
reg ///
	`commonVar' ///
	emp1 emp2 emp5 emp10 emp15 emp20 emp25 emp30 ///
	c.workexp##c.workexp ///
	, vce(r)
est sto olsempD

*** AS
qui {
	do "$Code\ConstructIV.do"
	foreach i of local tendm {
		bysort empid (year): egen avgemp`i'=mean(emp`i')
		gen empiv`i'=emp`i'-avgemp`i'
	}	
	ivregress 2sls ///
			`commonVar' ///
			(emp1 emp2 emp5 emp10 emp15 emp20 emp25 emp30 ///
			c.workexp##c.workexp = ///
			empiv1 empiv2 empiv5 empiv10 empiv15 empiv20 empiv25 empiv30 ///
			workexpiv workexpiv2) ///
			, vce(r)
	est sto isvempD
	drop if _est_isvempD==0
	drop *iv* avg*
	**** re-build iv
	do "$Code\ConstructIV.do"
	foreach i of local tendm {
		bysort empid (year): egen avgemp`i'=mean(emp`i')
		gen empiv`i'=emp`i'-avgemp`i'
	}
}
dis " /* AS's IV dummy */ "
ivregress 2sls ///
		`commonVar' ///
		(emp1 emp2 emp5 emp10 emp15 emp20 emp25 emp30 ///
		c.workexp##c.workexp = ///
		empiv1 empiv2 empiv5 empiv10 empiv15 empiv20 empiv25 empiv30 ///
		workexpiv workexpiv2) ///
		, vce(r)
est sto isvempD
 
*** output tex all results
qui{
local keepVar emp1 emp2 emp5 emp10 emp15 emp20 emp25 emp30 ///
						workexp c.workexp#c.workexp
*** coefficients
esttab olsempD isvempD ///
using "$Output\as_emp_dm.tex", ///
keep(`keepVar') ///
order(`keepVar') ///
coeflabel(emp1 "$ T_{ij}\geq1$" emp2 "$ T_{ij}\geq2$" ///
emp5 "$ T_{ij}\geq5$" emp10 "$ T_{ij}\geq10$" ///
emp15 "$ T_{ij}\geq15$" emp20 "$ T_{ij}\geq20$" ///
emp25 "$ T_{ij}\geq25$" emp30 "$ T_{ij}\geq30$" ///
workexp "Total experience" c.workexp#c.workexp "Experience$^{2}$") ///
title(Estimated Returns to Employer Tenure, Employer Tenure is Treated as Dummy Variables) ///
mgroups("OLS" "IV" ///
pattern(1 1) ///
`comSetTex'

*** simple dummy
est res Dm
qui coefplot, vertical yline(0) nolabel keep(*.emptenure) ///
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
graph export "$Output\plot_as_dm.pdf", replace
}
}


* 4. Topel / 1-4 dimenational polynomial
{
qui{
	global DmYear +y2005*_b[2005b.year]+y2006*_b[2006.year]+y2007*_b[2007.year] ///
							+y2008*_b[2008.year]+y2009*_b[2009.year]+y2010*_b[2010.year] ///
							+y2011*_b[2011.year]+y2012*_b[2012.year]+y2013*_b[2013.year] ///
							+y2014*_b[2014.year]
	global FstReg reg empwagedif i.year
	global SndReg i.dmarital i.schooling ///
								i.dregular i.dunion ///
								i.occ i.ind i.dsize ///
								initialemp, nocons
}

do "$Code\ReadData.do"
do "$Code\EstTopel.do"

*** output tex all results
quietly {
**** coefficients 
esttab fst1 fst2 fst3 fst4 ///
using "$Output\topel_emp.tex", ///
se star(* 0.1 ** 0.05 *** 0.01) b(4) ///
keep( ///
		_cons emptendif2 emptendif3 emptendif4 ///
		empexpdif2 empexpdif3 empexpdif4 ///
) ///
order( ///
		_cons emptendif2 emptendif3 emptendif4 ///
		empexpdif2 empexpdif3 empexpdif4 ///
) ///
coeflabel( ///
		_cons "Constant" ///
		emptendif2 "Emp.ten.$^{2}\times 100$" ///
		emptendif3 "Emp.ten.$^{3}\times 1000$" ///
		emptendif4 "Emp.ten.$^{4}\times 10000$" ///
		empexpdif2 "Experience$^{2}\times 100$" ///
		empexpdif3 "Experience$^{3}\times 1000$" ///
		empexpdif4 "Experience$^{4}\times 10000$" ///
		) ///
transform( ///
		emptendif2 100*@ 100 ///
		emptendif3 1000*@ 1000 ///
		emptendif4 10000*@ 10000 ///
		empexpdif2 100*@ 100 ///
		empexpdif3 1000*@ 1000 ///
		empexpdif4 10000*@ 10000 ///
		) ///
nodep nonote nomtitles ///
title("Estimation Results, using the Method of 2SFD Estimation.") ///
replace
}
}
 
* 5. Compare with Toda(2009)
{
** make the same sample as Toda
qui {
	use "$Inputfd\jhps_hc_allsample.dta", clear
	destring, replace
	tsset id year
}
*** construct employer tenure
forvalues X = 2005/2014{ 
	*** working more than 800h & not switched->+1
	/// If the sample dropped on the way was resurrected, 
	/// it is assumed that he kept being employed for the period
	/// in which it was dropped.
	dis "current year is `X' "
	bysort id (year): replace emptenure=emptenure[_n-1]+(year-year[_n-1]) ///
		if dswitch==0 & year==`X' & _n>1
	*** switched->0
	bysort id (year): replace emptenure=0.5 ///
		if dswitch==1 & year==`X'
}
do "$Code\SampleSelection.do"
*** replace workexp
replace workexp=age-schooling-6
*** sample selection: male, employed, 2004--2007, 20--60, regular
keep if year<=2007
tab year
keep if age>=20 & age<=60
sum age
keep if dregular==1
tab dregular
save "$Inputfd\jhps_hc_toda.dta", replace

** AS
qui {
	local commonVar realwage i.occ i.ind i.dunion schooling i.dsize
	local toda1 c.emptenure c.workexp
	local toda2 c.emptenure##c.emptenure c.workexp##c.workexp
	local toda3 c.emptenure##c.emptenure##c.emptenure ///
						c.workexp##c.workexp##c.workexp
	local toda4 c.emptenure##c.emptenure##c.emptenure##c.emptenure ///
						c.workexp##c.workexp##c.workexp##c.workexp
	local todaiv1 emptenureiv workexpiv
	local todaiv2 emptenureiv emptenureiv2 ///
						workexpiv workexpiv2
	local todaiv3 emptenureiv emptenureiv2 emptenureiv3 ///
						workexpiv workexpiv2 workexpiv3
	local todaiv4 emptenureiv emptenureiv2 emptenureiv3 emptenureiv4 ///
						workexpiv workexpiv2 workexpiv3 workexpiv4
}

qui {
	use "$Inputfd\jhps_hc_toda.dta", clear
	destring, replace
	tsset id year
}
sum realwage schooling dsize emptenure workexp, de


*** OLS
forvalues poly_x=1/4{
	dis "/* OLS  `poly_x'th order */"
	reg ///
			`commonVar' ///
			`toda`poly_x'' ///
			, vce(r)
	est sto olstoda`poly_x'
}


*** AS
forvalues poly_x=1/4{
	qui {
		use "$Inputfd\jhps_hc_toda.dta", clear
		destring, replace
		tsset id year
		do "$Code\ConstructIV.do"
		ivregress 2sls ///
					`commonVar' ///
					(`toda`poly_x'' = `todaiv`poly_x'') ///
					, vce(r)
		est sto isvtoda`poly_x'
		drop if _est_isvtoda`poly_x'==0
		drop *iv *iv? avg*
		do "$Code\ConstructIV.do"
	}
	dis "/* AS'sIV  `poly_x'th order */"
	ivregress 2sls ///
				`commonVar' ///
				(`toda`poly_x'' = `todaiv`poly_x'') ///
				, vce(r)
	est sto isvtoda`poly_x'
}

** culc. return
qui{
	local culcemp1 emptenure*_b[emptenure]
	local culcemp2 emptenure*_b[emptenure] ///
							+(emptenure^2)*_b[c.emptenure#c.emptenure]
	local culcemp3 emptenure*_b[emptenure] ///
							+(emptenure^2)*_b[c.emptenure#c.emptenure] ///
							+(emptenure^3)*_b[c.emptenure#c.emptenure#c.emptenure]
	local culcemp4 emptenure*_b[emptenure] ///
							+(emptenure^2)*_b[c.emptenure#c.emptenure] ///
							+(emptenure^3)*_b[c.emptenure#c.emptenure#c.emptenure] ///
							+(emptenure^4)*_b[c.emptenure#c.emptenure#c.emptenure#c.emptenure]
}

forvalues poly_x=1/4{ /* loop within ten_inomial */
		*** culculation
		est res olstoda`poly_x'
		margins, exp(`culcemp`poly_x'') ///
		at(emptenure=(0(1)25)) noe post
		est sto olstodar`poly_x'
		est res isvtoda`poly_x'
		margins, exp(`culcemp`poly_x'') ///
		at(emptenure=(0(1)25)) noe post
		est sto isvtodar`poly_x'
		
		*** plot
		qui coefplot (olstodar`poly_x', label(OLS)) (isvtodar`poly_x', label(IV)), ///
		`comSetPlot'
		graph export "$Output\plot_as_toda_`poly_x'.pdf", replace
}


** output tex file
*** coefficient
local keepVar emptenure c.emptenure#c.emptenure ///
						c.emptenure#c.emptenure#c.emptenure ///
						c.emptenure#c.emptenure#c.emptenure#c.emptenure ///
						oj workexp c.workexp#c.workexp ///
						c.workexp#c.workexp#c.workexp ///
						c.workexp#c.workexp#c.workexp#c.workexp

esttab olstoda1 olstoda2 olstoda3 olstoda4 ///
			isvtoda1 isvtoda2 isvtoda3 isvtoda4 ///
using "$Output\as_toda.tex", ///
keep(`keepVar') ///
order(`keepVar') ///
coeflabel(`labelVar') ///
transform(`transVar') ///
title("Replication of Toda (2007), using the AS's IV method.") ///
mgroups("OLS" "IV" ///
pattern(1 0 0 1 0 0) ///
`comSetTex'

**** return
esttab olstodar1 olstodar2 olstodar3 olstodar4 ///
			isvtodar1 isvtodar2 isvtodar3 isvtodar4 ///
using "$Output\as_return_toda.tex", ///
keep(3._at 6._at 11._at 16._at 21._at 26._at) ///
coeflabel(3._at "2 Years" ///
6._at "5 Years" 11._at "10 Years" ///
16._at "15 Years" ///
21._at "20 Years" 26._at "25 Years") ///
title("Estimated Returns to Employer Tenure, based on replication of Toda (2007).") ///
mgroups("OLS" "IV" ///
pattern(1 0 0 0 1 0 0 0) ///
`comSetTex'
}


*** Topel
qui {
	global DmYear
	global FstReg reg empwagedif
	global SndReg i.dunion ///
							i.occ i.ind i.dsize ///
							initialemp, nocons
}

qui {
	use "$Inputfd\jhps_hc_toda.dta", clear
	destring, replace
	tsset id year
}
do "$Code\EstTopel.do"

**** output tex all results
quietly {
***** coefficients 
esttab fst1 fst2 fst3 fst4 ///
using "$Output\topel_emp.tex", ///
se star(* 0.1 ** 0.05 *** 0.01) b(4) ///
keep( ///
		_cons emptendif2 emptendif3 emptendif4 ///
		empexpdif2 empexpdif3 empexpdif4 ///
) ///
order( ///
		_cons emptendif2 emptendif3 emptendif4 ///
		empexpdif2 empexpdif3 empexpdif4 ///
) ///
coeflabel( ///
		_cons "Constant" ///
		emptendif2 "Emp.ten.$^{2}\times 100$" ///
		emptendif3 "Emp.ten.$^{3}\times 1000$" ///
		emptendif4 "Emp.ten.$^{4}\times 10000$" ///
		empexpdif2 "Experience$^{2}\times 100$" ///
		empexpdif3 "Experience$^{3}\times 1000$" ///
		empexpdif4 "Experience$^{4}\times 10000$" ///
		) ///
transform( ///
		emptendif2 100*@ 100 ///
		emptendif3 1000*@ 1000 ///
		emptendif4 10000*@ 10000 ///
		empexpdif2 100*@ 100 ///
		empexpdif3 1000*@ 1000 ///
		empexpdif4 10000*@ 10000 ///
		) ///
nodep nonote nomtitles ///
title(Replication of Toda (2007), using the method of 2SFD.) ///
replace
}


log close


** predict muhat -> calculate bias in Topel and AS
*** see auxionaly estimation in AW, 2005
use "$Inputfd\jhps_hc.dta", clear
set mat 10000
gen intexp=workexp-emptenure
*** obtain gammaW0T
reg emptenure intexp
*** obtain cov(W0,T)
corr intexp emptenure, cov
*** obtain zeta
reg emptenure workexp
predict zeta, re
*** obtain V(T), V(W), V(zeta)
sum zeta workexp emptenure, de
*** obtain v(zeta)/bOLS=V(zeta)/[V(T)-2Cov(W,T)+V(W)])/(Cov(w,T)/V(T))
reg realwage emptenure
