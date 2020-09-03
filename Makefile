# contrib/frontend/ogawayama_fdw/Makefile

MODULE_big = ogawayama_fdw
OBJS = common/init.o common/stub_manager.o \
        ogawayama_fdw/ogawayama_fdw.o \
        alt_planner/alt_planner.o \
        alt_utility/tablecmds.o alt_utility/create_table.o alt_utility/alt_utility.o \
        $(WIN32RES)

EXTENSION = ogawayama_fdw
DATA = ogawayama_fdw--0.1.sql

REGRESS = test_create_table otable_of_constr ch-benchmark-ddl alternative unhappy happy

PGFILEDESC = "ogawayama_fdw - foregin data wrapper for ogawayama-server"

PG_CPPFLAGS = -Iinclude \
              -Ithird_party/ogawayama/stub/include \
              -Ithird_party/manager/metadata-manager/include \
              -Ithird_party/manager/message-broker/include \
              -std=c++17 -fPIC -Dregister= -O0

SHLIB_LINK = -logawayama-stub -lmanager-metadata -lmanager-message -lboost_filesystem

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
