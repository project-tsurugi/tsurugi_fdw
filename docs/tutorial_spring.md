# [Tsurugi FDW for Tsurugi](./tsurugi_fdw.md)

## チュートリアル

PostgreSQLのユーザインタフェースからTsurugiを利用する簡単な操作方法を説明します。  

### Spring Frameworkを活用

JavaアプリケーションからSpring Frameworkを使用してTsurugiを利用する簡単な方法を説明します。  
Spring Frameworkは、Javaアプリケーションを効率的に開発するさまざなな機能を提供しており、その機能を利用することで効率的にTsurugiを利用（データベース連携）することができます。  
Tsurugi FDWがサポートするSpring Frameworkのリファレンスについては [リファレンス（Spring Framework）](./spring_reference.md) を参照してください。

> [!TIP]
> Spring Frameworkの機能（データベース連携に関連する一部を抜粋）
>
> - ORM（Object-Relational Mapping）フレームワーク:  
> オブジェクトとリレーショナルデータベース間のマッピングが容易に実現でき、データベース連携が効率化できる。
>
> - トランザクション管理:  
> トランザクション処理が容易に実現でき、データの整合性が確保できる。
>
> - DI（Dependency Injection: 依存性注入）:  
> オブジェクト間の依存関係が疎結合されることで、オブジェクトの柔軟性が向上できる。
>
> - AOP（Aspect-Oriented Programming: アスペクト指向プログラミング）:  
> 共通的な処理がモジュール化されることで、コードの再利用性や保守性が向上できる。
>
> Spring Frameworkのコンポーネント（データベース連携に関連する一部を抜粋）
>
> - Spring JDBC: Spring Frameworkが提供するJDBCのラッパークラス  
> JDBC APIを使いやすくするためのユーティリティクラスとヘルパーメソッドを提供している。
>
> - Spring Data JPA（ORM）: Spring Data（Spring Frameworkの一部）が提供するライブラリ
> Java Persistence API (JPA) を利用してデータベースアクセスが簡素化（リポジトリインターフェースを定義しCRUD 操作を自動化）できる。
>
> - Spring Data JDBC（ORM）: Spring Data（Spring Frameworkの一部）が提供するライブラリ  
> JDBC APIを利用してデータベースアクセスが簡素化（リポジトリインターフェースを定義しCRUD 操作を自動化）できる。
>
> - Spring Boot: Spring Framework を基盤としたライブラリ  
> Spring Frameworkでの開発を迅速化し各機能が容易に行えるよう設計されたツールを提供している。

#### Spring Frameworkの入手

Spring Frameworkのライブラリは [https://spring.io/projects](https://spring.pleiades.io/projects) で公開されています。  
Tsurugiと連携するJavaアプリケーションの要件に適したライブラリをダウンロードしてください。  

> [!TIP]
> [Spring Initializr](https://start.spring.io/)にアクセスするとSpring Bootアプリケーションの雛形を簡単に作成することができます。（Spring FrameworkのライブラリはMaven Central Repositoryから取得する）。  
> アプリケーションに追加する依存ライブラリは、Tsurugi FDWがサポートする以下のコンポーネントを選択（複数可）してください。  
> 
> - JDBC API [SQL]  
> Database Connectivity API that defines how a client may connect and query a database.
>
> - Spring Data JPA [SQL]  
> Persist data in SQL stores with Java Persistence API using Spring Data and Hibernate.
>
> - Spring Data JDBC [SQL]  
> Persist data in SQL stores with plain JDBC using Spring Data.

#### データベースへの接続（Spring Framework）

データベースの接続情報は、DriverManagerDataSourceクラスに設定します。

~~~java
    public DataSource dataSource() {
        DriverManagerDataSource dataSource = new DriverManagerDataSource();
        dataSource.setDriverClassName("org.postgresql.Driver"); // PostgreSQL JDBCドライバ
        dataSource.setUrl("jdbc:postgresql://localhost:5432/your_database_name"); // データベース名
        dataSource.setUsername("your_username"); // ユーザー名
        dataSource.setPassword("your_password"); // パスワード
        return dataSource;
    }
~~~

`Spring JDBC`および`Spring Data JDBC`の場合、上記データベース接続情報をJdbcTemplateクラスに指定（インスタンス化）することでデータベースに接続します。

~~~java
    // for Spring JDBC
    public JdbcTemplate jdbcTemplate() {
        return new JdbcTemplate(dataSource());
    }
~~~

~~~java
    // for Spring Data JDBC
    public NamedParameterJdbcOperations namedParameterJdbcTemplate() {
        return new NamedParameterJdbcTemplate(dataSource());
    }
~~~

`Spring Data JPA`の場合、`@Configuration`アノテーションを付与したクラスの中で、上記データベース接続情報をEntityManagerFactoryクラスに設定、JpaTransactionManagerのインスタンスに設定することでデータベースに接続します。

~~~java
@Configuration
public class DatabaseConnection {
    public LocalContainerEntityManagerFactoryBean entityManagerFactory() {
        LocalContainerEntityManagerFactoryBean em = new LocalContainerEntityManagerFactoryBean();
        em.setDataSource(dataSource()); // データベース接続情報を設定
        …
        return em;
    }
    public PlatformTransactionManager transactionManager() {
        JpaTransactionManager transactionManager = new JpaTransactionManager();
        // JpaTransactionManagerのインスタンスにデータベース接続情報を含むエンティティ情報を設定
        transactionManager.setEntityManagerFactory(entityManagerFactory().getObject());
        …
        return transactionManager;
    }
    …
}
~~~

Spring Bootアプリケーションを作成してTsurugiと連携する場合、`application.properties`ファイルにデータベース接続情報を設定することができます。  

~~~properties
spring.datasource.url=jdbc:postgresql://localhost:5432/your_database_name
spring.datasource.username=your_username
spring.datasource.password=your_password
~~~

`application.properties`ファイルに指定したデータベース接続情報は、アプリケーションの起動が完了する直前に読み込まれ、データベースへの接続を自動で確立します。

#### 外部テーブルの作成（Spring Framework）

Tsuguriのテーブルを操作する外部テーブルを作成します。  

> [!NOTE]
> 接続先データベースに対象の外部テーブルが存在する場合は本手順はスキップしてください。  

`Spring JDBC`の`JdbcTemplate`を使用して、直接SQL文を実行します。

~~~java
    @Autowired  // 依存性注入（依存オブジェクトを疎結合）
    private JdbcTemplate jdbcTemplate;

    @PostConstruct // アプリケーション起動時に実行される
    public void createForeignTable() {
        jdbcTemplate.execute(
            "CREATE FOREIGN TABLE IF NOT EXISTS fdw_sample ("
                + "col INTEGER NOT NULL,"
                + "tm TIME"
                + ") SERVER tsurugi"
        );
    }
~~~

`Spring Data JDBC`および`Spring Data JDBC`は、直接的には外部テーブルの作成をサポートしていません。
基本的なCRUD (Create, Read, Update, Delete) 操作と、データベーステーブルへのJavaオブジェクトのマッピングに重点を置いています。

#### データの挿入（Spring Framework）

#### データの問い合わせ（Spring Framework）

#### データの更新と削除（Spring Framework）

#### トランザクション操作（Spring Framework）

#### ステートメントキャッシュの利用（Spring Framework）

#### エラー情報の取得（Spring Framework）

#### サンプルプログラム（Spring Framework）

