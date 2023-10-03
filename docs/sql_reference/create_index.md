# [リファレンス（SQL）](../sql_reference.md)

## CREATE INDEX

  CREATE INDEX － Tsurugiのインデックスを定義する。

### 概要

  ~~~sql
  CREATE [ UNIQUE ] INDEX [ [ IF NOT EXISTS ] name ] ON table_name [ USING method ]
      ( column_name [ ASC | DESC ] [, ...] )
      [ INCLUDE ( column_name [, ...] ) ]
      [ TABLESPACE tablespace_name ]
  ~~~

### 説明

  CREATE INDEXは、Tsurugi上に存在するテーブルの指定した列（複数可）に対するインデックスを生成する。その際、TABLESPACEにtsurugiを指定する必要がある。インデックスは主にデータベースの性能向上を目的として使用する。（ただし、インデックスの生成が必ず性能向上につながるとは限らない）

  インデックスを生成する際はインデックスを生成する対象となるテーブル名とテーブルの列名を指定する必要がある。複数の列名を指定することで、複数列インデックスを生成できる。

  Tsurugiはインデックスメソッドとしてmass-treeを使用する。

  CREATE TABLEでインデックスを生成することもできる。その際はINCLUDE句やTABLESPACEを指定できる。

### パラメータ

* **UNIQUE**  
  インデックスを生成するときやテーブルにデータを追加するときに、テーブル内に重複する値が存在しないかを検査する。重複する値が挿入もしくは更新される場合にエラーとなる。

* **IF NOT EXISTS**
  インデックスを生成する際に指定したインデックス名が既に存在する場合、エラーとせず注意のメッセージが出力される。このとき、生成時指定した構造と異なるインデックスが存在する可能性があることに注意する。IF NOT EXISTSを指定する場合、nameの指定は必須となる。

* **INCLUDE**  
  INLCUDE句で指定した列を非キー列としてインデックスに含める列のリストを指定する。非キー列をインデックススキャンおよび検索条件に使用することはできない。

* **name**  
  生成するインデックス名を指定する。名前の指定を省略する場合、「テーブル名_列名_idx」というインデックス名で生成する。
  列名が複数の場合はそれらを並べて記載し、INLCUDE句等で同列が複数指定される場合はn-1(nは指定された回数)が名前の後ろにつく。
  全く同じインデックスを名前の指定を省略して2回実行した場合、2回目のインデックス名は～_idx1となる。

* **table_name**  
  インデックスを生成するテーブル名を指定する。このテーブルはtsurugi上にあるテーブルである必要がある。

* **method**  
  使用するインデックスメソッドを指定する。デフォルトではmass-treeが指定される。

* **column_name**  
  インデックスを生成するテーブルの列名を指定する。複数列インデックスを生成する場合、複数指定することができる。

* **ASC**  
  インデックスのソート順を昇順に指定する。デフォルトではASCが指定される。このとき、NULLは非NULLより前にソートされる。

* **DESC**  
  インデックスのソート順を降順に指定する。このとき、NULLは非NULLより後にソートされる。

* **tablespace_name**  
  インデックスを生成するテーブル空間名を指定する。tsurugi上のテーブルに対してインデックスを生成する場合、tsurugiを指定する必要がある。

### 例

* テーブルtable1の列cloumn2に対して、UNIQUE制約のあるインデックスを生成する。

  ~~~sql
  CREATE UNIQUE INDEX table1_index ON table1 (column2) TABLESPACE tsurugi;
  ~~~

* テーブルtable2の列cloumn2,column3に対して、column2は昇順でcolumn3は降順でソートしたインデックスを生成する。

  ~~~sql
  CREATE INDEX table2_index ON table2 (column2 ASC, column3 DESC) TABLESPACE tsurugi;
  ~~~

* テーブルtable3の列cloumn2,column3に対して、column3を非キー列としてもつインデックスを生成する。
※インデックス名を指定していないため、table3_index_column2_column3_column31_idxという名前で生成される

  ~~~sql
  CREATE INDEX ON table3 (column2,column3) INCLUDE (colmun3) TABLESPACE tsurugi;
  ~~~

* テーブルtable4の列cloumn3に対して、mass-treeで構成されたインデックスを生成する。

  ~~~sql
  CREATE INDEX table4_index ON table4 USING mass-tree (column3) TABLESPACE tsurugi;
  ~~~
