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

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

/**
 * {@link SampleEntity} を操作するためのリポジトリインターフェースです。
 * Spring Data JPA によって提供される {@link JpaRepository} を拡張することで、
 * 基本的な CRUD (Create, Read, Update, Delete) 操作を容易に行うことができます。
 *
 * <p>
 * このインターフェースは、{@link SampleEntity} をデータベースに永続化するための
 * 抽象化を提供し、具体的な実装は Spring Data JPA によって自動的に生成されます。
 * </p>
 *
 * @see SampleEntity
 * @see JpaRepository
 */
@Repository
public interface SampleRepository extends JpaRepository<SampleEntity, Long> {
    /**
     * {@link JpaRepository} によって提供される基本的な CRUD 操作に加えて、
     * 必要に応じてカスタムのクエリメソッドを定義することができます。
     *
     * <p>
     * 例えば、特定の条件に合致する {@link SampleEntity} を検索するためのメソッドなどを
     * 追加することができます。
     * </p>
     *
     * <pre>{@code
     * // 例：特定の col 値を持つ SampleEntity を検索する
     * List<SampleEntity> findByCol(Integer col);
     * }</pre>
     */
}
