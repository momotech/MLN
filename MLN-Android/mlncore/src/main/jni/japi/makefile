

CC      = gcc

CFLAGS		:= -Wall -O2 -DLUA_DL_DLOPEN -DLUA_USE_C89 -DLUA_COMPAT_5_1 -DLUA_COMPAT_ALL -DLUA_USE_LINUX \
				-DENV_64	\
				-DMEM_INFO \
				-DJAVA_ENV

SOURCE_ROOT = $(shell pwd)

INCLUDE_DIR := -I $(JAVA_HOME)/include -I $(JAVA_HOME)/include/darwin -I ${SOURCE_ROOT}/../lua -I ${SOURCE_ROOT}/../luasocket -I ${SOURCE_ROOT}

APP_NAME=libluajapi.so

all: $(APP_NAME)
APP_OBJECTC = m_utf.c \
              stack.c \
              list.c \
              map.c \
              statistics.c \
              statistics_require.c \
              m_mem.c \
              saes.c \
              utils.c \
              jlog.c \
              debug_info.c \
              jinfo.c \
              cache.c \
              jfunction.c \
              jbridge.c \
              jtable.c \
              juserdata.c \
              compiler.c \
              message_looper.c \
              isolate.c \
              argo/LuaRPC.c \
              argo/databindengine.c \
              argo/argo_lib.c \
              luajapi.c

STATIC_OBJ_O  = $(patsubst %.c, %.o, $(APP_OBJECTC))

STATIC_OBJ_C  = $(foreach file, $(STATIC_OBJ_O), $(file) )

$(STATIC_OBJ_C) : %.o:%.c
	$(CC)  $(INCLUDE_DIR) $(CFLAGS) -pie -fPIE -c $(APP_OBJECTC)

$(APP_NAME): $(STATIC_OBJ_C)
	$(CC) -shared -o $(APP_NAME) ./*.o -L ${SOURCE_ROOT}/../sys -llua -lmlsocket

clean:
	@rm -f *.o *.so
.PHONY: clean