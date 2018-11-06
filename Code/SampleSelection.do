*******************************************************
*Title: SampleSelection
*Date: Oct 25th, 2018
*Written by Ayaka Nakamura
* 
* This file restrict observations
********************************************************

* Define indicator indicating which survey data
local isJHPS id<20000
local isOldKHPS id>=20000&id<40000
local isNewKHPS id>=40000


* restrict age 18--64
keep if age>=18 & age<=64
sum age
* keep household head
** head: Are you head of household?
** earnmost: Are you head of household?
keep if dearnmost==1
* drop female
drop if sex==2
sum sex
drop sex
* keep employee
drop if demployed==0
sum demployed
drop demployed
* drop government
drop if dsize==6
keep if owner==1 | owner==2 | owner==3
sum owner
drop owner
