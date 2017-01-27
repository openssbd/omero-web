# Docker で OMERO 環境を構築する方法

OMERO (<http://www.openmicroscopy.org>) はテラバイト単位の顕微鏡画像を管理することを目的に、Jason Swedlow 氏らのグループにより開発されたソフトウェアプラットフォームです。その OMERO のインストールと設定を自動で行う Dockerfile を作成しました。CentOS release 6.8 と MacOS Sierra で動作確認しています。

## 前提

* Docker (<https://docs.docker.com/engine/getstarted/step_one/>) をインストールして下さい。Mac OS Yosemite 10.10.3 以上では "Docker for Mac" の利用を推奨します。
* GitHub の "Download ZIP" (<https://github.com/openssbd/omero-web/archive/master.zip>) でダウンロードしたファイル omero-web-master.zip を解凍し omero-web というフォルダ名に変更し ~/ に置きます（Mac ならば /Users/username/）。

## OMERO.server のインストールおよび起動

  1. ターミナルなどで以下のように omero-web フォルダ内に移動したあと "sh run.sh" コマンドを打つと OMERO.server がインストールかつ環境設定されたDockerイメージを作成し、やがて起動します。インターネットとパソコンによりますが、起動まで1時間程度かかる場合があります。
  
    ```
    # cd ~/omero-web/
    # ls
    Dockerfile   OMERO.insight1.png   ... run.sh  ...   setup/
    (run.sh が直下にあることを確認して下さい）
    # sh run.sh
    ```
    
    Successfully built という以下のようなメッセージが表示されるのを待ちます。1cc や a54 ... などの数値はユーザ毎に異なります。
    OMERO.server の起動には、このメッセージが表示されてからさらに20秒ほどかかります。
    
    ```
    Step 41/41 : CMD /bin/bash /start.sh && tail -f /dev/null
     ---> Using cache
     ---> 1cc743c65045
    Successfully built 1cc743c65045
    omero-web
    omero-web
    a54fe17253be899e79b8ec93d39ec0f5062e85844cc82fc7cb01474266d975c7
    ```
    
  2. OMERO.server に接続するため Safari などのブラウザで以下の URL を入力して下さい。
  
    * <http://localhost/image/>
    
    ![Alt text](OMERO.web.png?raw=true "OMERO.server の画面")
    
    OMERO.server の起動途中だった場合に「ページを開けません」といったエラーメッセージが出てアクセスできないことがあります。その場合はもう少し待ってみて下さい。OMERO のサービスの起動にパソコンのスペックが足りない場合も残念ながらアクセスできない場合があります。MacBookPro では問題なく動きましたが、MacBookAir では難しいです(対応は「補足」参照）。

## OMERO.server に画像を新しく追加する方法

OMERO.insight の起動し Dockerに構築した OMERO.server に接続します。

  1. <http://downloads.openmicroscopy.org/omero/5.2.7/> の "OMERO client downloads" から OMERO v5.2.7/Ice v3.5 の OMERO.insight を ダウンロードします。Mac ならば OMERO.insight-5.2.7-ice35-b40-mac.zip です。
    
  2. ダウンロードしたファイルを解凍したフォルダ内の OMERO.insight.app をクリックし OMERO.insight を起動します。Mac で "開発元が未確認のため開けません" というエラーが出る場合は Control キーを押しながらクリックし「開く」を選択します。
  
  3. 以下のアカウントを入力し OMERO.server に接続します。
    * 鍵をかけた状態にする
    * Username: public_data
    * Password: public_data

    ![Alt text](OMERO.insight1.png?raw=true "OMERO.insight のログイン画面")
    
  4. 図中の赤丸で囲ったアイコンをクリックし、画像を選択し ">" ボタンで選択し、インポートする Project や Dataset を選び、"Import" ボタンをクリックして下さい。
    
    ![Alt text](OMERO.insight2.png?raw=true "OMERO.insight で画像をインポートする画面")
    
    追加のテストに SSBD データベース(<http://ssbd.qbic.riken.jp>) にある顕微鏡画像を使うことができます（例：<http://ssbd.qbic.riken.jp/search/afc304bc-7cca-4c92-8764-f5957dd06e3d/> の Source をダウンロードして解凍）。

## 補足

* "sh run.sh" を実行すると 初期状態の OMERO.server が起動します。画像の登録などの変更を加えても必ず初期状態に戻ります。omero-web フォルダの置く場所を変更した場合は run.sh の中の記述で ~/ となっている部分を修正する必要があります。

* パソコンのスペックが足りない（Successfully built が出るのにブラウザではいつまでもアクセスできない）場合は、"sh run.sh" の代わりに "sh run_test.sh" を実行して Docker コンテナにログインし以下のコマンドを順に実行してみてください。ctrl-p ctrl-q は "control を押しながら p を押した後、もう一度、control を押しながら q を押す" というキー操作で、コンテナを起動したまま内部から抜け出すという指示です。

    ```
    # service postgresql start
    # su - omero
    # omero admin start
    (ここで時間がかかります)
    # omero web start
    # exit
    # service nginx start
    # ctrl-p ctrl-q
    ```
* OMERO.server の root のパスワード は root_password にしています。外部公開などに使うには root パスワードの変更などセキュリティを向上させる必要があります。

<table class="wiki">
<tr><th><strong>アカウントの種類</strong></th><th><strong>Username</strong></th><th><strong>Password</strong></th></tr>
<tr><td>System 管理者アカウント</td><td>root</td><td>root</td></tr>
<tr><td>System データベースアカウント</td><td>postgres</td><td>postgres</td></tr>
<tr><td>System OMEROアカウント</td><td>omero</td><td>omero</td></tr>
<tr><td>Database 管理者アカウント</td><td>postgres</td><td>postgres</td></tr>
<tr><td>Database OMEROアカウント</td><td>db_user</td><td>db_password</td></tr>
<tr><td>OMERO 管理者アカウント</td><td>root</td><td>root_password</td></tr>
<tr><td>OMERO ユーザアカウント</td><td>public_data</td><td>public_data</td></tr>
</table>
