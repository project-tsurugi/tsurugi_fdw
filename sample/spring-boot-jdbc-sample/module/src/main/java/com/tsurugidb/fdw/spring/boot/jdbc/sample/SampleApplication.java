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
package com.tsurugidb.fdw.spring.boot.jdbc.sample;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.CommandLineRunner;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

import java.sql.Time;
import java.time.LocalTime;
import java.util.List;
import java.util.Map;

/**
 * Spring Boot アプリケーションのエントリーポイントとなるクラス
 *
 * <p>
 * このクラスは、{@link CommandLineRunner} インターフェースを実装し、
 * アプリケーション起動時に実行される処理を定義します。
 * </p>
 *
 * @see CommandLineRunner
 * @see SampleService
 */
@SpringBootApplication
public class SampleApplication implements CommandLineRunner {

    /**
     * SampleService の依存性注入を定義
     */
    @Autowired
    private SampleService sampleService;

    /**
     * アプリケーションのエントリポイント
     *
     * @param args コマンドライン引数
     */
    public static void main(String[] args) {
        SpringApplication.run(SampleApplication.class, args);
    }

    /**
     * アプリケーション起動時に実行される処理を定義
     *
     * <p>
     * このメソッドでは、データ（数値）の基本的な CRUD と、
     * トランザクションのコミットおよびロールバックのデモンストレーションを行います。
     * </p>
     *
     * @param args コマンドライン引数
     * @throws Exception 予期せぬエラーが発生した場合
     */
    @Override
    public void run(String... args) throws Exception {
        System.out.println("The sample application is running. Please wait 20 seconds...");
        System.out.print("Inserted Number.");

        /*
         * １から１０のデータを挿入するが奇数だけ削除する
         */
        for (int i = 1; i <= 10; i++) {
            try {
                Thread.sleep(1000);
                sampleService.SaveEntityButOddDelete(i);
                System.out.print(".");
            } catch (RuntimeException e) {
                System.out.print(i);
            } catch (InterruptedException e) {
                e.printStackTrace();
                Thread.currentThread().interrupt();
            }
        }

        /*
         * １１から２０のデータを挿入するが奇数だけロールバックする
         */
        for (int i = 11; i <= 20; i++) {
            try {
                Thread.sleep(1000);
                sampleService.SaveEntityButOddRollback(i);
                System.out.print(".");
            } catch (RuntimeException e) {
                System.out.print(i);
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
        List<Map<String, Object>> results = sampleService.findAllByOrderByNumAsc();
        results.forEach(e -> {
            System.out.printf ("     %02d\t\t %s\t(not used)\n", e.get("num"), e.get("tim"));
        });

        /*
         * ３の倍数のデータ（UpdateTime値）を更新する
         */
        System.out.println("\nUpdated UpdateTime.");
        Time updateTime = Time.valueOf(LocalTime.now());
        sampleService.SaveEntityMultiOfThreeUpdate(updateTime);

        /*
         * データ更新直後の結果を出力する
         */
        System.out.println("  Multiples of 3: Update the Time(" + updateTime + ").");
        System.out.println("    Number\tUpdateTime\tPrimaryKey");
        results = sampleService.findAllByOrderByNumAsc();
        results.forEach(e -> {
            System.out.printf ("     %02d\t\t %s\t(not used)\n", e.get("num"), e.get("tim"));
        });
    }
}
