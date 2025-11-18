# Copyright 2025 Project Tsurugi.
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

import psycopg
from psycopg import sql
import time
from datetime import datetime, time as datetime_time
import subprocess
import os

# Psycopg3の型アダプタをカスタマイズするために必要
import psycopg.adapt
from psycopg.types.numeric import Int4Dumper 

# データベース接続情報
DB_URL = "postgresql://localhost:35432/tsurugi_db"

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

def main():
    conn = None
    cursor = None
    try:
        print("--- Running setup tasks ---")
        run_shell_command("create_database")
        run_shell_command("create_table")
        run_shell_command("create_foreign_table")
        print("--- Setup tasks completed ---\n")

        print("The sample application is running. Please wait...\n")

        # PostgreSQL への接続
        conn = psycopg.connect(DB_URL)

        # Psycopg3でPythonのintをPostgreSQLのINTEGER(int4)として扱う。
        # デフォルトではINTEGER(int4)未満の値はSMALLINT(int2)で扱われる。
        conn.adapters.register_dumper(int, Int4Dumper)

        conn.autocommit = False # トランザクションを手動で制御する
        cursor = conn.cursor()

        print("Inserted Number.", end="", flush=True)

        # １から１０のデータを挿入するが奇数だけ削除する
        for i in range(1, 11):
            try:
                insert_sql = sql.SQL("INSERT INTO fdw_sample (num, tim) VALUES (%s, %s)")
                current_time = datetime.fromtimestamp(time.time()).time()
                cursor.execute(insert_sql, (i, current_time))
                conn.commit() # 挿入操作をコミット

                if i % 2 != 0:
                    delete_sql = sql.SQL("DELETE FROM fdw_sample WHERE num = %s")
                    cursor.execute(delete_sql, (i,))
                    conn.commit() # 削除操作をコミット
                    print(i, end="", flush=True)
                else:
                    print(".", end="", flush=True)
            except psycopg.Error as e:
                print(f"\nPsycopg Error: {e}")
                conn.rollback() # エラー時はロールバック
            except Exception as e:
                print(f"\nAn unexpected error occurred: {e}")
                conn.rollback() # エラー時はロールバック
            finally:
                time.sleep(1)

        # １１から２０のデータを挿入するが奇数だけロールバックする
        for i in range(11, 21):
            try:
                insert_sql = sql.SQL("INSERT INTO fdw_sample (num, tim) VALUES (%s, %s)")
                current_time = datetime.fromtimestamp(time.time()).time()
                cursor.execute(insert_sql, (i, current_time))

                if i % 2 != 0:
                    # 奇数の場合、挿入操作をロールバック
                    conn.rollback()
                    print(i, end="", flush=True)
                else:
                    # 偶数の場合、挿入操作をコミット
                    conn.commit()
                    print(".", end="", flush=True)
            except psycopg.Error as e:
                print(f"\nPsycopg Error: {e}")
                conn.rollback() # エラー時はロールバック
            except Exception as e:
                print(f"\nAn unexpected error occurred: {e}")
                conn.rollback() # エラー時はロールバック
            finally:
                time.sleep(1)
        print("") # 改行

        # データ挿入直後の結果を出力する
        print("  01-10: Even do nothing, Odd delete.")
        print("  11-20: Even commit, Odd rollback.")
        print("    Number\tUpdateTime")
        select_sql = sql.SQL("SELECT num, tim FROM fdw_sample ORDER BY num")
        cursor.execute(select_sql)
        rows = cursor.fetchall()
        for row in rows:
            # Pythonのtimeオブジェクトは秒までしか持たない
            print(f"     {row[0]:02d}\t\t {row[1].strftime('%H:%M:%S')}")

        # ３の倍数のデータを更新する
        print("\nUpdated UpdateTime.", flush=True)
        update_time = datetime.fromtimestamp(time.time()).time()
        update_sql = sql.SQL("UPDATE fdw_sample SET tim = %s WHERE num %% 3 = 0")
        cursor.execute(update_sql, (update_time,))
        conn.commit() # 更新操作をコミット

        # データ更新直後の結果を出力する
        print(f"  Multiples of 3: Update the Time({update_time.strftime('%H:%M:%S')}).", flush=True)
        print("    Number\tUpdateTime", flush=True)
        cursor.execute(select_sql)
        rows = cursor.fetchall()
        for row in rows:
            # Pythonのtimeオブジェクトは秒までしか持たない
            print(f"     {row[0]:02d}\t\t {row[1].strftime('%H:%M:%S')}")

    except psycopg.Error as e:
        print(f"Database error: {e}")
        if conn:
            conn.rollback() # エラー発生時はロールバック
    except Exception as e:
        print(f"An unexpected error occurred: {e}")
        if conn:
            conn.rollback() # エラー発生時はロールバック
    finally:
        # 接続リソースを解放
        if cursor:
            cursor.close()
        if conn:
            conn.close()

        print("\nThe sample application has finished.\n")

        print("--- Running cleanup tasks ---")
        run_shell_command("drop_foreign_table")
        run_shell_command("drop_table")
        print("--- Cleanup tasks completed ---\n")

if __name__ == "__main__":
    main()
