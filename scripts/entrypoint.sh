#!/bin/sh

##!はshebanと呼ばれスクリプトを読み込むインタープリタを指定する事がでる。
#今回はshを指定しているので実行時にshを指定する必要がなくなる。

#「インタプリタ」は通訳者の意味でソースコードを1命令ずつ解釈して実行するプログラムを指す
#プログラミング言語で書かれたソースコードを、機械語プログラム（オブジェクトプログラム）に
#1命令ずつ変換して実行する解釈・変換しながら処理・実行する。
#代表的なプログラミング言語には、BASIC、Lisp、JavaScript、Python、Rubyなどがある。

#「コンパイラ」は。ソースコードを事前に一括して変換してから実行する方法。
#変換自体には時間がかかるものの、プログラムの実行速度はインタプリタに比べてはるかに速い。
#ただし、ソースコードをプラットフォームに合わせて変更し、再度コンパイルし直す必要がある。
#代表的なプログラミング言語には、C、C++、COBOL、FORTRANなどがある。



set -e
#‐eはエラーがあったらシェルスクリプトをそこで打ち止めにしてくれる（exit 0以外が返るものがあったら止まるようになる）

#プログラムを書く上で、「途中脱出」という技法はよく必要。シェルスクリプトでそれを実現するのがexitコマンド。
#exit 0のように終了コードを指定すれば、それをシェルスクリプト全体の終了コードとするという結果になル。
#終了コードを指定しない場合は、「前のコマンドの終了コードをそのまま返す」ような挙動となる。
#set -eしている場合は、普通に実行していれば終了コード0のコマンドばかりが並び、exitだけでも終了コード0を返す状況が多いです。

python manage.py collectstatic --noinput
#web server(NGINX等)やHerokuにデプロイする際には、静的ファイルの置き場所を複数ではなく
#一つの場所に集める必要がある。それがcollectstaticコマンド。しかし、collectstaticする前に、
#集める場所をsettings.pyに設定する必要がある。
#settings.pyの中のSTATIC_ROOTに「manage.py collectstatic」を実行した時に、
#staticファイルがコピーされるディレクトリのパスを記述
#‐‐noinputはDjangoで構築しているシステムのデプロイをシェルスクリプトで行おうとしたときに、
#collectstaticでyes/noを入力せずに実行させる

uwsgi --socket :8000 --master --enable-threads --module app.wsgi
#uwsgiはただのアプリケーションの名前

#ソケットとポートの違い
#Both Socket and Port are the terms used in Transport Layer. 
#A port is a logical construct assigned to network processes so that they can be identified within the system.
#A socket is a combination of port and IP address. 
#Socket is used to identify both a machine and a service within the machine.
#--socket :8000はuwsgiサーバーがアプリケーションをポートの8000でサーブする

#--master uWSGI’s built-in prefork+threading multi-worker management mode, 
#activated by flicking the master switch on.
#For all practical serving deployments it is generally a good idea to use master mode.

#Preforking  By default uWSGI loads the whole application in the first process and 
#after the app is loaded it does fork() itself multiple times. This is the common Unix pattern, 
#it may highly reduce the memory usage of your app.
#Seeing it from the “graceful reloading” point of view, preforking extremely speeds up things
#your app is loaded only one time, and spawning additional workers will be really fast. 
#Avoiding disk access for each worker of your stack will decrease startup times, 
#especially for frameworks or languages doing a lot of disk access to find modules.
#Unfortunately, the preforking approach forces you to reload the whole stack whenever you make code changes 
#instead of reloading only the workers.

#graceful reloading 既に稼働しているアプリケーションサーバを更新する際に、
#既に接続しているクライアントが切断されないようにreloadを行うための技術。
#v1からv2の状態へと移行するためにreloadした場合v1のworkerを保持しつつv２のworkerを立ち上げてv1の接続がなくなったら
#順次そのworkerを切って行き、接続を切断せずに移行して行くような方法がある。
#So, why “graceful”?
#Take a traditional (and highly suggested) architecture: a proxy/load balancer (like nginx) forwards 
#requests to one or more uWSGI daemons listening on various addresses.
#ロード(load、負荷)＋バランサー(Balancer、平衡を保つためのもの)で、
#外部からの通信（トラフィック）を複数のサーバーに分散する仕組みを提供する装置。
#Two-Arm (inline)型では、インターネットと各種サーバーの間にロードバランサーを配置。
#このときにロードバランサーに設定するIPアドレスを、仮想IPアドレスと呼び、Webアクセスを一手に受け付け、
#配下の適切なWebサーバーに割り振りふる。割り振り方・内容によって、L４やL７のロードバランスと呼ばれる。

#worker 方式では1つのプロセスが複数のスレッドを持つ。リクエストはスレッドが1対1対応で処理する。
#これにより、少ないプロセス数で多くの仕事を同時実行できるようになる。
#このようなプロセスを『マルチスレッドプロセス』と呼ぶ。

#プロセス　実行中のプログラムのこと。1つのプロセスには、1つのメモリ空間 (メモリ領域) が割り当てられる。
#メモリ空間はプロセスから OS に要求すれば (空きがあれば) 増やしてくれる。

#スレッド
#並行処理に対応したマイクロプロセッサ（CPU/MPU）およびオペレーティングシステム（OS）におけるプログラムの最小の実行単位。
#連続して実行される一本の命令の並び、処理の流れのことで、並行処理を行わない場合は一つの実行プログラム（プロセス）は
#一つのスレッド（シングルスレッド）で命令を順に実行していく。

#--enable-threads　マルチスレッドを有効化する

#--module app.wsgi　アプリケーションのエントリーポイントを表す。wsgi.pyをさす。
#今回でいうと./app/app/wsgi.py(ジャンゴが自動生成するファイルの一つ) 