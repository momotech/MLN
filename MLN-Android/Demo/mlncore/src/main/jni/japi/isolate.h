//
// Created by Xiong.Fangyu 2019/06/17.
//

#ifndef ISOLATE_H
#define ISOLATE_H
#if defined(iOS_ENV)
#include "mil_lua.h"
#else
#include "lua.h"
#endif
#include <stdlib.h>

#define ISOLATE_LIB_NAME "isolate"

int isolate_open (lua_State *L);

int luaopen_isolate(lua_State *L);
#endif  //ISOLATE_H
