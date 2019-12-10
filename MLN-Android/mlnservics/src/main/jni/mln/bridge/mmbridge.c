/**
  * Created by MomoLuaNative.
  * Copyright (c) 2019, Momo Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */
//
// Created by XiongFangyu on 2019-07-04.
//

#include <jni.h>
#include "mmbridge.h"
#include "lauxlib.h"
#include "mmoslib.h"

#define MM_BIT "MBit"

/**
 * mmbit.c
 */
extern int mm_open_bit(lua_State *L);

static const luaL_Reg loadedlibs[] = {
        {MM_BIT, mm_open_bit},
        {NULL, NULL}
};

static const luaL_Reg preloadedlibs[] = {
        {NULL, NULL}
};

void mm_openlibs(lua_State *L) {
    const luaL_Reg *lib;
    /* call open functions from 'loadedlibs' and set results to global table */
    for (lib = loadedlibs; lib->func; lib++) {
        luaL_requiref(L, lib->name, lib->func, 1);
        lua_pop(L, 1);  /* remove lib */
    }
    /* add open functions from 'preloadedlibs' into 'package.preload' table */
    luaL_getsubtable(L, LUA_REGISTRYINDEX, "_PRELOAD");
    for (lib = preloadedlibs; lib->func; lib++) {
        lua_pushcfunction(L, lib->func);
        lua_setfield(L, -2, lib->name);
    }
    lua_pop(L, 1);  /* remove _PRELOAD table */
    luaopen_mmos(L);
}

JNIEXPORT void JNICALL Java_com_immomo_mls_NativeBridge__1openLib
        (JNIEnv *env, jclass cls, jlong l) {
    mm_openlibs((lua_State *) l);
}