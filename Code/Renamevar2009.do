*******************************************************
*Title: Renamevar2009
*Date: Oct 6th, 2018
*Written by Ayaka Nakamura
*
*This file changes variables' name in 2009 survey
* 
* 1. rename varname of repondent
* 2. rename varname of spouse
* 3. bind 1 and 2
* 
********************************************************
set mat 11000

* set list of variables
local varlist ///
				id marital sex byear bmonth ///
				head earnif earnmost ///
				edbg workstatus ///
				occ owner ind size employed regular ///
				empsinceyear empsincemonth union ///
				paymethod monthlypaid dailypaid hourlypaid yearlypaid bonus ///
				workdaypermonth workhourperweek overworkperweek
disp "`varlist'"


* 1. rename varname of repondent
rename ( ///
				v1 v4 v5 v6 v7 ///
				v101 v102 v103 ///
				v142 v146 ///
				v153 v154 v155 v156 v159 v160 ///
				v167 v168 v169 ///
				v173 v174 v175 v176 v177 v178 ///
				v180 v181 v182 ///
				) ///
			  ( `varlist' )

** make household head dummy
*** Q = Are you head of household?
gen dhead=head
replace dhead=0 if head!=1
label var dhead "HH head dummy"
tab head marital, sum(dhead) mean miss

*** Q = Are you main breadwinner?
ge dearnmost=.
replace dearnmost=1 if dhead==1&earnif==2
replace dearnmost=0 if dearnmost!=1
label var dearnmost "Beradwinner dummy"
tab earnmost marital, sum(dearnmost) mean miss

** save as matrix
mkmat `varlist' dhead dearnmost, matrix(pri)

** restore variable names
rename ( `varlist' ) ///
				( ///
				v1 v4 v5 v6 v7 ///
				v101 v102 v103 ///
				v142 v146 ///
				v153 v154 v155 v156 v159 v160 ///
				v167 v168 v169 ///
				v173 v174 v175 v176 v177 v178 ///
				v180 v181 v182 ///
				) 


* 2. rename varname of spouse
rename ( ///
				v1 v4  v12 v13 v14 ///
				v101 v102 v103 ///
				v274 v279 ///
				v286 v287 v288 v289 v292 v293 ///
				v300 v301 v302 ///
				v306 v307 v308 v309 v310 v311 ///
				v313 v314 v315) ///
			  ( `varlist' )

** replace id
replace id = id+10000
* 続柄が配偶者のサンプルのみ残す
keep if marital==1
* 世帯主ダミー作成
** 世帯主ですか
replace head=0 if head!=2
replace head=1 if head==2
** 主たる生計維持者
replace earnmost=1 if earnmost==2|head==1&earnif==2
replace earnmost=0 if earnmost!=1

** save as matrix
mkmat `varlist', matrix(spo)

* 3. bind 1 and 2
mat sp = pri \ spo
mat dir

* save matrix as dta
drop _all
svmat double sp, name(col)
qui sum
save "$Inter\JHPS`SvyY'.dta", replace
