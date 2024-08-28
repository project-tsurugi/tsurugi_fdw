# [Tsurugi FDW for Tsurugi](./tsurugi_fdw.md)

## セットアップ

### 必要条件

Tsurugi FDWをセットアップする環境は、TsurugiおよびPostgreSQLの必要条件に準じます。
必要となるソフトウェアパッケージ、および、ライブラリについては、[README.md](../README.md)を確認してください。

### PostgreSQLのインストール

Tsurugi FDWは、PostgreSQLのビルド環境を使用します。すでに環境が整っているとわかっている場合は、本手順はスキップしてください。

- 以下の例ではPostgreSQLのインストールディレクトリに `$HOME/pgsql` を指定しています。
- 以降、このディレクトリを **`<PostgreSQL install directory>`** と定義します。
- PostgreSQLのインストールについては、PostgreSQL付属のドキュメントまたはWeb上のマニュアルを確認してください。  


    ~~~sh
    curl -sL https://ftp.postgresql.org/pub/source/v12.4/postgresql-12.4.tar.bz2 | tar -xj
    cd postgresql-12.4
    ./configure --prefix=$HOME/pgsql
    make
    make install
    ~~~

### Tsurugi FDWのインストール

1. ソースコードのクローン

    GitHubのリポジトリからPostgreSQLのcontribディレクトリにクローンします。

    ~~~ sh
    $ cd <PostgreSQL build directory>/contrib/
    $ git clone https://github.com/project-tsurugi/tsurugi_fdw
    ~~~

1. サブモジュールの更新

    Tsurugi FDWのサブモジュールを更新します。
    - 以降、このディレクトリを **`<tsurugi_fdw build directory>`** と定義します。

    ~~~ sh
    $ cd <PostgreSQL build directory>/contrib/tsurugi_fdw
    $ git submodule update --init --recursive
    ~~~

1. 依存モジュールのビルドとインストール

    Tsurugi FDWの依存モジュールをビルドして、PostgreSQLにインストールします。

    ~~~ sh
    $ make install_dependencies
    ~~~

    PostgreSQLのライブラリパスをライブラリの検索パスに設定します。  
    すでに環境が整っているとわかっている場合は、本手順はスキップしてください。

    ~~~ sh
    $ LIBRARY_PATH=<PostgreSQL install directory>/lib:$LIBRARY_PATH
    $ export LIBRARY_PATH
    ~~~

1. Tsurugi FDWのビルドとインストール

    Tsurugi FDWをビルドして、PostgreSQLにインストールします。

    ~~~ sh
    $ make
    $ make install
    ~~~

    PostgreSQLがカスタムロケーションにインストールされている場合は、pg_configが存在するディレクトリをPATHに追加して、ビルドとインストールを行ってください。

    ~~~ sh
    $ make USE_PGXS=1
    $ make install USE_PGXS=1
    ~~~

### Tsurugi FDWの初期設定

1. データベースクラスタの作成

    Tsurugiを利用するためのデータベースクラスタを作成します。
    - 以下の例では`<PostgreSQL install directory>/data`にデータベースのディレクトリを作成しています。  
      ディレクトリの場所は任意です。

    ~~~ sh
    $ mkdir <PostgreSQL install directory>/data
    $ initdb -D <PostgreSQL install directory>/data
    ~~~

1. テーブル空間用のディレクトリ作成

    Tsurugiのテーブル空間として使用するディレクトリを作成します。
    - 以下の例では`<PostgreSQL install directory>/tsurugi`にテーブル空間用のディレクトリを作成しています。  
      ディレクトリの場所は任意です。

    ~~~ sh
    $ mkdir <PostgreSQL install directory>/tsurugi
    ~~~

1. Tsurugi FDWの登録

    PostgreSQLのサーバ起動時にプリロードされる共有ライブラリにTsurugi FDWを登録します。

    プリロードされる共有ライブラリの登録は、データベースクラスタのデータディレクトリ直下にあるpostgresql.confのshared_preload_librariesパラメータを更新します。

    ~~~ conf
    shared_preload_libraries = 'tsurugi_fdw'
    ~~~

1. PostgreSQLのサーバ起動

    PostgreSQLのサーバを起動します。

    ~~~ sh
    $ pg_ctl -D <PostgreSQL install directory>/data/ start
        ~~~

1. メタデータ管理基盤の初期化

    Tsurugiのメタデータ管理基盤を初期化します。

    ~~~ sh
    $ psql postgres < <tsurugi_fdw build directory>/third_party/metadata-manager/sql/ddl.sql
    ~~~

1. データベースサーバへの接続

    PostgreSQLの `psql` を使用して データベースサーバへ接続します。

    ~~~ sh
    $ psql postgres
    psql (12.4)
    Type "help" for help.

    postgres=#
    ~~~

1. エクステンションのインストール

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

1. 外部サーバの登録

    CREATE SERVERコマンドを実行して、Tsurugiを使用するための外部データラッパを登録します。

    ~~~ sql
    postgres=# CREATE SERVER tsurugi FOREIGN DATA WRAPPER tsurugi_fdw;
    ~~~

    登録された外部データラッパは、psqlのメタコマンド`\des`で確認できます。

    ~~~ sql
    postgres=# \des
            List of foreign servers
    Name    |  Owner   | Foreign-data wrapper
    --------+----------+----------------------
    tsurugi | postgres | tsurugi_fdw
    ~~~

1. テーブル空間の定義

    CREATE TABLESPACEコマンドを実行して、Tsurugiで使用するテーブル空間を定義します。

    ~~~ sql
    postgres=# CREATE TABLESPACE tsurugi LOCATION '<PostgreSQL install directory>/tsurugi';
    ~~~

    定義されたテーブル空間は、psqlのメタコマンド`\db`で確認できます。

    ~~~ sql
    postgres=# \db
                    List of tablespaces
        Name   |  Owner   |            Location
    -----------+----------+------------------------------------
    pg_default | postgres |
    pg_global  | postgres |
    tsurugi    | postgres | /home/postgres/local/pgsql/tsurugi
    ~~~

1. PostgreSQLのサーバ終了

    Tsurugi FDWの初期設定が完了しました。必要に応じてPostgreSQLのサーバを終了します。

    ~~~ sh
    postgres=# \q
    pg_ctl -D <PostgreSQL install directory>/data/ stop
    ~~~

### Tsurugi FDWの起動と終了

PostgreSQLレイヤーからTsurugiを利用する前に、Tsurugiサーバを起動してください。
Tsurugiサーバの起動方法はTsurugiのドキュメントを参照してください。

Tsurugi FDWの起動と終了は、Tsurugi FDWが登録されたPostgreSQLのサーバ仕様に準じます。

### Tsurugi FDWのアンインストール

1. テーブル空間の削除

    DROP TABLESPACEコマンドを実行して、Tsurugiで使用するテーブル空間の定義を削除します。

    ~~~ sql
    postgres=# DROP TABLESPACE tsurugi;
    ~~~

1. 外部サーバの解除

    DROP SERVERコマンドを実行して、Tsurugiを管理する外部データラッパを解除します。

    ~~~ sql
    postgres=# DROP SERVER tsurugi;
    ~~~

1. エクステンションのアンインストール

    DROP EXTENTIONコマンドを実行して、Tsurugi FDWをアンインストールします。

    ~~~ sql
    postgres=# DROP EXTENSION tsurugi_fdw;
    ~~~

1. Tsurugi FDWの解除

    postgresql.confのshared_preload_librariesパラメータに追加したTsurugi FDWを解除します。

    Tsurugi FDWのアンインストールが完了しました。PostgreSQLのサーバを再起動してください。
