/* Test case: unhappy path - Unsupported data types - PostgreSQL 18 */

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
INSERT INTO fdw_type_date VALUES (date '01:02:03.456');
INSERT INTO fdw_type_date VALUES (time '01:02:03.456');
INSERT INTO fdw_type_date VALUES (date '2021-02-30');
INSERT INTO fdw_type_date VALUES (date 'invalid');

SET DATESTYLE TO ISO, YMD;
INSERT INTO fdw_type_date VALUES (date '1/8/1999');
INSERT INTO fdw_type_date VALUES (date '1/18/1999');
INSERT INTO fdw_type_date VALUES (date '08-Jan-99');
INSERT INTO fdw_type_date VALUES (date 'Jan-08-99');
INSERT INTO fdw_type_date VALUES (date 'January 8, 99 BC');
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
INSERT INTO fdw_type_time VALUES (date '2025/01/01');
INSERT INTO fdw_type_time VALUES (time '2025/01/01');
INSERT INTO fdw_type_time VALUES (time '25:00:00');
INSERT INTO fdw_type_time VALUES (time '050607.890123456');
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
INSERT INTO fdw_type_timestamp VALUES (timestamp '01:02:03.456');
INSERT INTO fdw_type_timestamp VALUES (date '2021-02-30');
INSERT INTO fdw_type_timestamp VALUES (timestamp '2021-02-30 04:05:06.789');
INSERT INTO fdw_type_timestamp VALUES (timestamp '2025-01-01 25:00:00');
INSERT INTO fdw_type_timestamp VALUES (timestamp '2025/01/01');
INSERT INTO fdw_type_timestamp VALUES (timestamp '2025/01/01 12:00');
INSERT INTO fdw_type_timestamp VALUES (timestamp 'invalid');

SET DATESTYLE TO ISO, YMD;
INSERT INTO fdw_type_timestamp VALUES (timestamp '1/8/1999 01:02:03');
INSERT INTO fdw_type_timestamp VALUES (timestamp '1/18/1999 01:02:03');
INSERT INTO fdw_type_timestamp VALUES (timestamp '08-Jan-99 01:02:03');
INSERT INTO fdw_type_timestamp VALUES (timestamp 'Jan-08-99 01:02:03');
INSERT INTO fdw_type_timestamp VALUES (timestamp 'January 8, 99 BC 01:02:03');
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
INSERT INTO fdw_type_timestamp_wo_tz
  VALUES (timestamp without time zone '01:02:03.456');
INSERT INTO fdw_type_timestamp_wo_tz
  VALUES (date '2021-02-30');
INSERT INTO fdw_type_timestamp_wo_tz
  VALUES (timestamp without time zone '2021-02-30 04:05:06.789');
INSERT INTO fdw_type_timestamp_wo_tz
  VALUES (timestamp without time zone '2025-01-01 25:00:00');
INSERT INTO fdw_type_timestamp_wo_tz
  VALUES (timestamp without time zone '2025/01/01');
INSERT INTO fdw_type_timestamp_wo_tz
  VALUES (timestamp without time zone '2025/01/01 12:00');
INSERT INTO fdw_type_timestamp_wo_tz
  VALUES (timestamp without time zone 'invalid');

SET DATESTYLE TO ISO, YMD;
INSERT INTO fdw_type_timestamp_wo_tz
  VALUES (timestamp without time zone '1/8/1999 01:02:03');
INSERT INTO fdw_type_timestamp_wo_tz
  VALUES (timestamp without time zone '1/18/1999 01:02:03');
INSERT INTO fdw_type_timestamp_wo_tz
  VALUES (timestamp without time zone '08-Jan-99 01:02:03');
INSERT INTO fdw_type_timestamp_wo_tz
  VALUES (timestamp without time zone 'Jan-08-99 01:02:03');
INSERT INTO fdw_type_timestamp_wo_tz
  VALUES (timestamp without time zone 'January 8, 99 BC 01:02:03');
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
INSERT INTO fdw_type_timestamp_tz
  VALUES (time with time zone '04:05:06.789+9:00');
INSERT INTO fdw_type_timestamp_tz
  VALUES (timestamp with time zone '2025-01-01 12:00-16:00');
INSERT INTO fdw_type_timestamp_tz
  VALUES (timestamp with time zone '2025-01-01 12:00+16:00');
INSERT INTO fdw_type_timestamp_tz
  VALUES (timestamp with time zone '2021-02-30 04:05:06.789+9:00');
INSERT INTO fdw_type_timestamp_tz
  VALUES (timestamp with time zone 'invalid+tz');

SET DATESTYLE TO ISO, YMD;
INSERT INTO fdw_type_timestamp_tz
  VALUES (timestamp with time zone '1/8/1999 01:02:03+0900');
INSERT INTO fdw_type_timestamp_tz
  VALUES (timestamp with time zone '1/18/1999 01:02:03+0900');
INSERT INTO fdw_type_timestamp_tz
  VALUES (timestamp with time zone '08-Jan-99 01:02:03+0900');
INSERT INTO fdw_type_timestamp_tz
  VALUES (timestamp with time zone 'Jan-08-99 01:02:03+0900');
INSERT INTO fdw_type_timestamp_tz
  VALUES (timestamp with time zone 'January 8, 99 BC 01:02:03+0900');
INSERT INTO fdw_type_timestamp_tz
  VALUES (timestamp with time zone '2025-01-01 12:01:02.34567 UTC');
INSERT INTO fdw_type_timestamp_tz
  VALUES (timestamp with time zone '2025-01-01 12:01:02.34567 Universal');
INSERT INTO fdw_type_timestamp_tz
  VALUES (timestamp with time zone '2025-01-01 12:00');
SET DATESTYLE TO 'default';

--- Test teardown: DDL of the PostgreSQL
DROP FOREIGN TABLE fdw_type_timestamp_tz;
--- Test teardown: DDL of the Tsurugi
SELECT tg_execute_ddl('DROP TABLE fdw_type_timestamp_tz', 'tsurugidb');
