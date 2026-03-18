# [Tsurugi FDW for Tsurugi](./README.md)

## リファレンス（Django）

Tsurugi FDWがサポートするDjangoについて説明します。

### サポート対象プロジェクト

Tsurugi FDWは以下のDjangoをサポートします。  

- [Django (6.0.2 以降)](https://docs.djangoproject.com/ja/6.0/)

データアクセス方法については Django の仕様に準じます。  
詳細は[Djangoの公式ドキュメント](https://docs.djangoproject.com/ja/6.0/)を参照してください。

### 動作確認済オブジェクト一覧

Tsurugiへのデータアクセスで使用する基本的なオブジェクトを示します。

- [Connectionオブジェクト](#connectionオブジェクト) - データベース接続管理用のAPIを提供
- [Cursorオブジェクト](#cursorオブジェクト) - SQLコマンド制御用のAPIを提供
- [Modelsモジュール](#modelsオブジェクト) - モデル（データ構造）宣言用のAPIを提供
- [Routerオブジェクト](#routerオブジェクト) - 複数データベース接続時のルーティング制御用のAPIを提供
- [Transactionオブジェクト](#transactionオブジェクト) - トランザクション管理用のAPIを提供
- [Utilsモジュール](#utilsモジュール) - データベース関連ユーティリティ用のAPIを提供

### 動作確認済メソッド一覧

Tsurugiへのデータアクセスで使用する基本的なメソッドを示します。  

「動作確認」列は Tsurugiへのデータアクセスで使用したメソッドの検証状況を示しています。  
検証できたメソッドには「〇」、検証できていないメソッドには「－」を記入しています。

- 動作確認環境バージョン情報
  - Tsurugi：1.9.0
  - Tsurugi FDW：1.4.0
  - Django：6.0.2

#### Connectionオブジェクト

データベース接続管理用のAPIを提供する。

| 名前                      | 説明 | 動作確認 |
| :------------------------ | :--- | :------: |
| `cursor()`                | 新しいDBカーソルを返す | 〇 |
| `close()`                 | データベース接続を閉じる | 〇 |
| `commit()`                | トランザクションをコミットする | 〇 |
| `rollback()`              | トランザクションをロールバックする | 〇 |
| `savepoint()`             | 新しいセーブポイント生成する | － |
| `savepoint_commit(sid)`   | 指定セーブポイントをコミットする | － |
| `savepoint_rollback(sid)` | 指定セーブポイントにロールバックする | － |
| `set_autocommit(value)`   | オートコミットを有効/無効に切り替える | 〇 |
| `get_autocommit()`        | オートコミット状態を取得する | 〇 |
| `ensure_connection()`     | 接続状態を保証（必要なら再接続）する | ー |
| `close_if_unusable_or_obsolete()` | 使えなくなった接続の明示的なクローズする | ー |
| `in_atomic_block`（属性） | トランザクションブロック中ならTrue | 〇 |
| `settings_dict`（属性）   | 設定ファイルに基づいた接続定義の辞書 | ー |
| `introspection`（属性）   | DBメタ情報調査(テーブル一覧取得など)用APIインスタンス | ー |
| `features`（属性）        | DBバックエンド特有の機能フラグ一覧 | ー |
| `ops`（属性）             | SQL演算関連情報（DBバックエンド依存） | ー |
| `vendor`（属性）          | バックエンド名('postgresql'/'sqlite'等) | ー |
| `is_usable()`             | 現在接続が使えるかどうかチェックする | 〇 |
| `needs_rollback`（属性）  | ロールバック保留状態 | ー |
| `alias`（属性）           | connecions['default']等でアクセスするときの辞書キー名 | ー |

#### Cursorオブジェクト

SQLコマンド制御用のAPIを提供する。

| 名前                      | 説明 | 動作確認 |
| :------------------------ | :--- | :------: |
| `execute(sql, params=None)` | SQLを実行する | 〇 |
| `executemany(sql, seq)`   | 複数SQLを一括実行する | － |
| `fetchone()`              | 1行取得する | 〇 |
| `fetchmany(size)`         | 指定された数の行を取得する | 〇 |
| `fetchall()`              | 残り全ての行を取得する | 〇 |
| `close()`                 | カーソルクローズする | 〇 |
| `description`（属性）     | 結果セットのカラム情報(tuple群) | － |
| `rowcount`（属性）        | 直前のクエリで影響した行数 | 〇 |
| `lastrowid`（属性）       | 直前の挿入で生成されたPK | － |
| `db`（属性）              | 親となるconnectionオブジェクト | － |

#### Modelsオブジェクト

モデル（データ構造）の宣言および制御用のAPIを提供する。

| 名前                      | 説明 | 動作確認 |
| :------------------------ | :--- | :------: |
| `Model`（クラス）         | Djangoのモデル（データ構造）の基底クラス | [後述](#modelクラス) |
| `Field` 系クラス          | `Model`クラスで宣言可能なフィールドタイプ | [後述](#field系クラス) |
| `Manager`（クラス）       | データ操作（CRUD）を行う制御クラス | [後述](#managerクラス) |
| `QuerySet`（クラス）      | 評価型のクエリオブジェクト | － |
| `Function` 系オブジェクト | 集約/注釈などの関数オブジェクト | － |

##### Modelクラス

Djangoのモデル（データ）の基底クラス。

| 名前         | 説明 | 動作確認 |
| :----------- | :--- | :------: |
| `objects`    | オブジェクトマネージャ（`Manager`クラスの中身） | 〇 |
| `<field名>`  | モデルで定義した各フィールド(例:`name`, `age`など) | 〇 |
| `id`         | 主キー。独自にpk指定しない場合に自動生成される | 〇 |
| `pk`         | インスタンスの主キー（通常はid） | － |
| `Meta`（クラス） | モデルのメタ情報指定用サブクラス | [後述](#metaサブクラス) |

##### Field系クラス

モデルクラスで宣言可能なフィールドタイプ（カラムのデータ型）。

| フィールドクラス名        | 説明 | 動作確認 |
| :------------------------ | :--- | :------: |
| `AutoField`               | 整数の自動増分主キー | － |
| `BigAutoField`            | 64bit整数の自動増分キー | － |
| `SmallAutoField`          | 16bit整数の自動増分キー | － |
| `BinaryField`             | バイナリデータ | － |
| `BooleanField`            | 真偽値フィールド | － |
| `CharField`               | 可変長文字列 (最大長指定) | 〇 |
| `DateField`               | 日付のみ (YYYY-MM-DD) | － |
| `DateTimeField`           | 日付＋時刻 | － |
| `DecimalField`            | 固定小数点数 | － |
| `DurationField`           | タイムデルタ型 | － |
| `EmailField`              | メールアドレス（CharFieldのバリデーション付き） | － |
| `FileField`               | ファイルアップロード用 | － |
| `FilePathField`           | サーバー上のファイルパス選択 | － |
| `FloatField`              | 浮動小数点数(double) | － |
| `ImageField`              | 画像アップロード用（Pillow依存） | － |
| `GenericIPAddressField`   | IPv4 or IPv6 アドレス | － |
| `IntegerField`            | 32bit整数 | 〇 |
| `BigIntegerField`         | 64bit整数 | － |
| `SmallIntegerField`       | 16bit整数 | － |
| `PositiveIntegerField`    | 0以上の整数 | － |
| `PositiveBigIntegerField` | 0以上の64bit整数 | － |
| `PositiveSmallIntegerField` | 0以上の16bit整数 | － |
| `SlugField`               | スラッグ(短いラベル・URLに適した文字列) | － |
| `TextField`               | 長文テキスト | 〇 |
| `TimeField`               | 時刻のみ (hh:mm[:ss[.uuuuuu]]) | 〇 |
| `URLField`                | URL文字列（CharFieldのバリデーション付き） | － |
| `UUIDField`               | UUID値 | － |
| `ForeignKey`              | リレーション（多対一） | － |
| `OneToOneField`           | リレーション（一対一） | － |
| `ManyToManyField`         | リレーション（多対多） | － |
| `JSONField`               | JSON値/構造体 | － |
| `ArrayField`              | 配列フィールド（PostgreSQL専用） | － |
| `HStoreField`             | キーバリューペア（PostgreSQL専用） | － |
| `CICharField`             | 大文字小文字無視でのCharField（PostgreSQL専用） | － |
| `CIEmailField`            | 大文字小文字無視でのEmailField（PostgreSQL専用） | － |
| `IPAddressField`          | IPv4アドレス | － |

##### Metaサブクラス

モデルのメタ情報指定用サブクラス（Metaオプション）。

| Meta オプション名       | 説明 | 動作確認 |
| :---------------------- | :--- | :------: |
| `abstract`              | Trueだと「抽象モデル」となる | － |
| `app_label`             | モデルがどのアプリケーションに属するかを指定 | － |
| `base_manager_name`     | 「_base_manager」に使うManagerの名前（通常は"objects"） | － |
| `db_table`              | このモデルに対応するデータベーステーブル名 | 〇 |
| `db_table_comment`      | テーブルにコメントを付与 | － |
| `db_tablespace`         | テーブルがどの「テーブルスペース」にあるか指定 | － |
| `default_manager_name`  | デフォルトで使うManager（オブジェクト検索API）の名前 | － |
| `default_related_name`  | 他モデルからリバースアクセスする際のデフォルトの属性名 | － |
| `get_latest_by`         | latest(), earliest() で使うデフォルトの判別フィールド。通常は日付やIDなど | － |
| `managed`               | True（標準）：DjangoがDBテーブル作成を管理</br>False：既存の外部テーブル等をDjangoで管理しない | 〇 |
| `order_with_respect_to` | 指定フィールドの順で並べ替えメソッド&属性を自動追加 | － |
| `ordering`              | レコード取得時のデフォルト並び順リスト（例：["created"]） | － |
| `permissions`           | 追加の権限をタプル（コード名・表示名）で指定し、管理画面/認可で使えるようにする | － |
| `default_permissions`   | デフォルトで生成されるパーミッションリスト。空にすれば無効可 | － |
| `proxy`                 | Trueなら「プロキシモデル」化。内容は親そのままで振る舞いだけ追加したい時など | － |
| `required_db_features`  | このモデルに必要なDBの機能名リスト。無いとマイグレーション時に無視される | － |
| `required_db_vendor`    | このモデルを有効にするためのDBベンダ名（例："postgresql", "mysql", "sqlite", "oracle"） | － |
| `select_on_save`        | save時にまずSELECTしてからUPDATEするか（特殊用途以外は標準でOK） | － |
| `indexes`               | モデルに対して追加したいDBインデックス（`models.Index`等）のリスト | － |
| `unique_together`       | 指定フィールドの組み合わせが一意であることを求める（二重リスト形式） | － |
| `constraints`           | DBレベルの制約（ユニークや条件付き一意、チェック制約など）をリストで指定 | － |
| `verbose_name`          | 管理画面などで表示する日本語の（単数形）モデル名 | － |
| `verbose_name_plural`   | 管理画面などで表示する日本語の（複数形）モデル名 | － |
| `label`                 | モデルのラベル（"app_label.ModelName"の文字列） | － |
| `label_lower`           | モデルの小文字ラベル（"app_label.modelname"の文字列） | － |

##### Managerクラス

データ操作（CRUD）を行う制御クラス。

| メソッド名              | 説明 | 動作確認 |
| :---------------------- | :--- | :------: |
| `all()`                 | すべてのレコードを返す | 〇 |
| `filter(...)`           | 指定した条件でレコードを絞り込む | 〇 |
| `exclude(...)`          | 指定した条件に合致しないレコードを返す | － |
| `get(...)`              | 条件に該当する単一のレコードを返す | 〇 |
| `create(...)`           | レコードを新規作成する | 〇 |
| `get_or_create(...)`    | 同じ属性のレコードがあれば取得、なければ作成する | － |
| `update_or_create(...)` | 条件で探し、なければ新規作成、あれば更新して返す | － |
| `bulk_create(...)`      | 複数のレコードを一括作成する | － |
| `bulk_update(...)`      | 複数のレコードを一括更新する | － |
| `annotate(...)`         | 集計関数や計算結果を追加したクエリセットを返す | － |
| `aggregate(...)`        | 集約計算の結果を辞書で返す | － |
| `count()`               | 件数を返す | 〇 |
| `exists()`              | 少なくとも1件該当レコードがあるかどうか判定する | － |
| `first()`               | クエリセットの最初の1件を返す | 〇 |
| `last()`                | クエリセットの最後の1件を返す | 〇 |
| `order_by(...)`         | 指定フィールドでソートした結果を返す | 〇 |
| `reverse()`             | 並び順を逆にしたクエリセットを返す | － |
| `values(...)`           | 指定フィールド部分のみ辞書としてリスト返却する | － |
| `values_list(...)`      | 指定フィールド部分だけタプル/リストで返却する | － |
| `distinct()`            | 重複を除いたクエリセットする | － |
| `update(...)`           | 該当レコードをすべて指定内容で一括更新する | 〇 |
| `delete()`              | 該当レコードをすべて一括削除する | 〇 |
| `select_related(...)`   | 外部キー等のリレーション先も一度に取得する | － |
| `prefetch_related(...)` | 多対多/逆参照関係をまとめて取得する | － |
| `raw(...)`              | 生SQL文で直接QuerySetを構築する | － |
| `none()`                | 空のクエリセット返却する | － |
| `db_manager(...)`       | 指定DBエイリアスでのマネージャを返却する | － |

#### Routerオブジェクト

複数データベース接続時のルーティング制御用のAPIを提供する。

| 名前                      | 説明 | 動作確認 |
| :------------------------ | :--- | :------: |
| `db_for_read(model, **hints)` | 読み込みに使用するDBエイリアスを返す | 〇 |
| `db_for_write(model, **hints)` | 書き込みに使用するDBエイリアスを返す | 〇 |
| `allow_relation(obj1, obj2, **hints)` | リレーションを許可するかどうかを返す | 〇 |
| `allow_migrate(db, app_label, model_name=None, **hints)` | マイグレーションを許可するかどうかを返す | 〇 |
| `routers`（属性） | DATABASE_ROUTERSに指定されているルーターのリスト | － |

#### Transactionオブジェクト

トランザクション管理用のAPIを提供する。

| 名前                      | 説明 | 動作確認 |
| :------------------------ | :--- | :------: |
| `atomic()`                | with文内のトランザクションをまとめるコンテキストマネージャ | 〇 |
| `on_commit(func, using=None)` | コミット時にfuncを実行する | － |
| `set_autocommit(autocommit, using=None)` | 対象DBに対してオートコミットモードを切り替える | 〇 |
| `get_autocommit(using=None)` | オートコミット状態を取得する | 〇 |
| `commit(using=None)`      | 明示的にトランザクションコミットする | 〇 |
| `rollback(using=None)`    | 明示的にトランザクションロールバックする | 〇 |
| `savepoint(using=None)`   | セーブポイント作成しそのIDを返却する | － |
| `savepoint_rollback(sid, using=None)` | 指定したセーブポイントまでロールバックする | － |
| `savepoint_commit(sid, using=None)` | 指定したセーブポイントでコミットする | － |
| `get_connection(using=None)` | 接続オブジェクトを返す | ー |

#### Utilsモジュール

データベース関連ユーティリティ（データベース接続の管理や共通の例外定義）用のAPIを提供する。

| 名前                      | 説明 | 動作確認 |
| :------------------------ | :--- | :------: |
| `ConnectionHandler()`     | DB接続管理クラス（`connections`オブジェクトの中身） | 〇 |
| `ConnectionRouter()`      | DBルーター管理クラス（`router`オブジェクトの中身） | 〇 |
| `DEFAULT_DB_ALIAS`        | `"default"` という文字列定数。DjangoのデフォルトDBエイリアス名 | － |
| `DatabaseError`           | DBエラーの基底例外クラス | 〇 |
| `DataError`               | データエラー例外クラス | － |
| `IntegrityError`          | 整合性違反例外クラス | － |
| `InternalError`           | DB内部エラー例外クラス | 〇 |
| `OperationalError`        | 操作エラー例外クラス | － |
| `ProgrammingError`        | プログラムエラー例外クラス | 〇 |
| `NotSupportedError`       | サポートされない操作例外クラス | － |
| `ConnectionDoesNotExist`  | 指定したConnectionが存在しない時の例外クラス | － |
| `LoadError`               | DBエンジンのロード失敗時の例外クラス | － |
| `ImproperlyConfigured`    | 設定不足や誤設定時の例外クラス | － |
| `load_backend(backend_name)` | 指定されたバックエンド名のDBエンジンモジュールをインポート・初期化する | － |
| `close_all_connections()` | 全てのコネクションをクローズする | － |
| `close_connection()`      | アクティブなコネクションをクローズする | － |
| `reset_queries()`         | クエリログのリセットする | － |
| `get_backend_name(connection)` | コネクションオブジェクトからバックエンド名を取得する | － |
| `_threadlocal` （属性）   | スレッドローカルな接続情報保持インスタンス（内部利用） | － |
