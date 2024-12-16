/*
 * Copyright 2024 Project Tsurugi.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
package com.tsurugidb.fdw.jdbc.sample;

// 利用するJDBC APIのimport宣言
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.sql.Time;

// 現在時刻を取得するクラスのimport宣言
import java.time.LocalTime;

public class JdbcSample {
    public static void main(String[] args) {
        try {
            /* データベース(PostgreSQL)へ接続する */
            String url = "jdbc:postgresql://localhost:5432/postgres";
            Connection conn = DriverManager.getConnection(url);

            /* この接続の自動コミットモードを無効にする */
            conn.setAutoCommit(false);

            /* 外部テーブルを作成する */
            Statement st = conn.createStatement();
            st.execute(
                        "CREATE FOREIGN TABLE IF NOT EXISTS fdw_sample ("
                            + "col INTEGER NOT NULL,"
                            + "tm TIME"
                            + ") SERVER tsurugi"
                      );

            /* ステートメントキャッシュを利用してTsurugiテーブルにデータを挿入する */
            String sql = "INSERT INTO fdw_sample (col, tm) VALUES (?, ?)";
            PreparedStatement ps = conn.prepareStatement(sql);

            System.out.print("Please wait 10 seconds");
            for (int i=0; i<10; i++) {
                /* colカラムに値(i)を挿入する */
                ps.setInt(1, i);
                /* tmカラムに現在時間を挿入する */
                ps.setTime(2, Time.valueOf(LocalTime.now()));

                /* トランザクション(INSERT文)を開始する */
                ps.executeUpdate();

                /* 挿入した値(i)が偶数か奇数か判定 */
                if (i % 2 == 0) {
                    /* 偶数の場合：トランザクションをコミットする */
                    conn.commit();
                } else {
                    /* 奇数の場合：トランザクションをロールバックする */
                    conn.rollback();
                }

                System.out.print(".");
                try {
                    Thread.sleep(1000);
                } catch (InterruptedException e) {
                    e.printStackTrace();
                    Thread.currentThread().interrupt();
                }
            }
            System.out.println(".");

            /* 実行結果を問い合わせる（出力する） */
            ResultSet rs = st.executeQuery("SELECT * FROM fdw_sample");
            System.out.println("RESULT : Even are committed, odd are rolled back.");
            System.out.println("col,        tm");
            /* 最初の行から問い合わせ結果を順次出力する */
            while (rs.next()) {
                System.out.println("  " + rs.getString(1) + ",  " + 
                                          rs.getString(2));
            }

            /* オブジェクトをクローズする */
            ps.close();
            st.close();
            conn.close();
        } catch (SQLException e) {
            /* エラーが発生した場合のメッセージを出力する */
            System.out.println("\nSQLException e.getMessage = " + e.getMessage());
        }
    }
}
