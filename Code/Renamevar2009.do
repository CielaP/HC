*******************************************************
*Title: Renamevar2009
*Date: Oct 6th, 2018
*Written by "YOUR NAME"
*
*This file changes variables' name in 2009 survey
* 
********************************************************



** Rename variable names
*** fill out birthday, edbg and workstatus of spouse of sample who not married?
replace v6 = v12 if v6==.
replace v7 = v14 if v7==.
replace v142 = v274 if v124 ==.
replace v146 = v279 if v146==.
 
forvalues m of numlist 153/156 159/160 167/169 173/178 180/182{
	local n = `m' + 133
	disp "`m' , `n'"
	replace v`m' = v`n' if v`m'==.
}

rename  (  ///
			v1 v4 v5 v6 v7 ///
			v101 v102 v103 ///
			v142 v146 ///
		    v153 v154 v155 v156 v159 v160 ///
		    v167 v168 v169 ///
		    v173 v174 v175 v176 v177 v178 ///
		    v180 v181 v182
		) ///
		( ///
		    id marital sex byear bmonth ///
			head earnif earnmost ///
			edbg workstatus ///
			occ owner ind size employed regular ///
			empsinceyear empsincemonth union ///
			paymethod monthlypaid dailypaid hourlypaid yearlypaid bonus ///
		)
			
