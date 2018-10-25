*******************************************************
*Title: SampleSelection
*Date: Oct 25th, 2018
*Written by Ayaka Nakamura
* 
* This file restrict observations
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


* restrict age 18--64
keep if age>=18 & age<=64
* keep household head
** head: Are you head of household?
** earnmost: Are you head of household?
* keep if head==1
keep if earnmost==1
* drop female
drop if sex==2
drop sex
* keep employee
drop if employed==0
drop employed
* drop government
drop if size==6
keep if owner==1 | owner==2 | owner==3
drop owner
* make flag of spouse
gen sp =1 if (id>=10000&id<20000)|id>=30000
replace sp=0 if sp==.
* drop spouse
drop if sp==1
