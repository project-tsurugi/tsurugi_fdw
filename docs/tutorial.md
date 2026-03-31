# [Tsurugi FDW for Tsurugi](./README.md)

## チュートリアル

PostgreSQLのユーザインタフェースからTsurugiを利用する簡単な操作方法を説明します。  
このチュートリアルは単なる入門用であり、Tsurugi固有の仕様および制限については、Tsurugiのドキュメントを確認してください。

### 基本的なSQL言語

PostgreSQLのSQLコンソール（psql）からSQLコマンドを実行することでTsurugiを利用することができます。  
SQLコンソールからの簡単な利用方法を説明します。  
Tsurugi FDWがサポートするSQLコマンドについては [リファレンス（SQL）](./sql_reference.md) を参照してください。

#### 外部テーブルの作成

CREATE FOREIGN TABLEコマンドを実行して、外部テーブルを作成します。  
Tsuguriのテーブル操作は、この外部テーブルを通して行います。

~~~sql
CREATE FOREIGN TABLE weather (
    id              int,
    city            varchar(80),
    temp_lo         int,           -- 最低気温
    temp_hi         int,           -- 最高気温
    prcp            real,          -- 降水量
    the_date        date default '2023-04-01'
) SERVER tsurugi;
~~~

- 外部テーブルの名前は、Tsurugiのテーブル名と同じ名前を指定してください。
- `SERVER`には、Tsurugi FDWの初期設定で登録した外部サーバ`tsurugi`を指定してください。
- 外部テーブルが不要になった場合は以下のコマンドを使用して削除します。

    ~~~sql
    DROP FOREIGN TABLE table_name;
    ~~~

> [!NOTE]
> PostgreSQL（Tsurugi FDW）からのDDL実行は非サポートとなります。  
> PostgreSQLから操作するTsurugiテーブルはTsurugiのSQLコンソール（tgsql）などを利用して事前に作成する必要があります。  

#### データの挿入

INSERTコマンドを実行して、Tsurugiのテーブルに行を挿入します。

~~~sql
INSERT INTO weather (id, city, temp_lo, temp_hi, prcp)
    VALUES (1, 'San Francisco', 46, 50, 0.25);
~~~

リスト内の列は好きな順番で指定できます。

~~~sql
INSERT INTO weather (temp_lo, temp_hi, prcp, id, city)
    VALUES (43, 57, 0.0, 2, 'San Francisco');
~~~

一部の列を省略することもできます。  
例えば、降水量がわからない場合は以下のようにすることができます。

~~~sql
INSERT INTO weather (id, city, temp_lo, temp_hi)
    VALUES (3, 'Hayward', 54, 37);
~~~

#### データの問い合わせ

SELECTコマンドを実行して、Tsurugiに作成したテーブルのデータを問い合わせることができます。

~~~sql
SELECT * from weather;
~~~

出力は、以下のようになります。

~~~sql
 id |     city      | temp_lo | temp_hi | prcp |  the_date
----+---------------+---------+---------+------+------------
  1 | San Francisco |      46 |      50 | 0.25 | 2023-04-01
  2 | San Francisco |      43 |      57 |    0 | 2023-04-01
  3 | Hayward       |      54 |      37 |      | 2023-04-01
(3 rows)
~~~

#### データの更新と削除

UPDATEコマンドを実行して、Tsurugiのテーブルの既存行を更新することができます。  
例えば、Haywardの全ての気温が2度高くなっていたことがわかったとします。その場合、以下のコマンドによって、データを修正することができます。

~~~sql
UPDATE weather
    SET temp_hi = temp_hi - 2,  temp_lo = temp_lo - 2
    WHERE city = 'Hayward';
~~~

更新後のデータを確認します。

~~~sql
select * from weather ;
 id |     city      | temp_lo | temp_hi | prcp |  the_date
----+---------------+---------+---------+------+------------
  1 | San Francisco |      46 |      50 | 0.25 | 2023-04-01
  2 | San Francisco |      43 |      57 |    0 | 2023-04-01
  3 | Hayward       |      52 |      35 |      | 2023-04-01
(3 rows)
~~~

DELETEコマンドを実行して、Tsurugiのテーブルから行を削除することができます。  
例えば、Haywardの気象を対象としなくなったとします。その場合、以下のコマンドを使用して、テーブルから行を削除することができます。

~~~sql
DELETE FROM weather WHERE city = 'Hayward';
~~~

削除後のテーブルを確認します。

~~~sql
select * from weather ;
 id |     city      | temp_lo | temp_hi | prcp |  the_date
----+---------------+---------+---------+------+------------
  1 | San Francisco |      46 |      50 | 0.25 | 2023-04-01
  2 | San Francisco |      43 |      57 |    0 | 2023-04-01
(2 rows)
~~~

#### トランザクション操作

PostgreSQLからTsurugiのトランザクションを操作する方法を説明します。  
トランザクションの操作方法（自動コミットなど）はPostgreSQLの仕様に準じます。  
詳細は [PostgreSQLのドキュメント](https://www.postgresql.jp/document/12/html/sql-commands.html) を参照してください。

##### 明示的にトランザクションを開始する

BEGINまたはSTART TRANSACTIONコマンドを実行してトランザクションを開始してCOMMITまたはROLLBACKコマンドでトランザクションを終了します。  
明示的にトランザクションを開始した場合は、明示的にトランザクションを終了させる必要があります。  

~~~sql
BEGIN;      --  明示的にトランザクションを開始する

INSERT INTO weather (id, city, temp_lo, temp_hi, prcp)  --  Tsurugiテーブルを操作する
    VALUES (4, 'Los Angeles', 64, 82, 0.0);

COMMIT;     --  トランザクション終了
~~~

##### 暗黙的にトランザクションを開始する

BEGINまたはSTART TRANSACTIONコマンドを省略して暗黙的にトランザクションを開始することができます。  
暗黙的にトランザクションを開始した場合は、トランザクションが暗黙的にコミットされます（自動コミット）。

~~~sql
INSERT INTO weather (id, city, temp_lo, temp_hi, prcp)
    VALUES (7, 'Sacramento', 48, 60, 0.25);  --  暗黙的にトランザクションが開始し、コミットされる（COMMIT文不要）

BEGIN;
UPDATE weather SET temp_hi = temp_hi - 10 WHERE city = 'Sacramento';
ROLLBACK;   --  UPDATE文の更新内容は破棄されるが、直前のINSERT文の更新内容は破棄されない
~~~

#### ステートメントキャッシュの利用

PostgreSQLからTsurugiテーブルに同じSQL文を何度も実行する場合はステートメントキャッシュが便利です。  
ステートメントキャッシュの利用（プリペアド文の作成と実行）方法はPostgreSQLの仕様に準じます。  
詳細は [PostgreSQLのドキュメント](https://www.postgresql.jp/document/12/html/sql-commands.html) を参照してください。  

##### プリペアド文の作成

PREPAREコマンドを実行して、INSERT文のプリペアド文を作成します。

~~~sql
PREPARE add_weather (int, varchar(80), int, int, real, date)
    AS INSERT INTO weather (id, city, temp_lo, temp_hi, prcp, the_date)
            VALUES ($1, $2, $3, $4, $5, $6);
~~~

##### プリペアド文の実行

EXECUTコマンドを実行して、プリペアド文を実行します。

~~~sql
EXECUTE add_weather (8, 'San Diego', 41, 57, 0.25, current_date);
~~~

### Tsurugi固有の機能

#### トランザクション特性の変更

Tsurugi固有のトランザクション特性を変更する方法を説明します。  
詳細は [リファレンス（UDF）](./udf_reference.md) を参照してください。  

Tsurugiのトランザクションは以下の設定がデフォルトで適用されます。  

- トランザクション種別 - **'short'**
- 優先度 - **'default'**
- ラベル名 - **'pgsql-transaction'**

デフォルトのトランザクション特性は`tg_set_transaction`で変更することができます。

~~~sql
SELECT tg_set_transaction('short', 'interrupt');    /*  デフォルトのトランザクション特性を変更する
                                                        （priority = 'interrupt'） */
/*  以降、変更したトランザクション特性が適用される（priority = 'interrupt'）  */
BEGIN;  -- トランザクション開始
INSERT INTO weather (id, city, temp_lo, temp_hi, prcp)
    VALUES (5, 'Oakland', 48, 53, 0.5);
SELECT * FROM weather;
COMMIT;  -- トランザクション終了
~~~

例えば、Longトランザクションを実行するとします。  
トランザクション開始前に`tg_set_transaction`を実行することで（以下の例では`tg_set_write_preserve`で書き込み予約テーブルも設定）デフォルトのトランザクション特性を変更することができます。

~~~sql
SELECT tg_set_transaction('long');      --  Longトランザクションをデフォルトに設定する
SELECT tg_set_write_preserve('weather');    --  書き込みを予約するテーブルを設定する
/*  以降、変更したLongトランザクションが適用される */
BEGIN;  -- トランザクション開始
INSERT INTO weather (id, city, temp_lo, temp_hi)
    VALUES (3, 'Hayward', 37, 54);
UPDATE weather SET temp_hi = temp_hi + 5 WHERE city = 'Oakland';
DELETE FROM weather WHERE id = 2;
SELECT * FROM weather;
COMMIT;  -- トランザクション終了
~~~
