# contrib/tsurugi_fdw/Makefile

MODULE_big = tsurugi_fdw
SRCDIR     = ./src
C_SRCS     = $(shell find $(SRCDIR) -name *.c)
CPP_SRCS   = $(shell find $(SRCDIR) -name *.cpp)
OBJS       = $(C_SRCS:.c=.o) $(CPP_SRCS:.cpp=.o)

PG_CPPFLAGS = -Iinclude -I$(libpq_srcdir) -I$(includedir) -fPIC -O0 -Werror
PG_CXXFLAGS = -Iinclude/proto \
              -Ithird_party/ogawayama/include \
              -Ithird_party/takatori/include \
              -std=c++17 -Dregister= 

override rpath = -Wl,-rpath,'$$ORIGIN'
SHLIB_LINK_INTERNAL = $(libpq)
SHLIB_LINK = -logawayama-stub -lboost_filesystem

EXTENSION = tsurugi_fdw
DATA = tsurugi_fdw--1.3.0.sql \
		tsurugi_fdw--1.0.0--1.1.0.sql \
		tsurugi_fdw--1.1.0--1.2.0.sql \
		tsurugi_fdw--1.2.0--1.3.0.sql

# REGRESS_BASIC: Run basic tests.
# REGRESS_EXTRA: Run extra tests.
ifndef REGRESS_BASIC
	ifndef REGRESS_EXTRA
		REGRESS_BASIC := 1
		REGRESS_EXTRA := 1
	endif
endif

# Test settings according to regression test type
REGRESS := test_preparation
ifdef REGRESS_BASIC
	REGRESS += ddl_happy \
	           dml_happy data_types_happy case_sensitive_happy \
	           prep_dml_happy prep_data_types_happy prep_case_sensitive_happy \
	           manual_tutorial \
	           udf_transaction_happy udf_tg_show_tables_happy udf_tg_verify_tables_happy \
	           import_foreign_schema_happy
endif

PGFILEDESC = "tsurugi_fdw - foreign data wrapper for Tsurugi"

ifdef USE_PGXS
	PG_CONFIG = pg_config
	PGXS := $(shell $(PG_CONFIG) --pgxs)
	include $(PGXS)
else
	subdir = contrib/tsurugi_fdw
	top_builddir = ../../
	include $(top_builddir)/src/Makefile.global
	include $(top_srcdir)/contrib/contrib-global.mk
endif

ifndef MAJORVERSION
	MAJORVERSION := $(basename $(VERSION))
endif

ifdef REGRESS_EXTRA
	REGRESS += ddl_unhappy \
	           dml_unhappy data_types_unhappy case_sensitive_unhappy \
	           prep_dml_unhappy prep_data_types_unhappy prep_case_sensitive_unhappy \
	           udf_tg_show_tables_unhappy udf_tg_show_tables_extra udf_tg_verify_tables_unhappy udf_tg_verify_tables_extra \
	           udf_transaction_unhappy \
	           import_foreign_schema_unhappy import_foreign_schema_extra

	ifeq ($(MAJORVERSION), 12)
		# PostgreSQL 12.x
		REGRESS += dml_unhappy_pg12 prep_dml_unhappy_pg12
	else ifeq ($(MAJORVERSION), 13)
		# PostgreSQL 13.x
		REGRESS += dml_unhappy_pg13 prep_dml_unhappy_pg13
	else ifeq ($(filter $(MAJORVERSION), 14 15), $(MAJORVERSION))
		# PostgreSQL 14.x to PostgreSQL 15.x
		REGRESS += dml_unhappy_pg14-15 prep_dml_unhappy_pg14-15
	else ifeq ($(filter $(MAJORVERSION), 16), $(MAJORVERSION))
		# PostgreSQL 16.x
		REGRESS += dml_unhappy_pg16 prep_dml_unhappy_pg16
	endif
endif

install_deps:
	bash ./scripts/install_deps.sh $(libdir)

tests:
	bash ./scripts/test.sh