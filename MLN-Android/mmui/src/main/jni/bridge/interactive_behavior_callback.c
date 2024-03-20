/**
 * Created by MomoLuaNative.
 * Copyright (c) 2020, Momo Group. All rights reserved.
 *
 * This source code is licensed under the MIT.
 * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
 */
//
// Created by Generator on 2021-03-03
//

#include "lua.h"
#include "jfunction.h"
#include <jni.h>
#define _Call(R) JNIEXPORT R JNICALL
#define _Method(s) Java_com_immomo_mmui_ud_anim_InteractiveBehaviorCallback_ ## s
#define _PRE4PARAMS JNIEnv *env, jobject jobj, jlong Ls, jlong function

static inline void push_number(lua_State *L, jdouble num) {
    lua_Integer li1 = (lua_Integer) num;
    if (li1 == num) {
        lua_pushinteger(L, li1);
    } else {
        lua_pushnumber(L, num);
    }
}

static inline void push_string(JNIEnv *env, lua_State *L, jstring s) {
    const char *str = GetString(env, s);
    if (str)
        lua_pushstring(L, str);
    else
        lua_pushnil(L);
    ReleaseChar(env, s, str);
}
_Call(void) _Method(nativeCallback)(_PRE4PARAMS,jint p1,jfloat p2,jfloat p3) {
    lua_State *L = (lua_State *) Ls;
    check_and_call_method(L, 3, {
        lua_pushinteger(L, (lua_Integer)p1);
        push_number(L, p2);
        push_number(L, p3);
    })
}
