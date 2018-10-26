*******************************************************
*Title: Renamevar_Exp
*Date: Oct 19th, 2018
*Written by Ayaka Nakamura
*
*This file rename variables of working experience
* 
* 1. rename vars. of experience
* 2. bind observations of principal and spouse
********************************************************

* set list of variables
** of principal
local casPri $CasPri
local fullPri $FullPri
local selfPri $SelfPri
local sidePri $SidePri
local fmwPri $FmwPri
** of spouse
local casSpo $CasSpo
local fullSpo $FullSpo
local selfSpo $SelfSpo
local sideSpo $SideSpo
local fmwSpo $FmwSpo

* 1. rename vars. of experience
local empStatus cas full self side fmw
local num_m: word count `empStatus'
local resp_i $Resp_i
local age_t $Age_t

if `resp_i'==1{
	local expVar casPri fullPri selfPri sidePri fmwPri
	forvalues k=1/`num_m' {
		local renamelist: word `k' of `expVar'
		local currentEmpStatus: word `k' of `empStatus'
		rename ( ``renamelist'' ) ( `currentEmpStatus'# ), addnum(`age_t')
	}
}
else {
	local expVar casSpo fullSpo selfSpo sideSpo fmwSpo
	forvalues k=1/`num_m' {
		local renamelist: word `k' of `expVar'
		local currentEmpStatus: word `k' of `empStatus'
		rename ( ``renamelist'' ) ( `currentEmpStatus'# ), addnum(`age_t')
	}
}
sum $ExpList
