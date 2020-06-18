#ifndef TABLECMDS_
#define TABLECMDS_

#ifdef __cplusplus
extern "C" {
#endif
bool define_relation(CreateStmt *stmt);
bool is_type_supported(CreateStmt *stmt);
bool is_syntax_supported(CreateStmt *stmt);
bool store_metadata(CreateStmt *stmt);
#ifdef __cplusplus
}
#endif

#endif // TABLECMDS_
