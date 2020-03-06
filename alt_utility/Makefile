MODULES = create_table
PGFILEDESC = "alt_utility"
OBJS =  create_table.o

PG_CPPFLAGS = -I../third_party/ogawayama/stub/include -std=c++17 -Dregister=
SHLIB_LINK = -L../third_party/ogawayama/build/stub/src -L../../../../../lib -logawayama-stub

ifdef USE_PGXS
	PG_CONFIG = pg_config
	PGXS := $(shell $(PG_CONFIG) --pgxs)
	include $(PGXS)
else
	subdir = contrib/frontend/alt_utility
	top_builddir = ../../..
	include $(top_builddir)/src/Makefile.global
	include $(top_srcdir)/contrib/contrib-global.mk
endif
