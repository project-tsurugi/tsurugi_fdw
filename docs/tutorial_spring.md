# [Tsurugi FDW for Tsurugi](./tsurugi_fdw.md)

## チュートリアル

### Spring Frameworkを活用

JavaアプリケーションからSpring Frameworkを使用してTsurugiを利用（データベース連携）する簡単な方法を説明します。  
Spring Frameworkは、Javaアプリケーションを効率的に開発するさまざなな機能を提供しており、その機能を利用することで効率的にTsurugiを利用することができます。  
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
Tsurugiを利用するJavaアプリケーションの要件に適したライブラリをダウンロードしてください。  

> [!TIP]
> [Spring Initializr](https://start.spring.io/)にアクセスするとSpring Bootを使用したJavaアプリケーションの雛形を簡単に作成することができます。  
> Javaアプリケーションに追加する依存ライブラリは、Tsurugi FDWがサポートする以下のコンポーネントを選択（複数可）してください。  
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

Spring Frameworkを使用してデータベースに接続する方法はいくつかありますが、一般的な方法を説明します。

##### DriverManagerDataSourceクラスを利用

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

`Spring JDBC`および`Spring Data JDBC`の場合、上記データベース接続情報をJdbcTemplateクラスに指定（インスタンス化）することでデータベースに接続することができます。  

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

`Spring Data JPA`の場合、`@Configuration`アノテーションを付与したクラスの中で、上記データベース接続情報をEntityManagerFactoryクラスに設定、JpaTransactionManagerのインスタンスに設定することでデータベースに接続することができます。  

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

##### Spring Bootを利用

Spring Bootを利用する場合、`application.properties`ファイルにデータベース接続情報を設定することでができます。  

~~~properties
spring.datasource.url=jdbc:postgresql://localhost:5432/your_database_name
spring.datasource.username=your_username
spring.datasource.password=your_password
~~~

`application.properties`ファイルに指定したデータベース接続情報は、Javaアプリケーションが起動する直前に読み込まれ、自動でデータベースと接続します。  

#### SQL文の実行（Spring Framework）

Spring Frameworkを使用してSQL文を実行する方法はいくつかありますが、`Spring JDBC`の`JdbcTemplate`クラスを使用する一般的な方法を説明します。  
`JdbcTemplate`クラスの利用方法はSpring Frameworkの仕様に準じます。詳細は [Spring JDBCのドキュメント](https://spring.pleiades.io/spring-framework/docs/current/javadoc-api/org/springframework/jdbc/core/JdbcTemplate.html) を参照してください。  

##### データの更新

`JdbcTemplate`クラスの`update`メソッドを使用してTsurugiのデータを更新（INSERT/UPDATE/DELETE）することができます。  

~~~java
    @Autowired  // 依存性注入（依存オブジェクトを疎結合）
    private JdbcTemplate jdbcTemplate;
    // 実行するSQL文（ステートメントキャッシュを利用）
    private static final String INSERT_SQL = "insert into sample (num) values (?)";
    private static final String UPDATE_SQL = "update sample set num = ? where num % 3 = 0";
    private static final String DELETE_SQL = "delete from sample where num = ?";

    public void updateTsurugiData() {
        jdbcTemplate.update(INSERT_SQL, 9);
        jdbcTemplate.update(UPDATE_SQL, 0);
        jdbcTemplate.update(DELETE_SQL, 0);
    }
~~~

##### データの問い合わせ

`JdbcTemplate`クラスの`queryForList`メソッドを使用してTsurugiのデータを問い合わせる（SELECT）ことができます。  

~~~java
    @Autowired  // 依存性注入（依存オブジェクトを疎結合）
    private JdbcTemplate jdbcTemplate;
    // 実行するSQL文
    private static final String QUERY_SQL = "select * from sample";

    public List<Map<String, Object>> queryTsurugiData() {
        return jdbcTemplate.queryForList(QUERY_SQL);
    }
~~~

#### CRUDの実行（Spring Framework）

Spring Frameworkを使用してCRUDを実行（オブジェクト指向的にデータベース操作）する方法はいくつかありますが、`Spring Data JPA`および`Spring Data JDBC`を使用する一般的な方法を説明します。

##### エンティティクラス作成

データベースのテーブルに対応するエンティティクラスを作成します。  
ここでは、`Spring Data JPA`のコード例を示します。

~~~java
package com.tsurugidb.fdw.spring.boot.data.jpa.sample;
import jakarta.persistence.*;

@Entity  // このクラスがJPAエンティティであることを示す
@Table(name = "sample")  // データベースのテーブル名を指定 (省略するとクラス名がテーブル名になる)
public class SampleEntity {
    @Id  // 主キーであることを示す
    private String id;
    @Column(nullable = false)
    private Integer num;

    public SampleEntity() {
        // 主キーは手動生成する
        this.id = UUID.randomUUID().toString();
    }
    public SampleEntity(Integer num) { 
        // 主キーは手動生成する
        this.id = UUID.randomUUID().toString();
        this.num = num;
    }

    public String getId() { return id; }
    public void setId(String id) { this.id = id; }

    public Integer getNum() { return num; }
    public void setNum(Integer num) { this.num = num; }
}
~~~

> [!IMPORTANT]
> 主キーの生成戦略として自動生成を利用することはできません。  
> 主キーはエンティティクラスのコンストラクタなどで手動生成する必要があります。  
>
> 主キーを自動生成すると、Spring Framework(JDBC)はデータ作成(Create)時にRETURNING句を付与したINSERT SQLコマンドを実行します。  
> TsurugiはSQLコマンドでのRETURNING句をサポートしていないため、主キーを自動生成するデータ作成は失敗してしまう制約事項があります（`Spring Data JPA`の`@GeneratedValue`も実装することはできません）。

##### リポジトリインターフェース作成

データベースを操作（Create, Read, Update, Delete）するためのリポジトリインターフェースを作成します。  
ここでは、`Spring Data JPA`のコード例を示します。`Spring Data JDBC`の場合はCrudRepositoryを継承してください。

~~~java
package com.tsurugidb.fdw.spring.boot.data.jpa.sample;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository // このインターフェースがリポジトリであることを示す
public interface SampleRepository extends JpaRepository<SampleEntity, String> {
    // JpaRepositoryを継承することで、以下のメソッドが自動的に提供される:
    // save(entity): エンティティの保存/更新
    // findById(id): IDでエンティティを検索
    // findAll(): 全てのエンティティを検索
    // deleteById(id): IDでエンティティを削除
    // count(): エンティティの数を数える

    // さらに、命名規則に従ってカスタムクエリメソッドを定義できる
    Iterable<SampleEntity> findAllByOrderByNumAsc(); // 例: ソートした全てのエンティティを検索
}
~~~


##### サービスクラス作成

サービスクラスの作成は任意だが、ビジネスロジックをカプセル化するために作成します。

#### トランザクション操作（Spring Framework）

#### エラー情報の取得（Spring Framework）

#### サンプルプログラム（Spring Framework）

