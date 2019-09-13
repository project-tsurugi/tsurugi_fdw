MODULE_big = ogawayama_fdw
EXTENSION = ogawayama_fdw
OBJS = ogawayama_fdw.o
DATA = ogawayama_fdw--0.1.sql

PG_CPPFLAGS = -Ithird_party/ogawayama/stub/include -std=c++17

ifdef NO_PGXS
	subdir = contrib/frontend/ogawayama_fdw
	top_builddir = ../../..
	include $(top_builddir)/src/Makefile.global
	include $(top_srcdir)/contrib/contrib-global.mk
else
	PG_CONFIG = pg_config
	PGXS := $(shell $(PG_CONFIG) --pgxs)
	include $(PGXS)
endif
