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
DATA = tsurugi_fdw--1.0.0.sql

# REGRESS_*: variable used in frontend
REGRESS_PRE   = test_preparation
REGRESS_BASIC = create_table_happy create_index_happy insert_select_happy update_delete_happy select_statement_happy \
                user_management_happy udf_transaction_happy prepare_statement_happy prepare_select_statement_happy \
                prepare_decimal_happy manual_tutorial import_foreign_schema_happy udf_tg_show_tables_happy udf_tg_verify_tables_happy
REGRESS_EXTRA = create_table_unhappy insert_select_unhappy prepare_decimal_unhappy udf_transaction_unhappy \
                update_delete_unhappy user_management_unhappy prepare_select_statement_unhappy create_table_restrict \
                import_foreign_schema_unhappy import_foreign_schema_extra \
                udf_tg_show_tables_unhappy udf_tg_show_tables_extra udf_tg_verify_tables_unhappy udf_tg_verify_tables_extra

# REGRESS: variable defined in PostgreSQL
REGRESS = $(REGRESS_PRE) $(REGRESS_BASIC)
ifdef REGRESS_ALL
	REGRESS += $(REGRESS_EXTRA)
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
