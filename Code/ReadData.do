/* Title: ReadData */
/// Date: Nov 5th, 2018
/// Written by Ayaka Nakamura
/// 
/// This file reads data set

local inputfd "C:\Users\AyakaNakamura\Dropbox\materials\Works\Master\program\Submittion\Input"

qui {
	use "`inputfd'\jhps_hc.dta", clear
	destring, replace
	tsset id year
}
