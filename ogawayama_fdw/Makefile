# contrib/frontend/ogawayama_fdw/Makefile

MODULE_big = ogawayama_fdw
OBJS = ogawayama_fdw.o $(WIN32RES)
PGFILEDESC = "ogawayama_fdw - foregin data wrapper for Ogawayama"

PG_CPPFLAGS = -Ithird_party/ogawayama/stub/include -std=c++17 -pthread
SHLIB_LINK = -Lthird_party/ogawayama/build/stub/src -logawayama-stub -lrt -lpthread

EXTENSION = ogawayama_fdw
DATA = ogawayama_fdw--0.1.sql

ifdef USE_PGXS
        PG_CONFIG = pg_config
        PGXS := $(shell $(PG_CONFIG) --pgxs)
        include $(PGXS)
else
        subdir = contrib/frontend/ogawayama_fdw
        top_builddir = ../../..
        include $(top_builddir)/src/Makefile.global
        include $(top_srcdir)/contrib/contrib-global.mk
endif
