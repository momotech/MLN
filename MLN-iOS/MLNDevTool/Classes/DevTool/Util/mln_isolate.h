//
// Created by Xiong.Fangyu 2019/06/17.
//

#ifndef ISOLATE_H
#define ISOLATE_H

#ifdef __APPLE__
#ifndef iOS_ENV
#define iOS_ENV 1
#endif
#endif

#if defined(iOS_ENV)
#include "mln_lua.h"
#else
#include "lua.h"
#endif
#include <stdlib.h>

#define ISOLATE_LIB_NAME "isolate"

int isolate_open (lua_State *L);

int luaopen_isolate(lua_State *L);

void* mln_thread_sync_to_main(lua_State *L, void*(*callback)(void *));

#endif  //ISOLATE_H
