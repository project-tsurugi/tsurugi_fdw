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

package com.tsurugidb.fdw.spring.boot.data.jpa.sample;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.CommandLineRunner;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

import java.sql.Time;
import java.time.LocalTime;
import java.util.UUID;

/**
 * Spring Boot アプリケーションのエントリーポイントとなるクラスです。
 *
 * <p>
 * このクラスは、{@link CommandLineRunner} インターフェースを実装し、
 * アプリケーション起動時に実行される処理を定義します。
 * </p>
 *
 * @see CommandLineRunner
 * @see SampleRepository
 * @see SampleService
 */
@SpringBootApplication
public class SampleApplication implements CommandLineRunner {

    /**
     * データベースへのアクセスを提供するリポジトリインターフェースです。
     */
    @Autowired
    private SampleRepository sampleRepository;

    /**
     * ビジネスロジックを提供するサービスクラスです。
     */
    @Autowired
    private SampleService sampleService;

    /**
     * アプリケーションを起動します。
     *
     * @param args コマンドライン引数
     */
    public static void main(String[] args) {
        SpringApplication.run(SampleApplication.class, args);
    }

    /**
     * アプリケーション起動時に実行される処理を定義します。
     *
     * <p>
     * このメソッドでは、{@link SampleEntity} の保存と削除、
     * トランザクションのコミットとロールバックのデモンストレーションを行います。
     * </p>
     *
     * @param args コマンドライン引数
     * @throws Exception 予期せぬエラーが発生した場合
     */
    @Override
    public void run(String... args) throws Exception {
        System.out.print("The sample application is running...\nPlease wait 20 seconds");

        /*
         * ０から９のデータを挿入するが奇数だけ削除する
         */
        for (int i = 0; i < 10; i++) {
            SampleEntity entity = new SampleEntity();
            entity.setCol(i);
            entity.setTm(Time.valueOf(LocalTime.now()));
            entity.setId(UUID.randomUUID().toString());
            try {
                sampleService.SaveEntityButOddDelete(entity);
                System.out.print(".");
            } catch (RuntimeException e) {
                System.out.print(i);
            }

            try {
                Thread.sleep(1000);
            } catch (InterruptedException e) {
                e.printStackTrace();
                Thread.currentThread().interrupt();
            }
        }

        /*
         * １０から１９のデータを挿入するが奇数だけロールバックする
         */
        for (int i = 10; i < 20; i++) {
            SampleEntity entity = new SampleEntity();
            entity.setCol(i);
            entity.setTm(Time.valueOf(LocalTime.now()));
            entity.setId(UUID.randomUUID().toString());
            try {
                sampleService.SaveEntityButOddRollback(entity);
                System.out.print(".");
            } catch (RuntimeException e) {
                System.out.print(i);
            }

            try {
                Thread.sleep(1000);
            } catch (InterruptedException e) {
                e.printStackTrace();
                Thread.currentThread().interrupt();
            }
        }

        System.out.println(".");

        /*
         * データ挿入直後の結果を出力する
         */
        System.out.println("\nInserted Column.");
        System.out.println("   0- 9: Even do nothing, Odd delete.");
        System.out.println("  10-19: Even commit, Odd rollback.");
        System.out.println("    Col,\tTime,\t\tPrimary Key");
        sampleRepository.findAllByOrderByColAsc().forEach(e -> {
            System.out.printf ("    %02d,\t\t%s,\t%s\n", e.getCol(), e.getTm(), e.getId());
        });

        /*
         * ３の倍数のデータを更新する
         */
        sampleService.SaveEntityMultiOfThreeUpdate();

        /*
         * データ更新直後の結果を出力する
         */
        System.out.println("\nUpdated Column.");
        System.out.println("  Multiples of 3: Clear the tm (00:00:00).");
        System.out.println("    Col,\tTime,\t\tPrimary Key");
        sampleRepository.findAllByOrderByColAsc().forEach(e -> {
            System.out.printf ("    %02d,\t\t%s,\t%s\n", e.getCol(), e.getTm(), e.getId());
        });
    }
}
