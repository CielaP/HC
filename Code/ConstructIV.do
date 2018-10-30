/* Title: ConstructIV */
/// Date: Oct 29th, 2018
/// Written by Ayaka Nakamura
/// 
/// This file construct instrumental variable

sort empid year
* iv of emptenure
egen avgemptenure=mean(emptenure), by(empid)
egen avgemptenure2=mean(emptenure^2), by(empid)
egen avgemptenure3=mean(emptenure^3), by(empid)
egen avgemptenure4=mean(emptenure^4), by(empid)
gen emptenureiv=emptenure-avgemptenure
gen emptenureiv2=emptenure^2-avgemptenure2
gen emptenureiv3=emptenure^3-avgemptenure3
gen emptenureiv4=emptenure^4-avgemptenure4

* iv of workexp
egen avgworkexp=mean(workexp), by(id)
egen avgworkexp2=mean(workexp^2), by(id)
egen avgworkexp3=mean(workexp^3), by(id)
egen avgworkexp4=mean(workexp^4), by(id)
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
egen avgoj=mean(oj), by(empid)
gen ojiv=oj-avgoj
