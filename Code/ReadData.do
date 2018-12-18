/* Title: ReadData */
/// Date: Nov 5th, 2018
/// Written by Ayaka Nakamura
/// 
/// This file reads data set

local inputfd $Inputfd

qui {
	use "`inputfd'\jhps_hc.dta", clear
	destring, replace
	tsset id year
}
