# JDBCについて

2023.05.12 okada

## JDBC

JDBC(Java Database Connectivity)は、Javaからリレーショナル・データベースに接続するためのインタフェースを提供するJava標準である。

## PostgreSQLにおけるJDBCの実装方法

JDBCはlibpqやフロントエンド/バックエンドプロトコル（Low-level I/F）を利用して実現されている。

## JDBCからのDB操作

- <https://www.postgresql.jp/document/7.4/html/jdbc-query.html>
- <https://qiita.com/mimitaro/items/7628c86ad8c69dfd3f03>

### JDBCでのSELECT文

SQL 文をデータベースに発行する時には必ず、Statement、または PreparedStatement のインスタンスが必要である。Statement または PreparedStatement のインスタンスがあれば問い合わせを発行できる。

- executeQueryを使用した例

    ```java
    Statement st = db.createStatement();
    ResultSet rs = st.executeQuery("SELECT * FROM mytable WHERE columnfoo = 500");

    while (rs.next()) {
        System.out.print("Column 1 returned ");
        System.out.println(rs.getString(1));
    }
    rs.close();
    st.close();
    ```

- prepareStatementを使用した例（想定する一般的な使い方）

    ```java
    int foovalue = 500;
    PreparedStatement st = db.prepareStatement("SELECT * FROM mytable WHERE columnfoo = ?");
    st.setInt(1, foovalue);
    ResultSet rs = st.executeQuery();

    while (rs.next()) {
        System.out.print("Column 1 returned ");
        System.out.println(rs.getString(1));
    }
    rs.close();
    st.close();
    ```
    `Connection.prepareStatement()`でTsurugiに対してStatementをprepareできるようにする。


### JDBCでのINSERT/DELETE/UPDATE文

データを変更（INSERT、UPDATE、DELETEを実行）するには、executeUpdate() メソッドを使用する。 

- 簡単なINSERT文

    ```java
    //INSERT文の実行
    sql = "INSERT INTO jdbc_test VALUES (1, 'AAA')";
    stmt.executeUpdate(sql);
    conn.commit();
    ```

- PreparedStatementを使用した行の削除

    ```java
    int foovalue = 500;
    PreparedStatement st = db.prepareStatement("DELETE FROM mytable WHERE columnfoo = ?");
    st.setInt(1, foovalue);
    int rowsDeleted = st.executeUpdate();
    System.out.println(rowsDeleted + " rows deleted");
    st.close();    
    ```

- 少し本格的な例

    <https://itsakura.com/java-postgresql-insert>

    ```java
    package test1;
    import java.sql.Connection;
    import java.sql.DriverManager;
    import java.sql.PreparedStatement;

    public class Test1 {
        public static void main(String[] args) {

            final String URL = "jdbc:postgresql://127.0.0.1:5432/testdb10";
            final String USER = "postgres";
            final String PASS = "test1";
            final String SQL = "insert into syain(id, name, romaji) VALUES (?, ?, ?)";
            
            try (Connection conn = 
                    DriverManager.getConnection(URL, USER, PASS)){

                conn.setAutoCommit(false);
                
                try (PreparedStatement ps = conn.prepareStatement(SQL)) {
                    ps.setInt(1,4);
                    ps.setString(2,"竹田");
                    ps.setString(3,"takeda");
                    
                    ps.executeUpdate();
                    conn.commit();
                } catch (Exception e) {
                    conn.rollback();
                    System.out.println("rollback");
                    throw e;
                }
            } catch (Exception e) {
                e.printStackTrace();
            } finally {
                System.out.println("処理が完了しました");
            }
        }
    }

    ```

### JDBCでのデータベースオブジェクトの作成と変更（DDL）

テーブルやビューなどのデータベースオブジェクトを作成、変更、削除するには、execute() メソッドを使用する。

- JDBCでのテーブル削除の例

    ```java
    Statement st = db.createStatement();
    st.execute("DROP TABLE mytable");
    st.close();
    ```

## JDBCでのトランザクション制御

<https://qiita.com/white_tiger/items/2868a44aec6add385e04>

> JBDCのデフォルトでは、SQLが一つ送信されるたびに自動的にコミットされるオートコミットモードになっています。

#### トランザクション実行例 #1

auto-commitをオフにして暗黙的にトランザクションブロックを開始する。  
`Connection.start_transaction()`のようなコマンドはなさそう（PL/pgSQLと同じ）。

<https://stackoverflow.com/questions/4940648/how-to-start-a-transaction-in-jdbc>

```java
try
{
  con.setAutoCommit(false);

   //1 or more queries or updates

   con.commit();
}
catch(Exception e)
{
   con.rollback();
}
finally
{
   con.close();
}
```

この方法が主流っぽい。

- <https://kanda-it-school-kensyu.com/java-jdbc-contents/jj_ch03/jj_0301/>
- <https://software.fujitsu.com/jp/manual/manualfiles/m140019/j2ul1757/04z200/j1757-a-09-00.html>

#### トランザクション実行例 #2

トランザクションコマンドをSQLとして実行する。

```java
 try (Statement statement = conn.createStatement()) {
      statement.execute("BEGIN");
      try {
        // use statement ...
        statement.execute("COMMIT");
      }
      catch (SQLException failure) {
        statement.execute("ROLLBACK");
      }
  }
  ```

ちょっとイケてない。

### JDBCからのTsurugiトランザクションの制御

現状はPostgreSQLのトランザクションとTsurugiのトランザクションは別々に制御される。そのためJDBCにおける`Connection::commit()`や`Connection::rollback()`はPostgreSQLのトランザクションに対するコマンドになる。

JDBCからTsurugiのトランザクションを制御するためにはSQLコマンドとしてトランザクションコマンドを実行する必要がある。

```java
 try (Statement statement = conn.createStatement()) {
      statement.execute("SELECT tg_start_transaction()");
      try {
        // use statement ...
        statement.execute("SELECT tg_commit()");
      }
      catch (SQLException failure) {
        statement.execute("SELECT tg_rollback()");
      }
  }
```

別途auto-commitをオフにするコマンドの追加は検討する。

- JDBC

    ```java
    Connection.setAutoCommit(false);
    ```

- psql

    ```sql
    postgres=# \set AUTOCOMMIT off

    postgres=# \echo :AUTOCOMMIT
    off
    ```

- frontend（案）

    ```sql
    SELECT tg_auto_commit('off');
    SELECT tg_auto_commit('false');
    SELECT tg_auto_commit(0);
    ```



以上
