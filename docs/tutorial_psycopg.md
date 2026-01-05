# [Tsurugi FDW for Tsurugi](./README.md)

## チュートリアル

PostgreSQLのユーザインタフェースからTsurugiを利用する簡単な操作方法を説明します。  
このチュートリアルは単なる入門用であり、Tsurugi固有の仕様および制限については、Tsurugiのドキュメントを確認してください。

### Pythonアプリケーションからの利用

PostgreSQLのPsycopgを使用することでPythonアプリケーションからTsurugiを利用することができます。
Tsurugi FDWがサポートするPsycopgのAPIについては [リファレンス（Psycopg API）](./psycopg_reference.md) を参照してください。

#### Psycopgの入手

Psycopgのパッケージは Python Package Index (PyPI) で公開されています。
アプリケーションの要件に適したパッケージを適用してください。

* psycopg2を適用する場合

    ~~~sh
    $ pip install psycopg2-binary
    ~~~

* psycopg3を適用する場合

    ~~~sh
    $ pip install "psycopg[binary]"
    ~~~

#### データベースへの接続（Psycopg）

モジュールインタフェースのconnectメソッドを使用してデータベースに接続することができます。  
接続先データベースは、Tsurugi FDWをインストール（CREATE EXTENTION）したデータベースを指定してください。  
データベースへの接続が成功すると、Connectionクラスのインスタンスが返ります。  

~~~py
    DB_URL = "postgresql://localhost:5432/tsurugi_db"
    conn = psycopg.connect(DB_URL)
        ：
    conn.close();
~~~

#### SQL文の実行（Psycopg）

Corsorクラスのexecuteメソッドを使用してSQL文を実行することができます。
CorsorクラスはConnectionクラスのcursorメソッドを使用して作成します。

以下の例では、`CREATE FOREIGN TABLE`を実行して外部テーブルを作成しています。

~~~py
    cur = conn.corsor()
    create_foreign_table_sql = sql.SQL("""
        create foreign table if not exists fdw_sample (
            num int not null,
            tim time
        ) server tsurugi
        """)
    cur.execute(create_foreign_table_sql)
        ：
    cur.close()
    conn.close();
~~~

> [!NOTE]
> PostgreSQL（Tsurugi FDW）からのDDL実行は非サポートとなります。  
> PostgreSQLから操作するTsurugiテーブルはTsurugiのSQLコンソール（tgsql）などを利用して事前に作成する必要があります。  

#### データの更新（Psycopg）

Corsorクラスのexecuteメソッドを使用してTsurugiのデータを更新（INSERT/UPDATE/DELETE）することができます。

~~~py
    # 実行するSQL文
    ins_sql = sql.SQL("INSERT INTO fdw_sample (num) VALUES (11)")
    upd_sql = sql.SQL("UPDATE fdw_sample SET num = num + 11")
    del_sql = sql.SQL("DELETE FROM fdw_sample")

    # SQL文の実行
    cur.execute(ins_sql)
    cur.execute(upd_sql)
    cur.execute(del_sql)
~~~

#### データの問い合わせ（Psycopg）

Corsorクラスのexecuteメソッドを使用してTsurugiのデータを問い合わせることができます。
問い合わせた結果は同クラスのfetchallメソッドを使用して取得することができます。

~~~py
    # SELECT文の実行
    sel_sql = sql.SQL("SELECT num FROM fdw_sample ORDER BY num")
    cur.execute(sel_sql)

    # 結果の取得
    rows = cur.fetchall()
    for row in rows:
        print(f"  {row[0]:02d}")
~~~

#### プリペアドステートメントの利用（Psycopg）

Pythonアプリケーションから同じSQL文を何度も実行する場合はプリペアドステートメントが便利です。  
プリペアドステートメントの利用（SQL文にパラメータを渡す）方法はPsycopgの仕様に準じます。  
詳細は [Psycopgのドキュメント](https://www.psycopg.org/) を参照してください。  

~~~py
    # パラメータ付SQL文
    ins_sql = sql.SQL("INSERT INTO fdw_sample (num) VALUES (%s)")

    # パラメータを渡してSQL文実行
    cur.execute(ins_sql, (77,))
    cur.execute(ins_sql, (88,))
~~~

#### トランザクション操作（Psycopg）

PythonアプリケーションからTsurugiのトランザクションを操作する方法を説明します。  
トランザクションの操作方法（自動コミットなど）はPsycopgの仕様に準じます。  
詳細は [Psycopgのドキュメント](https://www.psycopg.org/) を参照してください。  

##### トランザクションの開始（Psycopg）

Psycopgでのトランザクションは自動的に開始される仕組みになっています。  
最初のSQL文が実行された時点でトランザクションが開始されるので、明示的に `BEGIN` を行う必要はありません。

##### トランザクションの終了方法（Psycopg）

データベースに接続した直後は自動コミットモード（デフォルト）は無効になっています。  
Connectionクラスの commit または rollback メソッドを使用してトランザクションを明示的に終了させる必要があります。  

~~~py
    DB_URL = "postgresql://localhost:5432/tsurugi_db"
    conn = psycopg.connect(DB_URL)
    cur = conn.corsor()
    cur.execute("INSERT INTO fdw_sample (num) VALUES (11)")
    conn.commit() # INSERTコマンドをコミット
    cur.execute("UPDATE fdw_sample SET num = num + 11")
    conn.rollback() # UPDATEコマンドをロールバック
        ：
    cur.close()
    conn.close();
~~~

##### コンテキストマネージャ（Psycopg）

データベースへの接続でWithステートメントを使用すると明示的なコミットやロールバックの操作が不要になります。  
Withステートメントのブロックを抜けるまでにエラーがなければ自動でコミットされ、エラーがあれば自動でロールバックする動作となります。

~~~py
    # 接続を with で囲むと、終了時に自動コミット＆クローズされる
    with psycopg.connect("dbname=tsurugi_db") as conn:
        with conn.cursor() as cur:
            cur.execute("INSERT INTO fdw_sample (num) VALUES (11)")
        # ここを抜けると自動で commit() される
~~~

##### トランザクション特性の変更（Psycopg）

Corsorクラスのexecuteメソッドを使用してTsurugi固有のトランザクション特性を変更することができます。  
トランザクション特性を変更するUDFの詳細は [リファレンス（UDF）](./udf_reference.md) を参照してください。  

~~~py
    cur.execute("select tg_set_transaction('long')")
    cur.execute("select tg_set_write_preserve('weather')")
~~~

#### エラー情報の取得（Psycopg）

Psycopgを使用したデータベース操作中に何らかの異常が発生すると、`psycopg.Error` が通知されます。  
Errorクラスでは、pgerror, pgcodeなどの属性を使用してエラー情報を取得することができます。  
エラー情報の取得方法はPsycopgの仕様に準じます。詳細は [Psycopgのドキュメント](https://www.psycopg.org/) を参照してください。  
Tsurugi FDWが出力するエラーメッセージについては [リファレンス（メッセージ）](./message_reference.md) を参照してください。

~~~py
    try:
        cur.execute("SELECT * FROM barf")
    except psycopg.Error as e:
        print(f"Database error: {e}")
        :
    except Exception as e:
        print(f"An unexpected error occurred: {e}")
        :
    finally:
        :
~~~

#### サンプルプログラム（Psycopg）

Psycopgを使用してTsurugiを利用するサンプルプログラムを示します。

##### サンプルプログラムの概要

Tsurugiの `fdw_sample` テーブルに、以下の順番でデータの操作を行います。

1. データ(行)挿入
    1. `1` から `10` までの数値と更新時刻を有するデータ(行)を1秒間隔で挿入 (**Insert**)
    1. 挿入した行の数値が `奇数` の場合、当該データ(行)を削除 (**Delete**)
    1. `11` から `20` までの数値と更新時刻を有するデータ(行)を1秒間隔で挿入 (**Insert**)
    1. 挿入したデータ(行)の数値が `奇数` の場合、当該挿入操作をロールバック (**Transaction**)
1. 全データ(行)問い合わせ (**Select**)
1. データ(行)の数値が`3の倍数`の場合、当該データ(行)の更新時刻を更新 (**Update**)
1. 全データ(行)問い合わせ (**Select**)

##### サンプルプログラムのソースコード

ソースコードおよび実行環境は以下にあるファイルを確認してください。

* Psycopg2: [sample/psycopg2-sample/](../sample/psycopg2-sample/)
* Psycopg3: [sample/psycopg3-sample/](../sample/psycopg3-sample/)

> [!TIP]
> TsurugiのテーブルおよびTsurugi FDWの外部テーブルはシェルスクリプトで作成および削除しています。  
> テーブルの詳細はスクリプトファイル(scriptsフォルダ配下)を確認してください。

##### サンプルプログラムの実行イメージ

~~~log
The sample application is running. Please wait...

Inserted Number.1.3.5.7.9.11.13.15.17.19.
  01-10: Even do nothing, Odd delete.
  11-20: Even commit, Odd rollback.
    Number      UpdateTime
     02          15:24:47
     04          15:24:49
     06          15:24:51
     08          15:24:54
     10          15:24:56
     12          15:24:58
     14          15:25:00
     16          15:25:02
     18          15:25:04
     20          15:25:06

Updated UpdateTime.
  Multiples of 3: Update the Time(15:25:07).
    Number      UpdateTime
     02          15:24:47
     04          15:24:49
     06          15:25:07
     08          15:24:54
     10          15:24:56
     12          15:25:07
     14          15:25:00
     16          15:25:02
     18          15:25:07
     20          15:25:06

The sample application has finished.
~~~
