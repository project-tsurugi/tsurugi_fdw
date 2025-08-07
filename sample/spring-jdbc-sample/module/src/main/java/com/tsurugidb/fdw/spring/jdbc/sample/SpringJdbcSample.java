/*
 * Copyright 2025 Project Tsurugi.
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
package com.tsurugidb.fdw.spring.jdbc.sample;

// 利用するSpring JDBCのimport宣言
import org.springframework.dao.DataAccessException;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.datasource.DataSourceTransactionManager;
import org.springframework.jdbc.datasource.DriverManagerDataSource;
import org.springframework.transaction.PlatformTransactionManager;
import org.springframework.transaction.support.TransactionTemplate;

import java.sql.Time;
import java.time.LocalTime;

/**
 * アプリケーションのエントリーポイントとなるクラス
 *
 * <p>
 * このクラスは、エントリーポイントのみの実装としている。
 * </p>
 */
public class SpringJdbcSample {

    /**
     * アプリケーションのエントリポイント
     *
     * <p>
     * このメソッドでは、Spring Framework を使用したデータベースへの接続と、
     * JdbcTemplate および TransactionTemplate を使用した基本的な DML 実行 および
     * トランザクション操作のデモンストレーションを行います。
     * </p>
     *
     * @param args コマンドライン引数
     */
    public static void main(String[] args) {
        System.out.println("The sample application is running. Please wait 20 seconds...");

        // データベース接続情報
        String url = "jdbc:postgresql://localhost:35432/postgres";
        // DataSourceの作成
        DriverManagerDataSource dataSource = new DriverManagerDataSource();
        dataSource.setDriverClassName("org.postgresql.Driver");
        dataSource.setUrl(url);

        // JdbcTemplateの作成
        JdbcTemplate jdbcTemplate = new JdbcTemplate(dataSource);

        System.out.print("Inserted Number.");
        /*
         * １から１０のデータを挿入するが奇数だけ削除する
         */
        for (int i = 1; i <= 10; i++) {
            try {
	            String insertSql = "INSERT INTO fdw_sample (num, tim) VALUES (?, ?)";
	            jdbcTemplate.update(insertSql, i, Time.valueOf(LocalTime.now()));
	            if (i % 2 != 0) {
	                String deleteSql = "DELETE from fdw_sample where num = ?";
	                jdbcTemplate.update(deleteSql, i);
	                System.out.print(i);
	            } else {
	                System.out.print(".");
	            }
                Thread.sleep(1000);
            } catch (DataAccessException e) {
	            System.err.println("\nDataAccessException e.getMessage = " + e.getMessage());
            } catch (InterruptedException e) {
                e.printStackTrace();
                Thread.currentThread().interrupt();
            }
        }

        // トランザクションマネージャーの作成
        PlatformTransactionManager transactionManager = new DataSourceTransactionManager(dataSource);
        // TransactionTemplateの作成
        TransactionTemplate transactionTemplate = new TransactionTemplate(transactionManager);

        /*
         * １１から２０のデータを挿入するが奇数だけロールバックする
         */
        for (int i = 11; i <= 20; i++) {
            try {
	            final int currenet = i;
	            transactionTemplate.execute(status -> {
	                String insertSql = "INSERT INTO fdw_sample (num, tim) VALUES (?, ?)";
	                jdbcTemplate.update(insertSql, currenet, Time.valueOf(LocalTime.now()));
	                if (currenet % 2 != 0) {
	                    // 奇数の場合、ロールバックのみを設定
	                    status.setRollbackOnly();
	                    System.out.print(currenet);
	                } else {
	                    System.out.print(".");
	                }
	                return null;
	            });
                Thread.sleep(1000);
            } catch (DataAccessException e) {
	            System.err.println("\nDataAccessException e.getMessage = " + e.getMessage());
            } catch (InterruptedException e) {
                e.printStackTrace();
                Thread.currentThread().interrupt();
            }
        }

        System.out.print("\n");

        /*
         * データ挿入直後の結果を出力する
         */
        System.out.println("  01-10: Even do nothing, Odd delete.");
        System.out.println("  11-20: Even commit, Odd rollback.");
        System.out.println("    Number\tUpdateTime\tPrimaryKey");
        String selectSql = "SELECT * FROM fdw_sample";
        jdbcTemplate.query(selectSql, (rs, rowNum) -> {
            System.out.printf ("     %02d\t\t %s\t(not used)\n", rs.getInt("num"), rs.getString("tim"));
            return null;
        });

        /*
         * ３の倍数のデータを更新する
         */
        System.out.println("\nUpdated UpdateTime.");
        String updateSql = "UPDATE fdw_sample SET tim = ? where num % 3 = 0";
        Time updateTime = Time.valueOf(LocalTime.now());
        jdbcTemplate.update(updateSql, updateTime);

        /*
         * データ更新直後の結果を出力する
         */
        System.out.println("  Multiples of 3: Update the Time(" + updateTime + ").");
        System.out.println("    Number\tUpdateTime\tPrimaryKey");
        jdbcTemplate.query(selectSql, (rs, rowNum) -> {
            System.out.printf ("     %02d\t\t %s\t(not used)\n", rs.getInt("num"), rs.getString("tim"));
            return null;
        });
    }
}
