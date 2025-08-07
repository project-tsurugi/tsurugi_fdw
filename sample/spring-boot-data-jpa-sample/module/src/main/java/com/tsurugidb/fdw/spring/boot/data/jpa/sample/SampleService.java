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
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.sql.Time;
import java.time.LocalTime;


/**
 * {@link SampleEntity} を操作するビジネスロジックを提供するサービスクラス
 * {@link SampleRepository} を使用してデータベースへのアクセスを行う。
 *
 * @see SampleRepository
 * @see SampleEntity
 */
@Service
public class SampleService {

    /**
     * SampleRepository の依存性注入を定義
     */
    @Autowired
    private SampleRepository sampleRepository;

    /**
     * {@link SampleEntity} を保存するが、{@code num} が奇数の場合は削除する。
     *
     * <p>
     * このメソッドはトランザクション管理を行わない。
     * 保存処理と削除処理はそれぞれ個別のトランザクションとして実行する。
     * </p>
     *
     * @param entity 保存（一部は保存後に削除）する {@link SampleEntity}
     * @throws RuntimeException {@code num} が奇数の場合、削除処理後にスローする。
     * @see SampleRepository#save(Object)
     * @see SampleRepository#delete(Object)
     */
    public void SaveEntityButOddDelete(SampleEntity entity) {
        // SampleEntityを保存
        sampleRepository.save(entity);
        if (entity.getNum() % 2 != 0) {
            // SampleEntityを削除
            sampleRepository.delete(entity);
            throw new RuntimeException("Delete! for num = " + entity.getNum());
        }
    }

    /**
     * {@link SampleEntity} を保存するが、{@code num} が奇数の場合はトランザクションをロールバックする。
     *
     * <p>
     * このメソッドは {@link Transactional} アノテーションによってトランザクション管理する。
     * {@code num} が奇数の場合、保存処理はロールバックする。
     * </p>
     *
     * @param entity 保存（一部はロールバック）する {@link SampleEntity}。
     * @throws RuntimeException {@code num} が奇数の場合、ロールバックを発生させるためにスローする。
     * @see SampleRepository#save(Object)
     * @see Transactional
     */
    @Transactional
    public void SaveEntityButOddRollback(SampleEntity entity) {
        // SampleEntityを保存
        sampleRepository.save(entity);
        if (entity.getNum() % 2 != 0) {
            // ロールバックを発生させるためのスロー
            throw new RuntimeException("Rollback! for num = " + entity.getNum());
        }
    }

    /**
     * 全てのデータの中から {@code num} が３の倍数の場合 {@code tim} を更新する。
     *
     * <p>
     * このメソッドは {@link Transactional} アノテーションによってトランザクション管理する。
     * 検索処理と更新処理は１つのトランザクションとして実行する。
     * </p>
     *
     * @see SampleRepository#save(Object)
     * @see Transactional
     */
    @Transactional
    public void SaveEntityMultiOfThreeUpdate(Time updateTime) {
        // 対象のデータ(全て)を検索
        sampleRepository.findAll().forEach(entity -> {
            if (entity.getNum() % 3 == 0) {
                // ３の倍数の場合 tim を更新
                entity.setTim(updateTime);
                sampleRepository.save(entity);
            }
        });
    }
}
