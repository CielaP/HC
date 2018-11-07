/* Title: ConstructIV */
/// Date: Oct 29th, 2018
/// Written by Ayaka Nakamura
/// 
/// This file construct instrumental variable
do "$Code\ReadData.do"

sort empid year
* iv of emptenure
bysort empid (year): egen avgemptenure=mean(emptenure)
bysort empid (year): egen avgemptenure2=mean(emptenure^2)
bysort empid (year): egen avgemptenure3=mean(emptenure^3)
bysort empid (year): egen avgemptenure4=mean(emptenure^4)
gen emptenureiv=emptenure-avgemptenure
gen emptenureiv2=emptenure^2-avgemptenure2
gen emptenureiv3=emptenure^3-avgemptenure3
gen emptenureiv4=emptenure^4-avgemptenure4

sort id year
* iv of workexp
bysort id (year): egen avgworkexp=mean(workexp)
bysort id (year): egen avgworkexp2=mean(workexp^2)
bysort id (year): egen avgworkexp3=mean(workexp^3)
bysort id (year): egen avgworkexp4=mean(workexp^4)
gen workexpiv=workexp-avgworkexp
gen workexpiv2=workexp^2-avgworkexp2
gen workexpiv3=workexp^3-avgworkexp3
gen workexpiv4=workexp^4-avgworkexp4

* iv of occtenure
egen avgocctenure=mean(occtenure), by(id occ)
egen avgocctenure2=mean(occtenure^2), by(id occ)
egen avgocctenure3=mean(occtenure^3), by(id occ)
egen avgocctenure4=mean(occtenure^4), by(id occ)
gen occtenureiv=occtenure-avgocctenure
gen occtenureiv2=occtenure^2-avgocctenure2
gen occtenureiv3=occtenure^3-avgocctenure3
gen occtenureiv4=occtenure^4-avgocctenure4

* iv of oj dummy
bysort empid (year): egen avgoj=mean(oj)
gen ojiv=oj-avgoj

* iv of year dummy
tabulate year, generate(y)
rename ( y# ) ( y# ), addnum(2004)
su year, meanonly
local ymax=r(max)
local ymin=r(min)
forvalues X = `ymin'/`ymax'{
	bysort id (year): egen avgy`X'=mean(y`X')
	gen yiv`X'=y`X'-avgy`X'
}
 