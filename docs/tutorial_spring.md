# [Tsurugi FDW for Tsurugi](./README.md)

## チュートリアル

### Spring Frameworkを使用

Spring Frameworkを使用してTsurugiを利用（Javaアプリケーションからデータベースにアクセス）する一般的な方法を説明します。  

#### Spring Frameworkとは

Spring FrameworkはJavaアプリケーションを効率的に開発するためのオープンソースのフレームワークです。  
Spring Frameworkの機能を使用することでTsurugiを効率的に利用（データベース接続、SQL文実行、CRUD操作など）することができます。  
Tsurugi FDWがサポートするSpring Frameworkの機能については [リファレンス（Spring Framework）](./spring_reference.md) を参照してください。  

##### Spring Frameworkの主な機能（一部抜粋）

- DI(Dependency Injection)コンテナ:  
アプリケーションコンポーネントの配置とライフサイクルを管理し、依存関係を外部から注入することができる。  
- AOP(アスペクト指向プログラミング):  
ログ、トランザクション、セキュリティといった、クラスの横断的な処理の実装を可能にすることができる。  
- トランザクション管理:  
データベースなどのトランザクション制御を一元的に管理し、Javaオブジェクトのトランザクションを管理することができる。  
- データアクセス:  
JDBC、ORM（Object-Relational Mapping）、R2DBC（Reactive Relational Database Connectivity）などを通じて、RDBへのアクセスを簡素化することができる。  

##### Spring Frameworkの主なプロジェクト（一部抜粋）

- Spring JDBC:  
JDBC APIを使いやすくするためのユーティリティクラスとヘルパーメソッドを提供している。
- Spring Data JPA（ORM）:  
Java Persistence API (JPA) を利用してデータアクセスを簡素化（リポジトリインターフェースを定義しCRUD 操作を自動化）することができる。
- Spring Data JDBC（ORM）:  
JDBC APIを利用してデータアクセスを簡素化（リポジトリインターフェースを定義しCRUD 操作を自動化）することができる。
- Spring Boot:  
Spring Frameworkでの開発を迅速化し各機能を容易に行えるよう設計されたツールを提供している。

#### Spring Frameworkのライブラリ入手

Spring Frameworkのライブラリは [https://spring.io/projects](https://spring.pleiades.io/projects) で公開されています。Javaアプリケーションの要件に適したライブラリをダウンロードしてください。  

[Spring Initializr](https://start.spring.io/)にアクセスするとJavaアプリケーションの雛形を簡単に作成することができます。  
Javaアプリケーションに追加する依存ライブラリは、Tsurugi FDWがサポートする以下のSpring Frameworkプロジェクトを選択（複数可）してください。  

- JDBC API [SQL]  
Database Connectivity API that defines how a client may connect and query a database.
- Spring Data JPA [SQL]  
Persist data in SQL stores with Java Persistence API using Spring Data and Hibernate.
- Spring Data JDBC [SQL]  
Persist data in SQL stores with plain JDBC using Spring Data.

#### データベースへの接続（Spring Framework）

Spring Frameworkを使用してデータベースに接続する方法はいくつかありますが、一般的な方法を２つ説明します。

##### 1. DriverManagerDataSourceクラスを利用

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

`Spring Data JPA`の場合、上記データベース接続情報をEntityManagerFactoryクラスに設定（JpaTransactionManagerのインスタンスに設定）することでデータベースに接続することができます。  

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

##### 2. Spring Bootを利用

Spring Bootを利用する場合、`application.properties`ファイルにデータベース接続情報を設定します。  

~~~properties
spring.datasource.url=jdbc:postgresql://localhost:5432/your_database_name
spring.datasource.username=your_username
spring.datasource.password=your_password
~~~

`application.properties`ファイルに指定したデータベース接続情報は、Javaアプリケーションが起動する直前に読み込まれ、自動でデータベースに接続します。  

#### SQL文の実行（Spring Framework）

Spring Frameworkを使用してSQL文を実行する方法はいくつかありますが、一般的な方法を説明します。  

##### `JdbcTemplate`クラスを使用

`Spring JDBC`の`JdbcTemplate`クラスを使用してSQL文を実行することができます。  
`JdbcTemplate`クラスの利用方法はSpring Frameworkの仕様に準じます。詳細は [Spring Frameworkのドキュメント](https://spring.pleiades.io/spring-framework/docs/current/javadoc-api/org/springframework/jdbc/core/JdbcTemplate.html) を参照してください。  

###### データの更新

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

###### データの問い合わせ

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

**セルフレビュー指摘：  
SQL文が実行できるので、UDFを使ってTsurugi固有のトランザクション属性（LTXやRTX）が変更できるチュートリアルを書いた方がよい！と思う。**


#### CRUDの実行（Spring Framework）

Spring Frameworkを使用してオブジェクト指向的にデータベース操作する方法はいくつかありますが、一般的な方法を説明します。  

##### エンティティクラス作成

データベースのテーブルに対応するエンティティクラスを作成します。  
ここでは、`Spring Data JPA`のコード例を示します。

~~~java
package com.tsurugidb.fdw.spring.boot.data.jpa.sample;
import jakarta.persistence.*;

@Entity  // このクラスがエンティティであることを示す
@Table(name = "sample")  // データベースのテーブル名を指定 (省略するとクラス名がテーブル名になる)
public class SampleEntity {
    @Id  // 主キーであることを示す
    private String id;
    @Column(nullable = false) // NULL値を持てないカラムであることを示す
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
> **主キーの生成戦略で自動生成を利用することはできません。**  
> **主キーはエンティティクラスのコンストラクタなどで手動生成する必要があります。**  
>
> Javaアプリケーションから主キーを自動生成すると、Spring Framework(PostgreSQL JDBC Driver)はデータを作成する際にRETURNING句を付与したINSERT SQLコマンドを実行します。  
> TsurugiはSQLコマンドのRETURNING句をサポートしていないため、主キーが自動生成されたデータ作成は失敗します（Tsurugi FDWの注意事項）。  

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

ビジネスロジックをカプセル化するためのサービスクラスを作成します。  
ここでは、Tsurugiにアクセスするデータベース操作を集約する目的で利用しています。  

~~~java
@Service // このクラスがサービスクラスであることを示す
public class SampleService {
    @Autowired  // リポジトリインターフェースの依存性注入
    private SampleRepository sampleRepository;
    public void SaveEntityButOddDelete(SampleEntity entity) {
        // データ（SampleEntity）を保存
        sampleRepository.save(entity);
        if (entity.getNum() % 2 != 0) {
            // 偶数の場合 データ（SampleEntity）を削除
            sampleRepository.delete(entity);
        }
    }
    public void SaveEntityMultiOfThreeUpdate(Time updateTime) {
        // 対象のデータ(全て)を検索
        sampleRepository.findAll().forEach(entity -> {
            if (entity.getNum() % 3 == 0) {
                // ３の倍数の場合 データ（SampleEntity）を更新
                entity.setTim(updateTime);
                sampleRepository.save(entity);
            }
        });
    }
}
~~~

#### トランザクション操作（Spring Framework）

Spring Frameworkを使用してトランザクションを操作する方法はいくつかありますが、一般的な方法を２つ説明します。  

##### 1. プログラム的トランザクション

Spring Frameworkの`TransactionTemplate`クラスを使用してトランザクションを操作することができます。  
`TransactionTemplate`クラスの利用方法はSpring Frameworkの仕様に準じます。詳細は [Spring Frameworkのドキュメント](https://spring.pleiades.io/spring-framework/reference/data-access/transaction/programmatic.html) を参照してください。  

~~~java
    // トランザクションマネージャーの作成
    PlatformTransactionManager transactionManager = new DataSourceTransactionManager(dataSource);
    // TransactionTemplateの作成
    TransactionTemplate transactionTemplate = new TransactionTemplate(transactionManager);

    transactionTemplate.execute(status -> {
        String insertSql = "INSERT INTO sample (num) VALUES (?)";
        jdbcTemplate.update(insertSql, number);
        if (number % 2 != 0) {
            // 奇数の場合ロールバックする
            // ロールバックをトリガーする例外をスローする代わりに
            // トランザクションマネージャーにロールバックを指示する
            status.setRollbackOnly();
        }
        return null;
    });
~~~

##### 2. 宣言的トランザクション

Spring Frameworkの`@Transactional`(アノテーション)を使用してトランザクションを操作することができます。  
`@Transactional`クラスの利用方法はSpring Frameworkの仕様に準じます。詳細は [Spring Frameworkのドキュメント](https://spring.pleiades.io/spring-framework/reference/data-access/transaction/programmatic.html) を参照してください。  

~~~java
    @Autowired  // 依存性注入（依存オブジェクトを疎結合）
    private JdbcTemplate jdbcTemplate;
    // 実行するSQL文（ステートメントキャッシュを利用）
    private static final String INSERT_SQL = "insert into sample (num) values (?)";

    @Transactional // このメソッド全体が単一のトランザクションで実行される
    public void updateTsurugiData(int number) {
        jdbcTemplate.update(INSERT_SQL, number);
        if (number % 2 != 0) {
            // 奇数の場合ロールバックする
            throw new RuntimeException("Rollback! for num = " + number);
        }
        // 例外が発生しなかった場合、トランザクションはコミットされる
        // 例外が発生した場合、トランザクションはロールバックされる    
    }

    @Transactional  // クラス全体に適用することも可能
    public class AnotherService {
        public void someMethod() {
            // このクラスのすべてのpublicメソッドにトランザクションが適用される
        }
    }
~~~

#### エラー情報の取得（Spring Framework）

Spring Frameworkを使用したデータベース操作中に何らかの異常が発生すると、[`DataAccessException`](https://spring.pleiades.io/spring-framework/docs/current/javadoc-api/org/springframework/dao/DataAccessException.html)が通知されます。  
DataAccessExceptionクラスのgetMessageメソッドを使用してエラー情報を取得することができます。  
エラー情報の取得方法はSpring Frameworkの仕様に準じます。詳細は [Spring Frameworkのドキュメント](https://spring.pleiades.io/spring-framework/docs/current/javadoc-api/org/springframework/dao/package-summary.html) を参照してください。  
Tsurugi FDWが出力するエラーメッセージについては [リファレンス（メッセージ）](./message_reference.md) を参照してください。

~~~java
try {
    ：
} catch (DataAccessException e) {
    /* エラーが発生した場合のメッセージを出力する */
    System.out.println("DataAccessException e.getMessage = " + e.getMessage());
    e.printStackTrace();
}
~~~

> [!TIP]
> Spring Frameworkは、データアクセスに関する一貫した例外階層（org.springframework.daoパッケージ）があり、`Spring JDBC`、`Spring Data JPA`、`Spring Data JDBC`など、プロジェクト毎のデータアクセス技術が異なっていても、統一的にエラーを処理することができます。

#### サンプルプログラム（Spring Framework）

Spring Frameworkを使用してTsurugiを利用するサンプルプログラムを示します。

##### サンプルプログラムの概要

Tsurugiの `fdw_sample` テーブルに、以下の順番でデータの操作を行います。

1. データ(行)挿入
    1. `1` から `10` までの数値と更新時刻を有するデータ(行)を1秒間隔で挿入 (**Create**)
    1. 挿入した行の数値が `奇数` の場合、当該データ(行)を削除 (**Delete**)
    1. `11` から `20` までの数値と更新時刻を有するデータ(行)を1秒間隔で挿入 (**Create**)
    1. 挿入したデータ(行)の数値が `奇数` の場合、当該挿入操作をロールバック (**Transaction**)
1. 全データ(行)問い合わせ (**Read**)
1. データ(行)の数値が`3の倍数`の場合、当該データ(行)の更新時刻を更新 (**Update**)
1. 全データ(行)問い合わせ (**Read**)

##### サンプルプログラムのソースコード

ソースコードおよび実行環境（Gradleを使用）は以下にあるファイルを確認してください。

- Spring JDBC: [sample/spring-boot-jdbc-sample/](../sample/spring-boot-jdbc-sample/)、[sample/spring-jdbc-sample/](../sample/spring-jdbc-sample/)
- Spring Data JPA: [sample/spring-boot-data-jpa-sample/](../sample/spring-boot-data-jpa-sample/)
- Spring Data JDBC: [sample/spring-boot-data-jdbc-sample/](../sample/spring-boot-data-jdbc-sample/)

> [!TIP]
> TsurugiのテーブルおよびTsurugi FDWの外部テーブルは、アプリケーション実行直前に作成し、アプリケーション終了後に削除しています。  
> 詳細は実行環境内のGradle設定ファイル(build.gradle)を確認してください。

##### サンプルプログラムの実行イメージ

~~~log
> Task :module:run
The sample application is running. Please wait 20 seconds...
Inserted Number.1.3.5.7.9.11.13.15.17.19.
  01-10: Even do nothing, Odd delete.
  11-20: Even commit, Odd rollback.
    Number      UpdateTime      PrimaryKey
     02          17:12:32        b1bddd92-d97c-4dad-a4ca-21c6506f5d50
     04          17:12:34        cb6d81ec-0e7a-46f7-a9b7-ae016e100d6f
     06          17:12:36        7a5c7991-027a-4926-8284-ef720dcc85d8
     08          17:12:38        d3e98972-dda5-4fc4-8b69-7169911329b9
     10          17:12:40        6456b8be-1f4f-4b13-911e-0882a99301dd
     12          17:12:42        73aea7b4-ae74-4830-98ff-7e3fbd469814
     14          17:12:44        ac58ab87-4cb3-4e34-a714-fa239572bd3a
     16          17:12:46        bbb9cbe6-58ad-4887-a922-5ef5c007ac19
     18          17:12:48        eddd6949-a004-4787-9245-a12f3f783b74
     20          17:12:50        98f25e5f-a121-463a-be7a-8da0b36a3f8a

Updated UpdateTime.
  Multiples of 3: Update the Time(17:12:52).
    Number      UpdateTime      PrimaryKey
     02          17:12:32        b1bddd92-d97c-4dad-a4ca-21c6506f5d50
     04          17:12:34        cb6d81ec-0e7a-46f7-a9b7-ae016e100d6f
     06          17:12:52        7a5c7991-027a-4926-8284-ef720dcc85d8
     08          17:12:38        d3e98972-dda5-4fc4-8b69-7169911329b9
     10          17:12:40        6456b8be-1f4f-4b13-911e-0882a99301dd
     12          17:12:52        73aea7b4-ae74-4830-98ff-7e3fbd469814
     14          17:12:44        ac58ab87-4cb3-4e34-a714-fa239572bd3a
     16          17:12:46        bbb9cbe6-58ad-4887-a922-5ef5c007ac19
     18          17:12:52        eddd6949-a004-4787-9245-a12f3f783b74
     20          17:12:50        98f25e5f-a121-463a-be7a-8da0b36a3f8a
~~~
