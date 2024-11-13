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

import java.sql.*;
import java.time.*;

public class JdbcSample {
	public static void main(String[] args) {

		/* データベース(PostgreSQL)の接続先 */
		String url = "jdbc:postgresql://localhost:35432/postgres";
		try {

			/* データベース(PostgreSQL)へ接続する */
			Connection conn = DriverManager.getConnection(url);

			/* この接続の自動コミット・モードを無効にする */
			conn.setAutoCommit(false);

			// 外部テーブル作成
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

			/* 実行結果を確認する */
			ResultSet rs = st.executeQuery("SELECT * FROM fdw_sample");
			System.out.println("RESULT : Even are committed, odd are rolled back.");
			System.out.println("col,        tm");
			while (rs.next()) {
				System.out.println("  " + rs.getString(1) + ",  " + 
										  rs.getString(2));
			}

			ps.close();
			st.close();
			conn.close();
		} catch (SQLException e) {
			System.out.println("SQLException e.getMessage = " + e.getMessage());
		}
	}
}
