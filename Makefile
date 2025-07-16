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
              -Ithird_party/ogawayama/third_party/metadata-manager/include \
              -Ithird_party/message-manager/include \
              -std=c++17 -Dregister= 

SHLIB_LINK_INTERNAL = $(libpq)
SHLIB_LINK = -logawayama-stub -lmetadata-manager -lmessage-manager -lboost_filesystem

EXTENSION = tsurugi_fdw
DATA = tsurugi_fdw--1.3.0.sql \
		tsurugi_fdw--1.0.0--1.1.0.sql

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
	REGRESS += 	create_table_happy create_index_happy \
				insert_select_happy update_delete_happy select_statement_happy \
			   	prepare_select_happy prepare_statement_happy prepare_decimal_happy \
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
	REGRESS += 	create_table_unhappy create_table_restrict \
				data_types_happy \
				insert_select_unhappy update_delete_unhappy\
				prepare_select_unhappy prepare_decimal_unhappy \
	           	udf_tg_show_tables_unhappy udf_tg_show_tables_extra udf_tg_verify_tables_unhappy udf_tg_verify_tables_extra \
            	udf_transaction_unhappy \
			   	import_foreign_schema_unhappy import_foreign_schema_extra 

	#REGRESS += dml_variation_happy_pg$(MAJORVERSION)
	ifeq ($(MAJORVERSION), 12)
#		REGRESS += dml_variation_happy_pg12
	else ifeq ($(MAJORVERSION), 13)
#		REGRESS += dml_variation_happy_pg13
	else ifeq ($(MAJORVERSION), 14)
#		REGRESS += dml_variation_happy_pg14
	endif
endif

install_deps:
	bash ./scripts/install_deps.sh $(libdir)

tests:
	bash ./scripts/test.sh