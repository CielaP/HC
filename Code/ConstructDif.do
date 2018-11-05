/* Title: ConstructDif */
/// Date: Nov 5th, 2018
/// Written by Ayaka Nakamura
/// 
/// This file construct wage and tenure difference for Topel

quietly {
* calculate initial working experience
sort empid year
gen initialemp=workexp-emptenure
* making flag of sample used for first stage
bysort empid (year): gen fst=1 ///
if _n!=1&emptenure>=1
replace fst=0 if fst==.
* generate difference of tenure for the flagged sample
gen emptendif2=2*emptenure-1 if fst==1
gen emptendif3=3*(emptenure^2)-3*emptenure+1 if fst==1
gen emptendif4=4*(emptenure^3)-6*(emptenure^2)+4*emptenure-1 if fst==1
gen empexpdif2=2*workexp-1 if fst==1
gen empexpdif3=3*(workexp^2)-3*workexp+1 if fst==1
gen empexpdif4=4*(workexp^3)-6*(workexp^2)+4*workexp-1 if fst==1
* generate variable of wage difference for the flagged sample
bysort empid (year): gen empwagedif=realwage-realwage[_n-1] if fst==1
drop if initialemp<0
tabulate year, generate(y)
* generate year dummies
for X in num 1/11 \ Y in num 2004/2014 : rename yX yY
drop if occ==1
replace fst=0 if fst==.|emptendif2==.
}
