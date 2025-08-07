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

import jakarta.persistence.*;  // javax.persistence -> jakarta.persistence

import java.sql.Time;
import java.time.LocalTime;
import java.util.UUID;

/**
 * データベーステーブル {@code fdw_sample} に対応する JPA エンティティ
 *
 * <p>
 * このクラスは、データベーステーブルのカラムをフィールドとして持ち、
 * JPA アノテーションを使用してテーブルとのマッピングを定義する。
 * </p>
 *
 * @see Table
 * @see Column
 */
@Entity
@Table(name = "fdw_sample")
public class SampleEntity {

    /**
     * 主キーとなるID
     */
    @Id
    private String id;

    /**
     * {@code num} カラムに対応する整数値
     * NOT NULL 制約が設定されている。
     */
    @Column(nullable = false)
    private Integer num;

    /**
     * {@code tim} カラムに対応する時刻値
     */
    @Column
    private Time tim;

    /**
     * このクラスのコンストラクタ
     */
    public SampleEntity() {
        this.id = UUID.randomUUID().toString();
        this.tim = Time.valueOf(LocalTime.now());
    }

    /**
     * このクラスのコンストラクタ
     * @param num
     */
    public SampleEntity(Integer num) {
        this.id = UUID.randomUUID().toString();
        this.num = num;
        this.tim = Time.valueOf(LocalTime.now());
    }


    /**
     * ID を取得
     *
     * @return ID
     */
    public String getId() {
        return id;
    }

    /**
     * ID を設定
     *
     * @param id 設定する ID
     */
    public void setId(String id) {
        this.id = id;
    }

    /**
     * {@code num} を取得
     *
     * @return {@code num}
     */
    public Integer getNum() {
        return num;
    }

    /**
     * {@code num} を設定
     *
     * @param num 設定する {@code num}
     */
    public void setNum(Integer num) {
        this.num = num;
    }

    /**
     * {@code tim} を取得
     *
     * @return {@code tim}
     */
    public Time getTim() {
        return tim;
    }

    /**
     * {@code tim} を設定
     *
     * @param tim 設定する {@code tim}
     */
    public void setTim(Time tim) {
        this.tim = tim;
    }

    /**
     * このエンティティの文字列表現を返す
     *
     * @return エンティティの文字列表現
     */
    @Override
    public String toString() {
        return "fdw_sample{" +
                "id=" + id +
                ", num='" + num + '\'' +
                ", tim=" + tim +
                '}';
    }
}
