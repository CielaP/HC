/* Title: TexFormat */
/// Date: Feb 15th, 2019
/// Written by Ayaka Nakamura
/// 
/// Standard format of estout

* set variables
local estList $EstList
local fileTex $FileTex
local keepVar $KeepVar
local labelVar $LabelVar
local transVar $TransVar
local titleTab $TitleTab
local labelTab $LabelTab
local group $Group
local groupPattern $GroupPattern

* estout
estout `estList' ///
using "$Output/`fileTex'.tex", ///
cells( ///
		b(star fmt(%9.4f) ) ///
		se(par fmt(%9.4f) ) ///
		) ///
starlevels(\sym{*} 0.1 \sym{**} 0.05 \sym{***} 0.01) ///
stats(N, labels("Observations") fmt(%9.0f)) ///
collabels(none) ///
mlabels( *, nodepvars numbers notitles) ///
nolz ///
style(tex) ///
substitute(_ \_) ///
keep(`keepVar') ///
order(`keepVar') ///
varlabels(`labelVar') ///
transform(`transVar') ///
title(`titleTab' \label{`labelTab'}) ///
prehead( ///
				"\begin{table}[htbp]\centering" ///
				"\begin{threeparttable}" ///
				"\caption{@title}" ///
				"\begin{tabular}{l*{@M}{c}}" ///
				"\hline\hline\\" ///
				) ///
posthead( "\hline\\" ) ///
prefoot( "\hline\\" ) ///
postfoot( "\hline\hline" ///
				"\end{tabular}" ///
				"\begin{tablenotes}" ///
				"\small" ///
				"\im Notes: Robust standard errors are in parentheses." ///
				"\im $^{*}$ , $^{**}$ and $^{***}$ Denote statistical significance at the 10\%, 5\% and 1\% level, respectively." ///
				"\end{tablenotes}" ///
				"\end{threeparttable}" ///
				"\end{table}" ///
				) ///
mgroups( ///
				`group', ///
				nodep ///
				pattern( `groupPattern' ) ///
				prefix( \multicolumn{@span}{c}{ ) ///
				suffix( } ) ///
				span erepeat( \cmidrule(lr){@span}) ///
				) ///
replace
	