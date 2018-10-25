*******************************************************
*Title: MergeVar
*Date: Oct 25th, 2018
*Written by Ayaka Nakamura
* 
* This file construct workexp and emptenure for each year
* 
* 1. 
* 2. 
********************************************************

* Define folder location
local path $Path
local original $Original
local input $Input
local output $Output
local inter $Inter
disp "`path', `original', `input', `output', `inter' "

* Define indicator indicating which survey data
local isJHPS id<20000
local isOldKHPS id>=20000&id<40000
local isNewKHPS id>=40000


** make data into panel
sort id year
tsset id year



* 1. construct emptenure



* 2. construct workexp




*** JHPSは2010の労働経験年数をもとに2009の労働経験年数を作成
replace workexp=workexp2010-1 if morethan800==1&cohort==9&year==2009
replace workexp=workexp2010 if morethan800==0&cohort==9&year==2009


*** emptenure
forvalues X = 2005(1)2014{ 
	**** 労働時間800時間以上&転職してない->+1
	replace emptenure=emptenure[_n-1]+(year-year[_n-1]) ///
		if morethan800==1 & switch==0 & year==`X'
	**** 労働時間800時間未満&転職してない->+-0
	replace emptenure=emptenure[_n-1] ///
		if morethan800==0 & switch==0 & year==`X'
	**** 転職した->0
	replace emptenure=0 ///
		if switch==1 & year==`X'
	**** 最初のobservationは変更しない
	bysort id (year): replace emptenure=intten if _n==1
}
drop empten2* intten

*** workexp
forvalues X = 2005(1)2014{ 
	**** 労働時間800時間以上->+1
	bysort id (year): replace workexp=workexp[_n-1]+(year-year[_n-1]) ///
		if morethan800==1 & _n!=1 & year==`X'
	**** 労働時間800時間未満->+-0
	bysort id (year): replace workexp=workexp[_n-1] ///
		if morethan800==0 & _n!=1 & year==`X'
	**** 最初のobservationは変更しない
	bysort id (year): replace workexp=intexp if _n==1
}
drop workexp2* intexp

*** occtenure
gen occtenure = emptenure if _n==1
replace occtenure=0 if occtenure==.
bysort id (year): gen occswitch=0 if occ==occ[_n-1] | occ==. | occ[_n-1]==. | _n==1
replace occswitch=1 if occswitch==.

forvalues X = 2005(1)2014{ 
	**** 労働時間800時間以上&転職してない->+1
	replace occtenure=occtenure[_n-1]+(year-year[_n-1]) ///
		if morethan800==1 & occswitch==0 & year==`X'
	**** 労働時間800時間未満&転職してない->+-0
	replace occtenure=occtenure[_n-1] ///
		if morethan800==0 & occswitch==0 & year==`X' 
	**** 転職した->0
	replace occtenure=0 ///
		if occswitch==1 & occ!=. & occ[_n-1]!=. & year==`X'
	**** 最初のobservationは変更しない
	bysort id (year): replace occtenure=emptenure if _n==1
}

**** Old job dummy
*gen oj=1 if emptenure>0
*gen oj=1 if switch==0&emptenure>0
gen oj=1 if switch==0
replace oj=0 if oj==.

*** empidの作成
sort id year
by id: gen empid = 1 if _n==1|switch==1|emptenure<emptenure[_n-1]
replace empid=sum(empid)

