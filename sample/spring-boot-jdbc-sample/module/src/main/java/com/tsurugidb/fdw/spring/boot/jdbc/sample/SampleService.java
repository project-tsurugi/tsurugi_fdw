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
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.sql.Time;
import java.time.LocalTime;
import java.util.List;
import java.util.Map;

/**
 * 数値（num）を操作するビジネスロジックを提供するサービスクラス
 * {@link JdbcTemplate} を使用してデータベースへのアクセスを行う。
 *
 * @see JdbcTemplate
 */
@Service
public class SampleService {

    /**
     * JdbcTemplate の依存性注入を定義
     */
    @Autowired
    private JdbcTemplate jdbcTemplate;

    private static final String CREATE_DATA_SQL = "insert into fdw_sample (num, tim) values (?, ?)";
    private static final String READ_DATA_SQL   = "select num, tim from fdw_sample order by num asc";
    private static final String UPDATE_DATA_SQL = "update fdw_sample set tim = ? where num % 3 = 0";
    private static final String DELETE_DATA_SQL = "delete from fdw_sample where num = ?";

    /**
     * 数値（num）を保存するが、数値（num）が奇数の場合は削除する。
     *
     * <p>
     * このメソッドはトランザクション管理を行わない。
     * 保存処理と削除処理はそれぞれ個別のトランザクションとして実行する。
     * </p>
     *
     * @param number 保存（一部は保存後に削除）する数値（num）
     * @throws RuntimeException {@code number} が奇数の場合、削除処理後にスローする。
     * @see JdbcTemplate#update(sql, ... args)
     */
    public void SaveEntityButOddDelete(int number) {
        // 列を保存
        Time time = Time.valueOf(LocalTime.now());
        jdbcTemplate.update(CREATE_DATA_SQL, number, time);

        if (number % 2 != 0) {
            // 列を削除
            jdbcTemplate.update(DELETE_DATA_SQL, number);
            throw new RuntimeException("Delete! for num = " + number);
        }
    }

    /**
     * 数値（num）を保存するが、数値（num）が奇数の場合はトランザクションをロールバックする。
     *
     * <p>
     * このメソッドは {@link Transactional} アノテーションによってトランザクション管理する。
     * {@code number} が奇数の場合、保存処理はロールバックする。
     * </p>
     *
     * @param number 保存（一部はロールバック）する数値（num）
     * @throws RuntimeException {@code number} が奇数の場合、ロールバックを発生させるためにスローする。
     * @see JdbcTemplate#update(sql, ... args)
     * @see Transactional
     */
    @Transactional
    public void SaveEntityButOddRollback(int number) {
        // 列を保存
        Time time = Time.valueOf(LocalTime.now());
        jdbcTemplate.update(CREATE_DATA_SQL, number, time);

        if (number % 2 != 0) {
            // ロールバックを発生させるためのスロー
            throw new RuntimeException("Rollback! for num = " + number);
        }
    }

    /**
     * 全てのデータの中から数値（num）が３の倍数の場合 {@code tim} を更新する。
     *
     * <p>
     * このメソッドは {@link Transactional} アノテーションによってトランザクション管理する。
     * 更新処理は一つのトランザクションとして実行する。
     * </p>
     *
     * @see JdbcTemplate#update(sql, ... args)
     * @see Transactional
     */
    @Transactional
    public void SaveEntityMultiOfThreeUpdate(Time updateTime) {
        // ３の倍数の場合 tim を更新
        jdbcTemplate.update(UPDATE_DATA_SQL, updateTime);
    }

    /**
     * 全てのデータを検索する。
     *
     * <p>
     * このメソッドはトランザクション管理を行わない。
     * 検索処理は一つのトランザクションとして実行する。
     * </p>
     *
     * @see JdbcTemplate#update(sql, ... args)
     * @see Transactional
     */
    public List<Map<String, Object>> findAllByOrderByNumAsc() {
        return jdbcTemplate.queryForList(READ_DATA_SQL);
    }
}
