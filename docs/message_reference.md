# [Tsurugi FDW for Tsurugi](./tsurugi_fdw.md)

## リファレンス（メッセージ）

Tsurugi FDWが異常時に出力するメッセージについて説明します。  
メッセージのSQLSTATE値はすべてinternal_errorを示す `XX000` となります。  
その他のメッセージはPostgreSQLのメッセージ仕様に準じます。
詳細は [PostgreSQLのドキュメント](https://www.postgresql.jp/document/12/html/errcodes-appendix.html) を参照してください。

### Tsurugi FDWのエラーメッセージ

Tsurugi FDWからTsurugiの操作中に異常が発生した場合に返されるメッセージです。
エラーの詳細および対処はメッセージ中の *<error_code>* から判断します。

- **メッセージ**  
"Failed to make the Ogawayama Stub. (error: *<error_code>*)"  
"Failed to connect to Tsurugi. (error: *<error_code>*)"  
"Failed to begin the Tsurugi transaction. (error: *<error_code>*)"  
"Failed to commit the Tsurugi transaction. (error: *<error_code>*)"  
"Failed to rollback the Tsurugi transaction. (error: *<error_code>*)"  
"Failed to prepare SQL statement to Tsurugi. (error: *<error_code>*)"  
"Failed to execute statement to Tsurugi. (error: *<error_code>*)"  
"Failed to execute query to Tsurugi. (error: *<error_code>*)"  
"Failed to retrieve result set from Tsurugi. (error: *<error_code>*)"  
"Failed to retrieve table list from Tsurugi. (error: *<error_code>*)"  
"Failed to retrieve table metadata from Tsurugi. (error: *<error_code>*)"  


- **エラーコード**  

    | error_code | 意味 |
    | :-: | :- |
    | 4 | Tsurugi FDWで内部エラーが発生しました。内部エラーが`COLUMN_TYPE_MISMATCH`であることを示す追加情報が出力されます。 |
    | 5 | Tsurugi FDWがサポートしていないSQL文が実行されました（`UNSUPPORTED`）。</BR>Tsurugi FDWがサポートするSQL文については[リファレンス（SQL）](./sql_reference.md)を確認ください。 |
    | 6 | Tsurugi FDWで内部エラーが発生しました。内部エラーが`NO_TRANSACTION`であることを示す追加情報が出力されます。 |
    | 7 | Tsurugi FDWで内部エラーが発生しました。内部エラーが`INVALID_PARAMETER`であることを示す追加情報が出力されます。 |
    | 8 | Tsurugi FDWで内部エラーが発生しました。内部エラーが`FILE_IO_ERROR`であることを示す追加情報が出力されます。 |
    | 9 | Tsurugi FDWで内部エラーが発生しました。内部エラーが`UNKNOWN`であることを示す追加情報が出力されます。 |
    | 10 | Tsurugi FDWで内部エラーが発生しました。内部エラーが`SERVER_FAILURE`であることを示す追加情報が出力されます。 |
    | 11 | Tsurugi FDWで内部エラーが発生しました。内部エラーが`TIMEOUT`であることを示す追加情報が出力されます。 |
    | 12 | Tsurugi FDWで内部エラーが発生しました。内部エラーが`TRANSACTION_ALREADY_STARTED`であることを示す追加情報が出力されます。 |
    | 13 | Tsurugiでエラーが発生しました。Tsurugiのエラー情報が追加情報として出力されます。</BR>Tsurugiのエラー情報については[Error Code of Tsurugi Services](https://github.com/project-tsurugi/tsurugidb/blob/master/docs/error-code-tsurugi-services.md)を確認ください。 |

- **その他のメッセージ**

  - **"This database is for Tsurugi, so CREATE TABLE is not supported"**  
    Tsurugi FDWをインストールしたデータベースにPostgreSQLのテーブルは作成できません。  
    PostgreSQLのテーブルは、Tsurugi FDWがインストールされていないデータベースに作成してください。  

  - **"This database is for Tsurugi, so CREATE FOREIGN TABLE for non-Tsurugi foreign table is not supported"**  
    Tsurugi FDWをインストールしたデータベースにTsurugi以外の外部テーブルは作成できません。  
    Tsurugi以外の外部テーブルは、Tsurugi FDWがインストールされていないデータベースに作成してください。  

  - **"tsurugi_fdw extension cannot be installed in the non-empty database. Please make sure there are no tables by using the \\d command."**  
    PostgreSQLのテーブルまたはTsurugi以外の外部テーブルが存在する既存のデータベースにTsurugi FDWをインストールすることはできません。  
    Tsurugiを利用するためのデータベースは新たに作成してください。  
