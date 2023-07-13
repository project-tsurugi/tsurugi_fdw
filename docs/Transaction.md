# Tsurugiトランザクション管理機能

2023.06.30 NEC  

## 1. 概要

PostgreSQLからTsurugiのトランザクション（Tsurugiトランザクション）を制御するインタフェースについて記述する。PostgreSQLのトランザクションとの関係についても記す。

## 2. Tsurugiトランザクションの概要

Tsurugiのトランザクションには以下の５つのトランザクション特性がある。  
それぞれの特性について概要を説明する。

- トランザクション種別
- トランザクション優先度
- トランザクションラベル
- 書き込み予約テーブル ※ロングトランザクションのみ
- 読み込み制限テーブル ※将来実装予定（本ドキュメントでは省略）

### トランザクション種別

Tsurugiトランザクションの種別を表す。トランザクションの用途によって適した種別を指定する必要がある。
Tsurugiトランザクションには以下のトランザクション種別が用意されている。

- `short`

    Tsurugiにおいて`Short Transaction`と位置付けられているトランザクション（optimistic concurrency control）。比較的短時間で完了するトランザクションを想定している。

- `long`

    Tsurugiにおいて`Long Transaction`と位置付けられているトランザクション（pessmisic concurrency control）。バッチ処理など比較的長い処理時間がかかるトランザクションを想定している。

- `read only`

    読み取りのみのトランザクション。

デフォルトでは`short`が選択される。

### トランザクション優先度

トランザクションの実行優先度を指定する。

- `default` - デフォルトの優先度
- `interrupt` - 実行中の他のトランザクションを直ちに中断させる
- `wait` - 実行中のトランザクションの完了を待ち、新たなトランザクションの開始を防ぐ
- `interrupt exclude` - 実行中の他のトランザクションを直ちに中断させ、それらのトランザクションが完了するまでロックアウトを保持する
- `wait exclude` - 実行中のトランザクションの完了を待ち、新たなトランザクションの開始を防ぎ、それらのトランザクションが完了するまでロックアウトを保持する

### トランザクションラベル

それぞれのトランザクションにつける名前。  
デフォルトでは'pgsql-transaction'が設定される。

### 書き込み予約テーブル

ロングトランザクションにおいてデータの挿入／更新／削除などを可能とするテーブル。ロングトランザクションでは、事前に書き込み予約テーブルを設定しておく必要がある。

## 3. PostgreSQLからTsurugiのトランザクションを利用する方法

### 3-1. 明示的にトランザクションブロックを開始する

`tg_start_transaction`でトランザクションを開始し`tg_commit`でトランザクションを終了する。明示的にトランザクションブロックを開始した場合は、明示的にトランザクションブロックを終了させる必要がある。

```sql
SELECT tg_start_transaction();          --  明示的にトランザクションを開始する

--  Tsurugiテーブル（tg_table）を操作する
INSERT INTO tg_table VALUES (...);      
UPDATE tg_table SET ... WHERE ...;
DELETE FROM tg_table WHERE ...;
SELECT ... FROM tg_table WHERE ...;

SELECT tg_commit();                     --  トランザクション終了
```

デフォルトのトランザクション特性を変更したい場合は`tg_set_transaction`で変更する。

```sql
SELECT tg_set_transaction('short', 'interrupt');    /*  デフォルトのトランザクション特性を変更する
                                                        （priority = 'interrupt'） */

SELECT tg_start_transaction();                      /*  変更されたトランザクション特性が適用される
                                                        （priority = 'interrupt'）  */
INSERT INTO tg_table VALUES (...);
SELECT ... FROM tg_table WHERE ...;

SELECT tg_commit();                                 -- トランザクション終了
```

特定のトランザクションブロックのみトランザクション特性を変更したい場合は、`tg_start_transaction`にパラメータを設定する。ここで設定したトランザクション特性は該当トランザクションブロックのみで有効になり、**デフォルトのトランザクション特性および`tg_set_transaction`で設定されたトランザクション特性は更新されない**。

```sql
SELECT tg_start_transaction('read_only', 'wait', 'read_only_tx');   --  このトランザクションブロックのみで有効
SELECT ... FROM tg_table WHERE ...;
SELECT tg_commit();                 --  トランザクション終了

SELECT tg_start_transaction();      /*  デフォルトの（またはtg_set_transactionで設定された）トランザクション
                                        特性が適用される  */
INSERT INTO tg_table VALUES (...); 
SELECT tg_commit();                 --  トランザクション終了
```

### 3-2 暗黙的にトランザクションを開始する

`tg_start_transaction`を省略して暗黙的にトランザクションを開始することができる。  
~~トランザクションの終了（`tg_commit`や`tg_rollback`）は必須である。~~  
この場合はトランザクションが暗黙的にコミットされる（auto-commit）。

```sql
INSERT INTO tg_table VALUES (...);  --  暗黙的にトランザクションが開始し、コミットされる（COMMIT文不要）

SELECT tg_start_transaction();
UPDATE tg_table SET ... WHERE ...;
SELECT tg_rollback();   --  UPDATE文の更新内容は破棄されるが、上記のINSERT文の更新内容は破棄されない
```

トランザクションブロックが開始されていない状態でコミットが実行された場合は警告メッセージを表示する。

```sql
INSERT INTO tg_table VALUES (...);              -- auto-commitでトランザクション終了

SELECT tg_commit();
WARNING:  there is no transaction in progress   -- 警告メッセージ（イメージ）
```

### 3-3. ロングトランザクションを実行する

ロングトランザクションを実行するためには、事前に`tg_set_transaction`でデフォルトのトランザクション特性を変更した後に、`tg_set_write_preserve`で書き込みを予約するテーブル名を設定しておく。

```sql
SELECT tg_set_transaction('long');      --  ロングトランザクションをデフォルトに設定する
SELECT tg_set_write_preserve('tg_table1', 'tg_table2');    --  書き込みを予約するテーブルを設定する

SELECT tg_start_transaction();          -- ロングトランザクション開始
INSERT INTO tg_table1 VALUES (...);
UPDATE tg_table2 SET ... WHERE ...;
DELETE FROM tg_table1 WHERE ...;
...
SELECT tg_commit();                     -- ロングトランザクション終了
```

### 3-4. PostgreSQLのトランザクションとの関係

PostgreSQLとTsurugiのトランザクションは別々に管理され相互に影響を与えない。そのため片方のトランザクションの実行に失敗した場合にもう片方のトランザクションにその影響が及ぶことはない。

```sql
BEGIN;                              -- PostgreSQLのトランザクションを開始する
SELECT tg_start_transaction();      -- Tsurugiトランザクションを開始する

-- Tsurugi、PostgreSQLそれぞれのテーブルのデータを操作する
UPDATE tg_table ...;                -- tg_table : Tsurugiテーブル
UPDATE pg_table ...;                -- pg_table : PostgreSQLテーブル

SELECT tg_rollback();               /*  Tsurugiテーブル(tg_table)の更新内容は破棄されるが、
                                        PostgreSQLテーブル(pg_table)の更新内容は破棄されない。 */
COMMIT;                             --  PostgreSQLテーブル(pg_table)の更新内容をコミットする
```

### 3-5. PostgreSQLのテーブルと連携したクエリーのトランザクション

Tsurugiテーブルの検索結果をPostgreSQLのテーブルに挿入することができるが、PostgreSQLとTsurugiのトランザクションは別々に管理されるためコミットのタイミングに気を付ける必要がある。また、PostgreSQLとTsurugiのトランザクションを併用する場合は、トランザクションブロックの開始と終了のタイミングを合わせて使用することを推奨する。

#### NGケース

```sql
BEGIN;
SELECT tg_start_transaction(); 

UPDATE tg_table ...;                            --  Tsurugiテーブル(tg_table)を更新する
INSERT INTO pg_table SELECT ... FROM tg_table;  /*  Tsurugiテーブルの検索結果をPostgreSQLテーブル
                                                    (pg_table)に挿入する */
COMMIT;                                         --  PostgreSQLテーブルの更新内容をコミットする
SELECT tg_rollback();                           /*  Tsurugiテーブル(tg_table)の更新内容は破棄されるが、
                                                    PostgreSQLテーブル(pg_table)の更新内容は破棄されない */
```

#### OKケース

```sql
BEGIN;
SELECT tg_start_transaction();

UPDATE tg_table ...;                            --  Tsurugiテーブル(tg_table)を更新する
INSERT INTO pg_table SELECT ... FROM tg_table;  /*  Tsurugiテーブルの検索結果をPostgreSQLテーブル
                                                    (pg_table)に挿入する */
SELECT tg_commit();                             --  先にTsurugiテーブルの更新内容をコミットする
COMMIT;                                         --  PostgreSQLテーブルの更新内容をコミットする
```

### 3-6. JDBC経由（Javaプログラムから）のトランザクション制御

PostgreSQLとTsurugiのトランザクションは別々に管理されるため、JavaプログラムからJDBC経由でTurugiのトランザクションを制御するには、明示的にTsurugiのトランザクションを開始する必要がある。

- ソースコード（transaction_sample.java）

    ```java
    /* java.sql パッケージをインポート */
    import java.sql.*;

    class transaction_sample {
        public static void main(String[] args) throws Exception {

            /* JDBCドライバの読み込み */
            Class.forName("org.postgresql.Driver");

            /* データベース(PostgreSQL)の接続先 */
            String url = "jdbc:postgresql://localhost:35432/postgres";
            try {

                /* データベース(PostgreSQL)へ接続する */
                Connection conn = DriverManager.getConnection(url);

                /* Statementを使用してTsurugiのトランザクションを制御する */
                Statement st = conn.createStatement();
                /* PreparedStatementを使用してTsurugiのテーブルにデータを挿入する */
                String sql = "INSERT INTO tg_sample (col) VALUES (?)";
                PreparedStatement ps = conn.prepareStatement(sql);

                for (int i=0; i<9; i++) {

                    /* Tsurugiのトランザクションを開始する */
                    st.execute("SELECT tg_start_transaction()");

                    /* Tsurugiのテーブルにデータ(i)を挿入する */
                    ps.setInt(1, i);
                    ps.executeUpdate();

                    /* 挿入した値(i)が偶数か奇数か判定 */
                    if (i % 2 == 0) {
                        /* 偶数の場合：トランザクションをコミットする */
                        st.execute("SELECT tg_commit()");
                    } else {
                        /* 奇数の場合：トランザクションをロールバックする */
                        st.execute("SELECT tg_rollback()");
                    }

                }

                /* 実行結果を確認する */
                ResultSet rs = st.executeQuery("SELECT * FROM tg_sample");
                System.out.println("--- 実行結果：奇数は破棄(ロールバック)される ---");
                while (rs.next()) {
                    System.out.println("  " + rs.getString(1));
                }

                ps.close();
                st.close();
                conn.close();
            } catch (SQLException e) {
                System.out.println("CATCH SQLException e.getMessage = " + e.getMessage());
            }
        }
    }
    ```

- コンパイルと実行

    ```sh
    $ javac transaction_sample.java
    $ java -cp .:./postgresql-42.6.0.jar transaction_sample
    --- 実行結果：奇数は破棄(ロールバック)される ---
      0
      2
      4
      6
      8
    $
    ```

ロングトランザクションで実行する場合は、トランザクション特性と必要に応じて書き込みを予約するテーブル名を設定する必要がある。

### 3-7. ストアドプロシージャ（PL/pgSQL）のトランザクション制御 ※将来実装予定

PostgreSQLとTsurugiのトランザクションは別々に管理されるため、ストアドプロシージャでTurugiのトランザクションを制御するには、明示的にTsurugiのトランザクションを開始する必要がある。
なお、PL/pgSQLでTsurugiトランザクション制御関数を実行する場合は、PERFORM文を使用する必要がある。

```sql
CREATE PROCEDURE transaction_test()  -- 新しいプロシージャを定義する
LANGUAGE plpgsql
AS $$
BEGIN
    FOR i IN 0..9 LOOP
        PERFORM tg_start_transaction();        -- Tsurugiのトランザクションを開始する
        INSERT INTO tg_test (col) VALUES (i);
        IF i % 2 = 0 THEN                      -- 挿入した値(i)が偶数か奇数かの判定
            PERFORM tg_commit();               -- 偶数の場合：トランザクションをコミットする
        ELSE
            PERFORM tg_rollback();             -- 奇数の場合：トランザクションをロールバックする
        END IF;
    END LOOP;
END
$$;

CALL transaction_test();             -- プロシージャを実行する

SELECT * from tg_test;               -- 実行結果を確認する
 col                                           -- コミットされた偶数だけが存在し、
-----                                          -- ロールバックされた奇数は破棄されている。
   0
   2
   4
   6
   8
(5 rows)
```

ストアドプロシージャをロングトランザクションで実行する場合は、プロシージャを実行する前にデフォルトのトランザクション特性と必要に応じて書き込みを予約するテーブル名を設定する必要がある。

```sql
SELECT tg_set_transaction('long');        -- ロングトランザクションをデフォルトに設定する
SELECT tg_set_write_preserve('tg_test');  -- プロシージャで書き込みを予約するテーブルを設定する

CALL transaction_test();                  -- ロングトランザクションでプロシージャを実行する

SELECT tg_set_transaction(...);           -- 必要に応じてトランザクション特性を設定する
```

## 4. リファレンス

### Tsurugiトランザクション制御関数

- [tg_commit](design/Transaction/commands/tg_commit.md) - 現在のトランザクションをコミットする
- [tg_rollback](design/Transaction/commands/tg_rollback.md) - 現在のトランザクションをアボートする
- [tg_set_transaction](design/Transaction/commands/tg_set_transaction.md) - デフォルトのトランザクション特性を設定する
- [tg_set_write_preserve](design/Transaction/commands/tg_set_write_preserve.md) - ロングトランザクションにおける書き込み予約テーブルを設定する
- [tg_show_transaction](design/Transaction/commands/tg_show_transaction.md) - デフォルトのトランザクション特性の値を表示する
- [tg_start_transaction](design/Transaction/commands/tg_start_transaction.md) - 新しいトランザクションブロックを開始する

## 5. 付録

### a. PostgreSQLのauto-commitとTsurugiのauto-commitの違い

#### 例１ 単文クエリーの場合

PostgreSQL、Tsurugi共に暗黙的に開始されたトランザクションは暗黙的にコミットされる。

- PostgreSQL

    ```sql
    tsurugi=# Select * From pt1;
     c1 |     c2
    ----+------------
      1 | one
    (1 row)

    tsurugi=# Insert Into pt1(c1, c2) Values (2, 'two'); -- 暗黙的にトランザクションを開始し、コミットする
    INSERT 0 1

    tsurugi=# Select * From pt1;
     c1 |     c2
    ----+------------
      1 | one
      2 | two
    (2 rows)
    ```

- Tsurugi(tgsql)

    ```sql
    tgsql> Select * From tt1;
    start transaction implicitly. option=[type: SHORT
    label: "tgsql-transaction"
    ]
    Time: 0.85 ms
    [c1: INT4, c2: CHARACTER]
    [1, one       ]
    (1 rows)
    Time: 44.295 ms
    transaction committed implicitly. status=COMMIT_STATUS_UNSPECIFIED
    Time: 0.488 ms

    tgsql> Insert Into tt1(c1, c2) Values (2, 'two');  -- 暗黙的にトランザクションを開始する
    Time: 67.16 ms
    transaction committed implicitly. status=COMMIT_STATUS_UNSPECIFIED  -- 暗黙的にコミットされる
    Time: 0.569 ms

    tgsql> Select * From tt1;
    start transaction implicitly. option=[type: SHORT
    label: "tgsql-transaction"
    ]
    Time: 0.861 ms
    [c1: INT4, c2: CHARACTER]
    [1, one       ]
    [2, two       ]
    (2 rows)
    Time: 46.691 ms
    transaction committed implicitly. status=COMMIT_STATUS_UNSPECIFIED  
    Time: 0.515 ms
    ```

#### 例２ 明示的にトランザクションブロックを開始した場合

PostgreSQLは、明示的にトランザクションブロックが開始された場合は明示的にコミットする必要がある。  
Tsurugi(tgsql)は、明示的にトランザクションブロックを開始した場合でも強制的に暗黙的なコミットが実行される。

- PostgreSQL

    ```sql
    tsurugi=# Start Transaction;  -- 明示的にトランザクションブロックを開始する
    START TRANSACTION

    tsurugi=# Insert Into pt1(c1, c2) Values (3, 'three');
    INSERT 0 1

    tsurugi=# Select * From pt1;
     c1 |     c2
    ----+------------
      1 | one
      2 | two
      3 | three
    (3 rows)

    tsurugi=# Commit;  -- 明示的にトランザクションを終了する
    COMMIT
    ```

- Tsurugi(tgsql)

    ```sql
    tgsql> Start Transaction;  -- 明示的にトランザクションブロックを開始する
    transaction started. option=[]
    Time: 0.747 ms

    tgsql> Insert Into tt1(c1, c2) Values (3, 'three');
    Time: 42.461 ms
    transaction committed implicitly. status=COMMIT_STATUS_UNSPECIFIED  -- 暗黙的にコミットされる
    Time: 0.432 ms

    tgsql> Select * From tt1;
    start transaction implicitly. option=[type: SHORT
    label: "tgsql-transaction"
    ]
    Time: 0.784 ms
    [c1: INT4, c2: CHARACTER]
    [1, one       ]
    [2, two       ]
    [3, three     ]
    (3 rows)
    Time: 46.074 ms
    transaction committed implicitly. status=COMMIT_STATUS_UNSPECIFIED
    Time: 0.578 ms

    tgsql> Commit;
    transaction is not started (line=1, column=1)  -- COMMITがエラーになる
    ```

#### 例３ ROLLBACKした場合

- PostgreSQL

    ```sql
    tsurugi=# Start Transaction;
    START TRANSACTION

    tsurugi=# Delete From pt1 Where c1 = 3;
    DELETE 1

    tsurugi=# Select * From pt1;
     c1 |     c2
    ----+------------
      1 | one
      2 | two
    (2 rows)

    tsurugi=# Rollback;  -- DELETE文による変更を破棄
    ROLLBACK

    tsurugi=# Select * From pt1;  -- DELETE文による変更が破棄されている
     c1 |     c2
    ----+------------
      1 | one
      2 | two
      3 | three
    (3 rows)
    ```

- Tsurugi(tgsql)

    ```sql
    tgsql> Start Transaction;  -- 明示的にトランザクションブロックを開始する
    transaction started. option=[]
    Time: 0.749 ms

    tgsql> Delete From tt1 Where c1 = 3;
    start transaction implicitly. option=[type: SHORT
    label: "tgsql-transaction"
    ]
    Time: 0.857 ms
    Time: 45.716 ms
    transaction committed implicitly. status=COMMIT_STATUS_UNSPECIFIED  -- 暗黙的にコミットされる
    Time: 0.47 ms

    tgsql> Select * From tt1;
    start transaction implicitly. option=[type: SHORT
    label: "tgsql-transaction"
    ]
    Time: 0.795 ms
    [c1: INT4, c2: CHARACTER]
    [1, one       ]
    [2, two       ]
    (2 rows)
    Time: 44.788 ms
    transaction committed implicitly. status=COMMIT_STATUS_UNSPECIFIED
    Time: 0.632 ms

    tgsql> Rollback;
    transaction is not started (line=1, column=1)  -- ROLLBACKがエラーになる

    tgsql> Select * From tt1;  -- DELETE文による変更が破棄されない
    start transaction implicitly. option=[type: SHORT
    label: "tgsql-transaction"
    ]
    Time: 0.703 ms
    [c1: INT4, c2: CHARACTER]
    [1, one       ]
    [2, two       ]
    (2 rows)
    Time: 2.659 ms
    transaction committed implicitly. status=COMMIT_STATUS_UNSPECIFIED
    Time: 0.523 ms
    ```

以上
