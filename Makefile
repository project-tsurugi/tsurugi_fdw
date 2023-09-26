# contrib/frontend/tsurugi_fdw/Makefile

MODULE_big = tsurugi_fdw
OBJS = common/init.o common/tsurugi.o \
        tsurugi_fdw/deparse.o tsurugi_fdw/shippable.o tsurugi_fdw/helper_funcs.o \
		tsurugi_fdw/tsurugi_utils.o tsurugi_fdw/tsurugi_fdw.o \
        tsurugi_planner/tsurugi_planner.o \
		tsurugi_utility/send_message.o \
        tsurugi_utility/tsurugi_utility.o tsurugi_utility/create_stmt.o tsurugi_utility/drop_stmt.o \
        tsurugi_utility/create_table/create_table_executor.o tsurugi_utility/create_table/create_table.o \
        tsurugi_utility/create_index/create_index_executor.o tsurugi_utility/create_index/create_index.o \
		tsurugi_utility/create_role/create_role.o \
        tsurugi_utility/drop_table/drop_table_executor.o tsurugi_utility/drop_index/drop_index_executor.o tsurugi_utility/drop_role/drop_role.o \
		tsurugi_utility/grant_revoke_role/grant_revoke_role.o \
		tsurugi_utility/grant_revoke_table/grant_revoke_table.o \
		tsurugi_utility/role_managercmds.o tsurugi_utility/table_managercmds.o tsurugi_utility/syscachecmds.o  \
        tsurugi_utility/alter_table/alter_table_executor.o tsurugi_utility/alter_table/alter_table.o \
		tsurugi_utility/alter_role/alter_role.o \
        alt_function/alt_function.o \
        $(WIN32RES)

EXTENSION = tsurugi_fdw
DATA = tsurugi_fdw--0.1.sql

# REGRESS_BASIC: variable used in frontend
#REGRESS_BASIC = test_create_table otable_of_constr ch-benchmark-ddl create_table_syntax_type update_delete insert_select
REGRESS_BASIC = test_preparation create_table insert_select_happy update_delete select_statements user_management
ifdef REGRESS_EXTRA
	# REGRESS: variable defined in PostgreSQL
	REGRESS = $(REGRESS_BASIC) otable_of_constr2
else
	# REGRESS: variable defined in PostgreSQL
	REGRESS = $(REGRESS_BASIC)
endif

PGFILEDESC = "tsurugi_fdw - foregin data wrapper for Tsurugi"

PG_CPPFLAGS = -Icommon/include \
			  -Itsurugi_utility/include \
              -Ithird_party/ogawayama/include \
              -Ithird_party/takatori/include \
              -Ithird_party/metadata-manager/include \
              -Ithird_party/message-manager/include \
              -std=c++17 -fPIC -Dregister= -O0\
              -I$(libpq_srcdir)
              
SHLIB_LINK_INTERNAL = $(libpq)

SHLIB_LINK = -logawayama-stub -lmetadata-manager -lmessage-manager -lboost_filesystem

ifdef USE_PGXS
        PG_CONFIG = pg_config
        PGXS := $(shell $(PG_CONFIG) --pgxs)
        include $(PGXS)
else
        subdir = contrib/frontend/tsurugi_fdw
        top_builddir = ../../
        include $(top_builddir)/src/Makefile.global
        include $(top_srcdir)/contrib/contrib-global.mk
endif

tests:
	bash test.sh
