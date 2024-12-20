# [Tsurugi FDW for Tsurugi](./tsurugi_fdw.md)

## セットアップ

### 必要条件

Tsurugi FDWをセットアップする環境は、TsurugiおよびPostgreSQLの要件に準じます。  
必要となるソフトウェアパッケージ、および、ライブラリについては、[README.md](../README.md)を確認してください。

### PostgreSQLのインストール

Tsurugi FDWは、PostgreSQLのビルド環境を使用します。

> [!NOTE]
> すでに環境が整っているとわかっている場合は、本手順はスキップしてください。

以下の例ではPostgreSQLのインストールディレクトリに `$HOME/pgsql` を指定しています。  
PostgreSQLのインストールについては、PostgreSQL付属のドキュメントまたはWeb上のマニュアルを確認してください。  
以降、このディレクトリを **`<PostgreSQL install directory>`** と定義します。  

~~~sh
curl -sL https://ftp.postgresql.org/pub/source/v12.4/postgresql-12.4.tar.bz2 | tar -xj
cd postgresql-12.4
./configure --prefix=$HOME/pgsql
make
make install
~~~

### Tsurugi FDWのインストール

#### 1) ソースコードのクローン

GitHubのリポジトリからPostgreSQLのcontribディレクトリにクローンします。

~~~ sh
$ cd <PostgreSQL build directory>/contrib/
$ git clone https://github.com/project-tsurugi/tsurugi_fdw
~~~

#### 2) サブモジュールの更新

Tsurugi FDWのサブモジュールを更新します。  
以降、このディレクトリを **`<tsurugi_fdw build directory>`** と定義します。

~~~ sh
$ cd <PostgreSQL build directory>/contrib/tsurugi_fdw
$ git submodule update --init --recursive
~~~

#### 3) 依存モジュールのビルドとインストール

Tsurugi FDWの依存モジュールをビルドして、PostgreSQLにインストールします。

~~~ sh
$ make install_dependencies
~~~

PostgreSQLのcontribディレクトリ以外にTsuguri FDWをクローンした場合は、pg_configが存在するディレクトリをPATHに追加し`USE_PGXS=1`を指定した上でビルドとインストールを行ってください。

~~~ sh
$ make install_dependencies USE_PGXS=1
~~~

PostgreSQLのライブラリパスをライブラリ検索パスに設定します。  

~~~ sh
$ LIBRARY_PATH=<PostgreSQL install directory>/lib:$LIBRARY_PATH
$ export LIBRARY_PATH
~~~

#### 4) Tsurugi FDWのビルドとインストール

Tsurugi FDWをビルドして、PostgreSQLにインストールします。

~~~ sh
$ make
$ make install
~~~

PostgreSQLのcontribディレクトリ以外にTsuguri FDWをクローンした場合は、pg_configが存在するディレクトリをPATHに追加し`USE_PGXS=1`を指定した上でビルドとインストールを行ってください。

~~~ sh
$ make USE_PGXS=1
$ make install USE_PGXS=1
~~~

### Tsurugi FDWの初期設定

#### 1) データベースクラスタの作成

Tsurugiを利用するためのデータベースクラスタを作成します。

> [!NOTE]
> 既存のデータベースクラスタを使用してTsurugiを利用する場合は、本手順はスキップしてください。  
> その場合、Tsurugiを利用するためのデータベースを新たに作成する必要があります。  
> 以下の例では`tsurugidb`という名前のデータベースを作成しています。  
> ``` $ createdb tsurugidb ```  
> 以降の接続先データベース `postgres` は `tsurugidb` に置き換えて行ってください。  

以下の例では`<PostgreSQL install directory>/data`にデータベースのディレクトリを作成しています。  
ディレクトリの場所は任意です。

~~~ sh
$ mkdir <PostgreSQL install directory>/data
$ initdb -D <PostgreSQL install directory>/data
~~~

#### 2) Tsurugi FDWの登録

PostgreSQLのサーバ起動時にプリロードされる共有ライブラリにTsurugi FDWを登録します。

プリロードされる共有ライブラリの登録は、データベースクラスタのデータディレクトリ直下にあるpostgresql.confのshared_preload_librariesパラメータを更新します。

~~~ conf
shared_preload_libraries = 'tsurugi_fdw'
~~~

#### 3) PostgreSQLのサーバ起動

PostgreSQLのサーバを起動します。

~~~ sh
$ pg_ctl -D <PostgreSQL install directory>/data/ start
~~~

#### 4) メタデータ管理基盤の初期化

Tsurugiのメタデータ管理基盤を初期化します。

~~~ sh
$ psql postgres < <tsurugi_fdw build directory>/third_party/metadata-manager/sql/ddl.sql
~~~

#### 5) データベースへの接続

PostgreSQLの `psql` を使用して データベースへ接続します。

~~~ sh
$ psql postgres
psql (12.4)
Type "help" for help.

postgres=#
~~~

#### 6) エクステンションのインストール

CREATE EXTENTIONコマンドを実行して、Tsurugi FDWをインストールします。

~~~ sql
postgres=# CREATE EXTENSION tsurugi_fdw;
~~~

インストールされたTsurugi FDWは、psqlのメタコマンド`\dew`で確認できます。

~~~ sql
postgres=# \dew
                List of foreign-data wrappers
    Name     |  Owner   |       Handler       | Validator
    ------------+----------+-----------------------+-----------
    tsurugi_fdw | postgres | tsurugi_fdw_handler | -
~~~

#### 7) 外部サーバの登録

CREATE SERVERコマンドを実行して、Tsurugiを使用するための外部サーバを登録します。

~~~ sql
postgres=# CREATE SERVER tsurugi FOREIGN DATA WRAPPER tsurugi_fdw;
~~~

登録された外部サーバは、psqlのメタコマンド`\des`で確認できます。

~~~ sql
postgres=# \des
        List of foreign servers
Name    |  Owner   | Foreign-data wrapper
--------+----------+----------------------
tsurugi | postgres | tsurugi_fdw
~~~

#### 8) PostgreSQLのサーバ終了

Tsurugi FDWの初期設定が完了しました。必要に応じてPostgreSQLのサーバを終了します。

~~~ sh
postgres=# \q
$ pg_ctl -D <PostgreSQL install directory>/data/ stop
~~~

### Tsurugi FDWの起動と終了

PostgreSQLからTsurugiを利用する前に、Tsurugiサーバを起動してください。  
Tsurugiサーバの起動方法はTsurugiのドキュメントを参照してください。

Tsurugi FDWの起動と終了は、Tsurugi FDWが登録されたPostgreSQLのサーバ仕様に準じます。

### Tsurugi FDWのアンインストール

#### 1) 外部サーバの解除

DROP SERVERコマンドを実行して、外部サーバ（tsurugi）を解除します。

~~~ sql
postgres=# DROP SERVER tsurugi;
~~~

#### 2) エクステンションのアンインストール

DROP EXTENTIONコマンドを実行して、Tsurugi FDWをアンインストールします。

~~~ sql
postgres=# DROP EXTENSION tsurugi_fdw;
~~~

#### 3) Tsurugi FDWの解除

postgresql.confのshared_preload_librariesパラメータに追加したTsurugi FDWを解除します。

Tsurugi FDWのアンインストールが完了しました。PostgreSQLのサーバを再起動してください。
