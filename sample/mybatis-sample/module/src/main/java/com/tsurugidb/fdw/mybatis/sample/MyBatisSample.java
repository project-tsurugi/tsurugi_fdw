/*
 * Copyright 2024 Project Tsurugi.
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
package com.tsurugidb.fdw.mybatis.sample;

import java.io.InputStream;
import java.sql.Time;
import java.time.LocalTime;
import java.util.List;
import org.apache.ibatis.io.Resources;
import org.apache.ibatis.session.SqlSession;
import org.apache.ibatis.session.SqlSessionFactory;
import org.apache.ibatis.session.SqlSessionFactoryBuilder;

public class MyBatisSample {
    public static void main(String[] args) {
        /* 設定ファイルからSqlSessionFactoryを生成する */
        String resource = "mybatis-config.xml";
        try (InputStream inputStream = Resources.getResourceAsStream(resource)) {
            SqlSessionFactory sqlSessionFactory = new SqlSessionFactoryBuilder().build(inputStream);
            /* SqlSessionFactoryからSqlSessionを取得する */
            /* 引数を指定しないopenSession()はauto-commitが無効になる */
            try (SqlSession session = sqlSessionFactory.openSession()) {
                /* Mapperインターフェイスのインスタンスを取得する */
                RawMapper mapper = session.getMapper(RawMapper.class);
                System.out.print("Please wait 10 seconds");
                for (int i=0; i<10; i++) {
                    Raw newRaw = new Raw();
                    /* colカラムに値(i)を挿入する */
                    newRaw.setCol(i);
                    /* tmカラムに現在時間を挿入する */
                    newRaw.setTm(Time.valueOf(LocalTime.now()));
                    /* トランザクション(INSERT文)を開始する */
                    mapper.insertRaw(newRaw);
                    /* 挿入した値(i)が偶数か奇数か判定 */
                    if (i % 2 == 0) {
                        /* 偶数の場合：トランザクションをコミットする */
                        session.commit();
                    } else {
                        /* 奇数の場合：トランザクションをロールバックする */
                        session.rollback();
                    }
                    System.out.print(".");
                    try {
                        Thread.sleep(1000);
                    } catch (InterruptedException e) {
                        e.printStackTrace();
                        Thread.currentThread().interrupt();
                    }
                }
                System.out.println(".");
                System.out.println("RESULT : Even are committed, odd are rolled back.");
                /* 実行結果を問い合わせる */
                List<Raw> raws = mapper.getAllRaws();
                /* 実行結果を出力する */
                raws.forEach(System.out::println);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}
