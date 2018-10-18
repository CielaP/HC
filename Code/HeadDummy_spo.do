*******************************************************
*Title: 
*Date: Oct 18th, 2018
*Written by Ayaka Nakamura
*
*This file makes household head dummy of spouse
* 
********************************************************

*** Q = Are you head of household?
gen dhead=head
replace dhead=0 if head!=2
replace dhead=1 if head==2
label var dhead "HH head dummy"
tab head marital, sum(dhead) mean miss

*** Q = Are you main breadwinner?
ge dearnmost=.
replace earnmost=2 if dhead==1&earnif==2
replace dearnmost=1 if earnmost==2
replace dearnmost=0 if dearnmost!=1
label var dearnmost "Beradwinner dummy"
tab earnmost marital, sum(dearnmost) mean miss
