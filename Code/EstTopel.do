local code "C:\Users\AyakaNakamura\Dropbox\materials\Works\Master\program\Submittion\Code"

local dmYear +y2005*_b[2005b.year]+y2006*_b[2006.year]+y2007*_b[2007.year] ///
						+y2008*_b[2008.year]+y2009*_b[2009.year]+y2010*_b[2010.year] ///
						+y2011*_b[2011.year]+y2012*_b[2012.year]+y2013*_b[2013.year] ///
						+y2014*_b[2014.year]
local fstReg reg empwagedif i.year
local sndReg reg intwemp1 i.union i.marital i.schooling i.regular ///
							i.occ i.ind i.size ///
							initialemp, nocons

*** linear
do "`code'\ConstructDif.do"
**** 1st step
`fstReg' ///
			if fst==1
est sto fst1
gen coefsum1=_b[_cons]
gen emptenB1=emptenure*_b[_cons] ///
							`dmYear'
gen intwemp1=realwage-emptenB

**** 2nd step
`sndReg'
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
`fstReg' ///
			emptendif2 empexpdif2 ///
			if fst==1
est sto fst2
gen emptenB2=emptenure*_b[_cons] ///
						+_b[emptendif2]*emptenure^2+_b[empexpdif2]*workexp^2 ///
						`dmYear'
gen intwemp2=realwage-emptenB2

**** 2nd step
`sndReg'
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
`fstReg' ///
			emptendif2 empexpdif2 emptendif3 empexpdif3 ///
			if fst==1
est sto fst3
gen emptenB3=emptenure*_b[_cons] ///
						+_b[emptendif2]*emptenure^2+_b[empexpdif2]*workexp^2 ///
						+_b[emptendif3]*emptenure^3+_b[empexpdif3]*workexp^3 ///
						`dmYear'
gen intwemp3=realwage-emptenB3

**** 2nd step
`sndReg'
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
`fstReg' ///
			emptendif2 empexpdif2 ///
			emptendif3 empexpdif3 ///
			emptendif4 empexpdif4 ///
			if fst==1
est sto fst4
gen emptenB4=emptenure*_b[_cons] ///
						+_b[emptendif2]*emptenure^2+_b[empexpdif2]*workexp^2 ///
						+_b[emptendif3]*emptenure^3+_b[empexpdif3]*workexp^3 ///
						+_b[emptendif4]*emptenure^4+_b[empexpdif4]*workexp^4 ///
						`dmYear'
gen intwemp4=realwage-emptenB4

**** 2nd step
`sndReg'
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
