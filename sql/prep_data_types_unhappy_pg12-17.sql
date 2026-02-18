/* Test case: unhappy path - Unsupported data types (preparation) - PostgreSQL 12-17 */

-- Date/Time Types - date
--- Test setup: DDL of the Tsurugi
SELECT tg_execute_ddl('
  CREATE TABLE fdw_type_date (c DATE)
', 'tsurugidb');
--- Test setup: DDL of the PostgreSQL
CREATE FOREIGN TABLE fdw_type_date (
  c date
) SERVER tsurugidb;

--- Test
SET DATESTYLE TO 'default';
PREPARE prep_insert AS
  INSERT INTO fdw_type_date VALUES (date '01:02:03.456');
PREPARE prep_insert AS
  INSERT INTO fdw_type_date VALUES (time '01:02:03.456');
PREPARE prep_insert AS
  INSERT INTO fdw_type_date VALUES (date '2021-02-30');
PREPARE prep_insert AS
  INSERT INTO fdw_type_date VALUES (date 'invalid');

SET DATESTYLE TO ISO, YMD;
PREPARE prep_insert (date) AS
  INSERT INTO fdw_type_date VALUES ($1);
EXECUTE prep_insert (date '1/8/1999');
EXECUTE prep_insert (date '1/18/1999');
EXECUTE prep_insert (date '08-Jan-99');
EXECUTE prep_insert (date 'Jan-08-99');
EXECUTE prep_insert (date 'January 8, 99 BC');
DEALLOCATE prep_insert;
SET DATESTYLE TO 'default';

--- Test teardown: DDL of the PostgreSQL
DROP FOREIGN TABLE fdw_type_date;
--- Test teardown: DDL of the Tsurugi
SELECT tg_execute_ddl('DROP TABLE fdw_type_date', 'tsurugidb');

-- Date/Time Types - time
--- Test setup: DDL of the Tsurugi
SELECT tg_execute_ddl('
  CREATE TABLE fdw_type_time (c TIME)
', 'tsurugidb');
--- Test setup: DDL of the PostgreSQL
CREATE FOREIGN TABLE fdw_type_time (
  c time
) SERVER tsurugidb;

--- Test
PREPARE prep_insert AS
  INSERT INTO fdw_type_time VALUES (date '2025/01/01');
PREPARE prep_insert AS
  INSERT INTO fdw_type_time VALUES (time '2025/01/01');
PREPARE prep_insert AS
  INSERT INTO fdw_type_time VALUES (time '25:00:00');
PREPARE prep_insert AS
  INSERT INTO fdw_type_time VALUES (time 'invalid');

--- Test teardown: DDL of the PostgreSQL
DROP FOREIGN TABLE fdw_type_time;
--- Test teardown: DDL of the Tsurugi
SELECT tg_execute_ddl('DROP TABLE fdw_type_time', 'tsurugidb');

-- Date/Time Types - timestamp
--- Test setup: DDL of the Tsurugi
SELECT tg_execute_ddl('
  CREATE TABLE fdw_type_timestamp (c TIMESTAMP)
', 'tsurugidb');
--- Test setup: DDL of the PostgreSQL
CREATE FOREIGN TABLE fdw_type_timestamp (
  c timestamp
) SERVER tsurugidb;

--- Test
PREPARE prep_insert AS
  INSERT INTO fdw_type_timestamp VALUES (timestamp '01:02:03.456');
PREPARE prep_insert AS
  INSERT INTO fdw_type_timestamp VALUES (date '2021-02-30');
PREPARE prep_insert AS
  INSERT INTO fdw_type_timestamp
    VALUES (timestamp '2021-02-30 04:05:06.789');
PREPARE prep_insert AS
  INSERT INTO fdw_type_timestamp VALUES (timestamp '2025-01-01 25:00:00');
PREPARE prep_insert AS
  INSERT INTO fdw_type_timestamp VALUES (timestamp 'invalid');

SET DATESTYLE TO ISO, YMD;
PREPARE prep_insert (timestamp) AS
  INSERT INTO fdw_type_timestamp VALUES ($1);
EXECUTE prep_insert (timestamp '1/8/1999 01:02:03');
EXECUTE prep_insert (timestamp '1/18/1999 01:02:03');
EXECUTE prep_insert (timestamp '08-Jan-99 01:02:03');
EXECUTE prep_insert (timestamp 'Jan-08-99 01:02:03');
EXECUTE prep_insert (timestamp 'January 8, 99 BC 01:02:03');
DEALLOCATE prep_insert;
SET DATESTYLE TO 'default';

--- Test teardown: DDL of the PostgreSQL
DROP FOREIGN TABLE fdw_type_timestamp;
--- Test teardown: DDL of the Tsurugi
SELECT tg_execute_ddl('DROP TABLE fdw_type_timestamp', 'tsurugidb');

-- Date/Time Types - timestamp without time zone
--- Test setup: DDL of the Tsurugi
SELECT tg_execute_ddl('
  CREATE TABLE fdw_type_timestamp_wo_tz (c TIMESTAMP WITHOUT TIME ZONE)
', 'tsurugidb');
--- Test setup: DDL of the PostgreSQL
CREATE FOREIGN TABLE fdw_type_timestamp_wo_tz (
  c timestamp without time zone
) SERVER tsurugidb;

--- Test
PREPARE prep_insert AS
  INSERT INTO fdw_type_timestamp_wo_tz
    VALUES (timestamp without time zone '01:02:03.456');
PREPARE prep_insert AS
  INSERT INTO fdw_type_timestamp_wo_tz
    VALUES (date '2021-02-30');
PREPARE prep_insert AS
  INSERT INTO fdw_type_timestamp_wo_tz
    VALUES (timestamp without time zone '2021-02-30 04:05:06.789');
PREPARE prep_insert AS
  INSERT INTO fdw_type_timestamp_wo_tz
    VALUES (timestamp without time zone '2025-01-01 25:00:00');
PREPARE prep_insert AS
  INSERT INTO fdw_type_timestamp_wo_tz
    VALUES (timestamp without time zone 'invalid');

SET DATESTYLE TO ISO, YMD;
PREPARE prep_insert (timestamp without time zone) AS
  INSERT INTO fdw_type_timestamp_wo_tz VALUES ($1);
EXECUTE prep_insert (timestamp without time zone '1/8/1999 01:02:03');
EXECUTE prep_insert (timestamp without time zone '1/18/1999 01:02:03');
EXECUTE prep_insert (timestamp without time zone '08-Jan-99 01:02:03');
EXECUTE prep_insert (timestamp without time zone 'Jan-08-99 01:02:03');
EXECUTE prep_insert
  (timestamp without time zone 'January 8, 99 BC 01:02:03');
DEALLOCATE prep_insert;
SET DATESTYLE TO 'default';

--- Test teardown: DDL of the PostgreSQL
DROP FOREIGN TABLE fdw_type_timestamp_wo_tz;
--- Test teardown: DDL of the Tsurugi
SELECT tg_execute_ddl('DROP TABLE fdw_type_timestamp_wo_tz', 'tsurugidb');

-- Date/Time Types - timestamp with time zone
--- Test setup: DDL of the Tsurugi
SELECT tg_execute_ddl('
  CREATE TABLE fdw_type_timestamp_tz (c TIMESTAMP WITH TIME ZONE)
', 'tsurugidb');
--- Test setup: DDL of the PostgreSQL
CREATE FOREIGN TABLE fdw_type_timestamp_tz (
  c timestamp with time zone
) SERVER tsurugidb;

--- Test
PREPARE prep_insert AS
  INSERT INTO fdw_type_timestamp_tz
    VALUES (time with time zone '04:05:06.789+9:00');
PREPARE prep_insert AS
  INSERT INTO fdw_type_timestamp_tz
    VALUES (timestamp with time zone '2025-01-01 12:00-16:00');
PREPARE prep_insert AS
  INSERT INTO fdw_type_timestamp_tz
    VALUES (timestamp with time zone '2025-01-01 12:00+16:00');
PREPARE prep_insert AS
  INSERT INTO fdw_type_timestamp_tz
    VALUES (timestamp with time zone '2021-02-30 04:05:06.789+9:00');
PREPARE prep_insert AS
  INSERT INTO fdw_type_timestamp_tz
    VALUES (timestamp with time zone 'invalid+tz');

SET DATESTYLE TO ISO, YMD;
PREPARE prep_insert (timestamp with time zone) AS
  INSERT INTO fdw_type_timestamp_tz VALUES ($1);
EXECUTE prep_insert (timestamp with time zone '1/8/1999 01:02:03+0900');
EXECUTE prep_insert (timestamp with time zone '1/18/1999 01:02:03+0900');
EXECUTE prep_insert (timestamp with time zone '08-Jan-99 01:02:03+0900');
EXECUTE prep_insert (timestamp with time zone 'Jan-08-99 01:02:03+0900');
EXECUTE prep_insert
  (timestamp with time zone 'January 8, 99 BC 01:02:03+0900');
DEALLOCATE prep_insert;
SET DATESTYLE TO 'default';

--- Test teardown: DDL of the PostgreSQL
DROP FOREIGN TABLE fdw_type_timestamp_tz;
--- Test teardown: DDL of the Tsurugi
SELECT tg_execute_ddl('DROP TABLE fdw_type_timestamp_tz', 'tsurugidb');
