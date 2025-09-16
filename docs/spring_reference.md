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

#### Spring Frameworkプロジェクト

- [DriverManagerDataSourceクラス](#drivermanagerdatasourceクラス) - データベース接続情報を管理する  
- [JdbcTemplateクラス](#jdbctemplateクラス) - JDBCの使用を簡素化する  
- [TransactionTemplateクラス](#transactiontemplateクラス) - プログラムによるトランザクション管理を簡素化する  
- [Transactionalアノテーションインターフェース](#transactionalアノテーションインターフェース) - トランザクション属性を記述する

#### Spring Dataプロジェクト

- [CrudRepositoryインターフェース](#crudrepositoryインターフェース) - CRUD操作を行うための汎用リポジトリインターフェース
- [JpaRepositoryインターフェース](#jparepositoryインターフェース) - JPA固有のリポジトリインターフェース（CrudRepositoryを継承）

- [SpringDataアノテーションインターフェース](#jparepositoryインターフェース) - Spring Dataで使用されるアノテーションインターフェース
- [RelationalMappingアノテーションインターフェース](#jparepositoryインターフェース) - Spring Dataの永続性およびオブジェクト / リレーショナルで使用されるアノテーションインターフェース

#### Jakarta EE

- [Persistenceパッケージ](#persistenceパッケージ) - 永続性およびオブジェクト / リレーショナルマッピングを管理する

#### DriverManagerDataSourceクラス

[org.springframework.jdbc.datasource](https://spring.pleiades.io/spring-framework/docs/current/javadoc-api/org/springframework/jdbc/datasource/package-summary.html)パッケージにおいてデータベース接続情報を管理する。

| メソッド名 | 説明 | 動作確認 |
| :--- | :--- | :---: |
| getConnectionFromDriver(Properties props) | 指定されたプロパティを使用して接続を取得する | × |
| getConnectionFromDriverManager(String url, Properties props) | DriverManager から厄介な静的を使用して接続を取得する。protected メソッドに抽出され、簡単な単体テストが可能になる | × |
| setDriverClassName(String driverClassName) | JDBC ドライバーのクラス名を設定する | 〇 |
| getCatalog() | 各 Connection に適用されるデータベースカタログがあれば、それを返す | × |
| getConnection() | この実装は、この DataSource のデフォルトのユーザー名とパスワードを使用して getConnectionFromDriver に委譲する | × |
| getConnection(String username, String password) | この実装は、指定されたユーザー名とパスワードを使用して getConnectionFromDriver に委譲する | × |
| getConnectionFromDriver(String username, String password) | 指定されたユーザー名とパスワード（存在する場合）を含むドライバーのプロパティを構築し、対応する接続を取得する | × |
| getConnectionProperties() | ドライバーに渡される接続プロパティがあれば、それを返す | × |
| getPassword() | ドライバーを介した接続に使用する JDBC パスワードを返す | × |
| getSchema() | 各接続に適用されるデータベーススキーマがあれば、それを返す | × |
| getUrl() | ドライバーを介した接続に使用する JDBC URL を返す | × |
| getUsername() | ドライバーを介した接続に使用する JDBC ユーザー名を返す | × |
| setCatalog(String catalog) | 各接続に適用されるデータベースカタログを指定する | × |
| setConnectionProperties(Properties connectionProperties) | 任意の接続プロパティをキー / 値のペアとして指定し、ドライバーに渡す | × |
| setPassword(String password) | ドライバーを介した接続に使用する JDBC パスワードを設定する | 〇 |
| setSchema(String schema) | 各接続に適用されるデータベーススキーマを指定する | × |
| setUrl(String url) | ドライバーを介した接続に使用する JDBC URL を設定する | 〇 |
| setUsername(String username) | ドライバーを介した接続に使用する JDBC ユーザー名を設定する | 〇 |

#### JdbcTemplateクラス

[org.springframework.jdbc.core](https://spring.pleiades.io/spring-framework/docs/current/javadoc-api/org/springframework/jdbc/core/package-summary.html)パッケージにおいてJDBCの使用を簡素化する。

| メソッド名 | 説明 | 動作確認 |
| :--- | :--- | :---: |
| applyStatementSettings(Statement stmt) | 指定された JDBC ステートメントを準備し、フェッチサイズ、最大行、クエリタイムアウトなどのステートメント設定を適用する | × |
| batchUpdate(String... sql) | バッチ処理を使用して、単一の JDBC ステートメントで複数の SQL 更新を発行する | × |
| batchUpdate(String sql, Collection\<T> batchArgs, int batchSize, ParameterizedPreparedStatementSetter\<T> pss) | 提供された引数を収集して提供された SQL ステートメントを使用して、複数のバッチを実行する | × |
| batchUpdate(String sql, List\<Object[]> batchArgs) | 提供された引数のバッチで提供された SQL ステートメントを使用して、バッチを実行する | × |
| batchUpdate(String sql, List\<Object[]> batchArgs, int[] argTypes) | 提供された引数のバッチで提供された SQL ステートメントを使用して、バッチを実行する | × |
| batchUpdate(String sql, BatchPreparedStatementSetter pss) | 単一の PreparedStatement で複数の更新ステートメントを発行し、バッチ更新と BatchPreparedStatementSetter を使用して値を設定する | × |
| batchUpdate(PreparedStatementCreator psc, BatchPreparedStatementSetter pss, KeyHolder generatedKeyHolder) | 単一の PreparedStatement で複数の更新ステートメントを発行し、バッチ更新と BatchPreparedStatementSetter を使用して値を設定する | × |
| call(CallableStatementCreator csc, List\<SqlParameter> declaredParameters) | CallableStatementCreator を使用して SQL 呼び出しを実行し、SQL および必要なパラメーターを提供する | × |
| createConnectionProxy(Connection con) | 指定された JDBC 接続用の密接抑制プロキシを作成する | × |
| createResultsMap() | 結果マップとして使用される Map インスタンスを作成する | × |
| execute(String sql) | 単一の SQL 実行（通常は DDL ステートメント）を発行する | 〇 |
| execute(String callString, CallableStatementCallback\<T> action) | JDBC CallableStatement で動作するコールバックアクションとして実装される JDBC データアクセス操作を実行する | × |
| execute(String sql, PreparedStatementCallback\<T> action) | JDBC PreparedStatement で動作するコールバックアクションとして実装される JDBC データアクセス操作を実行する | × |
| execute(CallableStatementCreator csc, CallableStatementCallback\<T> action) | JDBC CallableStatement で動作するコールバックアクションとして実装される JDBC データアクセス操作を実行する | × |
| execute(ConnectionCallback\<T> action) | JDBC 接続で動作するコールバックアクションとして実装される JDBC データアクセス操作を実行する | × |
| execute(PreparedStatementCreator psc, PreparedStatementCallback\<T> action) | JDBC PreparedStatement で動作するコールバックアクションとして実装される JDBC データアクセス操作を実行する | × |
| execute(StatementCallback\<T> action) | JDBC ステートメントで動作するコールバックアクションとして実装される JDBC データアクセス操作を実行する | × |
| extractOutputParameters(CallableStatement cs, List\<SqlParameter> parameters) | 完了したストアドプロシージャから出力パラメーターを抽出する | × |
| extractReturnedResults(CallableStatement cs, List\<SqlParameter> updateCountParameters, List\<SqlParameter> resultSetParameters, int updateCount) | 完了したストアドプロシージャから返された ResultSets を抽出する | × |
| getColumnMapRowMapper() | 列をキーと値のペアとして読み取るための新しい RowMapper を作成する | × |
| getFetchSize() | この JdbcTemplate に指定されたフェッチサイズを返す | × |
| getMaxRows() | この JdbcTemplate に指定された行の最大数を返す | × |
| getQueryTimeout() | この JdbcTemplate が実行するステートメントのクエリタイムアウト (秒) を返す | × |
| getSingleColumnRowMapper(Class\<T> requiredType) | 単一の列から結果オブジェクトを読み取るための新しい RowMapper を作成する | × |
| handleWarnings(SQLWarning warning) | 実際の警告が発生した場合は、SQLWarningException をスローする | × |
| handleWarnings(Statement stmt) | 指定された JDBC ステートメントに警告がある場合は、それを処理する | × |
| handleWarnings(Statement stmt, SQLException ex) | 指定されたステートメントの実行からプライマリ SQLException を伝播する前に、警告を処理する | × |
| isIgnoreWarnings() | SQLWarnings を無視するかどうかを返す | × |
| isResultsMapCaseInsensitive() | CallableStatement を実行すると、パラメーターに大文字と小文字を区別しない名前を使用するマップで結果が返されるかどうかを返す | × |
| isSkipResultsProcessing() | 結果処理をスキップするかどうかを返す | × |
| isSkipUndeclaredResults() | 宣言されていない結果をスキップするかどうかを返す | × |
| newArgPreparedStatementSetter(Object[] args) | 渡された引数を使用して、新しい引数ベースの PreparedStatementSetter を作成する | × |
| newArgTypePreparedStatementSetter(Object[] args, int[] argTypes) | 渡された引数と型を使用して、新しい引数型ベースの PreparedStatementSetter を作成する | × |
| processResultSet(ResultSet rs, ResultSetSupportingSqlParameter param) | ストアドプロシージャから指定された ResultSet を処理する | × |
| query(String sql, Object[] args, int[] argTypes, ResultSetExtractor\<T> rse) | 指定された SQL をクエリして、SQL から準備されたステートメントと、クエリにバインドする引数のリストを作成し、ResultSet を ResultSetExtractor で読み取る | × |
| query(String sql, Object[] args, int[] argTypes, RowCallbackHandler rch) | 指定された SQL にクエリを実行して、SQL から準備されたステートメントとクエリにバインドする引数のリストを作成し、RowCallbackHandler で ResultSet を行ごとに読み取る | × |
| query(String sql, Object[] args, int[] argTypes, RowMapper\<T> rowMapper) | 指定された SQL をクエリして、SQL から準備されたステートメントとクエリにバインドする引数のリストを作成し、RowMapper を介して各行を結果オブジェクトにマッピングする | × |
| query(String sql, PreparedStatementSetter pss, ResultSetExtractor\<T> rse) | ResultSet を ResultSetExtractor で読み取り、準備済みステートメントを使用して照会する | × |
| query(String sql, PreparedStatementSetter pss, RowCallbackHandler rch) | 指定された SQL を照会して、SQL から準備済みステートメントを作成し、値を照会にバインドする方法を知っている PreparedStatementSetter 実装を作成し、RowCallbackHandler で行ごとに ResultSet を読み取る | × |
| query(String sql, PreparedStatementSetter pss, RowMapper\<T> rowMapper) | 与えられた SQL をクエリして、SQL から準備されたステートメントを作成し、RowMapper を介して各行を結果オブジェクトにマッピングして、クエリに値をバインドする方法を知っている PreparedStatementSetter 実装を作成する | × |
| query(String sql, ResultSetExtractor\<T> rse) | 静的 SQL を指定してクエリを実行し、ResultSet を ResultSetExtractor で読み取る | × |
| query(String sql, ResultSetExtractor\<T> rse, Object... args) | 指定された SQL をクエリして、SQL から準備されたステートメントと、クエリにバインドする引数のリストを作成し、ResultSet を ResultSetExtractor で読み取る | × |
| query(String sql, RowCallbackHandler rch) | RowCallbackHandler を使用して行ごとに ResultSet を読み取り、静的 SQL を指定してクエリを実行する | × |
| query(String sql, RowCallbackHandler rch, Object... args) | 指定された SQL にクエリを実行して、SQL から準備されたステートメントとクエリにバインドする引数のリストを作成し、RowCallbackHandler で ResultSet を行ごとに読み取る | × |
| query(String sql, RowMapper\<T> rowMapper) | 静的 SQL を指定してクエリを実行し、RowMapper を介して各行を結果オブジェクトにマッピングする | 〇 |
| query(String sql, RowMapper\<T> rowMapper, Object... args) | 指定された SQL をクエリして、SQL から準備されたステートメントとクエリにバインドする引数のリストを作成し、RowMapper を介して各行を結果オブジェクトにマッピングする | × |
| query(PreparedStatementCreator psc, PreparedStatementSetter pss, ResultSetExtractor\<T> rse) | PreparedStatementCreator および PreparedStatementSetter を許可する準備済みステートメントを使用した照会する | × |
| query(PreparedStatementCreator psc, ResultSetExtractor\<T> rse) | ResultSet を ResultSetExtractor で読み取り、準備済みステートメントを使用して照会する | × |
| query(PreparedStatementCreator psc, RowCallbackHandler rch) | RowCallbackHandler で行ごとに ResultSet を読み取り、準備されたステートメントを使用して照会する | × |
| query(PreparedStatementCreator psc, RowMapper\<T> rowMapper) | 準備済みステートメントを使用して照会し、RowMapper を介して各行を結果オブジェクトにマッピングする | × |
| queryForList(String sql) | 静的 SQL を指定して、結果リストのクエリを実行する | × |
| queryForList(String sql, Class\<T> elementType) | 静的 SQL を指定して、結果リストのクエリを実行する | × |
| queryForList(String sql, Class\<T> elementType, Object... args) | 指定された SQL をクエリし、SQL から準備されたステートメントと、クエリにバインドする引数のリストを作成し、結果リストを期待する | × |
| queryForList(String sql, Object... args) | 指定された SQL をクエリし、SQL から準備されたステートメントと、クエリにバインドする引数のリストを作成し、結果リストを期待する | × |
| queryForList(String sql, Object[] args, int[] argTypes) | 指定された SQL をクエリし、SQL から準備されたステートメントと、クエリにバインドする引数のリストを作成し、結果リストを期待する | × |
| queryForList(String sql, Object[] args, int[] argTypes, Class\<T> elementType) | 指定された SQL をクエリし、SQL から準備されたステートメントと、クエリにバインドする引数のリストを作成し、結果リストを期待する | × |
| queryForMap(String sql) | 静的 SQL を指定して、結果マップのクエリを実行する | × |
| queryForMap(String sql, Object... args) | 指定された SQL をクエリし、SQL から準備されたステートメントと、クエリにバインドする引数のリストを作成し、結果マップを期待する | × |
| queryForMap(String sql, Object[] args, int[] argTypes) | 指定された SQL をクエリし、SQL から準備されたステートメントと、クエリにバインドする引数のリストを作成し、結果マップを期待する | × |
| queryForObject(String sql, Class\<T> requiredType) | 静的 SQL を指定して、結果オブジェクトのクエリを実行する | × |
| queryForObject(String sql, Class\<T> requiredType, Object... args) | 指定された SQL をクエリし、SQL から準備されたステートメントと、クエリにバインドする引数のリストを作成し、結果オブジェクトを期待する | × |
| queryForObject(String sql, Object[] args, int[] argTypes, Class\<T> requiredType) | 指定された SQL をクエリし、SQL から準備されたステートメントと、クエリにバインドする引数のリストを作成し、結果オブジェクトを期待する | × |
| queryForObject(String sql, Object[] args, int[] argTypes, RowMapper\<T> rowMapper) | 指定された SQL をクエリして、SQL から準備されたステートメントとクエリにバインドする引数のリストを作成し、RowMapper を介して単一の結果行を結果オブジェクトにマッピングする | × |
| queryForObject(String sql, RowMapper\<T> rowMapper) | 静的 SQL を指定してクエリを実行し、RowMapper を介して単一の結果行を結果オブジェクトにマッピングする | × |
| queryForObject(String sql, RowMapper\<T> rowMapper, Object... args) | 指定された SQL をクエリして、SQL から準備されたステートメントとクエリにバインドする引数のリストを作成し、RowMapper を介して単一の結果行を結果オブジェクトにマッピングする | × |
| queryForRowSet(String sql) | 静的 SQL を指定して、SqlRowSet のクエリを実行する | × |
| queryForRowSet(String sql, Object... args) | 指定された SQL を照会して、SQL から準備済みステートメントを作成し、SqlRowSet を想定して、照会にバインドする引数のリストを作成する | × |
| queryForRowSet(String sql, Object[] args, int[] argTypes) | 指定された SQL を照会して、SQL から準備済みステートメントを作成し、SqlRowSet を想定して、照会にバインドする引数のリストを作成する | × |
| queryForStream(String sql, PreparedStatementSetter pss, RowMapper\<T> rowMapper) | 指定された SQL をクエリして、SQL とクエリに値をバインドする方法を知っている PreparedStatementSetter 実装から準備済みステートメントを作成し、各行を RowMapper を介して結果オブジェクトにマッピングし、反復可能でクローズ可能なストリームに変換する | × |
| queryForStream(String sql, RowMapper\<T> rowMapper) | 静的 SQL を指定してクエリを実行し、各行を RowMapper を介して結果オブジェクトにマッピングし、それを反復可能でクローズ可能なストリームに変換する | × |
| queryForStream(String sql, RowMapper\<T> rowMapper, Object... args) | 指定された SQL をクエリして、SQL から準備されたステートメントとクエリにバインドする引数のリストを作成し、各行を RowMapper を介して結果オブジェクトにマッピングし、それを反復可能でクローズ可能なストリームに変換する | × |
| queryForStream(PreparedStatementCreator psc, PreparedStatementSetter pss, RowMapper\<T> rowMapper) | PreparedStatementCreator および PreparedStatementSetter を許可する準備済みステートメントを使用した照会する | × |
| queryForStream(PreparedStatementCreator psc, RowMapper\<T> rowMapper) | 準備済みステートメントを使用してクエリを実行し、各行を RowMapper を介して結果オブジェクトにマッピングし、それを反復可能でクローズ可能なストリームに変換する | × |
| setFetchSize(int fetchSize) | この JdbcTemplate のフェッチサイズを設定する | × |
| setIgnoreWarnings(boolean ignoreWarnings) | JDBC ステートメントの警告 ( SQLWarning ) を無視するかどうかを設定する | × |
| setMaxRows(int maxRows) | この JdbcTemplate の最大行数を設定する | × |
| setQueryTimeout(int queryTimeout) | この JdbcTemplate が実行するステートメントのクエリタイムアウト (秒) を設定する | × |
| setResultsMapCaseInsensitive(boolean resultsMapCaseInsensitive) | CallableStatement を実行すると、パラメーターに大文字と小文字を区別しない名前を使用するマップで結果が返されるかどうかを設定する | × |
| setSkipResultsProcessing(boolean skipResultsProcessing) | 結果処理をスキップするかどうかを設定する | × |
| setSkipUndeclaredResults(boolean skipUndeclaredResults) | 宣言されていない結果をスキップするかどうかを設定する | × |
| translateException(String task, String sql, SQLException ex) | 指定された SQLException を汎用 DataAccessException に変換する | × |
| update(String sql) | 単一の SQL 更新操作（挿入、更新、削除ステートメントなど）を発行する | 〇 |
| update(String sql, Object... args) | 準備されたステートメントを介して、単一の SQL 更新操作（挿入、更新、削除ステートメントなど）を発行し、指定された引数をバインドする | 〇 |
| update(String sql, Object[] args, int[] argTypes) | 準備されたステートメントを介して、単一の SQL 更新操作（挿入、更新、削除ステートメントなど）を発行し、指定された引数をバインドする | × |
| update(String sql, PreparedStatementSetter pss) | PreparedStatementSetter を使用して更新ステートメントを発行し、指定された SQL でバインドパラメーターを設定する | × |
| update(PreparedStatementCreator psc) | PreparedStatementCreator を使用して単一の SQL 更新操作（挿入、更新、削除ステートメントなど）を発行し、SQL および必要なパラメーターを提供する | × |
| update(PreparedStatementCreator psc, KeyHolder generatedKeyHolder) | PreparedStatementCreator を使用して更新ステートメントを発行し、SQL および必要なパラメーターを提供する | × |

#### TransactionTemplateクラス

[org.springframework.transaction.support](https://spring.pleiades.io/spring-framework/docs/current/javadoc-api/org/springframework/transaction/support/package-summary.html)パッケージにおいてプログラムによるトランザクション管理を簡素化する。

| メソッド名 | 説明 | 動作確認 |
| :--- | :--- | :---: |
| afterPropertiesSet() | すべての Bean プロパティを設定し、BeanFactoryAware、ApplicationContextAware などを満たした後、包含 BeanFactory によって呼び出す | × |
| equals(Object other) | この実装は、toString() の結果を比較する | × |
| execute(TransactionCallback\<T> action) | トランザクション内で、指定されたコールバックオブジェクトによって指定されたアクションを実行する | 〇 |
| getTransactionManager() | 使用するトランザクション管理戦略を返す | × |
| setTransactionManager(PlatformTransactionManager transactionManager) | 使用するトランザクション管理戦略を設定する | × |

#### Transactionalアノテーションインターフェース

[org.springframework.transaction.annotation](https://spring.pleiades.io/spring-framework/docs/current/javadoc-api/org/springframework/transaction/annotation/package-summary.html)パッケージ（宣言的トランザクション）においてトランザクション属性（オプション要素）を記述する。

| オプション要素 | 説明 | 動作確認 |
| :--- | :--- | :---: |
| isolation | トランザクション分離レベルを記述する | × |
| label | ゼロ (0) 以上のトランザクションラベルを記述する | × |
| noRollbackFor | ゼロ (0) 以上の例外 types を記述する | × |
| noRollbackForClassName | ゼロ (0) 以上の例外名パターンを記述する | × |
| propagation | トランザクション伝播型を記述する | × |
| readOnly | トランザクションが事実上読み取り専用である場合に true に設定できるブールフラグを記述する | × |
| rollbackFor | ゼロ (0) 以上の例外型を記述する | × |
| rollbackForClassName | ゼロ (0) 以上の例外名パターンを記述する | × |
| timeout | このトランザクションのタイムアウト（秒単位）を記述する | × |
| timeoutString | このトランザクションのタイムアウト（秒単位）を記述する | × |
| transactionManager | 指定されたトランザクションの修飾子値を記述する | × |
| value | transactionManager() のエイリアスを記述する | × |

#### Persistenceパッケージ

永続性およびオブジェクト / リレーショナルマッピングを管理するために[Jakarta EE Persistence](https://spring.pleiades.io/specifications/platform/10/apidocs/jakarta/persistence/package-summary)パッケージのアノテーション型を利用する。

| アノテーション型 | 説明 | 動作確認 |
| :--- | :--- | :---: |
| Access | エンティティクラス、マッピングされたスーパークラス、埋め込み可能なクラス、そのようなクラスの特定の属性に適用されるアクセス型を指定するために使用する | × |
| AssociationOverride | エンティティ関連のマッピングをオーバーライドするために使用する | × |
| AssociationOverrides | 複数の関連プロパティまたはフィールドのマッピングをオーバーライドするために使用する | × |
| AttributeOverride | Basic （明示的またはデフォルト）プロパティまたはフィールド、または Id プロパティまたはフィールドのマッピングをオーバーライドするために使用する | × |
| AttributeOverrides | 複数のプロパティまたはフィールドのマッピングをオーバーライドするために使用する | × |
| Basic | データベース列へのマッピングの最も単純な型 | × |
| Cacheable | persistence.xml キャッシング要素の値が ENABLE_SELECTIVE または DISABLE_SELECTIVE のときにキャッシングが有効になっている場合、エンティティをキャッシュするかどうかを指定する | × |
| CollectionTable | 基本型または埋め込み型のコレクションのマッピングに使用されるテーブルを指定する | × |
| Column | 永続プロパティまたはフィールドのマップされた列を指定する | 〇 |
| ColumnResult | SQL クエリの SELECT リストの列をマップするために、SqlResultSetMapping アノテーションまたは ConstructorResult アノテーションと組み合わせて使用する | × |
| ConstructorResult | SqlResultSetMapping アノテーションと組み合わせて使用して、SQL クエリの SELECT 句をコンストラクターにマッピングする | × |
| Convert | 基本的なフィールドまたはプロパティの変換を指定する | × |
| Converter | アノテーション付きクラスがコンバーターであることを指定し、そのスコープを定義する | × |
| Converts | Convert アノテーションをグループ化するために使用する | × |
| DiscriminatorColumn | SINGLE_TABLE および JOINED Inheritance マッピング戦略の識別子列を指定する | × |
| DiscriminatorValue | 指定された型のエンティティの識別子列の値を指定する | × |
| ElementCollection | 基本型または埋め込み可能なクラスのインスタンスのコレクションを指定する | × |
| Embeddable | インスタンスが所有エンティティの固有部分として格納され、エンティティの ID を共有するクラスを指定する | × |
| Embedded | 値が埋め込み可能クラスのインスタンスであるエンティティの永続フィールドまたはプロパティを指定する | × |
| EmbeddedId | エンティティクラスまたはマップされたスーパークラスの永続フィールドまたはプロパティに適用され、埋め込み可能なクラスである複合主キーを示す | × |
| Entity | クラスがエンティティであることを指定する | 〇 |
| EntityListeners | エンティティまたはマップされたスーパークラスに使用されるコールバックリスナークラスを指定する | × |
| EntityResult | SQL クエリの SELECT 句をエンティティ結果にマッピングするために、SqlResultSetMapping アノテーションと組み合わせて使用する | × |
| Enumerated | 永続プロパティまたはフィールドを列挙型として永続化することを指定する | × |
| ExcludeDefaultListeners | エンティティクラス（またはマッピングされたスーパークラス）とそのサブクラスのデフォルトリスナーの呼び出しを除外することを指定する | × |
| ExcludeSuperclassListeners | エンティティクラス（またはマップされたスーパークラス）とそのサブクラスのスーパークラスリスナーの呼び出しを除外することを指定する | × |
| FieldResult | SQL クエリの SELECT リストで指定された列をエンティティクラスのプロパティまたはフィールドにマッピングするために、EntityResult アノテーションと組み合わせて使用する | × |
| ForeignKey | スキーマ生成が有効な場合の外部キー制約の処理を指定するために使用する | × |
| GeneratedValue | 主キーの値の生成戦略の仕様を提供する | 使用不可 |
| Id | エンティティの主キーを指定する | 〇 |
| IdClass | エンティティの複数のフィールドまたはプロパティにマップされる複合主キークラスを指定する | × |
| Index | スキーマ生成で使用され、インデックスの作成を指定する | × |
| Inheritance | エンティティクラス階層に使用される継承戦略を指定する | × |
| JoinColumn | エンティティの関連付けまたは要素コレクションに参加するための列を指定する | × |
| JoinColumns | 複合外部キーのマッピングを指定する | × |
| JoinTable | 関連付けのマッピングを指定する | × |
| Lob | 永続プロパティまたはフィールドを、データベースでサポートされるラージオブジェクト型のラージオブジェクトとして永続化することを指定する | × |
| ManyToMany | 多対多の多重度を持つ多値の関連付けを指定する | × |
| ManyToOne | 多対 1 の多重度を持つ別のエンティティクラスへの単一値の関連付けを指定する | × |
| MapKey | マップキー自体がプライマリキーであるか、マップの値であるエンティティの永続フィールドまたはプロパティである場合、型 java.util.MapSE の関連付けのマップキーを指定する | × |
| MapKeyClass | 型 java.util.Map の関連付けのマップキーの型を指定する | × |
| MapKeyColumn | マップキーが基本型であるマップのキー列のマッピングを指定する | × |
| MapKeyEnumerated | 基本型が列挙型であるマップキーの列挙型を指定する | × |
| MapKeyJoinColumn | マップキーであるエンティティへのマッピングを指定する | × |
| MapKeyJoinColumns | エンティティを参照する複合マップキーをサポートする | × |
| MapKeyTemporal | このアノテーションは、型 DateSE および CalendarSE の永続マップキーに指定する必要がある | × |
| MappedSuperclass | マッピング情報が継承するエンティティに適用されるクラスを指定する | × |
| MapsId | EmbeddedId 主キー、EmbeddedId 主キー内の属性、親エンティティの単純主キーのマッピングを提供する ManyToOne または OneToOne 関連属性を指定する | × |
| NamedAttributeNode | NamedAttributeNode は NamedEntityGraph のメンバー要素 | × |
| NamedEntityGraph | 検索操作またはクエリのパスと境界を指定するために使用する | × |
| NamedEntityGraphs | NamedEntityGraph アノテーションをグループ化するために使用する | × |
| NamedNativeQueries | 複数のネイティブ SQL 名前付きクエリを指定する | × |
| NamedNativeQuery | 名前付きのネイティブ SQL クエリを指定する | × |
| NamedQueries | 複数の名前付き Jakarta Persistence クエリ言語クエリを指定する | × |
| NamedQuery | Jakarta Persistence クエリ言語で静的な名前付きクエリを指定する | × |
| NamedStoredProcedureQueries | 複数の名前付きストアドプロシージャクエリを指定する | × |
| NamedStoredProcedureQuery | ストアドプロシージャ、そのパラメーター、その結果の型を指定し、名前を付ける | × |
| NamedSubgraph | NamedSubgraph は NamedEntityGraph のメンバー要素 | × |
| OneToMany | 1 対多の多重度を持つ多値の関連付けを指定する | × |
| OneToOne | 1 対 1 の多重度を持つ別のエンティティへの単一値の関連付けを指定する | × |
| OrderBy | 関連付けまたはコレクションが取得される時点で、コレクション値の関連付けまたは要素コレクションの要素の順序を指定する | × |
| OrderColumn | リストの永続的な順序を維持するために使用される列を指定する | × |
| PersistenceContext | コンテナー管理の EntityManager とそれに関連する永続コンテキストへの依存関係を表す | × |
| PersistenceContexts | 1 つ以上の PersistenceContext アノテーションを宣言する | × |
| PersistenceProperty | 単一のコンテナーまたは永続プロバイダーのプロパティを説明する | × |
| PersistenceUnit | EntityManagerFactory とそれに関連する永続性ユニットへの依存関係を表す | × |
| PersistenceUnits | 1 つ以上の PersistenceUnit アノテーションを宣言する | × |
| PostLoad | 対応するライフサイクルイベントのコールバックメソッドを指定する | × |
| PostPersist | 対応するライフサイクルイベントのコールバックメソッドを指定する | × |
| PostRemove | 対応するライフサイクルイベントのコールバックメソッドを指定する | × |
| PostUpdate | 対応するライフサイクルイベントのコールバックメソッドを指定する | × |
| PrePersist | 対応するライフサイクルイベントのコールバックメソッドを指定する | × |
| PreRemove | 対応するライフサイクルイベントのコールバックメソッドを指定する | × |
| PreUpdate | 対応するライフサイクルイベントのコールバックメソッドを指定する | × |
| PrimaryKeyJoinColumn | 別のテーブルに結合するための外部キーとして使用される主キー列を指定する | × |
| PrimaryKeyJoinColumns | PrimaryKeyJoinColumn アノテーションをグループ化する | × |
| QueryHint | NamedQuery または NamedNativeQuery アノテーションにクエリプロパティまたはヒントを提供するために使用する | × |
| SecondaryTable | アノテーション付きエンティティクラスのセカンダリテーブルを指定する | × |
| SecondaryTables | エンティティに複数のセカンダリテーブルを指定する | × |
| SequenceGenerator | GeneratedValue アノテーションにジェネレーター要素が指定されている場合に、名前で参照できる主キージェネレーターを定義する | × |
| SequenceGenerators | SequenceGenerator アノテーションをグループ化するために使用する | × |
| SqlResultSetMapping | ネイティブ SQL クエリまたはストアドプロシージャの結果のマッピングを指定する | × |
| SqlResultSetMappings | 1 つ以上の SqlResultSetMapping アノテーションを定義するために使用する | × |
| StoredProcedureParameter | 名前付きストアドプロシージャクエリのパラメーターを指定する | × |
| Table | アノテーション付きエンティティのプライマリテーブルを指定する | 〇 |
| TableGenerator | GeneratedValue アノテーションにジェネレーター要素が指定されている場合に、名前で参照できる主キージェネレーターを定義する | × |
| TableGenerators | TableGenerator アノテーションをグループ化するために使用する | × |
| Temporal | このアノテーションは、型 java.util.Date および java.util.Calendar の永続フィールドまたはプロパティに指定する必要がある | × |
| Transient | プロパティまたはフィールドが永続的ではないことを指定する | × |
| UniqueConstraint | プライマリテーブルまたはセカンダリテーブルの生成された DDL に一意の制約を含めることを指定する | × |
| Version | 楽観的ロック値として機能するエンティティクラスのバージョンフィールドまたはプロパティを指定する | × |
