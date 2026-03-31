# Copyright 2026 Project Tsurugi.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

import os
import django
from django.conf import settings
from django.db import transaction, connections
from django.db.utils import IntegrityError, ProgrammingError, DatabaseError
from django.utils import timezone
import subprocess
import time
import uuid

# Django環境のセットアップ
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'django_sample_project.settings')
django.setup()

# my_app.models.FdwSample をインポート
from my_app.models import FdwSample

# シェルスクリプトを実行するヘルパー関数
def run_shell_command(script_name, *args):
    script_path = os.path.join(os.path.dirname(__file__), "scripts", f"{script_name}.sh")
    command = [script_path] + list(args)
    print(f"Executing: {' '.join(command)}")
    try:
        result = subprocess.run(command, check=True, capture_output=True, text=True)
        if result.stdout:
            print(result.stdout)
        if result.stderr:
            print(result.stderr)
    except subprocess.CalledProcessError as e:
        print(f"Error executing {script_name}: {e.stderr}")
        raise

def run_sample_logic():
    print("--- Running setup tasks ---")
    run_shell_command("create_database")
    run_shell_command("create_table")
    # run_shell_command("create_foreign_table")
    # ↓ SQL文を実行した場合
    tsurugi_sql_cur = connections['tsurugi_connection'].cursor()
    create_foreign_table_sql = """
        create foreign table if not exists fdw_sample (
            id varchar(50),
            num int not null,
            tim time
        ) server tsurugi"""
    tsurugi_sql_cur.execute(create_foreign_table_sql)
    tsurugi_sql_cur.close()

    print("--- Setup tasks completed ---\n")

    print("The sample application is running. Please wait...\n")

    print("Inserted Number.", end="", flush=True)

    # １から１０のデータを挿入(ORM)するが奇数だけ削除(ORM)する
    for i in range(1, 11):
        try:
            current_time = timezone.localtime(timezone.now()).time()
            FdwSample.objects.create(num=i, tim=current_time)

            if i % 2 != 0:
                FdwSample.objects.filter(num=i).delete()
                print(str(i), end="", flush=True)
            else:
                print(".", end="", flush=True)

        except Exception as e:
            print(f"\nError during insert/delete for {i}: {e}")
        finally:
            time.sleep(1)

    # １１から２０のデータを挿入(SQL)するが奇数だけロールバックする
    for i in range(11, 21):
        try:
            transaction.set_autocommit(False, using='tsurugi_connection')
            current_time = timezone.localtime(timezone.now()).time()
            with connections['tsurugi_connection'].cursor() as cursor:
                generated_id = str(uuid.uuid4())
                time_str = current_time.strftime('%H:%M:%S')
                sql = "INSERT INTO fdw_sample (id, num, tim) VALUES (%s, %s, %s)"
                cursor.execute(sql, [generated_id, i, time_str])

                if i % 2 != 0:
                    transaction.rollback(using='tsurugi_connection')
                    print(str(i), end="", flush=True)
                else:
                    transaction.commit(using='tsurugi_connection')
                    print(".", end="", flush=True)

        # -------------------------------------------------------------
        # 例外ハンドリングの具体的な例
        # -------------------------------------------------------------
        except IntegrityError as e:
            # UNIQUE制約違反やNOT NULL制約違反などの整合性エラー
            print(f"\n--- IntegrityError during insert/rollback for {i} ---")
            print(f"Error Message: {e}")

        except ProgrammingError as e:
            # テーブルやカラムが存在しない、SQL構文エラーなどのプログラミングエラー
            print(f"\n--- ProgrammingError during insert/delete for {i} ---")
            print(f"Error Message: {e}")

        except DatabaseError as e:
            # その他の一般的なデータベースエラー (例えば接続エラーなど)
            print(f"\n--- Generic DatabaseError during insert/delete for {i} ---")
            print(f"Error Message: {e}")

        except Exception as e:
            # 上記で捕捉されなかった予期せぬエラー
            print(f"\n--- Unexpected Error during insert/delete for {i} ---")
            print(f"Error Type: {type(e)}")
            print(f"Error Message: {e}")
        # -------------------------------------------------------------

        finally:
            if not transaction.get_autocommit(using='tsurugi_connection'):
                 transaction.set_autocommit(True, using='tsurugi_connection')
            time.sleep(1)

    print("") # 改行

    # データ挿入直後の結果を問い合わせ(ORM)出力する
    print("  01-10: Even do nothing, Odd delete.")
    print("  11-20: Even commit, Odd rollback (simulated by insert then delete).")
    print("    Number\tUpdateTime\tid(primary key)")
    rows = FdwSample.objects.using('tsurugi_connection').all().order_by('num')
    for row in rows:
        print(f"     {row.num:02d}\t\t {row.tim.strftime('%H:%M:%S')}\t {row.id}")

    # ３の倍数のデータを更新(ORM)する
    print("\nUpdated UpdateTime.", flush=True)
    update_time = timezone.localtime(timezone.now()).time()
    with transaction.atomic(using='tsurugi_connection'):
        multiples_of_3_nums = [obj.num for obj in FdwSample.objects.using('tsurugi_connection').all() if obj.num % 3 == 0]
        FdwSample.objects.using('tsurugi_connection').filter(num__in=multiples_of_3_nums).update(tim=update_time)

    # データ更新直後の結果を問い合わせ(SQL)出力する
    print(f"  Multiples of 3: Update the Time({update_time.strftime('%H:%M:%S')}).", flush=True)
    print("    Number\tUpdateTime\tid(primary key)", flush=True)
    with connections['tsurugi_connection'].cursor() as cursor:
        cursor.execute("SELECT num, tim, id FROM fdw_sample ORDER BY num")
        rows = cursor.fetchall()
        for row in rows:
            num, tim, id_val = row
            print(f"     {num:02d}\t\t {tim.strftime('%H:%M:%S')}\t {id_val}")

    print("\nThe sample application has finished.\n")

    print("--- Running cleanup tasks ---")
    run_shell_command("drop_foreign_table")
    run_shell_command("drop_table")
    print("--- Cleanup tasks completed ---\n")

if __name__ == "__main__":
    run_sample_logic()
