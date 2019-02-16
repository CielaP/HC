/* Title: TexTab_sum */
/// Date: Feb 16th, 2019
/// Written by Ayaka Nakamura
/// 
/// Standard format of summary statistics

* set variables
local fileTex $FileTex
local labelVar $LabelVar
local titleTab $TitleTab
local labelTab $LabelTab
local space $Space

* estab
esttab using "$Output/`fileTex'.tex", ///
	cells( ///
			( ///
			mean( label(Mean) fmt(%5.4f) ) ///
			sd( label(St.d) fmt(%5.4f) ) ///
 			min(label(Min) fmt(%9.0f) ) ///
			max(label(Max) fmt(%9.0f) ) ///
			) ///
			) ///
	coeflabel( `labelVar' ) ///
	noobs nomtitles nonumber nolz ///
	gaps ///
	style(tex) ///
	substitute(_ \_ 1em `space') ///
	title(`titleTab' \label{`labelTab'}) ///
	prehead( ///
					"\begin{table}[htbp]\centering" ///
					"\begin{threeparttable}" ///
					"\caption{@title}" ///
					"\begin{tabular}{l*{4}{c}}" ///
					"\hline\hline\\" ///
					) ///
	posthead( "\hline\\" ) ///
	prefoot( "\hline\\" ) ///
	postfoot( "\end{tabular}" ///
					"\begin{tablenotes}" ///
					"\small" ///
					"\im Notes: ." ///
					"\end{tablenotes}" ///
					"\end{threeparttable}" ///
					"\end{table}" ///
					) ///
replace

