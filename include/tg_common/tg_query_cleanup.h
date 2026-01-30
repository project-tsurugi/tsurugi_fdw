/* tg_query_cleanup.h */
#ifndef TG_QUERY_CLEANUP_H
#define TG_QUERY_CLEANUP_H

#include "postgres.h"
#include "utils/memutils.h"

#include "tg_common/tsurugi_api.h"

typedef struct TgQueryCleanup
{
	MemoryContextCallback callback;
	TGstmt	   *stmt;
	TGresult   *result;
	bool		cleaned;
} TgQueryCleanup;

TgQueryCleanup *tg_query_cleanup_create(MemoryContext mcxt);
void tg_query_cleanup_set_stmt(TgQueryCleanup *qc, TGstmt *stmt);
void tg_query_cleanup_set_result(TgQueryCleanup *qc, TGresult *result);
void tg_query_cleanup_cleanup(TgQueryCleanup *qc);

#endif  /* TG_QUERY_CLEANUP_H */
