/* Title: ReplicationOLS */
/// Date: Dec 13th, 2018
/// Written by Ayaka Nakamura
/// 
/// Comparing the coefficients with previous literatures.

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
}

do "$Code\ReadData.do"

* Mincer and Higuchi (1988)
local regVar realwage ///
					i.schooling i.dmarital i.year ///
					c.workexp##c.workexp ///
					c.emptenure##c.emptenure oj
local culcemp _b[oj]+emptenure*_b[emptenure] ///
							+(emptenure^2)*_b[c.emptenure#c.emptenure]

qui	reg `regVar' ///
				, vce(r)
		est sto minAll

margins, exp(`culcemp') ///
		at(emptenure=(0(1)25)) noe post
		est sto minAllr

qui	reg `regVar' ///
				if age<=30 ///
				, vce(r)
		est sto minYng

qui	reg `regVar' ///
				if age>30 ///
				, vce(r)
		est sto minOld

* Hashimoto and Raisan (1985)
local regVar realwage ///
					i.schooling i.dunion ///
					c.workexp##c.workexp ///
					c.emptenure##c.emptenure ///
					c.workexp#c.emptenure
local culcemp emptenure*_b[emptenure] ///
							+(emptenure^2)*_b[c.emptenure#c.emptenure] ///
							+emptenure*_b[c.workexp#c.emptenure]

qui	reg `regVar' ///
				, vce(r)
		est sto hasAll

qui	reg `regVar' ///
				i.year ///
				, vce(r)
		est sto hasYd

margins, exp(`culcemp') ///
		at(emptenure=(0(1)25)) noe post
		est sto hasYdr

qui	reg `regVar' ///
				if dsize==0 ///
				, vce(r)
		est sto hasSm

qui	reg `regVar' ///
				i.year ///
				if dsize==0 ///
				, vce(r)
		est sto hasSmYd

qui	reg `regVar' ///
				if dsize>0 ///
				, vce(r)
		est sto hasLa

qui	reg `regVar' ///
				i.year ///
				if dsize>0 ///
				, vce(r)
		est sto hasLaYd

* Ohkusa and Ohta
local regVar realwage ///
					i.schooling i.year ///
					c.workexp##c.workexp ///
					c.emptenure##c.emptenure ///
					c.workexp#c.emptenure
local culcemp emptenure*_b[emptenure] ///
							+(emptenure^2)*_b[c.emptenure#c.emptenure] ///
							+emptenure*_b[c.workexp#c.emptenure]

qui	reg `regVar' ///
				, vce(r)
		est sto ohta

margins, exp(`culcemp') ///
		at(emptenure=(0(1)25)) noe post
		est sto ohtar

* plot
qui coefplot (minAllr, label(Mincer and Higuchi)) ///
					(hasYdr, label(Hashimoto and Raisan)) ///
					(ohtar, label(Ohkusa and Ohta)) ///
					,at ciopts(recast(rline) lpattern(dash)) recast(connected) ///
					xtitle("Employer Tenure") ytitle("Returns to Tenure on Earnings (%)") ///
					yline(0) rescale(100)
graph export "$Output\plot_olsCheck.pdf", replace

* output tex
qui{
esttab minAll minYng minOld ///
			hasAll hasYd hasSm hasSmYd hasLa hasLaYd ///
			hasLaYd ///
using "$Output\olsCheck.tex", ///
se star(* 0.1 ** 0.05 *** 0.01) b(4) ///
keep( ///
			_cons workexp c.workexp#c.workexp ///
			emptenure c.emptenure#c.emptenure ///
			c.workexp#c.emptenure oj ///
			12.schooling 14.schooling 16.schooling ///
			1.dmarital 1.dunion ///
			) ///
order( ///
			_cons workexp c.workexp#c.workexp ///
			emptenure c.emptenure#c.emptenure ///
			c.workexp#c.emptenure oj ///
			12.schooling 14.schooling 16.schooling ///
			1.dmarital 1.dunion ///
			) ///
coeflabel( ///
			_cons "Constant" ///
			workexp "Total Experience" ///
			c.workexp#c.workexp "Experience $^{2}$" ///
			emptenure "Employer Tenure" ///
			c.emptenure#c.emptenure "Emp.ten. $^{2}$" ///
			c.workexp#c.emptenure "Exp. $\times$ Emp.ten." ///
			oj "Old Job" ///
			12.schooling "High School" ///
			14.schooling "Some College" ///
			16.schooling "College" ///
			1.dmarital "Married" ///
			1.dunion "Union Member" ///
			) ///
title(Earnings Function Estimates.) ///
nodep nonote ///
replace
}





