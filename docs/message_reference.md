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
"Failed to prepare SQL statement to Tsurugi. (error: *<error_code>*)"  
"Failed to retrieve error information from Tsurugi. (error: *<error_code>*)"  
"Failed to execute statement to Tsurugi. (error: *<error_code>*)"  
"Failed to execute query to Tsurugi. (error: *<error_code>*)"  
"Failed to commit the Tsurugi transaction. (error: *<error_code>*)"  
"Failed to rollback the Tsurugi transaction. (error: *<error_code>*)"  
"Failed to retrieve result set from Tsurugi. (error: *<error_code>*)"  

- **エラーコード**  

    | error_code | 意味・対処 |
    | :-: | :- |
    | 4 | COLUMN_TYPE_MISMATCH</BR>Tsurugi FDWで内部エラーが発生しました。</BR>実行中のアプリケーションを終了させ、PostgreSQLサーバのメッセージログを採取して、技術員に連絡してください。 |
    | 5 | UNSUPPORTED</BR>Tsurugi FDWがサポートしていないSQL文が実行されました。</BR>アプリケーションから未サポートのSQL文を削除してください。</BR>Tsurugi FDWがサポートするSQL文については[リファレンス（SQL）](./sql_reference.md)を確認ください。 |
    | 6 | NO_TRANSACTION</BR>Tsurugi FDWで内部エラーが発生しました。</BR>実行中のアプリケーションを終了させ、PostgreSQLサーバのメッセージログを採取して、技術員に連絡してください。 |
    | 7 | INVALID_PARAMETER</BR>Tsurugi FDWで内部エラーが発生しました。</BR>実行中のアプリケーションを終了させ、PostgreSQLサーバのメッセージログを採取して、技術員に連絡してください。 |
    | 8 | FILE_IO_ERROR</BR>Tsurugi FDWで内部エラーが発生しました。</BR>実行中のアプリケーションを終了させ、PostgreSQLサーバのメッセージログを採取して、技術員に連絡してください。 |
    | 9 | UNKNOWN</BR>Tsurugi FDWで内部エラーが発生しました。</BR>実行中のアプリケーションを終了させ、PostgreSQLサーバのメッセージログを採取して、技術員に連絡してください。 |
    | 10 | SERVER_FAILURE</BR>Tsurugi FDWで内部エラーが発生しました。</BR>実行中のアプリケーションを終了させ、PostgreSQLサーバのメッセージログを採取して、技術員に連絡してください。 |
    | 11 | TIMEOUT</BR>Tsurugi FDWで内部エラーが発生しました。</BR>実行中のアプリケーションを終了させ、PostgreSQLサーバのメッセージログを採取して、技術員に連絡してください。 |
    | 12 | TRANSACTION_ALREADY_STARTED</BR>Tsurugi FDWで内部エラーが発生しました。</BR>実行中のアプリケーションを終了させ、PostgreSQLサーバのメッセージログを採取して、技術員に連絡してください。 |
    | 13 | SERVER_ERROR</BR>Tsurugiでエラーが発生しました。Tsurugiのエラー情報が追加情報として出力されます。</BR>実行中のアプリケーションを終了させ、TsurugiとPostgreSQLサーバのメッセージログを採取して、技術員に連絡してください。</BR>Tsurugiのエラー情報については[Error Code of Tsurugi Services](https://github.com/project-tsurugi/tsurugidb/blob/master/docs/error-code-tsurugi-services.md)を確認ください。 |

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
