# [Tsurugi FDW for Tsurugi](./tsurugi_fdw.md)

## 付録

### 注意事項

PostgreSQLとTsurugiはアーキテクチャおよびその性質が異なるため、PostgreSQLをユーザインタフェースとしてTsurugiを利用する際は以下の点に注意する必要があります。

- ORDER BY句を利用して文字列型のデータを問い合わせた場合、対象データの大文字小文字をソート条件に含みます。PostgreSQLは大文字小文字を区別しません。

- ORDER BY句のNULLSオプションのデフォルトがNULLS FIRSTとなります。PostgreSQLはNULLS LASTです。

- SQLのINSERTコマンドに`insert-option`（OR REPLACE/OR IGNORE/IF NOT EXISTS）が指定できません。PostgreSQLは`insert-option`を指定することができません。

- Tsurugiのデータ型とそれに対応するJDBC API(Java)およびPostgreSQLのデータ型は適切にマッピングする必要があります。※ PostgreSQL JDBDドライバは`TIME WITH TIME ZONE`型を[非サポート](https://jdbc.postgresql.org/documentation/query/#using-java-8-date-and-time-classes)としています。

    | Tsurugi | Java(JDBC) | PostgreSQL |
    | :---: | :---: | :---: |
    | INT | int・Integer | integer |
    | BIGINT | long・Long | bigint |
    | REAL | float・Float | real |
    | FLOAT | double・Double | double precision |
    | DOUBLE | double・Double | double precision |
    | DECIMAL | java.math.BigDecimal | decimal・numeric |
    | CHAR・CHARACTER | String | char・character |
    | VARCHAR・CHAR VARYING・CHARACTER VARYING | String | varchar・character varying |
    | BINARY | byte[] | bytea |
    | VARBINARY・BINARY VARYING | byte[] | bytea |
    | DATE | java.sql.Date・LocalDate | date |
    | TIME | java.sql.Time・LocalTime | time |
    | TIME WITH TIME ZONE | - [※]((https://jdbc.postgresql.org/documentation/query/#using-java-8-date-and-time-classes)) | time with time zone |
    | TIMESTAMP | java.sql.Timestamp・LocalDateTme | timestamp |
    | TIMESTAMP WITH TIME ZONE | OffsetDateTime | timestamp with time zone |

- JDBC APIで送信可能なSQL文は、Tsurugi_FDWがサポートする[SQLコマンド](./sql_reference.md)および[ユーザ定義関数](./udf_reference.md)に限ります。  

- JDBC APIのPreparedStatementではSELECT文のステートメントキャッシュが利用できません。このためPreparedStatementを使用した場合でもSELECT文の性能向上は見込めません。  
  PreparedStatementでのINSERT/UPDATE/DELETE文はステートメントキャッシュを利用することができます。  
  なお、SQLのPREPAREコマンドを使用する場合はSELECT/INSERT/UPDATE/DELETE文のすべてでステートメントキャッシュを利用することはできます。

### 制約事項

現バージョン（Tsurugi 1.2.0とTsurugi FDWの組み合わせ環境）では以下の機能を制限とします。

- バイナリデータ型（BINARY/VARBINARY/BINARY VARYING）を操作することはできません。
- SQLのPREPAREコマンドでプリペアするSQL文に集合演算子（UNION/EXCEPT/INTERSECT）があるとEXECUTEコマンドで正しい結果を得ることができません。

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

- 1.0.0
  - 初版
- 1.1.0
  - SQLのPREPAREコマンドで制約事項としていた以下のSQL構文の使用を解除
    SELECT文で指定可能なset-quantifier（ALL/DISTINCT）  
    SELECT文で指定可能なLIMIT句  
    INSERT文のinsert-sourceで指定可能なDEFAULT VALUES  
    INSERT文のinsert-sourceで指定可能なquery-expression  
  - SQLのIMPORT FOREIGN SCHEMAコマンドを追加 
