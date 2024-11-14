# [Tsurugi FDW for Tsurugi](./tsurugi_fdw.md)

## リファレンス（JDBC API）

Tsurugi FDWがサポートするJDBC APIについて説明します。

JDBC APIの仕様はPostgreSQL JDBCドライバの要件（Java 8以降のJDBC 4.2バージョン）に準じます。
詳細は JDBC API（ [java.sql パッケージ](https://docs.oracle.com/javase/jp/8/docs/api/java/sql/package-summary.html) および [javax.sql パッケージ](https://docs.oracle.com/javase/jp/8/docs/api/javax/sql/package-summary.html) ）のドキュメントを参照してください。

### JDBC API一覧

#### DriverManagerクラス - JDBCドライバを管理する

| メソッド名 | 説明 | サポート |
| :--- | :--- | :---: |
| deregisterDriver(Driver driver) | DriverManagerの登録済ドライバ・リストから指定されたドライバを削除する | × |
| getConnection(String url) | 指定されたデータベースのURLへの接続を試みる | 〇 |
| getConnection(String url, Properties info) | 指定されたデータベースのURLへの接続を試みる | 〇 |
| getConnection(String url, String user, String password) | 指定されたデータベースのURLへの接続を試みる | 〇 |
| getDriver(String url) | 指定されたURLを認識するドライバを獲得する | × |
| getDrivers() | 現在の呼出し元がアクセスしている、現在ロードされているすべてのJDBCドライバの列挙を取得する | × |
| getLoginTimeout() | データベースにログインしているときに、ドライバが待つことのできる最長の時間を秒数で取得する | × |
| getLogStream() | 非推奨。 getLogWriterを使用してください | × |
| getLogWriter() | ログ・ライターを取得する | × |
| println(String message) | 現在のJDBCログ・ストリームにメッセージを印刷する | × |
| registerDriver(Driver driver) | 指定されたドライバをDriverManagerに登録する | × |
| registerDriver(Driver driver, DriverAction da) | 指定されたドライバをDriverManagerに登録する | × |
| setLoginTimeout(int seconds) | 識別された後のドライバがデータベースに接続しようとするときの最大待機時間(秒単位)を設定する | × |
| setLogStream(PrintStream out) | 非推奨。setLogWriterを使用してください | × |
| setLogWriter(PrintWriter out) | DriverManagerおよびすべてのドライバが使用する、ログおよびトレースのPrintWriterオブジェクトを設定する | × |

#### Connectionインタフェース - 文を作成し接続とそのプロパティを管理する

| メソッド名 | 説明 | サポート |
| :--- | :--- | :---: |

#### Statementインターフェース - 基本SQL文を送信する

| メソッド名 | 説明 | サポート |
| :--- | :--- | :---: |

#### PreparedStatement - 準備済み文または基本SQL文を送信する

| メソッド名 | 説明 | サポート |
| :--- | :--- | :---: |

#### ResultSetインタフェース - データベースの結果セットを取得更新する

| メソッド名 | 説明 | サポート |
| :--- | :--- | :---: |

#### Dateクラス -- SQLのDATE型をマッピングする

| メソッド名 | 説明 | サポート |
| :--- | :--- | :---: |

#### Timeクラス -- SQLのTIME型をマッピングする

| メソッド名 | 説明 | サポート |
| :--- | :--- | :---: |

#### Timestampクラス -- SQLのTIMESTAMP型をマッピングする

| メソッド名 | 説明 | サポート |
| :--- | :--- | :---: |
