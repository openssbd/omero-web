# omero-web: Docker で OMERO 環境を構築する方法

OMERO (<http://www.openmicroscopy.org>) はテラバイト単位の顕微鏡画像を管理することを目的に、Jason Swedlow 氏らのグループにより開発されたソフトウェアプラットフォームです。その OMERO のインストールと設定を自動で行う Dockerfile を作成しました。CentOS release 6.8 と MacOS Sierra で確認しています。

## 前提

* Docker 環境 (<https://docs.docker.com/engine/getstarted/step_one/>) を用意して下さい。Mac では "Docker for Mac" のインストールを推奨します。MacBookPro では特に問題なく稼働しました。MacBookAir にインストールしたときはスペック少し足りず、Docker の Preferences ... General で CPUs:3, Memory 3.0GB 設定することで安定しました。
  
* GitHub からダウンロードしたファイル（"Download ZIP"を利用した場合は omero-web-master.zip を解凍する）を ~/omero-web/ に置きます（Mac ならば/Users/username/omero-web/）。置く場所を変更した場合は run.sh で ~/ となっている部分を対応するパスに修正する必要があります。

## OMERO.server のインストールおよび起動

  1. ターミナルなどで以下のコマンドを打ち込むと OMERO.server がインストールかつ環境設定されたDockerイメージを作成し、やがて起動します。起動までインターネットとパソコンによりますが1時間程度かかること場合があります。
  
    ```
    # cd ~/omero-web/
    # pwd
    /Users/username/omero-web/
    # sh run.sh
    ```
    
    Successfully build という以下のようなメッセージが表示されるのを待ちます。1cc や a54 ... などの数値はユーザ毎に異なります。
    OMERO.server の起動には、このメッセージが表示されてからさらに10秒ほどかかります。
    
    ```
    Step 41/41 : CMD /bin/bash /start.sh && tail -f /dev/null
     ---> Using cache
     ---> 1cc743c65045
    Successfully built 1cc743c65045
    omero-web
    omero-web
    a54fe17253be899e79b8ec93d39ec0f5062e85844cc82fc7cb01474266d975c7
    ```
    
  2. OMERO.server に接続するため Safari などのブラウザで以下のURLを入力して下さい。
  
    * <http://localhost/image/>
    
    ![Alt text](OMERO.web.png?raw=false "OMERO.server の画面")
    
    OMERO.server の起動途中だった場合に「ページを開けません」といったエラーメッセージがでることがあります。OMERO.server の root のパスワード は root_password にしています。外部公開などに使うには root パスワードの変更などセキュリティを向上させる必須があります。

## 画像を OMERO.server に追加する方法

OMERO.insight の起動し OMERO.server に接続します。

  1. <http://downloads.openmicroscopy.org/omero/5.2.7/> の "OMERO client downloads" から OMERO v5.2.7/Ice v3.5 の OMERO.insight を ダウンロードします。Mac ならば OMERO.insight-5.2.7-ice35-b40-mac.zip です。
    
  2. ダウンロードしたファイルを解凍したフォルダ内の OMERO.insight.app をクリックし OMERO.insight を起動します。Mac でエラーが出る場合は option を押しながらクリックしてください。
  
  3. OMERO.insight から以下のアカウントを入力し OMERO.server に接続します。
    * 鍵をかけた状態にする
    * Username: public_data
    * Password: public_data

    ![Alt text](OMERO.insight1.png?raw=false "OMERO.insight の画面")
    
  4. 顕微鏡画像を OMERO.server に登録します。図中の赤丸で囲ったアイコンをクリックし、画像を選択し ">" ボタンで選択し、インポートする Project や Dataset を選び、"Import" ボタンをクリックしてください。
    
    ![Alt text](OMERO.insight2.png?raw=true "OMERO.insight でインポートする画面")
    
    インポートのテスト用に SSBD データベース(<http://ssbd.qbic.riken.jp>) にある顕微鏡画像を使うことができます（例：<http://ssbd.qbic.riken.jp/search/afc304bc-7cca-4c92-8764-f5957dd06e3d/> の Source をダウンロードして解凍）。
