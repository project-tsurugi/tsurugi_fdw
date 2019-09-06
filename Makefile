MODULE_big = ogawayama_fdw
<<<<<<< HEAD
SRCS = ogawayama_fdw.cpp
=======
>>>>>>> origin/master
OBJS = ogawayama_fdw.o
EXTENSION = ogawayama_fdw
DATA = ogawayama_fdw--0.0.sql

<<<<<<< HEAD
PG_CPPFLAGS = -I../ogawayama/stub/include -std=c++17
SHLIB_LINK = libs/libogawayama-stub.so

ifdef NO_PGXS
	top_builddir = ../psotgresql-11.1
	subdir = ../frontend
	include $(top_builddir)/src/Makefile.global
	include $(top_srcdir)/../postgresql-11.1/contrib/contrib-global.mk
else
	PG_CONFIG = pg_config
	PGXS := $(shell $(PG_CONFIG) --pgxs)
	include $(PGXS)
=======
PG_CPPFLAGS = -I./ogawayama-wrapper/include

ifdef NO_PGXS
subdir = contrib/ogawayama_fdw
top_builddir = ../..
include $(top_builddir)/src/Makefile.global
include $(top_srcdir)/contrib/contrib-global.mk
else
PG_CONFIG = pg_config
PGXS := $(shell $(PG_CONFIG) --pgxs)
include $(PGXS)
>>>>>>> origin/master
endif
