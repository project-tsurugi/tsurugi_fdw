/*-------------------------------------------------------------------------
 *
 * dispatcher.h
 *		  Dispatch a query to DB engine.
 *
 * IDENTIFICATION
 *		  contrib/frontend/dispatcher.h
 *
 *-------------------------------------------------------------------------
 */
#ifndef DISPATCH_QUERY_H
#define DISPATCH_QUERY_H

#ifdef __cplusplus
extern "C" {
#endif

bool dispatch_query( char* str );

#ifdef __cplusplus
}
#endif

#endif // DISPATCH_QUERY_H
