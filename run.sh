#!/bin/sh

## ENV PG_DATA_FLG 1にしたDockerfileを使ってイメージを作成する
docker build -t omero-web:1 ~/omero-web/.

## 旧コンポーネントの削除
docker stop omero-web
docker rm omero-web

## 作成したイメージから新しくコンポーネントの作成しログイン (開発用)
## ログイン後 root で /start.sh を実行するとサービスが起動する
#docker run -it -p 80:80 -p 4064:4064 --name omero-web omero-web:1 /bin/bash

## 作成したイメージから新しくコンポーネントの作成しバックグラウンドモードで起動 (サービス用)
docker run  -d -p 80:80 -p 4064:4064 --name omero-web omero-web:1
