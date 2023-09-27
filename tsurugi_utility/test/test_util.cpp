#include <iostream>
#include <string>
#include <string_view>
#include <vector>

#include "create_table.h"

// extern int create_table(const char* query_string);

int main(void)
{
    std::vector<std::string> queries= {
        "CREATE TABLE sample1 (INTEGER_COLUMN INTEGER) TABLESPACE Tsurugi",
        "CREATE TABLE sample2 (COLUMN_INTEGER INTEGER NOT NULL PRIMARY KEY) TABLESPACE Tsurugi",
        "CREATE TABLE sample3 (column1 INTEGER, column2 INTEGER NOT NULL PRIMARY KEY) TABLESPACE Tsurugi",
        "CREATE TABLE sample4 (column1 integer, column2 Integer NOT NULL PRIMARY KEY) TABLESPACE Tsurugi",
        "CREATE TABLE sample5 (column1 real, column2 double precision NOT NULL PRIMARY KEY) TABLESPACE Tsurugi",
        "CREATE TABLE sample6 (column1 bigint NOT NULL PRIMARY KEY, column2 smallint NOT NULL) TABLESPACE Tsurugi",
        "CREATE TABLE sample7 (column1 BIGINT NOT NULL PRIMARY KEY, column2 double precision ) TABLESPACE Tsurugi",
    };

    std::cout << "Begin" << std::endl;
    for (auto query = queries.begin(); query != queries.end(); query++) {
        create_table((*query).c_str());
    }
    std::cout << "End" << std::endl;

    return 0;
}
