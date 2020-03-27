# contrib/frontend/ogawayama_fdw/Makefile

MODULE_big = ogawayama_fdw
OBJS = common/stub_connector.o ogawayama_fdw/ogawayama_fdw.o alt_utility/create_table.o  alt_utility/alt_utility.o $(WIN32RES)
PGFILEDESC = "ogawayama_fdw - foregin data wrapper for Ogawayama"

PG_CPPFLAGS = -Iinclude \
              -Ithird_party/ogawayama/stub/include \
              -Ithird_party/manager/metadata-manager/include \
	      -std=c++17 -fPIC -Dregister= -O0

SHLIB_LINK = -Lthird_party/ogawayama/build/stub/src -logawayama-stub \
             -Lthird_party/manager/metadata-manager/build/output -lmetadata

EXTENSION = ogawayama_fdw
DATA = ogawayama_fdw--0.1.sql

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
