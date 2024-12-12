# [Tsurugi FDW for Tsurugi](./tsurugi_fdw.md)

## リファレンス（メッセージ）

Tsurugi FDWが異常時に出力するメッセージについて説明します。  
メッセージのSQLSTATE値はすべてinternal_errorを示す `XX000` となります。  
その他のメッセージはPostgreSQLのメッセージ仕様に準じます。
詳細は [PostgreSQLのドキュメント](https://www.postgresql.jp/document/12/html/errcodes-appendix.html) を参照してください。

### Tsurugiからのエラーメッセージ

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
  - 4 : INVALID_PARAMETER
  - 5 : UNSUPPORTED
  - 6 : NO_TRANSACTION
  - 7 : INVALID_PARAMETER
  - 8 : FILE_IO_ERROR
  - 9 : UNKNOWN
  - 10 : SERVER_FAILURE
  - 11 : TIMEOUT
  - 12 : TRANSACTION_ALREADY_STARTED
  - 13 : SERVER_ERROR

### その他のメッセージ

- "This database is for Tsurugi, so CREATE TABLE is not supported"

- "This database is for Tsurugi, so CREATE FOREIGN TABLE for non-Tsurugi foreign table is not supported"

- "tsurugi_fdw extension cannot be installed in the non-empty database. Please make sure there are no tables by using the \\d command."

https://github.com/project-tsurugi/ogawayama/blob/master/docs/API_contracts.md#errorcode

https://github.com/project-tsurugi/tsurugidb/blob/master/docs/error-code-tsurugi-services.md

