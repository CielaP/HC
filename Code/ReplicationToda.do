/* Title: ReplicationToda */
/// Date: Dec 14th, 2018
/// Written by Ayaka Nakamura
/// 
/// Comparing the coefficients with Toda (2007).

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

	* Setting for plot
	local comSetPlot at ciopts(recast(rline) lpattern(dash)) recast(connected) ///
								xtitle("Employer Tenure") ytitle("Returns to Tenure on Earnings (%)") ///
								yline(0) rescale(100)
	
	* Variable lists used for estimation
	local commonVar realwage i.occ i.ind i.dunion schooling i.dsize
	local todaemp1 c.emptenure
	local todaexp2 c.workexp
	local todaemp2 c.emptenure##c.emptenure
	local todaexp2 c.workexp##c.workexp
	local todaemp3 c.emptenure##c.emptenure##c.emptenure
	local todaexp3 c.workexp##c.workexp##c.workexp
	local todaemp4 c.emptenure##c.emptenure##c.emptenure##c.emptenure
	local todaexp4 c.workexp##c.workexp##c.workexp##c.workexp
	local todaiv1 emptenureiv
	local todaiv2 emptenureiv emptenureiv2
	local todaiv3 emptenureiv emptenureiv2 emptenureiv3
	local todaiv4 emptenureiv emptenureiv2 emptenureiv3 emptenureiv4
	
	* Equations used for calculation of returns
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

* Open Log file
cap log close /* close any log files that accidentally have been left open. */
log using "$Path\Log\ReplicationToda.log", replace

/*
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
*/

** Summary statistics
qui {
	use "$Inputfd\jhps_hc_toda.dta", clear
	destring, replace
	tsset id year
}
sum realwage schooling dsize emptenure workexp, de

** AS
*** OLS
forvalues poly_x=1/4{
	dis "/* OLS  `poly_x'th order */"
	reg ///
			`commonVar' ///
			`todaemp`poly_x'' ///
			`todaexp`poly_x'' ///
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
					`todaexp`poly_x'' ///
					(`todaemp`poly_x'' = `todaiv`poly_x'') ///
					, vce(r)
		est sto isvtoda`poly_x'
		drop if _est_isvtoda`poly_x'==0
		drop *iv *iv? avg*
		do "$Code\ConstructIV.do"
	}
	dis "/* AS'sIV  `poly_x'th order */"
	ivregress 2sls ///
				`commonVar' ///
					`todaexp`poly_x'' ///
					(`todaemp`poly_x'' = `todaiv`poly_x'') ///
				, vce(r)
	est sto isvtoda`poly_x'
}

** culc. return
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
global EstList ///
		olstoda1 olstoda2 olstoda3 olstoda4 ///
		isvtoda1 isvtoda2 isvtoda3 isvtoda4
global FileTex ///
		as_toda
global KeepVar ///
		emptenure c.emptenure#c.emptenure ///
		c.emptenure#c.emptenure#c.emptenure ///
		c.emptenure#c.emptenure#c.emptenure#c.emptenure ///
		workexp c.workexp#c.workexp ///
		c.workexp#c.workexp#c.workexp ///
		c.workexp#c.workexp#c.workexp#c.workexp
global LabelVar ///
		emptenure "Employer tenure" ///
		c.emptenure#c.emptenure "Emp.ten.$^{2}\times 100$" ///
		c.emptenure#c.emptenure#c.emptenure "Emp.ten.$^{3}\times 100$" ///
		c.emptenure#c.emptenure#c.emptenure#c.emptenure "Emp.ten.$^{4}\times 1000$" ///
		workexp "Total experience" c.workexp#c.workexp "Experience$^{2}$" ///
		c.workexp#c.workexp#c.workexp "Exp.$^{3}\times 100$" ///
		c.workexp#c.workexp#c.workexp#c.workexp "Exp.$^{4}\times 10000$"
global TransVar ///
		c.emptenure#c.emptenure 100*@ 100 ///
		c.emptenure#c.emptenure#c.emptenure 100*@ 100 ///
		c.emptenure#c.emptenurec.emptenure#c.emptenure 10000*@ 10000 ///
		c.workexp#c.workexp#c.workexp 100*@ 100 ///
		c.workexp#c.workexp#c.workexp 10000*@ 10000
global TitleTab ///
		"Replication of Toda (2007), using the AS's IV method."
global LabelTab
global Group ///
		"OLS" "IV"
global GroupPattern ///
		1 0 0 0 1 0 0 0

do "$Code\TexTab_est.do"

**** return
global EstList olstodar1 olstodar2 olstodar3 olstodar4 ///
						isvtodar1 isvtodar2 isvtodar3 isvtodar4
global FileTex as_return_toda
global KeepVar 3._at 6._at 11._at 16._at 21._at 26._at
global LabelVar 3._at "2 Years" ///
							6._at "5 Years" 11._at "10 Years" ///
							16._at "15 Years" ///
							21._at "20 Years" 26._at "25 Years"
global TransVar 
global TitleTab "Estimated Returns to Employer Tenure, based on replication of Toda (2007)."

do "$Code\TexTab_est.do"

** Topel
qui {
	global DmYear
	global FstReg reg empwagedif
	global SndReg i.dunion ///
							i.occ i.ind i.dsize ///
							initialemp
}

qui {
	use "$Inputfd\jhps_hc_toda.dta", clear
	destring, replace
	tsset id year
}
do "$Code\EstTopel.do"

**** output tex all results
qui {
global EstList fst1 fst2 fst3 fst4
global FileTex topel_toda
global KeepVar ///
		_cons emptendif2 emptendif3 emptendif4 ///
		empexpdif2 empexpdif3 empexpdif4
global LabelVar ///
		_cons "Constant" ///
		emptendif2 "Emp.ten.$^{2}\times 100$" ///
		emptendif3 "Emp.ten.$^{3}\times 1000$" ///
		emptendif4 "Emp.ten.$^{4}\times 10000$" ///
		empexpdif2 "Experience$^{2}\times 100$" ///
		empexpdif3 "Experience$^{3}\times 1000$" ///
		empexpdif4 "Experience$^{4}\times 10000$"
global TransVar ///
		emptendif2 100*@ 100 ///
		emptendif3 1000*@ 1000 ///
		emptendif4 10000*@ 10000 ///
		empexpdif2 100*@ 100 ///
		empexpdif3 1000*@ 1000 ///
		empexpdif4 10000*@ 10000
global TitleTab "Replication of Toda (2007), using the method of 2SFD."
global LabelTab
global Group 
global GroupPattern 

do "$Code\TexTab_est.do"
}

log close
