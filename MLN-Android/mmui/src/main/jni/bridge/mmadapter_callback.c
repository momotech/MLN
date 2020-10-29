/**
 * Created by MomoLuaNative.
 * Copyright (c) 2020, Momo Group. All rights reserved.
 *
 * This source code is licensed under the MIT.
 * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
 */
//
// Created by Generator on 2020-10-16
//

#include "lua.h"
#include "jfunction.h"
#include <jni.h>
#define _Call(R) JNIEXPORT R JNICALL
#define _Method(s) Java_com_immomo_mmui_ud_AdapterLuaFunction_ ## s
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
_Call(jstring) _Method(SninvokeII)(_PRE4PARAMS,jint p1,jint p2) {
    lua_State *L = (lua_State *) Ls;
    jstring fr = NULL;
    call_method_return(L, 2, 1, {
        lua_pushinteger(L, (lua_Integer)p1);
        lua_pushinteger(L, (lua_Integer)p2);
    },{
        if (lua_type(L, -1) == LUA_TSTRING)
            fr = newJString(env, lua_tostring(L, -1));
    }, return fr)
    return fr;
}
_Call(jboolean) _Method(Zninvoke)(_PRE4PARAMS) {
    lua_State *L = (lua_State *) Ls;
    jboolean fr = 0;
    call_method_return(L, 0, 1, {
    },{
        fr = lua_toboolean(L, -1);
    }, return fr)
    return fr;
}
_Call(void) _Method(ninvokeJII)(_PRE4PARAMS,jlong p1,jint p2,jint p3) {
    lua_State *L = (lua_State *) Ls;
    check_and_call_method(L, 3, {
        getValueFromGNV(L, (ptrdiff_t) p1, LUA_TTABLE);
        if (p1 && lua_isnil(L, -1)) {
            throwInvokeError(env, "Table p1 is destroyed.");
            lua_settop(L, oldTop);
            lua_unlock(L);
            return ;
        }

        lua_pushinteger(L, (lua_Integer)p2);
        lua_pushinteger(L, (lua_Integer)p3);
    })
}
_Call(jint) _Method(Ininvoke)(_PRE4PARAMS) {
    lua_State *L = (lua_State *) Ls;
    jint fr = 0;
    call_method_return(L, 0, 1, {
    },{
        if (lua_type(L, -1) == LUA_TNUMBER)
            fr = (jint) lua_tonumber(L, -1);
    }, return fr)
    return fr;
}
_Call(jint) _Method(IninvokeI)(_PRE4PARAMS,jint p1) {
    lua_State *L = (lua_State *) Ls;
    jint fr = 0;
    call_method_return(L, 1, 1, {
        lua_pushinteger(L, (lua_Integer)p1);
    },{
        if (lua_type(L, -1) == LUA_TNUMBER)
            fr = (jint) lua_tonumber(L, -1);
    }, return fr)
    return fr;
}
_Call(jint) _Method(IninvokeII)(_PRE4PARAMS,jint p1,jint p2) {
    lua_State *L = (lua_State *) Ls;
    jint fr = 0;
    call_method_return(L, 2, 1, {
        lua_pushinteger(L, (lua_Integer)p1);
        lua_pushinteger(L, (lua_Integer)p2);
    },{
        if (lua_type(L, -1) == LUA_TNUMBER)
            fr = (jint) lua_tonumber(L, -1);
    }, return fr)
    return fr;
}
_Call(jobject) _Method(UninvokeII)(_PRE4PARAMS,jint p1,jint p2) {
    lua_State *L = (lua_State *) Ls;
    jobject fr = NULL;
    call_method_return(L, 2, 1, {
        lua_pushinteger(L, (lua_Integer)p1);
        lua_pushinteger(L, (lua_Integer)p2);
    },{
        fr = toJavaValue(env, L, -1);
    }, return fr)
    return fr;
}
