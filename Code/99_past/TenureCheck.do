* pathを通す
quietly {
clear
set more off
 cd "C:\Users\AyakaNakamura\Dropbox\materials\Works\Master\program\Submittion"
 adopath + "C:\Users\AyakaNakamura\Dropbox\materials\Works\Master\program\Submittion"
 adopath + "C:\Users\AyakaNakamura\Dropbox\materials\Works\Master\program\Submittion\OriginalData"
 adopath + "C:\Users\AyakaNakamura\Dropbox\materials\Works\Master\program\Submittion\Intermediate"
 adopath + "C:\Users\AyakaNakamura\Dropbox\materials\Works\Master\program\Submittion\Output"
 adopath + "C:\Users\AyakaNakamura\Dropbox\materials\Works\Master\program\Submittion\Intput"
 adopath + "C:\Users\AyakaNakamura\Dropbox\materials\Works\Master\program\Submittion\coefplot"
 adopath + "C:\Users\AyakaNakamura\Dropbox\materials\Works\Master\program\coefplot"
 adopath + "C:\Users\AyakaNakamura\Dropbox\materials\Works\Master\program\estout"
}

/* jhps_hc_oldとjhps_hcで推定結果が異なる理由を探る */
* テニュアの変数が同じか比較(Empten, Workexp)
* 賃金の変数が同じか比較

/*
use "C:\Users\AyakaNakamura\Dropbox\materials\Works\Master\program\Submittion\Input\jhps_hc_old.dta", clear
* jhps_hc_oldをjhps_hcの形式に合わせて保存しなおす
** 元のoldデータのディレクトリ上では変更してない
*** KHPSのidをid+20000に変更
replace id=id+20000 if id<9000
*** JHPSのidを元のidに戻す
replace id=id-9000 if id<20000
rename empst regular
drop *iv *iv? avg*
sort id year
replace size=0 if size<5
replace size=1 if size==5
save  "C:\Users\AyakaNakamura\Dropbox\materials\Works\Master\program\Submittion\Input\jhps_hc_old.dta", replace
*/

** jhps_hc
use "C:\Users\AyakaNakamura\Dropbox\materials\Works\Master\program\Submittion\Input\jhps_hc.dta", clear

* どのサンプルでtenure&wageが異なっているかを比較
** jhps_hc_oldとjhps_hcをidでマージしてマージされたものだけテニュアの差を計算
use "C:\Users\AyakaNakamura\Dropbox\materials\Works\Master\program\Submittion\Input\jhps_hc_old.dta", clear
rename (emptenure workexp empswitch realwage1) ///
(emp_old workexp_old switch_old realwage_old)
sort id year
keep id year age emp_old workexp_old switch_old realwage_old
merge 1:1 id year  using "C:\Users\AyakaNakamura\Dropbox\materials\Works\Master\program\Submittion\Input\jhps_hc_AllSample.dta"
keep if _merge==3
replace realwage=log(realwage)
keep id year age emptenure workexp switch realwage ///
emp_old workexp_old switch_old realwage_old
order _all, alpha
order id year
gen empdif=emptenure-emp_old
replace empdif=0 if emptenure==.&emp_old==.
gen expdif=workexp-workexp_old
replace expdif=0 if workexp==.&workexp_old==.
gen swdif=switch-switch_old
replace swdif=0 if switch==.&switch_old==.
gen wagedif=realwage-realwage_old
replace wagedif=0 if realwage==.&realwage_old==.
table empdif /// 24sample異なる(1<=diff<=32)
/// ほとんどは_oldにおいてサンプルが落ちる->復活したときにemp_old=0とリセットされることが原因
/// それ以上にemptenure==.理由による欠損が多いのが問題になっていそう
table expdif /// 10sampleが-1
table swdif /// equal
table wagedif ///equal

** empdif==.のサンプルについて元データを確認
keep if empdif==.
*** empdif==.となっているidのリストを作成
bysort id: gen dup=cond(_N==1,0,_n)
drop if dup>1
keep id
mkmat id, matrix(vc)
*** 再度empdifを計算
use "C:\Users\AyakaNakamura\Dropbox\materials\Works\Master\program\Submittion\Input\jhps_hc_old.dta", clear
rename (emptenure workexp empswitch realwage1) ///
(emp_old workexp_old switch_old realwage_old)
sort id year
keep id year age emp_old workexp_old switch_old realwage_old
merge 1:1 id year  using "C:\Users\AyakaNakamura\Dropbox\materials\Works\Master\program\Submittion\Input\jhps_hc_AllSample.dta"
replace realwage=log(realwage)
keep id year age emptenure workexp switch realwage ///
emp_old workexp_old switch_old realwage_old morethan800
order _all, alpha
order id year
gen empdif=emptenure-emp_old
replace empdif=0 if emptenure==.&emp_old==.
gen expdif=workexp-workexp_old
replace expdif=0 if workexp==.&workexp_old==.
gen swdif=switch-switch_old
replace swdif=0 if switch==.&switch_old==.
gen wagedif=realwage-realwage_old
replace wagedif=0 if realwage==.&realwage_old==.
*** 齟齬ありidリストとマージするidのみ残す
merge m:1 id using vc
keep if _merge==3
sort id year
keep id year age emptenure emp_old ///
workexp workexp_old switch switch_old morethan800 realwage
order id year age emptenure emp_old ///
workexp workexp_old switch switch_old morethan800 realwage
/// 初年度がemp=NAのときにswitchしない限りずっとemp=NA
/// emp_oldは初年度にNAでも2年目にemp_old=0として以降も勝手に計算しているっぽい
/// newではswitch=NAのときにemp=0になる->switch=0と仮定するのが妥当?
/// これらについて戸田, Manovskiiに記載なし

** tenureが異なったサンプルについて元データを確認
/// _oldにおいてサンプルが落ちる->復活したときにemp_old=0とリセットされることが原因のもの以外
use "C:\Users\AyakaNakamura\Dropbox\materials\Works\Master\program\Submittion\Input\jhps_hc_TenureCheck.dta", clear
keep if id==23989|id==2687|id==20461|id==21471
sort id year
keep id year age emptenure workexp switch realwage morethan800
order id year age emptenure switch morethan800
rename (emptenure workexp) (emp_ord workexp_ord)
*** jhps_hcとマージしてテニュアの計算方法を確認
merge 1:1 id year  using "C:\Users\AyakaNakamura\Dropbox\materials\Works\Master\program\Submittion\Input\jhps_hc_AllSample.dta"
keep if id==23989|id==2687|id==20461|id==21471
keep id year age emptenure emp_ord switch morethan800 workexp workexp_ord realwage earnmost
order id year age emptenure emp_ord switch morethan800 workexp workexp_ord realwage earnmost
/// -> id==23989|id==2687|id==20461|id==21471についてはjhps_hcにおいて正しく計算されている

