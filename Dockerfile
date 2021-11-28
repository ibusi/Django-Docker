#Dockerfile　公開されているDockerイメージをそのまま使うのではなく、必要なパッケージやアプリ、
#各種設定を含んだDockerイメージを自分で作成して使用する


#FROMは、ベースとするDockerイメージを指定する。
#alpine 軽いOSでdockerのアプリに向いている
FROM python:3.8-alpine

#ENVは環境変数を設定
#コンテナへのパスを追加
ENV PATH="/scripts:${PATH}"

#./requirements.txtがdockerイメージの/requirements.txtにコピーされる
COPY ./requirements.txt /requirements.txt

#RUNは、OSのコマンドを実行する際に使用する。
#apk はalpineのパッケージマネージャー
#apk addはパッケージをインストールする
#--update レポジトリがアップデートされる
#--no-cache パッケージキャッシュを使わない。
#--virtual インストールするパッケージ群に名前をつけれる（今回は.tmpという名前）
#gcc libc-dev linux-headersの3つのパッケージはalpineでuWSGI（PythonでWebサービスを動かすためのアプリケーションサーばー）をインストールするのに必要
RUN apk add --update --no-cache --virtual .tmp gcc libc-dev linux-headers

#requirements.txt に書いてあるdependensiesをダウンロード
RUN pip install -r /requirements.txt

#requirementsから必要な物はダウンロードしたので軽くするために.tmpを削除
RUN apk del .tmp


#dockerイメージにディレクトリを作る
RUN mkdir /app
COPY ./app /app

#ディレクトリを変更
WORKDIR /app
COPY ./scripts /scripts


#scripts以下に実行権限を与える
RUN chmod +x /scripts/*


#mkdirオプションの-pは親ディレクトリも同時に作成
#mediaファイルとはユーザーがアップロードしたファイルなどが保存されるファイルのことを指す
RUN mkdir -p /vol/web/media

#staticファイルはpython以外の静的ファイル（クライアント側で使うJSとかCSSとか）が入る
#静的ページはHTMLファイルで作られている普通のホームページのこと。
#いつ誰が見ても同じ内容が表示される、ホームページ（の中の1ページ）のこと
RUN mkdir -p /vol/web/static


#dockerイメージにユーザーを作成
RUN adduser -D user
#ユーザー所有権とグループ所有権を新しく作ったユーザーに変える　-Rは指定したディレクトリとその中の全ファイルの所有者を変更
RUN chown -R user:user /vol
RUN chmod -R 755 /vol/web
#新しく作ったユーザーにスイッチする
USER user


#docker image からdocker containerを実行するときにCMDの記述内容が実行される　エントリーポイントの指定
CMD ["entrypoint.sh"]