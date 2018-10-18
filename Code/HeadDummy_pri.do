*******************************************************
*Title: 
*Date: Oct 18th, 2018
*Written by Ayaka Nakamura
*
*This file makes household head dummy of principal
* 
********************************************************

*** Q = Are you head of household?
gen dhead=head
replace dhead=0 if head!=1
label var dhead "HH head dummy"
tab head marital, sum(dhead) mean miss

*** Q = Are you main breadwinner?
ge dearnmost=.
replace earnmost=1 if dhead==1&earnif==2
replace dearnmost=1 if earnmost==1
replace dearnmost=0 if dearnmost!=1
label var dearnmost "Breadwinner dummy"
tab earnmost marital, sum(dearnmost) mean miss
