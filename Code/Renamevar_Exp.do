*******************************************************
*Title: RenamevarExp
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
local reguPri $ReguPri
local selfPri $SelfPri
local sidePri $SidePri
local fmwPri $FmwPri
** of spouse
local casSpo $CasSpo
local reguSpo $ReguSpo
local selfSpo $SelfSpo
local sideSpo $SideSpo
local fmwSpo $FmwSpo

* 1. rename vars. of experience
local empStatus cas regu self side fmw
local num_m: word count `empStatus'
local resp_i $Resp_i

if `resp_i'==1{
	local expVar casPri reguPri selfPri sidePri fmwPri
	forvalues k=1/`num_m' {
		local renamelist: word `k' of `expVar'
		local currentEmpStatus: word `k' of `empStatus'
		rename ( ``renamelist'' ) ( `currentEmpStatus'# ), addnum(18)
	}
}
else {
	local expVar casSpo reguSpo selfSpo sideSpo fmwSpo
	forvalues k=1/`num_m' {
		local renamelist: word `k' of `expVar'
		local currentEmpStatus: word `k' of `empStatus'
		rename ( ``renamelist'' ) ( `currentEmpStatus'# ), addnum(18)
	}
}
sum $ExpList
