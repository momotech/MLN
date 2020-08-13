/**
  * Created by MomoLuaNative.
  * Copyright (c) 2019, Momo Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */
//
// Created by XiongFangyu on 2019-12-12.
//

#include "llimits.h"
#include "lua.h"
#include "jfunction.h"
#include "cache.h"
#include "jinfo.h"
#include "lobject.h"
#include "mlog.h"
#include "utils.h"
#include "m_mem.h"

extern jclass LuaValue;
extern int getErrorFunctionIndex(lua_State *L);

jobjectArray
jni_invoke(JNIEnv *env, jobject jobj, jlong L, jlong function, jobjectArray params, jint rc) {
    lua_State *LS = (lua_State *) L;
    lua_lock(LS);
    int erridx = getErrorFunctionIndex(LS);
    int oldTop = lua_gettop(LS);
    getValueFromGNV(LS, (ptrdiff_t) function, LUA_TFUNCTION);
    if (lua_isnil(LS, -1)) {
        throwInvokeError(env, "function is destroyed.");
        lua_pop(LS, 1);
        lua_unlock(LS);
        return NULL;
    }

    int len = pushJavaArray(env, LS, params);
    int ret = lua_pcall(LS, len, (int) rc, erridx);
    if (ret != 0) {
        throwJavaError(env, LS);
        lua_settop(LS, oldTop);
        lua_unlock(LS);
        return NULL;
    }
    int returnCount = lua_gettop(LS) - oldTop;
    if (returnCount == 0) {
        lua_settop(LS, oldTop);
        // lua_pop(LS, 1);
        lua_unlock(LS);
        return NULL;
    }
    int i;
    jobjectArray r = (*env)->NewObjectArray(env, returnCount, LuaValue, NULL);
    for (i = returnCount - 1; i >= 0; i--) {
        jobject v = toJavaValue(env, LS, oldTop + i + 1);
        (*env)->SetObjectArrayElement(env, r, i, v);
        FREE(env, v);
    }
    lua_settop(LS, oldTop);
    lua_unlock(LS);
    return r;
}

jstring jni_getFunctionSource(JNIEnv *env, jobject jobj, jlong LS, jlong function) {
    lua_State *L = (lua_State *) LS;
    lua_lock(L);
    getValueFromGNV(L, (ptrdiff_t) function, LUA_TFUNCTION);
    if (!lua_isfunction(L, -1)) {
        lua_pop(L, 1);
        lua_unlock(L);
        return NULL;
    }
    Proto *p = ((LClosure *)lua_topointer(L, -1))->p;
    lua_unlock(L);
    if (p->source) {
        const char *source = getstr(p->source);
        jstring ret;
        if (p->lineinfo && p->sizelineinfo > 0) {
            char *str = formatstr("%s:%d", source, p->lineinfo[0]);
            ret = newJString(env, str);
            m_malloc(str, sizeof(char) * (strlen(str) + 1), 0);
        } else {
            ret = newJString(env, source);
        }
        return ret;
    }
    return NULL;
}

void throwJavaError(JNIEnv *env, lua_State *L) {
    const char *errMsg = NULL;
    if (lua_isstring(L, -1))
        errMsg = lua_tostring(L, -1);
    throwInvokeError(env, errMsg);
}

//<editor-fold desc="fast call">

#define Void_Call JNIEXPORT void JNICALL
#define LuaFunctionMethod(m) Java_org_luaj_vm2_LuaFunction_ ## m
#define Pre4Params JNIEnv *env, jobject jobj, jlong Ls, jlong function

Void_Call LuaFunctionMethod(nativeInvokeV)(Pre4Params) {
    lua_State *L = (lua_State *) Ls;
    check_and_call_method(L, 0, NULL)
}

Void_Call LuaFunctionMethod(nativeInvokeB)(Pre4Params, jboolean b) {
    lua_State *L = (lua_State *) Ls;
    check_and_call_method(L, 1, {
    lua_pushboolean(L, b);
    })
}

Void_Call LuaFunctionMethod(nativeInvokeN)(Pre4Params, jdouble num) {
    lua_State *L = (lua_State *) Ls;
    check_and_call_method(L, 1, {
    lua_Integer li = (lua_Integer) num;
    if (li == num) {
        lua_pushinteger(L, li);
    } else {
        lua_pushnumber(L, num);
    }
    })
}

Void_Call LuaFunctionMethod(nativeInvokeS)(Pre4Params, jstring s) {
    lua_State *L = (lua_State *) Ls;
    check_and_call_method(L, 1, {
    const char *str = GetString(env, s);
    if (str)
        lua_pushstring(L, str);
    else
        lua_pushnil(L);
    ReleaseChar(env, s, str);
    })
}

Void_Call LuaFunctionMethod(nativeInvokeT)(Pre4Params, jlong table) {
    lua_State *L = (lua_State *) Ls;
    check_and_call_method(L, 1, {
    getValueFromGNV(L, (ptrdiff_t) table, LUA_TTABLE);
    if (lua_isnil(L, -1)) {
        throwInvokeError(env, "table is destroyed.");
        lua_settop(L, oldTop);
        lua_unlock(L);
        return;
    }
    })
}
//</editor-fold>