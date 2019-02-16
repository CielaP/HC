/* Title: TexTab_est */
/// Date: Feb 15th, 2019
/// Written by Ayaka Nakamura
/// 
/// Standard format of estout

* set variables
local estList $EstList /* list of estimation */
local fileTex $FileTex /* file name of .tex */
local keepVar $KeepVar /* variables kept in the table */
local labelVar $LabelVar /* display format of variable name */
local transVar $TransVar /* transformation of the esimtors */
local titleTab $TitleTab /* title of the table */
local labelTab $LabelTab /* label of the table */
local group $Group /* group of the estimations, ex) "OLS" "IV" */
local groupPattern $GroupPattern /* pattern of the groups, ex) 1 0 1 0 */

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
mlabels( *, none) ///
numbers nolz ///
style(tex) ///
substitute(_ \_) ///
keep(`keepVar') ///
order(`keepVar') ///
varlabels(`labelVar') ///
transform(`transVar') ///
title(`titleTab' \label{`labelTab'}) ///
prehead( ///
				"\begin{table}[!tp] \centering" ///
				"\begin{threeparttable}" ///
				"\caption{@title}" ///
				"\begin{tabular}{l*{@M}{c}}" ///
				"\hline\hline\\" ///
				"[-.8em]" ///
				) ///
posthead( 
				"\hline\\" ///
				"[-.8em]" ///
				) ///
prefoot( 
				"\hline\\" ///
				"[-.8em]" ///
				) ///
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








