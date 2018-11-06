local code "C:\Users\AyakaNakamura\Dropbox\materials\Works\Master\program\Submittion\Code"

*** linear
do "`code'\ConstructDif.do"
**** 1st step
$FstReg ///
			if fst==1
est sto fst1
gen emptenB1=emptenure*_b[_cons] ///
							$DmYear
gen intwemp1=realwage-emptenB

**** 2nd step
$SndReg
est sto snd1

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

*** qadratic
**** 1st step
$FstReg ///
			emptendif2 empexpdif2 ///
			if fst==1
est sto fst2
gen emptenB2=emptenure*_b[_cons] ///
						+_b[emptendif2]*emptenure^2+_b[empexpdif2]*workexp^2 ///
						$DmYear
gen intwemp2=realwage-emptenB2

**** 2nd step
$SndReg
est sto snd2

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
	lincom ([fst2_mean]_b[_cons]-[snd2_mean]_b[initialemp])*`X' ///
				+[fst2_mean]_b[emptendif2]*`X'*`X'
	return scalar rtn`X' =r(se)
	}
end
emprtn
}

*** cubic
**** 1st step
$FstReg ///
			emptendif2 empexpdif2 emptendif3 empexpdif3 ///
			if fst==1
est sto fst3
gen emptenB3=emptenure*_b[_cons] ///
						+_b[emptendif2]*emptenure^2+_b[empexpdif2]*workexp^2 ///
						+_b[emptendif3]*emptenure^3+_b[empexpdif3]*workexp^3 ///
						$DmYear
gen intwemp3=realwage-emptenB3

**** 2nd step
$SndReg
est sto snd3

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
	lincom ([fst3_mean]_b[_cons]-[snd3_mean]_b[initialemp])*`X' ///
				+[fst3_mean]_b[emptendif2]*`X'*`X' ///
				+[fst3_mean]_b[emptendif3]*`X'*`X'*`X'
	return scalar rtn`X' =r(se)
	}
end
emprtn
}

*** quartic
**** 1st step
$FstReg ///
			emptendif2 empexpdif2 ///
			emptendif3 empexpdif3 ///
			emptendif4 empexpdif4 ///
			if fst==1
est sto fst4
gen emptenB4=emptenure*_b[_cons] ///
						+_b[emptendif2]*emptenure^2+_b[empexpdif2]*workexp^2 ///
						+_b[emptendif3]*emptenure^3+_b[empexpdif3]*workexp^3 ///
						+_b[emptendif4]*emptenure^4+_b[empexpdif4]*workexp^4 ///
						$DmYear
gen intwemp4=realwage-emptenB4

**** 2nd step
$SndReg
est sto snd4

**** culc return
{
capture program drop coef
program coef, rclass
	suest fst4 snd4
	lincom [fst4_mean]_b[_cons]-[snd4_mean]_b[initialemp]
	return scalar diffse =r(se)
end
coef
capture program drop emprtn
program emprtn, rclass
suest fst4 snd4
	foreach X of numlist 2 5 10 15 20 25 {
	lincom ([fst4_mean]_b[_cons]-[snd4_mean]_b[initialemp])*`X' ///
				+[fst4_mean]_b[emptendif2]*`X'*`X' ///
				+[fst4_mean]_b[emptendif3]*`X'*`X'*`X' ///
				+[fst4_mean]_b[emptendif4]*`X'*`X'*`X'*`X'
	return scalar rtn`X' =r(se)
	}
end
emprtn
}
