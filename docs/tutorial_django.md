# [Tsurugi FDW for Tsurugi](./README.md)

## チュートリアル

PostgreSQLのユーザインタフェースからTsurugiを利用する簡単な操作方法を説明します。  
このチュートリアルは単なる入門用であり、Tsurugi固有の仕様および制限については、Tsurugiのドキュメントを確認してください。  

### Djangoを使用

Djangoを使用してTsurugiを利用する一般的な方法を説明します。  
Tsurugi FDWがサポートするDjangoの詳細については [リファレンス（Django）](./django_reference.md) を参照してください。  

#### Djangoとは

DjangoはPythonでWebアプリケーションを開発するためのオープンソースのフレームワークです。  
フルスタックフレームワークとして、認証機能、データベース連携、管理画面作成など、Webアプリケーションに必要な機能が揃っており、SNS、ECサイト、社内システムなど、小規模から大規模まで幅広いWebアプリケーションを効率的に開発できます。  

#### Djangoのインストール

Djangoをインストールすることで、Djangoのコードのインポートやユーティリティコマンドの利用など、Djangoが使用可能になります。  
インストール方法は、最新公式リリースのダウンロード、特定ディストリビューションのパッケージ、最新の開発バージョンなど、インストール対象によって異なります。詳細は [Djangoの公式ドキュメント](https://docs.djangoproject.com/ja/6.0/topics/install/)を参照してください。  

以下のコマンドは、最新の公式リリースパッケージをインストールする一般的な（公式ドキュメントで推奨）手順です。  

~~~sh
$ python3 -m venv venv
$ source venv/bin/activate
(venv) $ pip install Django
(venv) $ python
>>> import django
>>> print(django.get_version())
6.0.2
~~~

#### Djangoプロジェクトの作成

`django-admin` を使用して、Djangoプロジェクトを構成するコードを自動生成します。  

~~~sh
$ django-admin startproject django_project .
$
~~~

Djangoプロジェクトは、データベースの設定、Django固有のオプション、アプリケーション固有の設定など、個々のDjangoのインスタンスを設定します。詳細は [Djangoの公式ドキュメント](https://docs.djangoproject.com/ja/6.0/intro/tutorial01/)を参照してください。  

本チュートリアルでは、Tsurugiのデータベース接続情報をDjangoプロジェクトに設定しています（[後述](#データベースへの接続django)）。  

#### Djangoアプリケーションの作成

`manage.py`を使用して、Djangoアプリケーションを構成するコードを自動生成します。  

~~~sh
$ python manage.py startapp my_app
$
~~~

Djangoアプリケーションには、Webアプリケーションを構成するパーツ（Djangoのモデルクラスやビュークラスなど）を実装します。詳細は [Djangoの公式ドキュメント](https://docs.djangoproject.com/ja/6.0/intro/tutorial01/)を参照してください。  

本チュートリアルでは、Tsurugiのテーブル情報をDjangoアプリケーションのモデル層に実装しています（[後述](#モデルクラス定義)）。  

#### データベースへの接続（Django）

データベースの接続情報は、Djangoプロジェクトの `django_project/settings.py` ファイルに設定します。  

~~~py
DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.postgresql',
        'NAME': 'tsurugi_db',
        'USER': 'postgres',
        'PASSWORD': '',
        'HOST': 'localhost',
        'PORT': '35432',
    }
}
~~~

`django_project/settings.py` ファイルに設定したデータベース接続情報は、データベースへの操作を行うときに（最初の接続 または 前の接続がクローズされている場合）読み込まれ、自動でデータベースに接続します。  

#### SQL文の実行（Django）

Djangoを使用してSQL文を実行する方法はいくつかありますが、`cursor` オブジェクトの `execute` メソッドを使用する方法を説明します。  
`cursor` オブジェクトは `django.db` モジュール `connection` オブジェクトの `cursor` メソッドで取得します。  

以下の例では、SQL の `CREATE FOREIGN TABLE` 文を実行して外部テーブルを作成しています。  

~~~py
from django.db import connection
 ：
cur = connection.cursor()
create_foreign_table_sql = """
    create foreign table if not exists fdw_sample (
        id varchar(50),
        num int not null,
        tim time
    ) server tsurugi"""
cur.execute(create_foreign_table_sql)
 ：
cur.close()
~~~

> [!NOTE]
> PostgreSQL（Tsurugi FDW）からのDDL実行は非サポートとなります。  
> PostgreSQLから操作するTsurugiテーブルはTsurugiのSQLコンソール（tgsql）などを利用して事前に作成する必要があります。  

##### データの更新

`cursor` オブジェクトの `execute` メソッドを使用してTsurugiのデータを更新（INSERT/UPDATE/DELETE）することができます。  

~~~py
with connection.cursor() as cursor:
    # 実行するSQL文
    ins_sql = "INSERT INTO fdw_sample (num) VALUES (11)"
    upd_sql = "UPDATE fdw_sample SET num = num + 11"
    del_sql = "DELETE FROM fdw_sample"

    # SQL文の実行
    cursor.execute(ins_sql)
    cursor.execute(upd_sql)
    cursor.execute(del_sql)
~~~

##### データの問い合わせ

`cursor` オブジェクトの `execute` メソッドを使用してTsurugiのデータを問い合わせることができます。  
問い合わせた結果は同クラスの `fetchall` メソッドなどを使用して取得することができます。  

~~~py
with connection.cursor() as cursor:
    cursor.execute("SELECT num FROM fdw_sample ORDER BY num")
    rows = cursor.fetchall()
    for row in rows:
        print(f"  {row[0]:02d}")
~~~

#### ORMの使用（Django）

DjangoのORMを使用してオブジェクト指向的にデータベース（CRUD）操作する一般的な方法を説明します。  
詳細は [Djangoの公式ドキュメント](https://docs.djangoproject.com/ja/6.0/ref/models/)を参照してください。  

##### モデルクラス定義

Djangoの `models.Model` を継承したクラスをDjangoアプリケーションの `my_app/models.py` ファイルに定義します。  
このクラスは、データベースのテーブルを表し、各属性はデータベースのカラムに対応します。  

~~~py
from django.db import models

def generate_uuid_str(): # UUIDを生成し その文字列表現を返す
    return str(uuid.uuid4())

class FdwSample(models.Model): # models.Modelを継承
    id = models.CharField(max_length=50, primary_key=True, default=generate_uuid_str, editable=False)
    num = models.IntegerField(unique=True)
    tim = models.TimeField()
    class Meta:
        managed = False # Djangoがテーブルを作成・変更しないように False を設定
        db_table = 'fdw_sample' # データベース内のテーブル名を指定
    def __str__(self):
        return f"FdwSample(id={self.id}, num={self.num}, tim={self.tim.strftime('%H:%M:%S')})"
~~~

> [!IMPORTANT]
>
> * **`managed` メタオプションについて**  
>   Tsurugi FDWはTsurugiへのDDL実行が非サポートのため、Tsurugiテーブルを定義するモデルクラスでは `managed` メタオプションを `False` に設定する必要があります。  
>   `managed` が `True`（デフォルト）の場合、モデルに対して行った属性の変更やモデル自体の追加および削除などの変更は Django が管理します（意図しないDDLが実行され失敗する）。  
>
> * **主キーの生成戦略について**  
>   TsurugiはINSERT SQL文のRETURNING句が非サポートのため、Tsurugiテーブルを定義するモデルクラスでは `default` フィールドオプションなどを使用して主キーを手動生成する必要があります。
>   主キーを自動生成（デフォルト）すると、INSERT SQL文にRETURNING句が付与され SQL文の実行（CRUD操作のデータ作成）が失敗します。  

##### データベース操作

モデルクラスの `.objects` マネージャを使用してデータベースのCRUD（データの作成・読み取り・更新・削除）や複雑なフィルタリング、リレーション定義を操作することができます。  

~~~py
from my_app.models import FdwSample
 ：
 for i in range(1, 11):
     # データ作成
     current_time = timezone.localtime(timezone.now()).time()
     FdwSample.objects.create(num=i, tim=current_time)
     if i % 2 != 0:
         # データ削除（奇数）
         FdwSample.objects.filter(num=i).delete()
     if i % 3 == 0:
         # データ更新（３倍数）
         clear_time = '00:00:00'
         FdwSample.objects.filter(num=i).update(tim=clear_time)

 # データ読み取り
 rows = FdwSample.objects.all().order_by('num')
 for row in rows:
     print(f"     {row.num:02d}\t\t {row.tim.strftime('%H:%M:%S')}\t {row.id}")
~~~

#### トランザクション操作（Django）

Djangoでトランザクションを操作する方法はいくつかありますが、`transaction` オブジェクトを利用する方法を説明します。  
`transaction` オブジェクトの利用方法（自動コミットなど）は Django の仕様に準じます。詳細は [Djangoの公式ドキュメント](https://docs.djangoproject.com/ja/6.0/topics/db/transactions/)を参照してください。  

##### 1. コンテキストマネージャの利用

コンテキストマネージャで`transaction` オブジェクトの `atomic()` メソッドを利用することで、明示的なコミットやロールバックの操作が不要になります。  
Withステートメントのブロックを抜けるまでにエラーがなければ自動でコミットされ、エラーがあれば自動でロールバックする動作となります。  

~~~py
from django.db import transaction
  ：
    with transaction.atomic(): # コンテキストマネージャを利用
        FdwSample.objects.create(num=i)
        if i % 2 != 0:
            # 奇数の場合：ロールバックさせるためのエラー発生
            raise RuntimeError("rollback for odd number")
        else:
            # 偶数の場合：自動でコミットされる
  ：
~~~

##### 2. 低レベルAPIの利用

`transaction` オブジェクトの低レベルAPI（`commit()`や`rollback()`など）を利用することで、独自のトランザクション管理を実装することができます。  

~~~py
from django.db import transaction
  ：
  transaction.set_autocommit(False) # 自動コミットを無効
  FdwSample.objects.create(num=i)
  if i % 2 != 0:
      # 奇数の場合：明示的にロールバックする
      transaction.rollback()
  else:
      # 偶数の場合：明示的にコミットする
      transaction.rollback()
  ：
~~~

##### トランザクション特性の変更

Tsurugi固有のトランザクション特性は、Tsurugi FDWのUDF（SQL文）で変更することができます。  
Tsurugi FDWのUDFは、`cursor` オブジェクトの `execute` メソッドで実行することができます。  
トランザクション特性を変更するUDFの詳細は [リファレンス（UDF）](./udf_reference.md) を参照してください。  

~~~py
from django.db import connection
  ：
  with connection.cursor() as cursor:
      cursor.execute("select tg_set_transaction('long')")
      cursor.execute("select tg_set_write_preserve('weather')")
~~~

#### エラー情報の取得（Django）

Djangoを使用したデータベース操作中に発生した異常（例外）は `django.db.utils` から取得することができます。  
Django は標準（DB API 2.0）のデータベース例外をラップしており、基となるデータベース例外と全く同じ動作をします。詳細については [DB API 2.0](https://peps.python.org/pep-0249/) を参照してください。  
Tsurugi FDWが出力するエラーメッセージについては [リファレンス（メッセージ）](./message_reference.md) を参照してください。

~~~py
from django.db.utils import IntegrityError, ProgrammingError, DatabaseError
 ：
  try:
   ：
  except IntegrityError as e:
      # UNIQUE制約違反やNOT NULL制約違反などの整合性エラー
      print(f"Error Message: {e}")
  except ProgrammingError as e:
      # テーブルやカラムが存在しない、SQL構文エラーなどのプログラミングエラー
      print(f"Error Message: {e}")
  except DatabaseError as e:
      # その他の一般的なデータベースエラー (例えば接続エラーなど)
      print(f"Error Message: {e}")
  except Exception as e:
      # 上記で捕捉されなかった予期せぬエラー
      print(f"Error Type: {type(e)}")
      print(f"Error Message: {e}")
  finally:
   ：
~~~

#### サンプルプログラム（Django）

Djangoを使用してTsurugiを利用するサンプルプログラムを示します。

##### サンプルプログラムの概要

Tsurugiの `fdw_sample` テーブルに、以下の順番でデータの操作を行います。

1. データ(行)挿入
    1. `1` から `10` までの数値と現在時刻を有するデータ(行)を1秒間隔で挿入 (**ORM Create**)
    1. 挿入した行の数値が `奇数` の場合、当該データ(行)を削除 (**ORM Delete**)
    1. `11` から `20` までの数値と現在時刻を有するデータ(行)を1秒間隔で挿入 (**SQL Insert**)
    1. 挿入したデータ(行)の数値が `奇数` の場合、当該挿入操作をロールバック (**Transaction**)
1. 全データ(行)問い合わせ (**ORM READ**)
1. データ(行)の数値が`3の倍数`の場合、当該データ(行)の現在時刻を更新 (**ORM Update**)
1. 全データ(行)問い合わせ (**SQL Select**)

##### サンプルプログラムのソースコード

ソースコードおよび実行環境は以下にあるファイルを確認してください。  

* Django: [sample/django-sample/](../sample/django-sample/)  

> [!TIP]
> TsurugiのテーブルおよびTsurugi FDWの外部テーブルはシェルスクリプトを使用して作成および削除しています。  
> テーブル操作の詳細はスクリプトファイル(scriptsフォルダ配下)を確認してください。  

##### サンプルプログラムの実行イメージ

~~~txt
The sample application is running. Please wait...

Inserted Number.1.3.5.7.9.11.13.15.17.19.
  01-10: Even do nothing, Odd delete.
  11-20: Even commit, Odd rollback (simulated by insert then delete).
    Number      UpdateTime      id(primary key)
     02          10:43:48        d8c6902b-8c60-4d02-80ec-961ad4a864c0
     04          10:43:50        7879883a-f0e1-446e-a7a5-4a8eb0d37fde
     06          10:43:52        8d641e56-5a98-45b2-9aec-2bf58b8fe264
     08          10:43:54        f8c9a27b-7746-4228-bd27-84562e0af1fa
     10          10:43:56        75305299-ef7b-4a7c-a938-203f378cd60d
     12          10:43:58        cdb71ce4-7d02-4569-b7c7-f93f41eab10e
     14          10:44:00        3d0a7ccd-b9e4-44e1-acb2-b37e54fd8c8f
     16          10:44:02        2b2f6cdb-4f3a-49d7-8f7c-2548dbb8f794
     18          10:44:04        cd1be05b-007a-43bc-bb41-7508a66b6409
     20          10:44:06        426422ad-4307-49a0-b77f-5a6d546d429f

Updated UpdateTime.
  Multiples of 3: Update the Time(10:44:08).
    Number      UpdateTime      id(primary key)
     02          10:43:48        d8c6902b-8c60-4d02-80ec-961ad4a864c0
     04          10:43:50        7879883a-f0e1-446e-a7a5-4a8eb0d37fde
     06          10:44:08        8d641e56-5a98-45b2-9aec-2bf58b8fe264
     08          10:43:54        f8c9a27b-7746-4228-bd27-84562e0af1fa
     10          10:43:56        75305299-ef7b-4a7c-a938-203f378cd60d
     12          10:44:08        cdb71ce4-7d02-4569-b7c7-f93f41eab10e
     14          10:44:00        3d0a7ccd-b9e4-44e1-acb2-b37e54fd8c8f
     16          10:44:02        2b2f6cdb-4f3a-49d7-8f7c-2548dbb8f794
     18          10:44:08        cd1be05b-007a-43bc-bb41-7508a66b6409
     20          10:44:06        426422ad-4307-49a0-b77f-5a6d546d429f

The sample application has finished.
~~~
