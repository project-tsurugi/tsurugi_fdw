# [Tsurugi FDW for Tsurugi](./tsurugi_fdw.md)

## チュートリアル

PostgreSQLレイヤーからTsurugiを利用する簡単な操作方法を説明します。  
このチュートリアルは単なる入門用であり、Tsurugi固有の仕様および制限については、Tsurugiのドキュメントを確認してください。

### 基本的なSQL言語

1. テーブルの作成

    1. Tsurugiのテーブル作成

        CREATE TABLEコマンドを実行して、Tsurugiのテーブルを作成します。  
        Tsurugi FDWは、テーブル空間に指定された内容でTsurugiのテーブルかPostgreSQLのテーブルか判断します。

        ~~~ sql
        CREATE TABLE weather (
            id              int primary key,
            city            varchar(80),
            temp_lo         int,           -- 最低気温
            temp_hi         int,           -- 最高気温
            prcp            real,          -- 降水量
            the_date        date default '2023-04-01'
        ) TABLESPACE tsurugi;
        ~~~

        - `TABLESPACE`には、初期設定で定義したテーブル空間`tsurugi`を指定してください。
        - Tsurugiは、標準SQLのデータ型、integer、bigint、real、double precision、char(N)、varchar(N)、date、time、timestampをサポートします。

    1. Tsurugiの外部テーブル作成

        CREATE FOREIGN TABLEコマンドを実行して、Tsurugiの外部テーブルを作成します。  
        Tsuguriの操作は、この外部テーブルを通して行います。

        ~~~ sql
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
        - `SERVER`には、初期設定で登録した外部サーバ`tsurugi`を指定してください。

    1. テーブルの削除

        テーブルが不要になった場合や別のものに作り直したい場合、以下のコマンドを使用して削除します。

        ~~~ sql
        DROP FOREIGN TABLE table_name;
        DROP TABLE table_name;
        ~~~

1. データの挿入

    INSERTコマンドを実行して、Tsurugiのテーブルに行を挿入します。

    ~~~ sql
    INSERT INTO weather (id, city, temp_lo, temp_hi, prcp)
        VALUES (1, 'San Francisco', 46, 50, 0.25);
    ~~~

    - 現行版では、列のリストを明示的に指定する必要があります。

    リスト内の列は好きな順番で指定できます。

    ~~~ sql
    INSERT INTO weather (temp_lo, temp_hi, prcp, id, city)
        VALUES (43, 57, 0.0, 2, 'San Francisco');
    ~~~

    一部の列を省略することもできます。  
    例えば、降水量がわからない場合は以下のようにすることができます。

    ~~~ sql
    INSERT INTO weather (id, city, temp_lo, temp_hi)
        VALUES (3, 'Hayward', 54, 37);
    ~~~

1. データの問い合わせ

    SELECTコマンドを実行して、Tsurugiに作成したテーブルのデータを問い合わせることができます。

    ~~~ sql
    SELECT * from weather ;
    ~~~

    出力は、以下のようになります。

    ~~~ sql
     id |     city      | temp_lo | temp_hi | prcp |  the_date
    ----+---------------+---------+---------+------+------------
      1 | San Francisco |      46 |      50 | 0.25 | 2023-04-01
      2 | San Francisco |      43 |      57 |    0 | 2023-04-01
      3 | Hayward       |      54 |      37 |      | 2023-04-01
    (3 rows)
    ~~~

    TsurugiとPostgreSQLのテーブルを同時にアクセスすることもできます。  
    例えば、PostgreSQLに位置情報のテーブルを作成します。

    ~~~ sql
    CREATE TABLE cities (
        name            varchar(80),
        location        point
    );
    INSERT INTO cities VALUES ('San Francisco', '(-194.0, 53.0)');
    INSERT INTO cities VALUES ('Hayward', '(-122.0, 37.0)');
    ~~~

    PostgreSQLに存在する気象データとTsurugiに存在する位置情報のテーブルを結合して問い合わせすることができます。

    ~~~ sql
    SELECT *
        FROM weather INNER JOIN cities ON (weather.city = cities.name) ORDER BY id;
     id |     city      | temp_lo | temp_hi | prcp |  the_date  |     name      | location
    ----+---------------+---------+---------+------+------------+---------------+-----------
      1 | San Francisco |      46 |      50 | 0.25 | 2023-04-01 | San Francisco | (-194,53)
      2 | San Francisco |      43 |      57 |    0 | 2023-04-01 | San Francisco | (-194,53)
      3 | Hayward       |      54 |      37 |      | 2023-04-01 | Hayward       | (-122,37)
    (3 rows)
    ~~~

1. データの更新と削除

    UPDATEコマンドを実行して、Tsurugiのテーブルの既存行を更新することができます。  
    例えば、Haywardの全ての気温が2度高くなっていたことがわかったとします。その場合、以下のコマンドによって、データを修正することができます。

    ~~~ sql
    UPDATE weather
        SET temp_hi = temp_hi - 2,  temp_lo = temp_lo - 2
        WHERE city = 'Hayward';
    ~~~

    更新後のデータを確認します。

    ~~~ sql
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

    ~~~ sql
    DELETE FROM weather WHERE city = 'Hayward';
    ~~~

    削除後のテーブルを確認します。

    ~~~ sql
    select * from weather ;
     id |     city      | temp_lo | temp_hi | prcp |  the_date
    ----+---------------+---------+---------+------+------------
      1 | San Francisco |      46 |      50 | 0.25 | 2023-04-01
      2 | San Francisco |      43 |      57 |    0 | 2023-04-01
    (2 rows)
    ~~~

1. アクセス制御

    PostgreSQLレイヤーからTsurugiテーブルのアクセス権を制御する操作方法を説明します。

    1. データベースロールの作成

        CREATE ROLEコマンドを実行して、アクセス制御を行うデータベースロールを作成します。  

        ~~~ sql
        CREATE ROLE jonathan;
        ~~~

        データベースロールの操作（作成、変更、削除など）は、PostgreSQLに準じます。  
        データベースロールの操作については、[PostgreSQLのマニュアル](https://www.postgresql.jp/document/12/html/sql-commands.html)を参照してください。

    1. アクセス権の付与

        GRANTコマンドを実行して、Tsurugiテーブルへアクセス権を付与することができます。  
        例えば、Tsurugiテーブルに対して問い合わせ権限のみをjonathanへ付与します。

        ~~~ sql
        GRANT SELECT ON weather TO jonathan;    -- Tsurugiテーブルにアクセス権を付与します
        ~~~

        問い合わせ以外の操作（アクセス）は失敗します。

        ~~~ sql
        SET ROLE jonathan;          -- 確認のためカレントのデータベースロールを変更します
        SELECT * from weather;      -- 問い合わせの操作は成功します
         id |     city      | temp_lo | temp_hi | prcp |  the_date  
        ----+---------------+---------+---------+------+------------
          1 | San Francisco |      46 |      50 | 0.25 | 2023-04-01
          2 | San Francisco |      43 |      57 |    0 | 2023-04-01
        (2 rows)
        DELETE FROM weather WHERE city = 'San Francisco'; -- 問い合わせ以外の操作は失敗します
        ERROR:  permission denied for foreign table weather
        RESET ROLE;                 -- 現在のデータベースロールを元に戻します
        ~~~

        アクセス権の操作（付与、剥奪など）は、PostgreSQLに準じます。  
        アクセス権の操作については、[PostgreSQLのマニュアル](https://www.postgresql.jp/document/12/html/sql-commands.html)を参照してください。

1. インデックス

    PostgreSQLからレイヤーからTsurugiのインデックスを制御する操作方法を説明します。  

   1. Tsurugiのインデックス

        Tsurugiのインデックスは、以下のインデックス特性があります。  

        - インデックス種別  
            異なる種類の問い合わせに応じた種別を指定します。デフォルトは`mass-tree`です。

        詳細は、Tsurugiのドキュメントを参照してください。

   1. インデックスの定義

        CREATE INDEXコマンドを実行して、Tsurugiテーブルの指定した列（複数可）に対するインデックスを作成します。

        例えば、以下のテーブルに対して以下のような問い合わせを頻繁に実行するとします。

        ~~~ sql
        CREATE TABLE test2 (
            major int,
            minor int,
            name varchar
        ) TABLESPACE tsurugi;

        SELECT name FROM test2 WHERE major = constant AND minor = constant;
        ~~~

        このような場合、majorおよびminorという２つの列に1つのインデックスを定義する方が適切な場合があります。

        ~~~ sql
        CREATE INDEX test2_mm_idx ON test2 (major, minor) TABLESPACE tsurugi;
        ~~~

        - `TABLESPACE`には、初期設定で定義したテーブル空間`tsurugi`を指定してください。

   1. 一意インデックスの定義

        インデックスは、列値の一意性や、複数列を組み合わせた値の一意性を強制するためにも使用できます。

        ~~~ sql
        CREATE UNIQUE INDEX name ON table (column [, ...]) TABLESPACE tsurugi;
        ~~~

        - `TABLESPACE`には、初期設定で定義したテーブル空間`tsurugi`を指定してください。
        - Tsurugi FDWでは、テーブルに一意性制約または主キーが定義されると、自動的に一意インデックスを作成します。

1. プリペアドステートメント

    PostgreSQLからレイヤーからTsurugiテーブルに同じSQL文を何度も実行する場合、プリペアドステートメントが便利です。

    1. プリペアド文

        PREPAREコマンドを実行して、INSERT文のプリペアド文を作成します。

        ~~~sql
        PREPARE add_weather (int, varchar(80), int, int, real, date)
            AS INSERT INTO weather (id, city, temp_lo, temp_hi, prcp, the_date)
                    VALUES ($1, $2, $3, $4, $5, $6);
        ~~~

        EXECUTコマンドを実行して、プリペアド文を実行します。

        ~~~sql
        EXECUTE add_weather (8, 'San Diego', 41, 57, 0.25, current_date);
        ~~~

    2. PreparedStatement（java.sql.PreparedStatement）

        Tsurugiテーブルへのプリペアドステートメントは、[外部プロジェクト](https://jdbc.postgresql.org/)から提供されているJDBCドライバを使用することで、JavaのPreparedStatementを利用することができます。

        サンプルプログラムのソースコードは以下となります。

        ~~~java
        /* java.sql パッケージをインポート */
        import java.sql.*;
        import java.time.*;

        class transaction_sample {
            public static void main(String[] args) throws Exception {

                /* JDBCドライバの読み込み */
                Class.forName("org.postgresql.Driver");

                /* データベース(PostgreSQL)の接続先 */
                String url = "jdbc:postgresql://localhost:5432/postgres";
                try {

                    /* データベース(PostgreSQL)へ接続する */
                    Connection conn = DriverManager.getConnection(url);

                    /* Statementを使用してTsurugiのトランザクションを制御する */
                    Statement st = conn.createStatement();

                    /* PreparedStatementを使用してTsurugiのテーブルにデータを挿入する */
                    String sql = "INSERT INTO tg_sample (col, tm) VALUES (?, ?)";
                    PreparedStatement ps = conn.prepareStatement(sql);

                    System.out.print("実行中 ");
                    for (int i=0; i<9; i++) {

                        /* Tsurugiのトランザクションを開始する */
                        st.execute("SELECT tg_start_transaction()");

                        /* Tsurugiのテーブルにデータ(i)を挿入する */
                        ps.setInt(1, i);
                        /* Tsurugiのテーブルに現在時間を挿入する */
                        ps.setTime(2, Time.valueOf(LocalTime.now()));
                        ps.executeUpdate();

                        /* 挿入した値(i)が偶数か奇数か判定 */
                        if (i % 2 == 0) {
                            /* 偶数の場合：トランザクションをコミットする */
                            st.execute("SELECT tg_commit()");
                        } else {
                            /* 奇数の場合：トランザクションをロールバックする */
                            st.execute("SELECT tg_rollback()");
                        }

                        System.out.print(".");
                        Thread.sleep(1000);
                    }

                    /* 実行結果を確認する */
                    ResultSet rs = st.executeQuery("SELECT * FROM tg_sample");
                    System.out.println("--- 実行結果：奇数は破棄(ロールバック)される ---");
                    while (rs.next()) {
                        System.out.println("  " + rs.getString(1) + ",  " + 
                                                  rs.getString(2));
                    }

                    ps.close();
                    st.close();
                    conn.close();
                } catch (SQLException e) {
                    System.out.println("CATCH SQLException e.getMessage = " + e.getMessage());
                }
            }
        }
        ~~~

### Tsurugi固有の機能

1. トランザクション

    PostgreSQLのレイヤーからTsurugiのトランザクションを制御する操作方法を説明します。  

   1. 明示的にトランザクションブロックを開始する

        `tg_start_transaction`でトランザクションを開始し`tg_commit`でトランザクションを終了します。
        明示的にトランザクションブロックを開始した場合は、明示的にトランザクションブロックを終了させる必要があります。  

        ~~~sql
        SELECT tg_start_transaction();      --  明示的にトランザクションを開始する

        INSERT INTO weather (id, city, temp_lo, temp_hi, prcp)  --  Tsurugiテーブルを操作する
            VALUES (4, 'Los Angeles', 64, 82, 0.0);

        SELECT tg_commit();     --  トランザクション終了
        ~~~

        デフォルトのトランザクション特性を変更したい場合は`tg_set_transaction`で変更します。

        ~~~sql
        SELECT tg_set_transaction('short', 'interrupt');    /*  デフォルトのトランザクション特性を変更する
                                                                （priority = 'interrupt'） */

        SELECT tg_start_transaction();  /*  変更されたトランザクション特性が適用される
                                            （priority = 'interrupt'）  */
        INSERT INTO weather (id, city, temp_lo, temp_hi, prcp)
            VALUES (5, 'Oakland', 48, 53, 0.5);
        SELECT * FROM weather;

        SELECT tg_commit();  -- トランザクション終了
        ~~~

        特定のトランザクションブロックのみトランザクション特性を変更したい場合は、`tg_start_transaction`にパラメータを設定します。ここで設定したトランザクション特性は、該当トランザクションブロックのみで有効になり、デフォルトのトランザクション特性は更新されないことに注意してください。

        ~~~sql
        SELECT tg_start_transaction('read_only', 'wait', 'read_only_tx');   --  このトランザクションブロックのみで有効
        SELECT * FROM weather;
        SELECT tg_commit();     --  トランザクション終了

        SELECT tg_start_transaction();      --  デフォルトのトランザクション特性が適用される
        INSERT INTO weather (id, city, temp_lo, temp_hi, prcp)
            VALUES (6, 'San Jose', 46, 55, 0.0);
        SELECT * FROM weather;
        SELECT tg_commit();     --  トランザクション終了
        ~~~

   1. 暗黙的にトランザクションを開始する

        `tg_start_transaction`を省略して暗黙的にトランザクションを開始することができます。  
        この場合はトランザクションが暗黙的にコミットされます（auto-commit）。

        ~~~sql
        INSERT INTO weather (id, city, temp_lo, temp_hi, prcp)
            VALUES (7, 'Sacramento', 48, 60, 0.25);  --  暗黙的にトランザクションが開始し、コミットされる（COMMIT文不要）

        SELECT tg_start_transaction();
        UPDATE weather SET temp_hi = temp_hi - 10 WHERE city = 'Sacramento';
        SELECT tg_rollback();   --  UPDATE文の更新内容は破棄されるが、上記のINSERT文の更新内容は破棄されない
        ~~~

   1. Longトランザクションを実行する

        Longトランザクションを実行するためには、事前に`tg_set_transaction`でデフォルトのトランザクション特性を変更した後に、`tg_set_write_preserve`で書き込みを予約するテーブル名を設定します。

        ~~~sql
        SELECT tg_set_transaction('long');      --  Longトランザクションをデフォルトに設定する
        SELECT tg_set_write_preserve('weather');    --  書き込みを予約するテーブルを設定する

        SELECT tg_start_transaction();  -- Longトランザクション開始

        INSERT INTO weather (id, city, temp_lo, temp_hi)
            VALUES (3, 'Hayward', 37, 54);
        UPDATE weather SET temp_hi = temp_hi + 5 WHERE city = 'Oakland';
        DELETE FROM weather WHERE id = 2;
        SELECT * FROM weather;

        SELECT tg_commit();             -- Longトランザクション終了
        ~~~
