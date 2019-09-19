
CC      = gcc
PP      = g++

CFLAGS		:= -Wall -O2 -DLUA_DL_DLOPEN -DLUA_USE_C89 -DLUA_COMPAT_5_1 -DLUA_COMPAT_ALL -DLUA_USE_LINUX \
				-DENV_64	\
				-DJ_API_INFO \
				-DMEM_INFO \
				-DJAVA_ENV

SOURCE_ROOT = $(shell pwd)

INCLUDE_DIR := -I ${JNI_H} -I ${JNI_MD} -I ${SOURCE_ROOT}/../lua -I ${SOURCE_ROOT}/../luasocket ${SOURCE_ROOT}

APP_NAME=libluajapi.so

all: $(APP_NAME)
APP_OBJECTC = 	stack.c \
                list.c \
				map.c \
				m_mem.c \
				saes.c \
				utils.c \
				jlog.c \
				debug_info.c \
				jinfo.c \
				cache.c \
				jbridge.c \
				jtable.c \
				juserdata.c \
				compiler.c \
				luajapi.c

STATIC_OBJ_O  = $(patsubst %.c, %.o, $(APP_OBJECTC))

STATIC_OBJ_C  = $(foreach file, $(STATIC_OBJ_O), $(file) )

$(STATIC_OBJ_C) : %.o:%.c 
	$(CC)  $(INCLUDE_DIR) $(CFLAGS) -pie -fPIE -c $(APP_OBJECTC)

$(APP_NAME): $(STATIC_OBJ_C)
	$(PP) -shared -o $(APP_NAME) ./*.o -L ${SOURCE_ROOT}/../sys -llua -lmlsocket

clean:
	@rm -f *.o *.so
.PHONY: clean	