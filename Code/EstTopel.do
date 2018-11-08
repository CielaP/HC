qui{
local code $Code
do "`code'\ConstructDif.do"

* list of control variable
local contrl1
local contrl2 emptendif2 empexpdif2
local contrl3 emptendif2 empexpdif2 ///
					emptendif3 empexpdif3
local contrl4 emptendif2 empexpdif2 ///
					emptendif3 empexpdif3 ///
					emptendif4 empexpdif4 ///

* list of terms subtracted from the LHS
local LHSterm1 emptenure*_b[_cons]
local LHSterm2 emptenure*_b[_cons] ///
						+_b[emptendif2]*emptenure^2+_b[empexpdif2]*workexp^2
local LHSterm3 emptenure*_b[_cons] ///
						+_b[emptendif2]*emptenure^2+_b[empexpdif2]*workexp^2 ///
						+_b[emptendif3]*emptenure^3+_b[empexpdif3]*workexp^3
local LHSterm4 emptenure*_b[_cons] ///
						+_b[emptendif2]*emptenure^2+_b[empexpdif2]*workexp^2 ///
						+_b[emptendif3]*emptenure^3+_b[empexpdif3]*workexp^3 ///
						+_b[emptendif4]*emptenure^4+_b[empexpdif4]*workexp^4
}


* estimation
forvalues i=1/4 {
	**** 1st step
	qui $FstReg ///
				`contrl`i'' ///
				if fst==1
	est sto fst`i'
	gen emptenB`i'=`LHSterm`i'' ///
								$DmYear
	gen intwemp`i'=realwage-emptenB`i'
	
	**** 2nd step
	qui $SndReg
	est sto snd`i'
}

* calc. return
** linear
capture program drop coef
program coef, rclass
	suest fst1 snd1
	lincom [fst1_mean]_b[_cons]-[snd1_mean]_b[initialemp]
	return scalar diffse =r(se)
end
coef
capture program drop emprtn
program emprtn, rclass
	qui suest fst1 snd1
	foreach X of numlist 2 5 10 15 20 25 {
	lincom ([fst1_mean]_b[_cons]-[snd1_mean]_b[initialemp])*`X'
	return scalar rtn`X' =r(se)
	}
end
emprtn

** qadratic
capture program drop coef
program coef, rclass
	suest fst2 snd2
	lincom [fst2_mean]_b[_cons]-[snd2_mean]_b[initialemp]
	return scalar diffse =r(se)
end
coef
capture program drop emprtn
program emprtn, rclass
	qui suest fst2 snd2
	foreach X of numlist 2 5 10 15 20 25 {
	lincom ([fst2_mean]_b[_cons]-[snd2_mean]_b[initialemp])*`X' ///
				+[fst2_mean]_b[emptendif2]*`X'*`X'
	return scalar rtn`X' =r(se)
	}
end
emprtn

** cubic
capture program drop coef
program coef, rclass
	suest fst3 snd3
	lincom [fst3_mean]_b[_cons]-[snd3_mean]_b[initialemp]
	return scalar diffse =r(se)
end
coef
capture program drop emprtn
program emprtn, rclass
	qui suest fst3 snd3
	foreach X of numlist 2 5 10 15 20 25 {
	lincom ([fst3_mean]_b[_cons]-[snd3_mean]_b[initialemp])*`X' ///
				+[fst3_mean]_b[emptendif2]*`X'*`X' ///
				+[fst3_mean]_b[emptendif3]*`X'*`X'*`X'
	return scalar rtn`X' =r(se)
	}
end
emprtn

** quartic
capture program drop coef
program coef, rclass
	suest fst4 snd4
	lincom [fst4_mean]_b[_cons]-[snd4_mean]_b[initialemp]
	return scalar diffse =r(se)
end
coef
capture program drop emprtn
program emprtn, rclass
	qui suest fst4 snd4
	foreach X of numlist 2 5 10 15 20 25 {
	lincom ([fst4_mean]_b[_cons]-[snd4_mean]_b[initialemp])*`X' ///
				+[fst4_mean]_b[emptendif2]*`X'*`X' ///
				+[fst4_mean]_b[emptendif3]*`X'*`X'*`X' ///
				+[fst4_mean]_b[emptendif4]*`X'*`X'*`X'*`X'
	return scalar rtn`X' =r(se)
	}
end
emprtn
