# [Tsurugi FDW for Tsurugi](./README.md)

## 付録

### 注意事項

PostgreSQLとTsurugiはアーキテクチャおよびその性質が異なるため、PostgreSQLをTsurugiのユーザインタフェースとして利用する際は以下の点に注意する必要があります。

1. ORDER BY句を利用して文字列型のデータを問い合わせた場合、対象データの大文字小文字を区別して並べ替えます。PostgreSQLは大文字小文字を区別しません。

2. ORDER BY句のNULLSオプションのデフォルトが`NULLS FIRST`になります。PostgreSQLは`NULLS LAST`です。

3. SQLのINSERTコマンドに`insert-option`（OR REPLACE/OR IGNORE/IF NOT EXISTS）が指定できません。PostgreSQLは`insert-option`を指定することができません。

4. Tsurugiのデータ型とそれに対応するJDBC API(Java)およびPostgreSQLのデータ型は適切にマッピングする必要があります。  

    |#| Tsurugi | Java(JDBC) | PostgreSQL |
    |:---:| :---: | :---: | :---: |
    |1.| INT | int・Integer | integer |
    |2.| BIGINT | long・Long | bigint |
    |3.| REAL | float・Float | real |
    |4.| FLOAT | double・Double | double precision |
    |5.| DOUBLE | double・Double | double precision |
    |6.| DECIMAL | java.math.BigDecimal | decimal・numeric |
    |7.| CHAR・CHARACTER | String | char・character |
    |8.| VARCHAR・CHAR VARYING・CHARACTER VARYING | String | varchar・character varying |
    |9.| BINARY | byte[] | bytea |
    |10.| VARBINARY・BINARY VARYING | byte[] | bytea |
    |11.| DATE | java.sql.Date・LocalDate | date |
    |12.| TIME | java.sql.Time・LocalTime | time |
    |13.| TIME WITH TIME ZONE | - [※]((https://jdbc.postgresql.org/documentation/query/#using-java-8-date-and-time-classes)) | time with time zone |
    |14.| TIMESTAMP | java.sql.Timestamp・LocalDateTme | timestamp |
    |15.| TIMESTAMP WITH TIME ZONE | OffsetDateTime | timestamp with time zone |

    ※ PostgreSQL JDBDドライバは`TIME WITH TIME ZONE`型を[非サポート](https://jdbc.postgresql.org/documentation/query/#using-java-8-date-and-time-classes)としています。

5. JDBC APIで送信可能なSQL文は、Tsurugi_FDWがサポートする[SQLコマンド](./sql_reference.md)および[ユーザ定義関数](./udf_reference.md)に限ります。  

6. JDBC APIのPreparedStatementではPostgreSQLに対してはステートメントキャッシュが効きますが、PostgreSQLからTsurugiへの実行においてはステートメントキャッシュは効きません。

7. Spring Frameworkを使用する場合、主キーの生成戦略に自動生成を指定できません。主キーはエンティティクラスのコンストラクタなどで手動生成する必要があります。主キーを自動生成するとTsurugiでサポートしていないRETURNING句がINSERT SQL文に付与されるため、INSERT SQL文の実行（CRUD操作のデータ作成）が失敗します。

### 制限事項

制限事項は以下の通りです。

1. publicスキーマに外部テーブルを作成してください。publicスキーマ以外では外部テーブルを経由してTsurugiのデータを操作をすることはできません。

2. バイナリデータ型（BINARY/VARBINARY/BINARY VARYING）を操作することはできません。

3. SQLのPREPAREコマンドでプリペアするSQL文に集合演算子（UNION/EXCEPT/INTERSECT）があるとEXECUTEコマンドで正しい結果を得ることができません。

4. PostgreSQL固有の文法を含むクエリーを実行すると失敗する場合があります。

5. SELECT文の選択リストとして指定できるのは列の参照と集約式のみです。

6. 暗黙的なJOINを含むクエリーは実行できません。

### サードパーティライセンス

Tsurugi FDWには、ライセンス規定または著作権の表示が必要なサードパーティ製ソフトウェアが含まれています。  
サードパーティ製ソフトウェアの要件に準拠できるよう、ライセンス規定または著作権のコピーを記載します。

- PostgreSQL License

  ~~~txt
  PostgreSQL Database Management System
  (formerly known as Postgres, then as Postgres95)

  Portions Copyright (c) 1996-2023, PostgreSQL Global Development Group

  Portions Copyright (c) 1994, The Regents of the University of California

  Permission to use, copy, modify, and distribute this software and its
  documentation for any purpose, without fee, and without a written agreement
  is hereby granted, provided that the above copyright notice and this
  paragraph and the following two paragraphs appear in all copies.

  IN NO EVENT SHALL THE UNIVERSITY OF CALIFORNIA BE LIABLE TO ANY PARTY FOR
  DIRECT, INDIRECT, SPECIAL, INCIDENTAL, OR CONSEQUENTIAL DAMAGES, INCLUDING
  LOST PROFITS, ARISING OUT OF THE USE OF THIS SOFTWARE AND ITS
  DOCUMENTATION, EVEN IF THE UNIVERSITY OF CALIFORNIA HAS BEEN ADVISED OF THE
  POSSIBILITY OF SUCH DAMAGE.

  THE UNIVERSITY OF CALIFORNIA SPECIFICALLY DISCLAIMS ANY WARRANTIES,
  INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY
  AND FITNESS FOR A PARTICULAR PURPOSE.  THE SOFTWARE PROVIDED HEREUNDER IS
  ON AN "AS IS" BASIS, AND THE UNIVERSITY OF CALIFORNIA HAS NO OBLIGATIONS TO
  PROVIDE MAINTENANCE, SUPPORT, UPDATES, ENHANCEMENTS, OR MODIFICATIONS.
  ~~~

### 修正履歴

#### 1.0.0

- 初版

#### 1.1.0

- SQLのPREPAREコマンドで制約事項としていた以下のSQL構文の使用を解除  
  SELECT文で指定可能なset-quantifier（ALL/DISTINCT）  
  SELECT文で指定可能なLIMIT句  
  INSERT文のinsert-sourceで指定可能なDEFAULT VALUES  
  INSERT文のinsert-sourceで指定可能なquery-expression  
- SQLのIMPORT FOREIGN SCHEMAコマンドを追加

#### 1.2.0

- 制限事項を追加（3, 4, 5）

以上
