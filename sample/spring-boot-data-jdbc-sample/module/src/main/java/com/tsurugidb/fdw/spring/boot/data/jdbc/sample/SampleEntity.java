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

/**
 * Spring Data JPA と比較して、
 * Spring Data JDBC は JPA のアノテーションを使用しません。
 * 代わりに、Spring Data パッケージのアノテーションを使用します。
 */
import org.springframework.data.annotation.Id;
import org.springframework.data.annotation.Transient;
import org.springframework.data.domain.Persistable;
import org.springframework.data.relational.core.mapping.Column;
import org.springframework.data.relational.core.mapping.Table;

import java.sql.Time;

/**
 * データベーステーブル {@code fdw_sample} に対応する JPA エンティティです。
 *
 * <p>
 * このクラスは、データベーステーブルのカラムをフィールドとして持ち、
 * JPA アノテーションを使用してテーブルとのマッピングを定義します。
 * </p>
 *
 * @see Table
 * @see Column
 */
@Table("fdw_sample")
public class SampleEntity implements Persistable<String> {
//public class SampleEntity {

    /**
     * 主キーとなるID。
     */
    @Id
    private String id;

    /**
     * {@code col} カラムに対応する整数値。
     * NOT NULL 制約が設定されています。
     */
    @Column("col")
    private Integer col;

    /**
     * {@code tm} カラムに対応する時刻値。
     */
    @Column("tm")
    private Time tm;

    /**
     * {@code isNew} 新規エンティティかどうかを示すフラグ。
     * @Transient を使ってデータベースに保存しないフィールドにしている。
     */
    @Transient
    private boolean isNew = true;

    /**
     * ID を取得します。
     *
     * @return ID
     */
    public String getId() {
        return id;
    }

    /**
     * isNew を取得します。
     * @return isNew
     */
    @Override
    public boolean isNew() {
        return isNew;
    }

    /**
     * エンティティの状態（新規か既存か）を切り替える。
     */
    public void setAsNotNew() {
        this.isNew = false;
    }

    /**
     * ID を設定します。
     *
     * @param id 設定する ID
     */
    public void setId(String id) {
        this.id = id;
    }

    /**
     * {@code col} を取得します。
     *
     * @return {@code col}
     */
    public Integer getCol() {
        return col;
    }

    /**
     * {@code col} を設定します。
     *
     * @param col 設定する {@code col}
     */
    public void setCol(Integer col) {
        this.col = col;
    }

    /**
     * {@code tm} を取得します。
     *
     * @return {@code tm}
     */
    public Time getTm() {
        return tm;
    }

    /**
     * {@code tm} を設定します。
     *
     * @param tm 設定する {@code tm}
     */
    public void setTm(Time tm) {
        this.tm = tm;
    }

    /**
     * このエンティティの文字列表現を返します。
     *
     * @return エンティティの文字列表現
     */
    @Override
    public String toString() {
        return "fdw_sample{" +
                "id=" + id +
                ", col='" + col + '\'' +
                ", tm=" + tm +
                '}';
    }
}
