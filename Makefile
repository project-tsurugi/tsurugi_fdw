# contrib/frontend/ogawayama_fdw/Makefile

MODULE_big = ogawayama_fdw
OBJS = common/init.o common/stub_manager.o \
        ogawayama_fdw/ogawayama_fdw.o ogawayama_fdw/deparse.o ogawayama_fdw/shippable.o \
        alt_planner/alt_planner.o \
				alt_utility/send_message.o \
        alt_utility/alt_utility.o alt_utility/create_stmt.o alt_utility/drop_stmt.o \
        alt_utility/create_table/create_table_executor.o alt_utility/create_table/create_table.o \
        alt_utility/create_index/create_index_executor.o alt_utility/create_index/create_index.o \
        alt_utility/drop_table/drop_table_executor.o \
        alt_utility/alter_table/alter_table_executor.o alt_utility/alter_table/alter_table.o \
        $(WIN32RES)

EXTENSION = ogawayama_fdw
DATA = ogawayama_fdw--0.1.sql

# REGRESS_BASIC: variable used in frontend
REGRESS_BASIC = test_create_table otable_of_constr ch-benchmark-ddl create_table_syntax_type update_delete insert_select
ifdef REGRESS_EXTRA
	# REGRESS: variable defined in PostgreSQL
	REGRESS = $(REGRESS_BASIC) otable_of_constr2
else
	# REGRESS: variable defined in PostgreSQL
	REGRESS = $(REGRESS_BASIC)
endif

PGFILEDESC = "ogawayama_fdw - foregin data wrapper for ogawayama-server"

PG_CPPFLAGS = -Icommon/include \
			  -Ialt_utility/include \
              -Ithird_party/ogawayama/stub/include \
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
        subdir = contrib/frontend/ogawayama_fdw
        top_builddir = ../../
        include $(top_builddir)/src/Makefile.global
        include $(top_srcdir)/contrib/contrib-global.mk
endif

tests:
	bash test.sh
