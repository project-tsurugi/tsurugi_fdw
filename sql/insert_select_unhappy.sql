/* Test setup: DDL of the Tsurugi */
SELECT tg_execute_ddl('
    CREATE TABLE integer1 (
        ol_w_id int PRIMARY KEY
    )
', 'tsurugidb');
SELECT tg_execute_ddl('
    CREATE TABLE bigint1 (
        id int PRIMARY KEY,
        ol_w_id bigint
    )
', 'tsurugidb');
SELECT tg_execute_ddl('
    CREATE TABLE tg_temporal_literal (
        id        INTEGER NOT NULL PRIMARY KEY,
        dt        DATE,
        tm        TIME,
        tms       TIMESTAMP,
        tms_wo_tz TIMESTAMP WITHOUT TIME ZONE,
        tms_w_tz  TIMESTAMP WITH TIME ZONE
    )
', 'tsurugidb');

/* Test setup: DDL of the PostgreSQL */
CREATE FOREIGN TABLE integer1 (
    ol_w_id int
) SERVER tsurugidb;
CREATE FOREIGN TABLE bigint1 (
    id int,
    ol_w_id bigint
) SERVER tsurugidb;
-- temporal_literal : tsurugi-issues#881
CREATE FOREIGN TABLE tg_temporal_literal (
    id        INTEGER NOT NULL,
    dt        DATE,
    tm        TIME,
    tms       TIMESTAMP,
    tms_wo_tz TIMESTAMP WITHOUT TIME ZONE,
    tms_w_tz  TIMESTAMP WITH TIME ZONE
) SERVER tsurugidb;

-- DML
--- int
INSERT INTO integer1 (ol_w_id) VALUES (1.1);  -- see tsurugi-issues#736
INSERT INTO integer1 (ol_w_id) VALUES (cast(1.1 as int));
SELECT * FROM integer1 ORDER BY ol_w_id;
INSERT INTO integer1 (ol_w_id) VALUES (0.1);  -- see tsurugi-issues#736
INSERT INTO integer1 (ol_w_id) VALUES (cast(0.1 as int));
SELECT * FROM integer1 ORDER BY ol_w_id;

--- bigint
INSERT INTO bigint1 (id, ol_w_id) VALUES (15, 1.1);  -- see tsurugi-issues#736
INSERT INTO bigint1 (id, ol_w_id) VALUES (15, cast(1.1 as bigint));
SELECT * FROM bigint1 ORDER BY id;
INSERT INTO bigint1 (id, ol_w_id) VALUES (16, 0.1);  -- see tsurugi-issues#736
INSERT INTO bigint1 (id, ol_w_id) VALUES (16, cast(0.1 as bigint));
SELECT * FROM bigint1 ORDER BY id;

--- temporal_literal(auto cast) : tsurugi-issues#896  -- error
INSERT INTO tg_temporal_literal (id, dt) VALUES (11, '2024-08-30');  -- error
INSERT INTO tg_temporal_literal (id, tm) VALUES (12, '04:05:06.789');  -- error
INSERT INTO tg_temporal_literal (id, tms) VALUES (13, '2024-08-30 04:05:06.789');  -- error
INSERT INTO tg_temporal_literal (id, tms_wo_tz) VALUES (14, '2024-08-30 04:05:06.789');  -- error
INSERT INTO tg_temporal_literal (id, tms_w_tz) VALUES (15, '2024-08-30 04:05:06.789+9:00');  -- error

/* Test teardown: DDL of the PostgreSQL */
DROP FOREIGN TABLE integer1;
DROP FOREIGN TABLE bigint1;
DROP FOREIGN TABLE tg_temporal_literal;

/* Test teardown: DDL of the Tsurugi */
SELECT tg_execute_ddl('DROP TABLE integer1', 'tsurugidb');
SELECT tg_execute_ddl('DROP TABLE bigint1', 'tsurugidb');
SELECT tg_execute_ddl('DROP TABLE tg_temporal_literal', 'tsurugidb');
