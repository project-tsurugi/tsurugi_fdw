# contrib/frontend/alt_utility/Makefile

MODULE_big = alt_utility
OBJS = create_table.o alt_utility.o
PGFILEDESC = "alt_utility"

PG_CFLAGS = a

PG_CPPFLAGS = -I../third_party/ogawayama/stub/include \
			  -I../third_party/manager/metadata-manager/include \
			  -std=c++17 -fPIC -Dregister= -O0

PG_CXXFLAGS = abc -std=c++17 -fPIC -Dregister=

PG_LDFLAGS = -aaa L../third_party/ogawayama/build/stub/src -logawayama-stub \
			 -L../third_party/manager/metadata-manager/build/output -lmetadata \

SHLIB_LINK = -L../third_party/ogawayama/build/stub/src -logawayama-stub \
			 -L../third_party/manager/metadata-manager/build/output -lmetadata \

# EXTENSION = alt_utility
# DATA = alt_utility--0.1.sql

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
