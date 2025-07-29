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
package com.tsurugidb.fdw.spring.boot.data.jdbc.sample;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.sql.Time;
import java.time.LocalTime;


/**
 * {@link SampleEntity} を操作するビジネスロジックを提供するサービスクラスです。
 * {@link SampleRepository} を使用してデータベースへのアクセスを行います。
 *
 * @see SampleRepository
 * @see SampleEntity
 */
@Service
public class SampleService {

    /**
     * データベースへのアクセスを提供するリポジトリインターフェースです。
     */
    @Autowired
    private SampleRepository sampleRepository;

    /**
     * {@link SampleEntity} を保存し、{@code col} が奇数の場合に削除します。
     * このメソッドはトランザクション管理を行いません。
     *
     * <p>
     * 保存処理と削除処理はそれぞれ個別のトランザクションとして実行されます。
     * </p>
     *
     * @param entity 保存または削除する {@link SampleEntity}。
     * @throws RuntimeException {@code col} が奇数の場合に削除処理後にスローされます。
     * @see SampleRepository#save(Object)
     * @see SampleRepository#delete(Object)
     */
    public void SaveEntityButOddDelete(SampleEntity entity) {
        // SampleEntityを保存
        sampleRepository.save(entity);

        if (entity.getCol() % 2 != 0) {
            // SampleEntityを削除
            sampleRepository.delete(entity);
            throw new RuntimeException("Delete! for col = " + entity.getCol());
        }
    }

    /**
     * {@link SampleEntity} を保存し、{@code col} が奇数の場合にトランザクションをロールバックします。
     * このメソッドは {@link Transactional} アノテーションによってトランザクション管理されます。
     *
     * <p>
     * {@code col} が奇数の場合、保存処理はロールバックされます。
     * </p>
     *
     * @param entity 保存する {@link SampleEntity}。
     * @throws RuntimeException {@code col} が奇数の場合にロールバックを発生させるためにスローされます。
     * @see SampleRepository#save(Object)
     * @see Transactional
     */
    @Transactional
    public void SaveEntityButOddRollback(SampleEntity entity) {
        // SampleEntityを保存
        sampleRepository.save(entity);

        if (entity.getCol() % 2 != 0) {
            // ロールバックを発生させるためのスロー
            throw new RuntimeException("Rollback! for col = " + entity.getCol());
        }
    }

    /**
     * {@link SampleRepository} の全てのデータを検索し、{@code col} が３の倍数の場合 {@code tm} を更新（00:00:00）します。
     * このメソッドは {@link Transactional} アノテーションによってトランザクション管理されます。
     *
     * <p>
     * 検索処理と更新処理は１つのトランザクションとして実行されます。
     * </p>
     *
     * @see SampleRepository#save(Object)
     * @see Transactional
     */
    @Transactional
    public void SaveEntityMultiOfThreeUpdate() {
        // 対象のデータ(全て)を検索
        sampleRepository.findAll().forEach(entity -> {
            if (entity.getCol() % 3 == 0) {
                // ３の倍数の場合 tmをクリア（00:00:00）する
                entity.setAsNotNew();
                entity.setTm(Time.valueOf(LocalTime.MIDNIGHT));
                sampleRepository.save(entity);
            }
        });

    }
}
