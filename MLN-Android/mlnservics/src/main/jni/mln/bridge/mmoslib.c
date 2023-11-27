/**
  * Created by MomoLuaNative.
  * Copyright (c) 2019, Momo Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */
//
// Created by XiongFangyu on 2019-08-14.
//

#include "mmoslib.h"

#ifdef JAVA_ENV
#include "lauxlib.h"
#include <time.h>
#else
#include "mil_lauxlib.h"
#include <sys/time.h>
#endif

#define LUA_MMOSLIBNAME "mmos"

static int mm_time(lua_State *L) {
    struct timeval t = {0};
    gettimeofday(&t, NULL);
    lua_pushnumber(L, (lua_Number) (t.tv_sec + t.tv_usec / 1000000.0));
    return 1;
}

static int mm_microsecond(lua_State *L) {
    struct timeval t = {0};
    gettimeofday(&t, NULL);
    lua_pushinteger(L, (lua_Integer) (t.tv_sec * 1000000 + t.tv_usec));
    return 1;
}

static const luaL_Reg funcs[] = {
        {"time",        mm_time},
        {"microsecond", mm_microsecond},
        {NULL,          NULL}
};

LUALIB_API int luaopen_mmos (lua_State *L) {
    luaL_register(L, LUA_MMOSLIBNAME, funcs);
    lua_pop(L, 1);
    return 1;
}