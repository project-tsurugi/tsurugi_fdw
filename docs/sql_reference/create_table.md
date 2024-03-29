# [リファレンス（SQL）](../sql_reference.md)

## CREATE TABLE

  CREATE TABLE － Tsurugiに新しいテーブルを定義する。

### 概要

  ~~~sql
  CREATE TABLE [ IF NOT EXISTS ] table_name ( [  
    { column_name data_type [ column_constraint [ ... ] ]  
      | table_constraint }  
      [, ... ]
  ] )  
  TABLESPACE tsurugi

  ここで、列制約(column_constraint)には、次の構文が入ります。  
  [ CONSTRAINT constraint_name ]  
  { NOT NULL |  
    NULL |
    CHECK ( expression ) |
    DEFAULT default_expr |
    UNIQUE |
    PRIMARY KEY |
    REFERENCES reftable |
    PRIMARY KEY }  

  また、テーブル制約(table_constraint)には、次の構文が入ります。
  [ CONSTRAINT constraint_name ]  
  { CHECK ( expression ) |
    UNIQUE index_parameters |
    PRIMARY KEY ( column_name [, ... ] ) index_parameters |
    FOREIGN KEY ( column_name [, ... ] ) REFERENCES reftable }

  UNIQUEおよびPRIMARY KEYのindex_parametersは以下の通りです。
  [ INCLUDE ( column_name [, ... ] ) ]
  ~~~

### 説明

  CREATE TABLEは、テーブル空間(TABLESPACE)にtsurugiを指定することで、新しい空のテーブルをTsurugiに作成します。
  Tsurugiに作成したテーブルはこのコマンドを実行したユーザが所有します。

  テーブル名は、他のテーブル、シーケンス、インデックス、ビュー、外部テーブルとは異なる名前にする必要があります。

  制約句には、作成するテーブルへの挿入や更新操作が成功するために、新しい行または更新する行が満たさなければならない制約を指定します。制約句はオプション（省略可能）です。  
  制約の定義にはテーブル制約と列制約という2種類があります。  
  列制約は、列の一部として定義されます。
  テーブル制約は、特定の列とは結びつけられておらず、複数の列を含むことができます。
  また、全ての列制約はテーブル制約として記述することができます。

  テーブルに作成する列には、型を持たなければなりません。

  CREATE TABLEのリファレンスは、PostgreSQLのCREATE TABLEに準じます。  
  PostgreSQLとの差分については「[互換性](#互換性)」を参照してください。  
  また、Tsurugi固有の仕様および制限については、Tsurugiのドキュメントを確認してください。

### パラメータ

* **IF NOT EXISTS**  
  同じ名前のリレーションがすでに存在していてもエラーとしません。

* **table_name**  
  作成するテーブルの名前です。

* **column_name**  
  新しいテーブルで作成される列の名前です。

* **data_type**  
  列のデータ型です。  

* **CONSTRAINT constraint_name**  
  列制約、テーブル制約の名前です。

* **NOT NULL**  
  その列がNULL値を持てないことを指定します。

* **NULL**  
  その列がNULL値を持てることを指定します。

* **CHECK ( expression )**  
  作成するテーブルへの挿入または更新操作が成功するために、新しい行または更新された行が満たさなければならないBoolean型の結果を返す条件式を指定します。  

  Tsurugiでは、CHECK制約におけるNO INHERITオプションを非サポートとします。

* **DEFAULT default_expr**  
  列にデフォルトのデータ値を割り当てます。  

* **UNIQUE （列制約）**  
  **UNIQUE ( column_name [, ... ] ) [ INCLUDE ( column_name [, ...]) ] (テーブル制約)**  
  テーブルの1つまたは複数の列からなるグループが、一意な値のみを持つことができることを指定します。  

  Tsurugiでは、WITH句にインデックスのパラメータを格納できません。非サポートとします。
  
* **PRIMARY KEY （列制約）**  
  **PRIMARY KEY ( column_name [, ... ] ) [ INCLUDE ( column_name [, ...]) ] (テーブル制約)**  
  テーブルの1つまたは複数の列からなるグループが、一意（重複がない）で非NULLの値のみを持つことを指定します。  
  
  Tsurugiでは、WITH句にインデックスのパラメータを格納できません。非サポートとします。

* **REFERENCES reftable [ ( refcolumn ) ] [ MATCH matchtype ] [ ON DELETE action ] [ ON UPDATE action ] （列制約）**  
  **FOREIGN KEY ( column_name [, ... ] ) REFERENCES reftable [ ( refcolumn [, ... ] ) ] [ MATCH matchtype ] [ ON DELETE referential_action ] [ ON UPDATE referential_action ] （テーブル制約）**  
  テーブルの1つまたは複数の列からなるグループが、被参照テーブルの一部の行の被参照列に一致する値を持たなければならないことを指定します。  

  Tsurugiでは、被参照列のデータが削除(ON DELETE)または更新(ON UPADTE)された場合の動作にCASCADEを指定することはできません。非サポートとします。

* **TABLESPACE tsurugi**  
  Tsurugiのテーブルが作成されるテーブル空間名であり、tsurugiを指定する必要があります。

### 例

* filmsテーブルとdistributorsテーブルを作成します。

  ~~~sql
  CREATE TABLE hollywood.films (
      code        char(5),
      title       varchar(40),
      did         integer,
      kind        varchar(10)
  ) TABLESPACE tsurugi;

  CREATE TABLE IF NOT EXISTS distributors (
      did    integer,
      name   varchar(40)
  ) TABLESPACE tsurugi;
  ~~~

  * filmsテーブルは、hollywoodスキーマに作成しています。
  * distributorsテーブルは、既に存在している場合に注意が出力されます。

* NOT NULL制約

  ~~~sql
  CREATE TABLE distributors (
      did    integer CONSTRAINT no_null NOT NULL,
      name   varchar(40) NOT NULL
  ) TABLESPACE tsurugi;
  ~~~

  * did列とname列にNOT NULL制約を定義しています。
  * did列に明示的な名前no_nullを付けています。

* CHECK制約

  ~~~sql
  CREATE TABLE distributors (
      did    integer CHECK (did > 100),
      name   varchar(40)
  ) TABLESPACE tsurugi;

  CREATE TABLE distributors_table (
      did    integer,
      name   varchar(40),
      CONSTRAINT table_check CHECK (did > 100 AND name <> '')
  ) TABLESPACE tsurugi;
  ~~~

  * distributorsテーブルは、did列にCHECK列制約を定義しています。
  * distributors_tableテーブルは、CHECKテーブル制約を定義しています。

* DEFAULT制約

  ~~~sql
  CREATE TABLE distributors (
      name      varchar(40) DEFAULT 'Luso Films',
      did       integer DEFAULT 100
  ) TABLESPACE tsurugi;
  ~~~

  * name列とdid列にDEAFALT制約を定義しています。

* UNIQUE制約

  ~~~sql
  CREATE TABLE distributors (
      name      varchar(40) UNIQUE,
      did       integer
  ) TABLESPACE tsurugi;

  CREATE TABLE distributors_table (
      name      varchar(40),
      did       integer,
      UNIQUE (name, did)
  ) TABLESPACE tsurugi;

  CREATE TABLE distributors_index (
      name      varchar(40),
      did       integer,
      UNIQUE (name, did) INCLUDE (did)
  ) TABLESPACE tsurugi;
  ~~~

  * distributorsテーブルは、name列にUNIQUE列制約を定義しています。
  * distributors_tableテーブルは、name列とdid列にUNIQUEテーブル制約を定義しています。
  * distributors_indexテーブルは、name列とdid列にUNIQUEテーブル制約を定義し、did列を非キー列としています。

* PRIMARY KEY制約

  ~~~sql
  CREATE TABLE films (
      code        char(5) PRIMARY KEY,
      title       varchar(40),
      did         integer,
      kind        varchar(10)
  ) TABLESPACE tsurugi;

  CREATE TABLE films_table (
      code        char(5),
      title       varchar(40),
      did         integer,
      kind        varchar(10),
      CONSTRAINT code_title PRIMARY KEY (code, title)
  ) TABLESPACE tsurugi;

  CREATE TABLE films_index (
      code        char(5),
      title       varchar(40),
      did         integer,
      kind        varchar(10),
      CONSTRAINT code_title PRIMARY KEY (code, title) INCLUDE (title)
  ) TABLESPACE tsurugi;
  ~~~

  * filmsテーブルは、code列にPRIMARY KEY列制約を定義しています。
  * films_tableテーブルは、code列とtitle列をセットとしたPRIMARY KEYテーブル制約を定義しています。
  * films_indexテーブルは、code列とtitle列にUNIQUEテーブル制約を定義し、title列を非キー列としています。

* FOREIGN KEY制約

  ~~~sql
  CREATE TABLE films (
      code        char(5),
      title       varchar(40) REFERENCES cinema,
      did         integer,
      kind        varchar(10)
  ) TABLESPACE tsurugi;

  CREATE TABLE films_table (
      code        char(5),
      title       varchar(40),
      did         integer,
      kind        varchar(10),
      FOREIGN KEY (title)  REFERENCES cinema (name) MATCH SIMPLE ON DELETE NO ACTION ON UPDATE NO ACTION
  ) TABLESPACE tsurugi;

  CREATE TABLE films_match (
      code        char(5),
      title       varchar(40),
      did         integer,
      kind        varchar(10),
      FOREIGN KEY (title did)  REFERENCES cinema (name) MATCH FULL
  ) TABLESPACE tsurugi;

  CREATE TABLE films_action (
      code        char(5),
      title       varchar(40),
      did         integer,
      kind        varchar(10),
      FOREIGN KEY (title)  REFERENCES cinema (name) ON DELETE SET NULL
  ) TABLESPACE tsurugi;
  ~~~

  * filmsテーブルは、title列にcinemaを被参照テーブルとした外部キー列制約を定義しています。
  * films_tableテーブルは、filmsテーブルと同じ設定の外部キーテーブル制約を定義しています。
  * films_matchテーブルは、すべての参照列がNULLまたはNULL以外となる制約を定義しています。
  * films_actionテーブルは、被参照テーブルの被参照行が削除されようとした場合に参照列がNULLとなるよう定義しています。

### 互換性

Tsurugi FDWのCREATE TABLEは、以下に挙げるものを除いて、PostgreSQLに従います。

* **構文**  
  Tsurugiでは、以下のパラメータを非サポートとします。  
  * TEMPORARY | TEMP
  * UNLOGGED
  * OF type_name
  * COLLATE collation
  * INHERITS ( parent_table [, ... ] )
  * PARTITION BY { RANGE | LIST | HASH } ( { column_name | ( expression ) } [ opclass ] [, ...] )
  * PARTITION OF parent_table { FOR VALUES partition_bound_spec | DEFAULT }
  * LIKE source_table [ like_option ... ]
  * GENERATED ALWAYS AS ( generation_expr ) STORED
  * GENERATED { ALWAYS | BY DEFAULT } AS IDENTITY [ ( sequence_options ) ]
  * EXCLUDE [ USING index_method ] ( exclude_element WITH operator [, ... ] ) index_parameters [ WHERE ( predicate ) ]
  * DEFERRABLE | NOT DEFERRABLE
  * INITIALLY IMMEDIATE | INITIALLY DEFERRED
  * USING method
  * WITH ( storage_parameter [= value] [, ... ] )
  * ON COMMIT
  * USING INDEX TABLESPACE tablespace_name

### エラー処理

Tsurugiでサポートしない構文・型はエラーとして出力します。  
内部で発生したエラーは、呼び出した関数の戻り値でエラーを受け取ってエラーメッセージを出力します。

#### 構文エラー

* Tsurugiでサポートしない構文が実行されたとき、次のエラーメッセージを出力する。

  ~~~ txt
  ERROR:  Tsurugi does not support this syntax
  ~~~

#### 型エラー

* Tsurugiでサポートしない型が指定されたとき、次のエラーメッセージを出力する。

  ~~~ txt
  ERROR:  Tsurugi does not support type %s
  ~~~

  %sは、データ型名を出力
