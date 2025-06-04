# contrib/tsurugi_fdw/Makefile

MODULE_big = tsurugi_fdw
SRCDIR     = ./src
C_SRCS     = $(shell find $(SRCDIR) -name *.c)
CPP_SRCS   = $(shell find $(SRCDIR) -name *.cpp)
OBJS       = $(C_SRCS:.c=.o) $(CPP_SRCS:.cpp=.o)

PG_CPPFLAGS = -Iinclude -I$(libpq_srcdir) -fPIC -O0 -Werror 
PG_CXXFLAGS = -Iinclude/proto \
              -Ithird_party/ogawayama/include \
              -Ithird_party/takatori/include \
              -Ithird_party/ogawayama/third_party/metadata-manager/include \
              -Ithird_party/message-manager/include \
              -std=c++17 -Dregister= 

SHLIB_LINK_INTERNAL = $(libpq)
SHLIB_LINK = -logawayama-stub -lmetadata-manager -lmessage-manager -lboost_filesystem

EXTENSION = tsurugi_fdw
DATA = tsurugi_fdw--1.1.1.sql \
       tsurugi_fdw--1.0.0--1.1.1.sql

# REGRESS_BASIC: variable used in frontend
REGRESS_BASIC = test_preparation create_table create_index insert_select_happy update_delete select_statements user_management \
                udf_transaction prepare_statment prepare_select_statment prepare_decimal manual_tutorial create_table_restrict

ifdef REGRESS_EXTRA
	REGRESS += create_table_unhappy insert_select_unhappy prepare_decimal_unhappy udf_transaction_unhappy \
	           update_delete_unhappy user_management_unhappy prepare_select_statement_unhappy create_table_restrict \
	           	import_foreign_schema_unhappy import_foreign_schema_extra \
	           udf_tg_show_tables_unhappy udf_tg_show_tables_extra udf_tg_verify_tables_unhappy udf_tg_verify_tables_extra
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

install_dependencies:
	bash ./scripts/install_dependencies.sh $(libdir)

tests:
	bash ./scripts/test.sh
