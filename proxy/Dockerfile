#これはnginx proxyのためのdockerfile

#nginxのイメージ
#ルートユーザーより権限の弱いunprivileged mode で動かせる
FROM nginxinc/nginx-unprivileged:1-alpine

COPY ./default.conf /etc/nginx/conf.d/default.conf
COPY ./uwsgi_params /etc/nginx/uwsgi_params

#ディレクトリーを作るために一度rootユーザーになる
USER root

RUN mkdir -p /vol/static
RUN chmod 755 /vol/static

#unprivileged ユーザーに戻る
USER nginx

