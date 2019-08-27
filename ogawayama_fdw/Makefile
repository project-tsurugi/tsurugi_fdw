MODULE_big = ogawayama_fdw
OBJS = ogawayama_fdw.o
EXTENSION = ogawayama_fdw
DATA = ogawayama_fdw--0.0.sql

ifdef NO_PGXS
subdir = contrib/ogawayama_fdw
top_builddir = ../..
include $(top_builddir)/src/Makefile.global
include $(top_srcdir)/contrib/contrib-global.mk
else
PG_CONFIG = pg_config
PGXS := $(shell $(PG_CONFIG) --pgxs)
include $(PGXS)
endif
