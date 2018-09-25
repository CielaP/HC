# HC
Object: Code for submitting the paper, HC
 
 - 配偶者とnew cohortの情報を使ってサンプル数を増やす->サンプルの代表性が失われたためnew cohortのみ追加
 
 - 投稿時にコードを送るための準備, 論文に使うコードのみを保存


Directory: C:\Users\Ayaka Nakamura\Dropbox\materials\Works\Master\program\Submittion


Folders:

 Code: 
  - DataCorrection.do: データ整理
  - Estimation.do: 推定
  - TenureCheck: 以前と今回のデータ間でのテニュア変数の齟齬をチェック

 OriginalData:
  - JHPS/KHPS 2004--2014

 Input:
  - jhps_hc: 推定用データ(DataCorrection.doにより作成)
  - jhps_hc_old: 以前の推定用データ
  - jhps_hc_TenureCheck.dta: DataCorrection.do内においてテニュア変数作成前のデータ
  - jhps_hc_AllSample.dta: DataCorrection.do内においてテニュア変数作成後サンプル制限前のデータ

 Intermediate:
  - JHPS/KHPS 2004--2014 -> jhps_hcの過程で生成されたデータ

 Output:
  - table, plot等の最終的なアウトプット

