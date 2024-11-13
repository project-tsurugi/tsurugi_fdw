/* SET DATASTYLE */
SET datestyle TO ISO, ymd;

/* Basic Action */
PREPARE trg_insnum  (integer, numeric) AS INSERT INTO trg_numeric (id, num) VALUES ($1, $2);
PREPARE trg_updnum1 (integer, numeric) AS UPDATE trg_numeric SET num = $2 WHERE id = $1;
PREPARE trg_updnum2 (integer, numeric) AS UPDATE trg_numeric SET id = $1 WHERE num = $2;
PREPARE trg_delnum1 (integer)          AS DELETE FROM trg_numeric WHERE id = $1;
PREPARE trg_delnum2 (numeric)          AS DELETE FROM trg_numeric WHERE num = $1;
PREPARE trg_selnum1 (integer)          AS SELECT * FROM trg_numeric WHERE id = $1;
PREPARE trg_selnum2 (numeric)          AS SELECT * FROM trg_numeric WHERE num = $1;

EXECUTE trg_insnum (1, 3.14);
EXECUTE trg_insnum (2, -3.14);

SELECT * FROM trg_numeric;

EXECUTE trg_updnum1 (1, 3.141592);
EXECUTE trg_updnum2 (2222, -3.14);

SELECT * FROM trg_numeric;

EXECUTE trg_selnum1 (2222);
EXECUTE trg_selnum2 (3.141592);

EXECUTE trg_delnum1 (1);
EXECUTE trg_delnum2 (-3.14);

SELECT * FROM trg_numeric;

/* Mathematical Functions */
-- Retutn numeric types
EXECUTE trg_insnum ( 1, abs(-17.4));
EXECUTE trg_insnum ( 2, ceil(-42.8));
EXECUTE trg_insnum ( 3, ceiling(-95.3));
EXECUTE trg_insnum ( 4, div(9,4));
EXECUTE trg_insnum ( 5, CAST(exp(1.0) AS DECIMAL(10,6)));
EXECUTE trg_insnum ( 6, factorial(5));
EXECUTE trg_insnum ( 7, floor(-42.8));
EXECUTE trg_insnum ( 8, CAST(ln(2.0) AS DECIMAL(10,6)));
EXECUTE trg_insnum ( 9, log(100.0));
EXECUTE trg_insnum (10, log10(100.0));
EXECUTE trg_insnum (11, log(2.0, 64.0));
EXECUTE trg_insnum (12, mod(9,4));
EXECUTE trg_insnum (13, power(9.0, 3.0));
EXECUTE trg_insnum (14, round(42.4));
EXECUTE trg_insnum (15, round(42.4382, 2));
EXECUTE trg_insnum (16, sign(-8.4));
EXECUTE trg_insnum (17, CAST(sqrt(2.0) AS DECIMAL(10,6)));
EXECUTE trg_insnum (18, trunc(42.8));
EXECUTE trg_insnum (19, trunc(42.4382, 2));
-- Retutn double precision or integer types
EXECUTE trg_insnum (20, CAST(cbrt(27.0) AS DECIMAL(10,6)));
EXECUTE trg_insnum (21, CAST(degrees(0.5) AS DECIMAL(10,6)));
EXECUTE trg_insnum (22, CAST(pi() AS DECIMAL(10,6)));
EXECUTE trg_insnum (23, CAST(radians(45.0) AS DECIMAL(10,6)));
EXECUTE trg_insnum (24, CAST(scale(8.41) AS DECIMAL(10,6)));
EXECUTE trg_insnum (25, CAST(width_bucket(5.35, 0.024, 10.06, 5) AS DECIMAL(10,6)));

SELECT * FROM trg_numeric;

/* value check */
PREPARE trg_insval_s0 (integer, numeric) AS INSERT INTO trg_numeric_s0 (id, num) VALUES ($1, $2);
PREPARE trg_insval_s38 (integer, numeric) AS INSERT INTO trg_numeric_s38 (id, num) VALUES ($1, $2);

-- correct value
EXECUTE trg_insval_s0 ( 1, 0);
EXECUTE trg_insval_s0 ( 2, 1);
EXECUTE trg_insval_s0 ( 3, 18446744073709551615);
EXECUTE trg_insval_s0 ( 4, 18446744073709551616);
EXECUTE trg_insval_s0 ( 5, 99999999999999999999999999999999999999);
EXECUTE trg_insval_s0 ( 6, -1);
EXECUTE trg_insval_s0 ( 7, -18446744073709551615);
EXECUTE trg_insval_s0 ( 8, -18446744073709551616);
EXECUTE trg_insval_s0 ( 9, -99999999999999999999999999999999999999);
-- incorrect value
EXECUTE trg_insval_s0 (99, 100000000000000000000000000000000000000);
EXECUTE trg_insval_s0 (98, 340282366920938463463374607431768211455);
EXECUTE trg_insval_s0 (97, 340282366920938463463374607431768211456);

SELECT * FROM trg_numeric_s0;

-- correct value
EXECUTE trg_insval_s38 ( 1, 0);  -- see tsurugi-issues#736
EXECUTE trg_insval_s38 ( 2, 0.00000000000000000000000000000000000001);
EXECUTE trg_insval_s38 ( 3, 0.00000000000000000018446744073709551615);
EXECUTE trg_insval_s38 ( 4, 0.00000000000000000018446744073709551616);
EXECUTE trg_insval_s38 ( 5, 0.99999999999999999999999999999999999999);
EXECUTE trg_insval_s38 ( 6, -0.00000000000000000000000000000000000001);
EXECUTE trg_insval_s38 ( 7, -0.00000000000000000018446744073709551615);
EXECUTE trg_insval_s38 ( 8, -0.00000000000000000018446744073709551616);
EXECUTE trg_insval_s38 ( 9, -0.99999999999999999999999999999999999999);
-- incorrect value
EXECUTE trg_insval_s38 (99, 1);
EXECUTE trg_insval_s38 (98, 0.000000000000000000000000000000000000001);
EXECUTE trg_insval_s38 (97, 0.340282366920938463463374607431768211455);
EXECUTE trg_insval_s38 (96, 0.340282366920938463463374607431768211456);

SELECT * FROM trg_numeric_s38;
