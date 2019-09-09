MODULES = alt_planner
PGFILEDESC = "alt_planner"
OBJS = alt_planner.o $(WIN32RES)

ifdef USE_PGXS
	PG_CONFIG = pg_config
	PGXS := $(shell $(PG_CONFIG) --pgxs)
	include $(PGXS)
else
	subdir = ../frontend/alt_planner
	top_builddir = ../../../postgresql-11.1
	include $(top_builddir)/src/Makefile.global
	include $(top_srcdir)/contrib/contrib-global.mk
endif