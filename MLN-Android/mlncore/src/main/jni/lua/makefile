

CC      = gcc
AR      = ar

CFLAGS		:= -Wall -O2 -DLUA_DL_DLOPEN -DLUA_USE_C89 -DLUA_COMPAT_5_1 -DLUA_COMPAT_ALL -DLUA_USE_LINUX -DJAVA_ENV

INCLUDE_DIR := -I $(JAVA_HOME)/include -I $(JAVA_HOME)/include/darwin

APP_NAME=liblua.a

all: $(APP_NAME)
APP_OBJECTC = lapi.c lauxlib.c lbaselib.c lbitlib.c lcode.c lcorolib.c lctype.c ldblib.c ldebug.c ldo.c ldump.c lfunc.c lgc.c linit.c liolib.c llex.c lmathlib.c lmem.c loadlib.c lobject.c lopcodes.c loslib.c lparser.c lstate.c lstring.c lstrlib.c ltable.c ltablib.c ltm.c lundump.c lvm.c lzio.c

STATIC_OBJ_O  = $(patsubst %.c, %.o, $(APP_OBJECTC))

STATIC_OBJ_C  = $(foreach file, $(STATIC_OBJ_O), $(file) )

$(STATIC_OBJ_C) : %.o:%.c
	$(CC)  $(INCLUDE_DIR) $(CFLAGS) -c -pie -fPIE $(APP_OBJECTC)

$(APP_NAME): $(STATIC_OBJ_C)
	$(AR) -r $(APP_NAME) ./*.o

clean:
	@rm -f *.o *.a
.PHONY: clean