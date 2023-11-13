# [Tsurugi FDW for Tsurugi](./tsurugi_fdw.md)

## セットアップ

1. 必要条件

    Tsurugi FDWをセットアップする環境は、TsurugiおよびPostgreSQLの必要条件に準じます。
    必要となるソフトウェアパッケージ、および、ライブラリについては、[README.md](../README.md)を確認してください。

1. Tsurugiのインストール

    Tsurugiをインストールします。すでに環境が整っているとわかっている場合は、本手順はスキップしてください。

    1. インストール

        Tsurugiのインストールについては、Tsurugi インストールガイドを確認してください。

    1. インストール後の設定

        インストール環境の環境変数 `LD_LIBRARY_PATH` にTsurugiのライブラリパスとPostgreSQLのライブラリパスが設定されていることを確認します。  
        設定されていない場合は環境変数を設定します。

        ~~~ sh
        $ LD_LIBRARY_PATH=$TSURUGI_HOME/lib:$LD_LIBRARY_PATH
        $ export LD_LIBRARY_PATH
        ~~~

        `$TSURUGI_HOME/bin`をPATHに追加します。これは必須ではありませんが、Tsurugiの使用が便利になります。

        ~~~ sh
        $ PATH=＄TSURUGI_HOME/bin:$PATH
        $ export PATH
        ~~~

        これらの環境変数はPostgreSQLからTsurugiを利用する際に必要になるため、`.profile`ファイルや`.bash_profile`ファイルなどの設定ファイルに記述し、ログイン時に自動的に設定されるようにしてください。

1. PostgreSQLのインストール

    Tsurugi FDWは、PostgreSQLのビルド環境を使用します。すでに環境が整っているとわかっている場合は、本手順はスキップしてください。

    1. インストール

       PostgreSQLのインストールについては、PostgreSQL付属のドキュメントまたはWeb上のマニュアルを確認してください。

    1. インストール後の設定

        PostgreSQLのライブラリパスを共有ライブラリの検索パスに設定します。

        ~~~ sh
        $ LD_LIBRARY_PATH=<PostgreSQL install directory>/lib:$LD_LIBRARY_PATH
        $ export LD_LIBRARY_PATH
        ~~~

        `<PostgreSQL install directory>/bin`をPATHに追加します。これは必須ではありませんが、PostgreSQLの使用が便利になります。

        ~~~ sh
        $ PATH=<PostgreSQL install directory>/bin:$PATH
        $ export PATH
        ~~~

        これらの環境変数はPostgreSQLからTsurugiを利用する際に必要になるため、`.profile`ファイルや`.bash_profile`ファイルなどの設定ファイルに記述し、ログイン時に自動的に設定されるようにしてください。

1. Tsurugi FDW のインストール

    1. ソースコードのクローン

        GitHubのリポジトリからPostgreSQLのcontribディレクトリにクローンします。

        ~~~ sh
        $ cd <PostgreSQL build directory>/contrib/
        $ git clone https://github.com/project-tsurugi/tsurugi_fdw
        $ cd <PostgreSQL build directory>/contrib/tsurugi_fdw
        ~~~

        - 以降、このディレクトリを`<tsurugi_fdw build directory>`と定義します。

    1. ビルド前の設定

        Tsurugiのライブラリパスをライブラリの検索パスに設定します。
        Tsurugiのライブラリパスは、$TSURUGI_HOME下のlibディレクトになります。すでに環境が整っているとわかっている場合は、本手順はスキップしてください。

        ~~~ sh
        $ LIBRARY_PATH=$TSURUGI_HOME/lib:$LIBRARY_PATH
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

1. Tsurugi FDW 初期設定

    1. データベースクラスタの作成

        Tsurugiを利用するためのデータベースクラスタを作成します。

        ~~~ sh
        $ mkdir <PostgreSQL install directory>/data
        $ initdb -D <PostgreSQL install directory>/data
        ~~~

        - 上記の例では`<PostgreSQL install directory>/data`にデータベースのディレクトリを作成しています。ディレクトリの場所は任意です。

    1. テーブル空間用のディレクトリ作成

        Tsurugiのテーブル空間として使用するディレクトリを作成します。

        ~~~ sh
        $ mkdir <PostgreSQL install directory>/tsurugi
        ~~~

        - 上記の例では`<PostgreSQL install directory>/tsurugi`にテーブル空間用のディレクトリを作成しています。ディレクトリの場所は任意です。

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

1. Tsurugi FDW 起動と終了

    PostgreSQLレイヤーからTsurugiを利用する前に、Tsurugi（Tsurugiサーバおよび認証サーバ）を起動してください。

    Tsurugi FDWが登録されたPostgreSQLサーバの起動と終了は、PostgreSQLの仕様に準じます。

1. Tsurugi FDW アンインストール

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
