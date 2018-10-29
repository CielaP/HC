/* Title: ConstructTen */
/// Date: Oct 25th, 2018
/// Written by Ayaka Nakamura
/// 
/// This file construct workexp and emptenure for each year
/// 
/// 1. 
/// 2. 

** make data into panel
*use "$Inter\JHPSKHPS_2004_2014.dta", clear
sort id year
tsset id year


* 1. construct emptenure
** recode employer month to emlpoyer year
replace emptenure=round(emptenure/12)
replace emptenure=. if emptenure<0

forvalues X = 2005/2014{ 
	*** working more than 800h & not switched->+1
	/// If the sample dropped on the way was resurrected, 
	/// it is assumed that he kept being employed for the period
	/// in which it was dropped.
	dis "current year is `X' "
	bysort id (year): replace emptenure=emptenure[_n-1]+(year-year[_n-1]) ///
		if morethan800==1 & dswitch==0 & year==`X' & _n>1
	*** working less than 800h & not switched->+-0
	bysort id (year): replace emptenure=emptenure[_n-1] ///
		if morethan800==0 & dswitch==0 & year==`X' & _n>1
	*** switched->0
	bysort id (year): replace emptenure=0 ///
		if dswitch==1 & year==`X'
}
gen lemp=l.emptenure
tab emptenure lemp if emptenure<10&lemp<10


* 2. construct workexp
** replace workexp of JHPS in 2009 based on workexp in 2010
local isJHPS id<20000
*local isKHPS id>=20000
bysort id (year): replace workexp=workexp[_n+1]-1 ///
	if morethan800==1 & year==2009 & `isJHPS'
bysort id (year): replace workexp=workexp[_n+1] ///
	if morethan800==0 & year==2009 & `isJHPS'

** workexp
forvalues X = 2005/2014{ 
	dis "current year is `X' "
	*** working more than 800h->+1
	bysort id (year): replace workexp=workexp[_n-1]+(year-year[_n-1]) ///
		if morethan800==1 & year==`X' & _n>1
	*** working less than 800h->+-0
	bysort id (year): replace workexp=workexp[_n-1] ///
		if morethan800==0 & year==`X' & _n>1
}


* 3. construct occtenure
/// missing occupation is assumed to be the same as the last year
bysort id (year): replace occ=occ[_n-1] if occ==.
** set occtenure to be equal to emptenure
bysort id (year): gen occtenure=emptenure if _n==1
** define occupation switch
bysort id (year): gen occswitch=0 ///
	if occ==occ[_n-1] | occ==. | occ[_n-1]==. | _n==1
replace occswitch=1 if occswitch==.
gen locc=l.occ
tab occ locc, sum(occswitch) mean

forvalues X = 2005/2014{ 
	*** working more than 800h & not switched->+1
	dis "current year is `X' "
	bysort id (year): replace occtenure=occtenure[_n-1]+(year-year[_n-1]) ///
		if morethan800==1 & occswitch==0 & year==`X' & _n>1
	*** working less than 800h & not switched->+-0
	bysort id (year): replace occtenure=occtenure[_n-1] ///
		if morethan800==0 & occswitch==0 & year==`X' & _n>1
	*** switched->0
	bysort id (year): replace occtenure=0 ///
		if occswitch==1 & year==`X'
}


* 4. define old job dummy and empid
** old job dummy
*gen oj=1 if emptenure>0
*gen oj=1 if switch==0&emptenure>0
gen oj=1 if dswitch==0
replace oj=0 if oj==.
tab oj dswitch

** empid
sort id year
by id: gen empid = 1 if _n==1|dswitch==1|emptenure<emptenure[_n-1]
replace empid=sum(empid)


* 5. make missing value
** negative tenure to missing value
replace emptenure=. if emptenure<0| emptenure>workexp
replace workexp=. if workexp<0
replace occtenure=. if occtenure<0
** relawage of working less than 500 to missing value
replace realwage=. if workinghour<500
