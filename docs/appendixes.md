# [Tsurugi FDW for Tsurugi](./tsurugi_fdw.md)

## 付録

- 注意事項

  Tsurugi FDWは、PostgreSQLと比較して以下の動作が異なります。

  - ORDER BY句を利用して文字列型のデータを問い合わせた場合、対象データの大文字小文字をソート条件に含みます。PostgreSQLは大文字小文字を区別しません。
  - ORDER BY句のNULLSオプションのデフォルトがNULLS FIRSTとなります。PostgreSQLはNULLS LASTです。

- 制約事項

  Tsurugi FDWは、以下の機能が利用できません。

  - 非サポート機能一覧
    - アクセスメソッド（ACCESS METHOD）
    - 集約関数（AGGREGATE）
    - キャスト（CAST）
    - 照合順序（COLLATION）
    - 符号化方式変換（CONVERSION）
    - ドメイン（DOMAIN）
    - イベントトリガ（EVENT TRIGGER）
    - マテリアライズドビュー（MATERIALIZED VIEW）
    - 演算子（OPERATOR）
    - セキュリティポリシー（POLICY）
    - スキーマ（SCHEMA）
    - シーケンスジェネレータ（SEQUENCE）
    - 拡張統計情報（STATISTICS）
    - テキスト検索（TEXT SEARCH）
    - 変換（TRANSFORM）
    - トリガ（TRIGGER）
    - ビュー（VIEW）
    - 統計（ANALYZE / EXPLAIN / VACUUM）
    - カーソル（DECLARE / FETCH / CLOSE）
    - 通知（NOTIFY / LISTEN）
    - セーブポイント（SAVEPOINT）
    - 二相コミット（COMMIT PREPARED）
    - 手続き言語（PL/pgSQL）

- 修正履歴

  - 1.0.0
    - 初版
  - 1.1.0
    - TsurugiトランザクションのRead Areasに対応
