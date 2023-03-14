# tsurugiトランザクション管理機能

2023.03.15 NEC  

## 1. 概要

PostgreSQLからTsurugiのトランザクション（tsurugiトランザクション）を制御するインタフェースについて記述する。PostgreSQLのトランザクションとの関係についても記す。

## 2. tsurugiトランザクションの概要

tsurugiのトランザクションには以下の５つのトランザクション特性がある。  
それぞれの特性について概要を説明する。

- トランザクション種別
- トランザクション優先度
- トランザクションラベル
- 書き込み予約テーブル ※longトランザクションのみ
- 読み込み制限テーブル ※将来実装される予定の特性（本ドキュメントでは省略）

### トランザクション種別

tsurugiトランザクションの種別を表す。トランザクションの用途によって適した種別を指定する必要がある。  
tsurugiトランザクションには以下のトランザクション種別が用意されている。

- `short` - アドホックな比較的短い処理時間が想定されるトランザクション（optimistic concurrency control）
- `long` - バッチ処理など比較的長い処理時間が想定されるトランザクション（pessmisic concurrency control）
- `read only` - 読み取りのみのトランザクション

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
デフォルトでは'pgsql-transaction'とする。

### 書き込み予約テーブル

longトランザクションにおいてデータの挿入／更新／削除などを可能とするテーブル。longトランザクションでは、事前に書き込み予約テーブルを設定しておく必要がある。

## 3. PostgreSQLからTsurugiのトランザクションを利用する方法

### 3-1. 明示的にトランザクションブロックを開始する

tsurugiトランザクションを開始する前に`tg_set_transaction`でデフォルトのトランザクション特性を設定しておく。
次に`tg_start_transaction`でトランザクションを開始し、`tg_commit`でトランザクションを終了する。

```sql
SELECT tg_set_transaction('short');  -- デフォルトのトランザクション特性を設定する

SELECT tg_start_transaction();  -- 明示的にトランザクションを開始する
INSERT INTO tg_table VALUES (...);  -- tg_table: tsurugiテーブル（外部テーブル）
SELECT ... FROM tg_table WHERE ...;
SELECT tg_commit();  -- トランザクション終了
```

特定のトランザクションについてデフォルトのトランザクション特性を変更して実行したい場合は、`tg_start_transaction`にパラメータを設定することで実現できる。ここで設定したトランザクション特性は該当トランザクションのみで有効になり、**デフォルトのトランザクション特性は更新されない**。

```sql
SELECT tg_set_transaction('short');  -- デフォルトのトランザクション特性を設定する(short)

SELECT tg_start_transaction('read_only', 'wait', 'read_only_tx');  -- このトランザクションでのみ有効な特性値
SELECT ... FROM tg_table WHERE ...;
SELECT tg_commit();  -- トランザクション終了

INSERT INTO tg_table VALUES (...);  -- デフォルト設定のshortトランザクションが暗黙的に開始される
SELECT tg_commit();  -- トランザクション終了
```

### 3-2 暗黙的にトランザクションを開始する

`tg_start_transaction`を省略して暗黙的にトランザクションを開始することもできる。  
~~トランザクションの終了（`tg_commit`や`tg_rollback`）は必須である。~~  
この場合は、トランザクションが暗黙的にコミットされる（auto-commit）。

```sql
SELECT tg_set_transaction('short');

INSERT INTO tg_table VALUES (...);  -- 暗黙的にトランザクションが開始し、コミットされる（COMMIT文不要）

SELECT ... FROM tg_table;  -- INSERT文による更新が反映される
```

### 3-3. longトランザクションを実行する

longトランザクションを開始するためには事前に`tg_set_transaction`でlongトランザクションをデフォルトに設定し、`tg_set_write_preserve`で書き込みを予約するテーブル名を設定する。

```sql
SELECT tg_set_transaction('long');  -- longトランザクションをデフォルトに設定する
SELECT tg_set_write_preserve('tg_table');  -- 書き込み予約するテーブルを設定する（複数可）

SELECT tg_start_transaction();  -- 省略可能
INSERT INTO tg_table VALUES (...);
...
SELECT ... FROM tg_table WHERE ...;
SELECT tg_commit();  -- トランザクション終了
```

### 3-4. PostgreSQLのトランザクションとの関係

PostgreSQLとTsurugiのトランザクションは別々に管理され、相互に影響を与えない。

```sql
SELECT tg_start_transaction();  -- tsurugiトランザクションを開始する
UPDATE tg_table SET ... WHERE ...;  -- tsurugiテーブル(tg_table)を更新する

    BEGIN;  -- PostgreSQLのトランザクションを開始する
    UPDATE pg_table SET ... WHERE ...;  -- PostgreSQLテーブル(pg_table)を更新する

SELECT tg_rollback();  /* tsurugiトランザクションをアボートして終了する。
                          tsurugiテーブル(tg_table)の更新内容は破棄されるが、
                          PostgreSQLテーブル(pg_table)の更新内容は破棄されない。 */

    COMMIT;             -- PostgreSQLのトランザクション終了（更新内容を永続化する）
```

### 3-5. PostgreSQLのテーブルと連携したクエリーのトランザクション

tsurugiテーブルのデータを検索した結果をPostgreSQLのテーブルに挿入することができる。

```sql
INSERT INTO pg_table SELECT ... FROM tg_table;  -- tsurugiテーブルのデータをPostgreSQLのテーブルに挿入する
SELECT tg_commit();
```

PostgreSQLとTsurugiのトランザクションは別々に管理されるため、コミット前のtsurugiテーブルのデータを参照していないか注意する必要がある。

```sql
SELECT tg_start_transaction();  -- tsurugiトランザクションを開始する
UPDATE tg_table SET ... WHERE ...;  -- tsurugiテーブル(tg_table)を更新する

    BEGIN;  -- PostgreSQLのトランザクションを開始する
    INSERT INTO pg_table SELECT ... FROM tg_table;  /* コミット前のtsurugiテーブルのデータを
                                                       PostgreSQLのテーブルに挿入する！      */

SELECT tg_rollback();  /* tsurugiトランザクションをアボートして終了する。
                          tsurugiテーブル(tg_table)の更新内容は破棄されるが、
                          PostgreSQLテーブル(pg_table)の更新内容は破棄されない！ */

    COMMIT;            -- PostgreSQLのトランザクション終了（更新内容を永続化する）
```

## 4. リファレンス

### Tsurugiトランザクション制御関数

- [tg_commit](commands/tg_commit.md) - 現在のトランザクションをコミットする
- [tg_rollback](commands/tg_rollback.md) - 現在のトランザクションをアボートする
- [tg_set_transaction](commands/tg_set_transaction.md) - デフォルトのトランザクション特性を設定する
- [tg_set_write_preserve](commands/tg_set_write_preserve.md) - longトランザクションにおける書き込み予約テーブルを設定する
- [tg_show_transaction](commands/tg_show_transaction.md) - デフォルトのトランザクション特性の値を表示する
- [tg_start_transaction](commands/tg_start_transaction.md) - 新しいトランザクションブロックを開始する

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
