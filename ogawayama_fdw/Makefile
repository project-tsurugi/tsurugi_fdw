MODULE_big = ogawayama_fdw
EXTENSION = ogawayama_fdw
OBJS = ogawayama_fdw.o
DATA = ogawayama_fdw--0.0.sql

PG_CPPFLAGS = -I../ogawayama/stub/include -std=c++17 
SHLIB_LINK = -Llib/ -logawayama-stub-stub

ifdef NO_PGXS
	subdir = ../git/frontend
	top_builddir = ../../postgresql-11.1
	include $(top_builddir)/src/Makefile.global
	include $(top_srcdir)/../../postgresql-11.1/contrib/contrib-global.mk
else
	PG_CONFIG = pg_config
	PGXS := $(shell $(PG_CONFIG) --pgxs)
	include $(PGXS)
endif
