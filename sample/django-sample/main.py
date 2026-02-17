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
from django.db import transaction
from django.utils import timezone
import subprocess
import time

# Django環境のセットアップ
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'django_sample_project.settings')
django.setup()

# my_app.models.FdwSample をインポート
# django.setup() 後にインポートする必要がある
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
    run_shell_command("create_foreign_table")
    print("--- Setup tasks completed ---\n")

    print("The sample application is running. Please wait...\n")

    print("Inserted Number.", end="", flush=True)

    # １から１０のデータを挿入するが奇数だけ削除する
    for i in range(1, 11):
        try:
            with transaction.atomic(using='tsurugi_connection'):
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

    # １１から２０のデータを挿入するが奇数だけロールバックする
    for i in range(11, 21):
        try:
            with transaction.atomic(using='tsurugi_connection'):
                current_time = timezone.localtime(timezone.now()).time()
                FdwSample.objects.create(num=i, tim=current_time)

                if i % 2 != 0:
                    # ロールバックを発生させるための RuntimeError
                    raise RuntimeError("Intentional rollback for odd number")
                else:
                    print(".", end="", flush=True)
        except RuntimeError as e:
            print(str(i), end="", flush=True)
        except Exception as e:
            print(f"\nAn error occurred during insert/delete for {i}: {e}")
        finally:
            time.sleep(1)

    print("") # 改行

    # データ挿入直後の結果を出力する
    print("  01-10: Even do nothing, Odd delete.")
    print("  11-20: Even commit, Odd rollback (simulated by insert then delete).")
    print("    Number\tUpdateTime\tid(primary key)")
    rows = FdwSample.objects.using('tsurugi_connection').all().order_by('num')
    for row in rows:
        print(f"     {row.num:02d}\t\t {row.tim.strftime('%H:%M:%S')}\t {row.id}")

    # ３の倍数のデータを更新する
    print("\nUpdated UpdateTime.", flush=True)
    update_time = timezone.localtime(timezone.now()).time()
    with transaction.atomic(using='tsurugi_connection'):
        multiples_of_3_nums = [obj.num for obj in FdwSample.objects.using('tsurugi_connection').all() if obj.num % 3 == 0]
        FdwSample.objects.using('tsurugi_connection').filter(num__in=multiples_of_3_nums).update(tim=update_time)

    # データ更新直後の結果を出力する
    print(f"  Multiples of 3: Update the Time({update_time.strftime('%H:%M:%S')}).", flush=True)
    print("    Number\tUpdateTime\tid(primary key)", flush=True)
    rows = FdwSample.objects.using('tsurugi_connection').all().order_by('num')
    for row in rows:
        print(f"     {row.num:02d}\t\t {row.tim.strftime('%H:%M:%S')}\t {row.id}")

    print("\nThe sample application has finished.\n")

    print("--- Running cleanup tasks ---")
    run_shell_command("drop_foreign_table")
    run_shell_command("drop_table")
    print("--- Cleanup tasks completed ---\n")

if __name__ == "__main__":
    run_sample_logic()
