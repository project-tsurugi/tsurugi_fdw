# contrib/tsurugi_fdw/Makefile

MODULE_big 	= tsurugi_fdw
SRCDIR 		= ./src
C_SRCS 		= $(shell find $(SRCDIR) -name *.c)
CPP_SRCS	= $(shell find $(SRCDIR) -name *.cpp)
OBJS 		= $(C_SRCS:.c=.o) $(CPP_SRCS:.cpp=.o)
DATA 		= tsurugi_fdw--0.1.sql

PG_CPPFLAGS = -Isrc/common/include \
              -Isrc/tsurugi_utility/include \
              -Ithird_party/ogawayama/include \
              -Ithird_party/takatori/include \
              -Ithird_party/metadata-manager/include \
              -Ithird_party/message-manager/include \
              -std=c++17 -fPIC -Dregister= -O0 \
              -I$(libpq_srcdir)

SHLIB_LINK_INTERNAL = $(libpq)
SHLIB_LINK = -logawayama-stub -lmetadata-manager -lmessage-manager -lboost_filesystem

EXTENSION = tsurugi_fdw
DATA = tsurugi_fdw--1.0.0.sql

# REGRESS_BASIC: variable used in frontend
#REGRESS_BASIC = test_create_table otable_of_constr ch-benchmark-ddl create_table_syntax_type update_delete insert_select
REGRESS_BASIC = test_preparation create_table create_index insert_select_happy update_delete select_statements user_management \
                udf_transaction prepare_statment prepare_select_statment
ifdef REGRESS_EXTRA
	# REGRESS: variable defined in PostgreSQL
	#REGRESS = $(REGRESS_BASIC) otable_of_constr2
	REGRESS = $(REGRESS_BASIC) manual_tutorial
else
	# REGRESS: variable defined in PostgreSQL
	REGRESS = $(REGRESS_BASIC)
endif

PGFILEDESC = "tsurugi_fdw - foregin data wrapper for Tsurugi"           

ifdef USE_PGXS
        PG_CONFIG = pg_config
        PGXS := $(shell $(PG_CONFIG) --pgxs)
        include $(PGXS)
else
        subdir = contrib/frontend/tsurugi_fdw
        top_builddir = ../../
        include $(top_builddir)/src/Makefile.global
        include $(top_srcdir)/contrib/contrib-global.mk
endif

tests:
	bash test.sh
