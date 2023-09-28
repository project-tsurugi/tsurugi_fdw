MODULES = tsurugi_planner
PGFILEDESC = "tsurugi_planner"
OBJS = tsurugi_planner.o $(WIN32RES)

ifdef USE_PGXS
	PG_CONFIG = pg_config
	PGXS := $(shell $(PG_CONFIG) --pgxs)
	include $(PGXS)
else
	subdir = contrib/frontend/tsurugi_planner
	top_builddir = ../../..
	include $(top_builddir)/src/Makefile.global
	include $(top_srcdir)/contrib/contrib-global.mk
endif