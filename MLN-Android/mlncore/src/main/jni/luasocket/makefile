

CC      = gcc
AR      = ar

CFLAGS		:= -Wall -O2 -DLUA_COMPAT_ALL -DLUA_DL_DLOPEN -DLUA_USE_C89 -DLUA_COMPAT_5_1 -DLUA_COMPAT_5_2 -DLUA_USE_LINUX -DJAVA_ENV

SOURCE_ROOT = $(shell pwd)

INCLUDE_DIR := -I $(JAVA_HOME)/include -I $(JAVA_HOME)/include/darwin -I ${SOURCE_ROOT}/../lua -I ${SOURCE_ROOT}/../japi

APP_NAME=libmlsocket.a

all: $(APP_NAME)
APP_OBJECTC = luasocket.c \
					buffer.c \
					auxiliar.c \
					options.c \
					timeout.c \
					io.c \
					usocket.c \
					compat.c \
					except.c \
					inet.c \
					mime.c \
					select.c \
					serial.c \
					tcp.c \
					udp.c

STATIC_OBJ_O  = $(patsubst %.c, %.o, $(APP_OBJECTC))

STATIC_OBJ_C  = $(foreach file, $(STATIC_OBJ_O), $(file) )

$(STATIC_OBJ_C) : %.o:%.c 
	$(CC)  $(INCLUDE_DIR) $(CFLAGS) -c -pie -fPIE $(APP_OBJECTC)

$(APP_NAME): $(STATIC_OBJ_C)	
	$(AR) -r $(APP_NAME) ./*.o

clean:
	@rm -f *.o *.a
.PHONY: clean