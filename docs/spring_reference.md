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

[DriverManagerDataSourceクラス](#drivermanagerdatasourceクラス) - データベース接続情報を管理する  
[JdbcTemplateクラス](#jdbctemplateクラス) - JDBCの使用を簡素化する  
[TransactionTemplateクラス](#transactiontemplateクラス) - プログラムによるトランザクション管理を簡素化する  


#### DriverManagerDataSourceクラス

[org.springframework.jdbc.datasource](https://spring.pleiades.io/spring-framework/docs/current/javadoc-api/org/springframework/jdbc/datasource/package-summary.html)パッケージにおいてデータベース接続情報を管理する。

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

#### JdbcTemplateクラス

[org.springframework.jdbc.core](https://spring.pleiades.io/spring-framework/docs/current/javadoc-api/org/springframework/jdbc/core/package-summary.html)パッケージにおいてJDBCの使用を簡素化する。

| メソッド名 | 説明 | 動作確認 |
| :--- | :--- | :---: |
| applyStatementSettings(StatementSE stmt) | 指定された JDBC ステートメントを準備し、フェッチサイズ、最大行、クエリタイムアウトなどのステートメント設定を適用する | × |
| batchUpdate(StringSE... sql) | バッチ処理を使用して、単一の JDBC ステートメントで複数の SQL 更新を発行する | × |
| batchUpdate(StringSE sql, CollectionSE\<T> batchArgs, int batchSize, ParameterizedPreparedStatementSetter\<T> pss) | 提供された引数を収集して提供された SQL ステートメントを使用して、複数のバッチを実行する | × |
| batchUpdate(StringSE sql, ListSE\<ObjectSE[]> batchArgs) | 提供された引数のバッチで提供された SQL ステートメントを使用して、バッチを実行する | × |
| batchUpdate(StringSE sql, ListSE\<ObjectSE[]> batchArgs, int[] argTypes) | 提供された引数のバッチで提供された SQL ステートメントを使用して、バッチを実行する | × |
| batchUpdate(StringSE sql, BatchPreparedStatementSetter pss) | 単一の PreparedStatement で複数の更新ステートメントを発行し、バッチ更新と BatchPreparedStatementSetter を使用して値を設定する | × |
| batchUpdate(PreparedStatementCreator psc, BatchPreparedStatementSetter pss, KeyHolder generatedKeyHolder) | 単一の PreparedStatement で複数の更新ステートメントを発行し、バッチ更新と BatchPreparedStatementSetter を使用して値を設定する | × |
| call(CallableStatementCreator csc, ListSE\<SqlParameter> declaredParameters) | CallableStatementCreator を使用して SQL 呼び出しを実行し、SQL および必要なパラメーターを提供する | × |
| createConnectionProxy(ConnectionSE con) | 指定された JDBC 接続用の密接抑制プロキシを作成する | × |
| createResultsMap() | 結果マップとして使用される Map インスタンスを作成する | × |
| execute(StringSE sql) | 単一の SQL 実行（通常は DDL ステートメント）を発行する | 〇 |
| execute(StringSE callString, CallableStatementCallback\<T> action) | JDBC CallableStatement で動作するコールバックアクションとして実装される JDBC データアクセス操作を実行する | × |
| execute(StringSE sql, PreparedStatementCallback\<T> action) | JDBC PreparedStatement で動作するコールバックアクションとして実装される JDBC データアクセス操作を実行する | × |
| execute(CallableStatementCreator csc, CallableStatementCallback\<T> action) | JDBC CallableStatement で動作するコールバックアクションとして実装される JDBC データアクセス操作を実行する | × |
| execute(ConnectionCallback\<T> action) | JDBC 接続で動作するコールバックアクションとして実装される JDBC データアクセス操作を実行する | × |
| execute(PreparedStatementCreator psc, PreparedStatementCallback\<T> action) | JDBC PreparedStatement で動作するコールバックアクションとして実装される JDBC データアクセス操作を実行する | × |
| execute(StatementCallback\<T> action) | JDBC ステートメントで動作するコールバックアクションとして実装される JDBC データアクセス操作を実行する | × |
| extractOutputParameters(CallableStatementSE cs, ListSE\<SqlParameter> parameters) | 完了したストアドプロシージャから出力パラメーターを抽出する | × |
| extractReturnedResults(CallableStatementSE cs, ListSE\<SqlParameter> updateCountParameters, ListSE\<SqlParameter> resultSetParameters, int updateCount) | 完了したストアドプロシージャから返された ResultSets を抽出する | × |
| getColumnMapRowMapper() | 列をキーと値のペアとして読み取るための新しい RowMapper を作成する | × |
| getFetchSize() | この JdbcTemplate に指定されたフェッチサイズを返す | × |
| getMaxRows() | この JdbcTemplate に指定された行の最大数を返す | × |
| getQueryTimeout() | この JdbcTemplate が実行するステートメントのクエリタイムアウト (秒) を返す | × |
| getSingleColumnRowMapper(ClassSE\<T> requiredType) | 単一の列から結果オブジェクトを読み取るための新しい RowMapper を作成する | × |
| handleWarnings(SQLWarningSE warning) | 実際の警告が発生した場合は、SQLWarningException をスローする | × |
| handleWarnings(StatementSE stmt) | 指定された JDBC ステートメントに警告がある場合は、それを処理する | × |
| handleWarnings(StatementSE stmt, SQLExceptionSE ex) | 指定されたステートメントの実行からプライマリ SQLException を伝播する前に、警告を処理する | × |
| isIgnoreWarnings() | SQLWarnings を無視するかどうかを返す | × |
| isResultsMapCaseInsensitive() | CallableStatement を実行すると、パラメーターに大文字と小文字を区別しない名前を使用するマップで結果が返されるかどうかを返す | × |
| isSkipResultsProcessing() | 結果処理をスキップするかどうかを返す | × |
| isSkipUndeclaredResults() | 宣言されていない結果をスキップするかどうかを返す | × |
| newArgPreparedStatementSetter(ObjectSE[] args) | 渡された引数を使用して、新しい引数ベースの PreparedStatementSetter を作成する | × |
| newArgTypePreparedStatementSetter(ObjectSE[] args, int[] argTypes) | 渡された引数と型を使用して、新しい引数型ベースの PreparedStatementSetter を作成する | × |
| processResultSet(ResultSetSE rs, ResultSetSupportingSqlParameter param) | ストアドプロシージャから指定された ResultSet を処理する | × |
| query(StringSE sql, ObjectSE[] args, int[] argTypes, ResultSetExtractor\<T> rse) | 指定された SQL をクエリして、SQL から準備されたステートメントと、クエリにバインドする引数のリストを作成し、ResultSet を ResultSetExtractor で読み取る | × |
| query(StringSE sql, ObjectSE[] args, int[] argTypes, RowCallbackHandler rch) | 指定された SQL にクエリを実行して、SQL から準備されたステートメントとクエリにバインドする引数のリストを作成し、RowCallbackHandler で ResultSet を行ごとに読み取る | × |
| query(StringSE sql, ObjectSE[] args, int[] argTypes, RowMapper\<T> rowMapper) | 指定された SQL をクエリして、SQL から準備されたステートメントとクエリにバインドする引数のリストを作成し、RowMapper を介して各行を結果オブジェクトにマッピングする | × |
| query(StringSE sql, PreparedStatementSetter pss, ResultSetExtractor\<T> rse) | ResultSet を ResultSetExtractor で読み取り、準備済みステートメントを使用して照会する | × |
| query(StringSE sql, PreparedStatementSetter pss, RowCallbackHandler rch) | 指定された SQL を照会して、SQL から準備済みステートメントを作成し、値を照会にバインドする方法を知っている PreparedStatementSetter 実装を作成し、RowCallbackHandler で行ごとに ResultSet を読み取る | × |
| query(StringSE sql, PreparedStatementSetter pss, RowMapper\<T> rowMapper) | 与えられた SQL をクエリして、SQL から準備されたステートメントを作成し、RowMapper を介して各行を結果オブジェクトにマッピングして、クエリに値をバインドする方法を知っている PreparedStatementSetter 実装を作成する | × |
| query(StringSE sql, ResultSetExtractor\<T> rse) | 静的 SQL を指定してクエリを実行し、ResultSet を ResultSetExtractor で読み取る | × |
| query(StringSE sql, ResultSetExtractor\<T> rse, ObjectSE... args) | 指定された SQL をクエリして、SQL から準備されたステートメントと、クエリにバインドする引数のリストを作成し、ResultSet を ResultSetExtractor で読み取る | × |
| query(StringSE sql, RowCallbackHandler rch) | RowCallbackHandler を使用して行ごとに ResultSet を読み取り、静的 SQL を指定してクエリを実行する | × |
| query(StringSE sql, RowCallbackHandler rch, ObjectSE... args) | 指定された SQL にクエリを実行して、SQL から準備されたステートメントとクエリにバインドする引数のリストを作成し、RowCallbackHandler で ResultSet を行ごとに読み取る | × |
| query(StringSE sql, RowMapper\<T> rowMapper) | 静的 SQL を指定してクエリを実行し、RowMapper を介して各行を結果オブジェクトにマッピングする | 〇 |
| query(StringSE sql, RowMapper\<T> rowMapper, ObjectSE... args) | 指定された SQL をクエリして、SQL から準備されたステートメントとクエリにバインドする引数のリストを作成し、RowMapper を介して各行を結果オブジェクトにマッピングする | × |
| query(PreparedStatementCreator psc, PreparedStatementSetter pss, ResultSetExtractor\<T> rse) | PreparedStatementCreator および PreparedStatementSetter を許可する準備済みステートメントを使用した照会する | × |
| query(PreparedStatementCreator psc, ResultSetExtractor\<T> rse) | ResultSet を ResultSetExtractor で読み取り、準備済みステートメントを使用して照会する | × |
| query(PreparedStatementCreator psc, RowCallbackHandler rch) | RowCallbackHandler で行ごとに ResultSet を読み取り、準備されたステートメントを使用して照会する | × |
| query(PreparedStatementCreator psc, RowMapper\<T> rowMapper) | 準備済みステートメントを使用して照会し、RowMapper を介して各行を結果オブジェクトにマッピングする | × |
| queryForList(StringSE sql) | 静的 SQL を指定して、結果リストのクエリを実行する | × |
| queryForList(StringSE sql, ClassSE\<T> elementType) | 静的 SQL を指定して、結果リストのクエリを実行する | × |
| queryForList(StringSE sql, ClassSE\<T> elementType, ObjectSE... args) | 指定された SQL をクエリし、SQL から準備されたステートメントと、クエリにバインドする引数のリストを作成し、結果リストを期待する | × |
| queryForList(StringSE sql, ObjectSE... args) | 指定された SQL をクエリし、SQL から準備されたステートメントと、クエリにバインドする引数のリストを作成し、結果リストを期待する | × |
| queryForList(StringSE sql, ObjectSE[] args, int[] argTypes) | 指定された SQL をクエリし、SQL から準備されたステートメントと、クエリにバインドする引数のリストを作成し、結果リストを期待する | × |
| queryForList(StringSE sql, ObjectSE[] args, int[] argTypes, ClassSE\<T> elementType) | 指定された SQL をクエリし、SQL から準備されたステートメントと、クエリにバインドする引数のリストを作成し、結果リストを期待する | × |
| queryForMap(StringSE sql) | 静的 SQL を指定して、結果マップのクエリを実行する | × |
| queryForMap(StringSE sql, ObjectSE... args) | 指定された SQL をクエリし、SQL から準備されたステートメントと、クエリにバインドする引数のリストを作成し、結果マップを期待する | × |
| queryForMap(StringSE sql, ObjectSE[] args, int[] argTypes) | 指定された SQL をクエリし、SQL から準備されたステートメントと、クエリにバインドする引数のリストを作成し、結果マップを期待する | × |
| queryForObject(StringSE sql, ClassSE\<T> requiredType) | 静的 SQL を指定して、結果オブジェクトのクエリを実行する | × |
| queryForObject(StringSE sql, ClassSE\<T> requiredType, ObjectSE... args) | 指定された SQL をクエリし、SQL から準備されたステートメントと、クエリにバインドする引数のリストを作成し、結果オブジェクトを期待する | × |
| queryForObject(StringSE sql, ObjectSE[] args, int[] argTypes, ClassSE\<T> requiredType) | 指定された SQL をクエリし、SQL から準備されたステートメントと、クエリにバインドする引数のリストを作成し、結果オブジェクトを期待する | × |
| queryForObject(StringSE sql, ObjectSE[] args, int[] argTypes, RowMapper\<T> rowMapper) | 指定された SQL をクエリして、SQL から準備されたステートメントとクエリにバインドする引数のリストを作成し、RowMapper を介して単一の結果行を結果オブジェクトにマッピングする | × |
| queryForObject(StringSE sql, RowMapper\<T> rowMapper) | 静的 SQL を指定してクエリを実行し、RowMapper を介して単一の結果行を結果オブジェクトにマッピングする | × |
| queryForObject(StringSE sql, RowMapper\<T> rowMapper, ObjectSE... args) | 指定された SQL をクエリして、SQL から準備されたステートメントとクエリにバインドする引数のリストを作成し、RowMapper を介して単一の結果行を結果オブジェクトにマッピングする | × |
| queryForRowSet(StringSE sql) | 静的 SQL を指定して、SqlRowSet のクエリを実行する | × |
| queryForRowSet(StringSE sql, ObjectSE... args) | 指定された SQL を照会して、SQL から準備済みステートメントを作成し、SqlRowSet を想定して、照会にバインドする引数のリストを作成する | × |
| queryForRowSet(StringSE sql, ObjectSE[] args, int[] argTypes) | 指定された SQL を照会して、SQL から準備済みステートメントを作成し、SqlRowSet を想定して、照会にバインドする引数のリストを作成する | × |
| queryForStream(StringSE sql, PreparedStatementSetter pss, RowMapper\<T> rowMapper) | 指定された SQL をクエリして、SQL とクエリに値をバインドする方法を知っている PreparedStatementSetter 実装から準備済みステートメントを作成し、各行を RowMapper を介して結果オブジェクトにマッピングし、反復可能でクローズ可能なストリームに変換する | × |
| queryForStream(StringSE sql, RowMapper\<T> rowMapper) | 静的 SQL を指定してクエリを実行し、各行を RowMapper を介して結果オブジェクトにマッピングし、それを反復可能でクローズ可能なストリームに変換する | × |
| queryForStream(StringSE sql, RowMapper\<T> rowMapper, ObjectSE... args) | 指定された SQL をクエリして、SQL から準備されたステートメントとクエリにバインドする引数のリストを作成し、各行を RowMapper を介して結果オブジェクトにマッピングし、それを反復可能でクローズ可能なストリームに変換する | × |
| queryForStream(PreparedStatementCreator psc, PreparedStatementSetter pss, RowMapper\<T> rowMapper) | PreparedStatementCreator および PreparedStatementSetter を許可する準備済みステートメントを使用した照会する | × |
| queryForStream(PreparedStatementCreator psc, RowMapper\<T> rowMapper) | 準備済みステートメントを使用してクエリを実行し、各行を RowMapper を介して結果オブジェクトにマッピングし、それを反復可能でクローズ可能なストリームに変換する | × |
| setFetchSize(int fetchSize) | この JdbcTemplate のフェッチサイズを設定する | × |
| setIgnoreWarnings(boolean ignoreWarnings) | JDBC ステートメントの警告 ( SQLWarningSE ) を無視するかどうかを設定する | × |
| setMaxRows(int maxRows) | この JdbcTemplate の最大行数を設定する | × |
| setQueryTimeout(int queryTimeout) | この JdbcTemplate が実行するステートメントのクエリタイムアウト (秒) を設定する | × |
| setResultsMapCaseInsensitive(boolean resultsMapCaseInsensitive) | CallableStatement を実行すると、パラメーターに大文字と小文字を区別しない名前を使用するマップで結果が返されるかどうかを設定する | × |
| setSkipResultsProcessing(boolean skipResultsProcessing) | 結果処理をスキップするかどうかを設定する | × |
| setSkipUndeclaredResults(boolean skipUndeclaredResults) | 宣言されていない結果をスキップするかどうかを設定する | × |
| translateException(StringSE task, StringSE sql, SQLExceptionSE ex) | 指定された SQLExceptionSE を汎用 DataAccessException に変換する | × |
| update(StringSE sql) | 単一の SQL 更新操作（挿入、更新、削除ステートメントなど）を発行する | 〇 |
| update(StringSE sql, ObjectSE... args) | 準備されたステートメントを介して、単一の SQL 更新操作（挿入、更新、削除ステートメントなど）を発行し、指定された引数をバインドする | 〇 |
| update(StringSE sql, ObjectSE[] args, int[] argTypes) | 準備されたステートメントを介して、単一の SQL 更新操作（挿入、更新、削除ステートメントなど）を発行し、指定された引数をバインドする | × |
| update(StringSE sql, PreparedStatementSetter pss) | PreparedStatementSetter を使用して更新ステートメントを発行し、指定された SQL でバインドパラメーターを設定する | × |
| update(PreparedStatementCreator psc) | PreparedStatementCreator を使用して単一の SQL 更新操作（挿入、更新、削除ステートメントなど）を発行し、SQL および必要なパラメーターを提供する | × |
| update(PreparedStatementCreator psc, KeyHolder generatedKeyHolder) | PreparedStatementCreator を使用して更新ステートメントを発行し、SQL および必要なパラメーターを提供する | × |

#### TransactionTemplateクラス
