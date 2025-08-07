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
 * Spring Data JDBC は JPA の JpaRepository を使用しない。
 * 代わりに、Spring Data パッケージの CrudRepository または ListCrudRepository を使用する。
 */
import org.springframework.data.repository.CrudRepository;
import org.springframework.stereotype.Repository;

/**
 * {@link SampleEntity} を操作するためのリポジトリインターフェースです。
 * Spring Data JDBC によって提供される {@link CrudRepository} を拡張することで
 * 基本的な CRUD (Create, Read, Update, Delete) 操作を容易に行うことができる。
 *
 * <p>
 * このインターフェースは、{@link SampleEntity} をデータベースに永続化するための
 * インターフェースを定義する。具体的な実装は Spring Data JDBC によって自動的に生成される。
 * </p>
 *
 * @see SampleEntity
 * @see CrudRepository
 */
@Repository
public interface SampleRepository extends CrudRepository<SampleEntity, String> {
    /**
     * {@link CrudRepository} によって提供される基本的な CRUD 操作に加えて、
     * 必要に応じてカスタムのクエリメソッドを定義することができる。
     *
     * <p>
     * 例えば、特定の条件に合致する {@link SampleEntity} を検索するためのメソッドなどを
     * 追加することができる。
     * </p>
     *
     * <pre>{@code
     * // 例：特定の num 値を持つ SampleEntity を検索する
     * List<SampleEntity> findByNum(Integer num);
     * }</pre>
     */

    /**
     * num 値でソート（昇順）された全てのデータを検索する
     */
    Iterable<SampleEntity> findAllByOrderByNumAsc();
}
