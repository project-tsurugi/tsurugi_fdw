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

- サードパーティライセンス

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

- 修正履歴

  - 1.0.0
    - 初版
