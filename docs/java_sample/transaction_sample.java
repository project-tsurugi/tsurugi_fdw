/* java.sql パッケージをインポート */
import java.sql.*;

class transaction_sample {
    public static void main(String[] args) throws Exception {

        /* JDBCドライバの読み込み */
        Class.forName("org.postgresql.Driver");

        /* データベース(PostgreSQL)の接続先 */
        String url = "jdbc:postgresql://localhost:5432/postgres";
        try {

            /* データベース(PostgreSQL)へ接続する */
            Connection conn = DriverManager.getConnection(url);

            /* Statementを使用してTsurugiのトランザクションを制御する */
            Statement st = conn.createStatement();

            // Drop Table
            try {
                st.execute("DROP FOREIGN TABLE tg_sample");
                st.execute("DROP TABLE tg_sample");
            } catch (SQLException e) {
                // 初回実行（Tsuguriサーバに"tg_sample"がない状況）の際に
                // SQLException(ERROR: table "tg_sample" does not exist)を
                // catchするが何もしない
            }

            // Create Table
            try {
                st.execute(
                            "CREATE TABLE tg_sample ("
                                + "col INTEGER NOT NULL PRIMARY KEY"
                                + ") TABLESPACE tsurugi"
                          );
                st.execute(
                            "CREATE FOREIGN TABLE tg_sample ("
                                + "col INTEGER NOT NULL"
                                + ") SERVER ogawayama"
                          );
            } catch (SQLException e) {
                System.out.println("Create Table error");
                System.out.println("CATCH SQLException e.getMessage = " + e.getMessage());
            }

            /* PreparedStatementを使用してTsurugiのテーブルにデータを挿入する */
            String sql = "INSERT INTO tg_sample (col) VALUES (?)";
            PreparedStatement ps = conn.prepareStatement(sql);

            for (int i=0; i<9; i++) {

                /* Tsurugiのトランザクションを開始する */
                st.execute("SELECT tg_start_transaction()");

                /* Tsurugiのテーブルにデータ(i)を挿入する */
                ps.setInt(1, i);
                ps.executeUpdate();

                /* 挿入した値(i)が偶数か奇数か判定 */
                if (i % 2 == 0) {
                    /* 偶数の場合：トランザクションをコミットする */
                    st.execute("SELECT tg_commit()");
                } else {
                    /* 奇数の場合：トランザクションをロールバックする */
                    st.execute("SELECT tg_rollback()");
                }

            }

            /* 実行結果を確認する */
            ResultSet rs = st.executeQuery("SELECT * FROM tg_sample");
            System.out.println("--- 実行結果：奇数は破棄(ロールバック)される ---");
            while (rs.next()) {
                System.out.println("  " + rs.getString(1));
            }

            ps.close();
            st.close();
            conn.close();
        } catch (SQLException e) {
            System.out.println("CATCH SQLException e.getMessage = " + e.getMessage());
        }
    }
}
