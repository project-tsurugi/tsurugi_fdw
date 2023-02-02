#ifndef TSURUGI_UTILS_H
#define TSURUGI_UTILS_H

#include <string>
#include <string_view>
#include "ogawayama/stub/api.h"

#ifdef __cplusplus
extern "C" {
#endif
#include "postgres.h"
#ifdef __cplusplus
}
#endif

std::string make_tsurugi_query(std::string_view query_string);
Datum tsurugi_convert_to_pg(Oid pgtype, ResultSetPtr result_set);

#endif  //TSURUGI_UTILS_H
