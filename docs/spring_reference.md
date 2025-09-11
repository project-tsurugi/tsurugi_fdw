# [Tsurugi FDW for Tsurugi](./README.md)

## リファレンス（Spring Framework）

Tsurugi FDWがサポートするSpring Frameworkについて説明します。

### サポート対象プロジェクト

Tsurugi FDWは以下のSpring Frameworkプロジェクトをサポートします。  

- [Spring JDBC](https://spring.pleiades.io/spring-framework/docs/current/javadoc-api/)
- [Spring Data JPA](https://spring.pleiades.io/spring-data/jpa/docs/current/api/)
- [Spring Data JDBC](https://spring.pleiades.io/spring-data/relational/docs/current/api/)

Spring Framework（Javaアプリケーション）からデータベース(Tsurugi)へのアクセス方法については、各プロジェクトの仕様に準じます。詳細は各プロジェクトのドキュメントを参照してください。

### 動作確認済みメソッド一覧

Tsurugiの操作に必要な基本的なクラスおよびインターフェースの動作確認済みメソッド一覧を示します。

[DriverManagerDataSourceクラス](#drivermanagerdatasourceクラス---データベース接続情報を管理する)  

#### DriverManagerDataSourceクラス - データベース接続情報を管理する

| メソッド名 | 説明 | 動作確認 |
| :--- | :--- | :---: |
| getConnectionFromDriver(PropertiesSE props) | 指定されたプロパティを使用して接続を取得する | × |
| getConnectionFromDriverManager(StringSE url, PropertiesSE props) | DriverManager から厄介な静的を使用して接続を取得する。protected メソッドに抽出され、簡単な単体テストが可能になる | × |
| setDriverClassName(StringSE driverClassName) | JDBC ドライバーのクラス名を設定する | 〇 |
| getCatalog() | 各 Connection に適用されるデータベースカタログがあれば、それを返す | × |
| getConnection() | この実装は、この DataSource のデフォルトのユーザー名とパスワードを使用して getConnectionFromDriver に委譲する | × |
| getConnection(StringSE username, StringSE password) | この実装は、指定されたユーザー名とパスワードを使用して getConnectionFromDriver に委譲する | × |
| getConnectionFromDriver(StringSE username, StringSE password) | 指定されたユーザー名とパスワード（存在する場合）を含むドライバーのプロパティを構築し、対応する接続を取得する | × |
| getConnectionProperties() | ドライバーに渡される接続プロパティがあれば、それを返す | × |
| getPassword() | ドライバーを介した接続に使用する JDBC パスワードを返す | × |
| getSchema() | 各接続に適用されるデータベーススキーマがあれば、それを返す | × |
| getUrl() | ドライバーを介した接続に使用する JDBC URL を返す | × |
| getUsername() | ドライバーを介した接続に使用する JDBC ユーザー名を返す | × |
| setCatalog(StringSE catalog) | 各接続に適用されるデータベースカタログを指定する | × |
| setConnectionProperties(PropertiesSE connectionProperties) | 任意の接続プロパティをキー / 値のペアとして指定し、ドライバーに渡す | × |
| setPassword(StringSE password) | ドライバーを介した接続に使用する JDBC パスワードを設定する | 〇 |
| setSchema(StringSE schema) | 各接続に適用されるデータベーススキーマを指定する | × |
| setUrl(StringSE url) | ドライバーを介した接続に使用する JDBC URL を設定する | 〇 |
| setUsername(StringSE username) | ドライバーを介した接続に使用する JDBC ユーザー名を設定する | 〇 |
