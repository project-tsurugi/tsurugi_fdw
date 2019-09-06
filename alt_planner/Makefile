MODULES = alt_planner
<<<<<<< HEAD
PGFILEDESC = "alt_planner (V0)"
=======
PGFILEDESC = "alt_planner"
>>>>>>> origin/master
OBJS = alt_planner.o $(WIN32RES)

ifdef USE_PGXS
PG_CONFIG = pg_config
PGXS := $(shell $(PG_CONFIG) --pgxs)
include $(PGXS)
else
<<<<<<< HEAD
subdir = contrib/yanagisawa
=======
subdir = contrib/alt_planner
>>>>>>> origin/master
top_builddir = ../..
include $(top_builddir)/src/Makefile.global
include $(top_srcdir)/contrib/contrib-global.mk
endif