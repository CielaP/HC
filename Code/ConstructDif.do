/* Title: ConstructDif */
/// Date: Nov 5th, 2018
/// Written by Ayaka Nakamura
/// 
/// This file construct wage and tenure difference for Topel

quietly {
* calculate initial working experience
sort empid year
gen initialemp=workexp-emptenure
replace initialemp=0 if initialemp<0

* making flag of sample used for first stage
bysort empid (year): gen fst=1 ///
		if _n!=1 & emptenure-emptenure[_n-1]==1
replace fst=0 if fst==.

* generate difference of tenure for the flagged sample
forvalues i=2/4 {
	bysort empid (year): gen emptendif`i'=(emptenure^`i')-emptenure[_n-1]^`i' ///
		if fst==1
	bysort id (year): gen empexpdif`i'=(workexp^`i')-workexp[_n-1]^`i' ///
		if fst==1
}

* generate variable of wage difference for the flagged sample
bysort empid (year): gen empwagedif=realwage-realwage[_n-1] ///
		if fst==1
sum empwagedif

/* * generate year dummies
tabulate year, generate(y)
rename ( y# ) ( y# ), addnum(2004)
*/
* sum form
su year, meanonly
local ymax=r(max)
local ymin=r(min)
forvalues t=`ymin'/`ymax'{
	gen y`t'=1 if year>=`t'
	replace y`t'=0 if y`t'==.
}
*drop if occ==1
}
