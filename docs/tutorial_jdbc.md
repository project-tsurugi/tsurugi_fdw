# [Tsurugi FDW for Tsurugi](./README.md)

## チュートリアル

PostgreSQLのユーザインタフェースからTsurugiを利用する簡単な操作方法を説明します。  
このチュートリアルは単なる入門用であり、Tsurugi固有の仕様および制限については、Tsurugiのドキュメントを確認してください。

### Javaアプリケーションからの利用

PostgreSQLのJDBCドライバを使用することでJavaアプリケーションからTsurugiを利用することができます。  
JavaアプリケーションからTsurugiを利用する簡単な方法を説明します。  
Tsurugi FDWがサポートするJDBC APIについては [リファレンス（JDBC API）](./jdbc_reference.md) を参照してください。

#### JDBCドライバの入手

PostgreSQL JDBCドライバのライブラリは [https://jdbc.postgresql.org/download/](https://jdbc.postgresql.org/download/) で公開されています。  
JDBC 4.2 (Java 8以降)バージョンをサポートするライブラリ（jarファイル）をダウンロードしてください。  
Gradleを使用している場合はMaven Central Repositoryから入手することもできます。  

~~~gradle
repositories {
    mavenCentral()
}
dependencies {
    implementation 'org.postgresql:postgresql:42.7.3'
}
~~~

#### データベースへの接続

DriverManagerクラスのgetConnectionメソッドを使用してデータベースに接続することができます。  
接続先データベースは、Tsurugi FDWをインストール（CREATE EXTENTION）したデータベースを指定してください。  

~~~java
String url = "jdbc:postgresql://localhost:5432/postgres";
Connection con = DriverManager.getConnection(url,"uid","pwd");
            ：
con.close();
~~~

#### 外部テーブルの作成（JDBC API）

Tsuguriのテーブルを操作する外部テーブルを作成します。  

> [!NOTE]
> 接続先データベースに対象の外部テーブルが存在する場合は本手順はスキップしてください。  

以下の例では Statementインターフェースのexecuteメソッドを使用して外部テーブルを作成しています。  

~~~java
Statement stmt = con.createStatement();
boolean retval = stmt.execute
                    ("CREATE FOREIGN TABLE IF NOT EXISTS weather (
                        id              int,
                        city            varchar(80),
                        temp_lo         int,           -- 最低気温
                        temp_hi         int,           -- 最高気温
                        prcp            real,          -- 降水量
                        the_date        date default '2023-04-01'
                    ) SERVER tsurugi");
stmt.close();
~~~

> [!NOTE]
> PostgreSQL（Tsurugi FDW）からのDDL実行は非サポートとなります。  
> PostgreSQLから操作するTsurugiテーブルはTsurugiのSQLコンソール（tgsql）などを利用して事前に作成する必要があります。  

#### データの更新（JDBC API）

StatementまたはPreparedStatementインターフェースのexecuteUpdateメソッドを使用してTsurugiテーブルのデータを更新（INSERT/UPDATE/DELETE）することができます。  

~~~java
Statement stmt = con.createStatement();
stmt.executeUpdate("INSERT INTO weather (id, city, temp_lo, temp_hi, prcp)
                        VALUES (1, 'San Francisco', 46, 50, 0.25)");

stmt.executeUpdate("UPDATE weather
                        SET temp_hi = temp_hi - 2,  temp_lo = temp_lo - 2
                        WHERE city = 'Hayward'");

stmt.executeUpdate("DELETE FROM weather WHERE city = 'Hayward'");
stmt.close();
~~~

#### データの問い合わせ（JDBC API）

StatementまたはPreparedStatementインターフェースのexecuteQueryメソッドを使用してTsurugiテーブルのデータを問い合わせ（SELECT）ることができます。  
問い合わせた結果は、ResultSetインターフェースのデータ型に応じたgetメソッドを使用して取得するができます。  

~~~java
Statement stmt = con.createStatement();
ResultSet rs = stmt.executeQuery("SELECT * from weather");
while (rs.next()) {
    System.out.print("  id = " + rs.getInt(1));
    System.out.print(", city = " + rs.getString(2));
    System.out.print(", temp_lo = " + rs.getInt(3));
    System.out.print(", temp_hi = " + rs.getInt(4));
    System.out.print(", prcp = " + rs.getFloat(5));
    System.out.println(", the_date = " + rs.getDate(6));
}
rs.close();
stmt.close();
~~~

#### トランザクション操作（JDBC API）

JavaアプリケーションからTsurugiのトランザクションを操作する方法を説明します。  
トランザクションの操作方法（自動コミットなど）はJDBC APIの仕様に準じます。  
詳細は [JDBC APIのドキュメント](https://docs.oracle.com/javase/jp/8/docs/api/java/sql/package-summary.html) を参照してください。  

##### 自動コミットモードを無効にする

Javaアプリケーションからのトランザクション操作は接続に対して行います。  
データベースに接続した直後は自動コミットが有効になっているので、Tsurugiのトランザクションを操作する場合はConnectionインターフェースのsetAutoCommitメソッドを使用して自動コミットを無効にする必要があります。  

~~~java
String url = "jdbc:postgresql://localhost:5432/postgres";
Connection con = DriverManager.getConnection(url);
Statement stmt = con.createStatement();
/* 接続直後は自動コミットが有効 */
stmt.executeUpdate("INSERT INTO weather (id, city, temp_lo, temp_hi, prcp)
                        VALUES (1, 'San Francisco', 46, 50, 0.25)");
/* 自動コミットを無効にする */
con.setAutoCommit(false);
stmt.executeUpdate("UPDATE weather
                        SET temp_hi = temp_hi - 2,  temp_lo = temp_lo - 2
                        WHERE city = 'Hayward'");
con.rollback();
/* UPDATE文の更新は破棄されるが、直前のINSERT文の更新は自動コミットにより破棄されない */
stmt.close();
con.close();
~~~

#### ステートメントキャッシュの利用（JDBC API）

JavaアプリケーションからTsurugiテーブルに同じSQL文を何度も実行する場合はステートメントキャッシュが便利です。  
ステートメントキャッシュ（PreparedStatementインターフェース）の利用方法はJDBC APIの仕様に準じます。  
詳細は [JDBC APIのドキュメント](https://docs.oracle.com/javase/jp/8/docs/api/java/sql/package-summary.html) を参照してください。  

~~~java
/* PreparedStatementインターフェースのオブジェクト（何度も実行するSQL文）を生成する */
String sql = "INSERT INTO weather (id, temp_lo, temp_hi)
                    VALUES (?, ?, ?)");
PreparedStatement pstmt = con.prepareStatement(sql);
/* 繰り返し実行する中でパラメータを設定しキャッシュされたSQL文を実行する */
pstmt.setInt(1, 8);
pstmt.setInt(3, 41);
pstmt.setInt(4, 57);
pstmt.executeUpdate()
stmt.close();
~~~

#### エラー情報の取得

データベース操作中に何らかの異常が発生するとSQLExceptionが通知されます。  
SQLExceptionクラスのgetMessageメソッドを使用してエラー情報を取得することができます。  
エラー情報の取得方法はJDBC APIの仕様に準じます。詳細は [JDBC APIのドキュメント](https://docs.oracle.com/javase/jp/8/docs/api/java/sql/package-summary.html) を参照してください。  
Tsurugi FDWが出力するエラーメッセージについては [リファレンス（メッセージ）](./message_reference.md) を参照してください。

~~~java
try {
    ：
} catch (SQLException e) {
    /* エラーが発生した場合のメッセージを出力する */
    System.out.println("SQLException e.getMessage = " + e.getMessage());
    e.printStackTrace();
}
~~~

#### サンプルプログラム

JavaアプリケーションからTsurugiを利用するサンプルプログラムを示します。

##### サンプルプログラム概要

Tsurugiにある `fdw_sample` テーブルに `0` から `9` までの数値データと現在時刻データを繰り返し挿入（トランザクションを開始）します。  
挿入した数値が偶数の場合はトランザクションをコミットし、奇数の場合はトランザクションをロールバックします。  
最後に `fdw_sample` テーブルのデータを問い合わせます。  

##### 実行結果

~~~log
Please wait 10 seconds...........
RESULT : Even are committed, odd are rolled back.
col,        tm
  0,  17:08:37
  2,  17:08:39
  4,  17:08:41
  6,  17:08:43
  8,  17:08:45
~~~

`fdw_sample` テーブルがTsurugiにない状況で実行した場合は以下のSQLExceptionが通知されます。  

~~~log
Please wait 10 seconds
SQLException e.getMessage = ERROR: Tsurugi::prepare() failed. (13)
        sql:INSERT INTO fdw_sample (col, tm) VALUES (:param_0, :param_1)
Tsurugi Server SYMBOL_ANALYZE_EXCEPTION (SQL-03004: compile failed with error:table_not_found message:"table "fdw_sample" is not found" location:<input>:1:13+10)
~~~

> [!TIP]
> 実行環境（Gradleを使用）については [sample/jdbc-sample/](../sample/jdbc-sample/) を確認してください。  
> `fdw_sample` テーブルは `tgsql` を使用して実行前に`CREATE TABLE` 実行後に`DROP TABLE`しています。  

##### ソースコード

~~~java
package com.tsurugidb.fdw.jdbc.sample;

// 利用するJDBC APIのimport宣言
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.sql.Time;

// 現在時刻を取得するクラスのimport宣言
import java.time.LocalTime;

public class JdbcSample {
    public static void main(String[] args) {
        try {
            /* データベース(PostgreSQL)へ接続する */
            String url = "jdbc:postgresql://localhost:35432/postgres";
            Connection conn = DriverManager.getConnection(url);

            /* この接続の自動コミットモードを無効にする */
            conn.setAutoCommit(false);

            /* 外部テーブルを作成する */
            Statement st = conn.createStatement();
            st.execute(
                        "CREATE FOREIGN TABLE IF NOT EXISTS fdw_sample ("
                            + "col INTEGER NOT NULL,"
                            + "tm TIME"
                            + ") SERVER tsurugi"
                      );

            /* ステートメントキャッシュを利用してTsurugiテーブルにデータを挿入する */
            String sql = "INSERT INTO fdw_sample (col, tm) VALUES (?, ?)";
            PreparedStatement ps = conn.prepareStatement(sql);

            System.out.print("Please wait 10 seconds");
            for (int i=0; i<10; i++) {
                /* colカラムに値(i)を挿入する */
                ps.setInt(1, i);
                /* tmカラムに現在時間を挿入する */
                ps.setTime(2, Time.valueOf(LocalTime.now()));

                /* トランザクション(INSERT文)を開始する */
                ps.executeUpdate();

                /* 挿入した値(i)が偶数か奇数か判定 */
                if (i % 2 == 0) {
                    /* 偶数の場合：トランザクションをコミットする */
                    conn.commit();
                } else {
                    /* 奇数の場合：トランザクションをロールバックする */
                    conn.rollback();
                }

                System.out.print(".");
                try {
                    Thread.sleep(1000);
                } catch (InterruptedException e) {
                    e.printStackTrace();
                    Thread.currentThread().interrupt();
                }
            }
            System.out.println(".");

            /* 実行結果を問い合わせる */
            ResultSet rs = st.executeQuery("SELECT * FROM fdw_sample");
            System.out.println("RESULT : Even are committed, odd are rolled back.");
            System.out.println("col,        tm");
            /* 最初の行から問い合わせ結果を順次出力する */
            while (rs.next()) {
                System.out.println("  " + rs.getString(1) + ",  " + 
                                          rs.getString(2));
            }

            /* オブジェクトをクローズする */
            ps.close();
            st.close();
            conn.close();
        } catch (SQLException e) {
            /* エラーが発生した場合のメッセージを出力する */
            System.out.println("\nSQLException e.getMessage = " + e.getMessage());
        }
    }
}
~~~
