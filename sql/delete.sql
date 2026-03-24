SELECT tg_execute_ddl('
    CREATE TABLE tsurugifdw_delete_test (
        id INT PRIMARY KEY,
        a INT,
        b VARCHAR
    )
', 'tsurugidb');
CREATE FOREIGN TABLE tsurugifdw_delete_test (
        id SERIAL,
        a INT,
        b VARCHAR
) SERVER tsurugidb;

INSERT INTO tsurugifdw_delete_test (a) VALUES (10);
INSERT INTO tsurugifdw_delete_test (a, b) VALUES (50, repeat('x', 10000));
INSERT INTO tsurugifdw_delete_test (a) VALUES (100);

-- allow an alias to be specified for DELETE's target table
DELETE FROM tsurugifdw_delete_test AS dt WHERE dt.a > 75;

-- if an alias is specified, don't allow the original table name
-- to be referenced
DELETE FROM tsurugifdw_delete_test dt WHERE tsurugifdw_delete_test.a > 25;

SELECT id, a, char_length(b) FROM tsurugifdw_delete_test;

-- delete a row with a TOASTed value
DELETE FROM tsurugifdw_delete_test WHERE a > 25;

SELECT id, a, char_length(b) FROM tsurugifdw_delete_test;

SELECT tg_execute_ddl('DROP TABLE tsurugifdw_delete_test', 'tsurugidb');
DROP FOREIGN TABLE tsurugifdw_delete_test;
