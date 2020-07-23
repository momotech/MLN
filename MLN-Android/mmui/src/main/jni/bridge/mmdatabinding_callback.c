/**
  * Created by MomoLuaNative.
  * Copyright (c) 2020, Momo Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */
//
// Created by XiongFangyu on 2020/7/20.
//

#include "mmdatabinding_callback.h"
#include "lua.h"
#include "llimits.h"
#include "jinfo.h"
#include "cache.h"
#include "jfunction.h"

extern int getErrorFunctionIndex(lua_State *L);

#define PRE                                                             \
            lua_lock(L);                                                \
            int erridx = getErrorFunctionIndex(L);                      \
            int oldTop = lua_gettop(L);                                 \
            getValueFromGNV(L, (ptrdiff_t) function, LUA_TFUNCTION);    \
            if (lua_isnil(L, -1)) {                                     \
                throwInvokeError(env, "function is destroyed.");        \
                lua_settop(L, oldTop);                                  \
                lua_unlock(L);                                          \
                return;                                                 \
            }

#define CALL(n)                                     \
            int ret = lua_pcall(L, n, 0, erridx);   \
            if (ret != 0) {                         \
                throwJavaError(env, L);             \
                lua_settop(L, oldTop);              \
                lua_unlock(L);                      \
                return;                             \
            }                                       \
            lua_settop(L, oldTop);                  \
            lua_unlock(L);

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

Void_Call MMCALLBACK_Method(nativeInvokeB)(MMCALLBACK_PRE4PARAMS jboolean b1, jboolean b2) {
    lua_State *L = (lua_State *) Ls;
    PRE
    lua_pushboolean(L, b1);
    lua_pushboolean(L, b2);
    CALL(2)
}
Void_Call MMCALLBACK_Method(nativeInvokeN)(MMCALLBACK_PRE4PARAMS jdouble num1, jdouble num2) {
    lua_State *L = (lua_State *) Ls;
    PRE
    push_number(L, num1);
    push_number(L, num2);
    CALL(2)
}
Void_Call MMCALLBACK_Method(nativeInvokeS)(MMCALLBACK_PRE4PARAMS jstring s1, jstring s2) {
    lua_State *L = (lua_State *) Ls;
    PRE
    push_string(env, L, s1);
    push_string(env, L, s2);
    CALL(2)
}
Void_Call MMCALLBACK_Method(nativeInvokeT)(MMCALLBACK_PRE4PARAMS jlong table1, jlong table2) {
    lua_State *L = (lua_State *) Ls;
    PRE
    getValueFromGNV(L, (ptrdiff_t) table1, LUA_TTABLE);
    if (table1 && lua_isnil(L, -1)) {
        throwInvokeError(env, "table1 is destroyed.");
        lua_settop(L, oldTop);
        lua_unlock(L);
        return;
    }
    getValueFromGNV(L, (ptrdiff_t) table2, LUA_TTABLE);
    if (table2 && lua_isnil(L, -1)) {
        throwInvokeError(env, "table2 is destroyed.");
        lua_settop(L, oldTop);
        lua_unlock(L);
        return;
    }
    CALL(2)
}