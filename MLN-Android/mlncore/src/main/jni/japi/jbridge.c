/**
  * Created by MomoLuaNative.
  * Copyright (c) 2019, Momo Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */
//
// Created by Xiong.Fangyu 2019/03/13.
//

#include "global_define.h"
#include "m_mem.h"
#include "llimits.h"
#include "debug_info.h"
#include "jbridge.h"
#include "jinfo.h"
#include "jtable.h"

#define S_DEFAULT_SIG "(J[" LUAVALUE_CLASS ")[" LUAVALUE_CLASS

static void pushStaticClosure(lua_State *L, jclass clz, jmethodID m, const char *name, int pc);

static int executeJavaStaticFunction(lua_State *L);

static int executeJavaIndexFunction(lua_State *L);

static void pushLuaIndexClosure(lua_State *L, jclass clz, jmethodID m);

static int executeLuaIndexFunction(lua_State *L);

static inline void findOrCreateTable(lua_State *L, const char *name, int len) {
    lua_getglobal(L, name);
    if (lua_isnil(L, -1)) {
        lua_pop(L, 1);
        lua_createtable(L, 0, len);
        lua_pushvalue(L, -1);
        lua_setglobal(L, name);
    }
}

typedef struct context {
    lua_State *L;
    jclass clz;
    const char *className;
} context;

/**
 * -1: table
 * @param key
 * @param value
 * @param ud
 * @return
 */
static int traverse_listener(const void *key, const void *value, void *ud) {
    const char *methodName = (const char *) key;
    jmethodID m = (jmethodID) value;
    context *c = (context *) ud;

    lua_pushstring(c->L, methodName);
    char *name = join3str(c->className, ".", methodName);
    pushStaticClosure(c->L, c->clz, m, name, -1);
    if (name) {
        m_malloc(name, sizeof(char) * (strlen(name) + 1), 0);
    }
    lua_rawset(c->L, -3);
    return 0;
}

void jni_registerStaticClassSimple(JNIEnv *env, jobject jobj, jlong L, jstring jn, jstring ln,
                                   jstring lpcn) {
    const char *jclassname = GetString(env, jn);
    jclass clz = getClassByName(env, jclassname);
    if (!clz) {
        ReleaseChar(env, jn, jclassname);
        return;
    }

    lua_State *LS = (lua_State *) L;
    lua_lock(LS);
    lua_createtable(LS, 0, 0);

    /// 有父类的情况
    if (lpcn) {
        const char *parent_name = GetString(env, lpcn);
        lua_getglobal(LS, parent_name);
        if (lua_istable(LS, -1))
            copyTable(LS, -1, -2);
        lua_pop(LS, 1);
        ReleaseChar(env, lpcn, parent_name);
    }

    context c = {LS, clz, jclassname};
    traverseAllMethods(clz, traverse_listener, &c);
    ReleaseChar(env, jn, jclassname);

    const char *lname = GetString(env, ln);
    lua_setglobal(LS, lname);
    ReleaseChar(env, ln, lname);
    lua_unlock(LS);
}

void jni_registerJavaMetatable(JNIEnv *env, jobject jobj, jlong LS, jstring jn, jstring ln) {
    const char *jclassname = GetString(env, jn);
    jclass clz = getClassByName(env, jclassname);
    if (!clz) {
        return;
    }
    ReleaseChar(env, jn, jclassname);

    jmethodID jmethod = getIndexStaticMethod(env, clz);
    if (!jmethod) {
        return;
    }

    lua_State *L = (lua_State *) LS;
    lua_lock(L);
    lua_newtable(L);                // -1: table
    lua_createtable(L, 0, 1);       // -1: mt --table
    lua_pushstring(L, "__index");   // -1: "__index" --mt-table
    pushLuaIndexClosure(L, clz, jmethod);  // -1: closure --"__index"-mt-table
    lua_rawset(L, -3);              // mt[__index]=closure  -1: mt --table
    lua_setmetatable(L, -2);        // -1: table

    const char *lname = GetString(env, ln);
    lua_setglobal(L, lname);
    ReleaseChar(env, ln, lname);
    lua_unlock(LS);
}

void jni_registerNumberEnum(JNIEnv *env, jobject jobj, jlong LS, jstring lcn, jobjectArray keys,
                            jdoubleArray values) {
    lua_State *L = (lua_State *) LS;
    lua_lock(L);
    const char *name = GetString(env, lcn);
    int len = GetArrLen(env, keys);
    findOrCreateTable(L, name, len);        // -1: table
    ReleaseChar(env, lcn, name);

    int i;
    jstring jk;
    const char *k;
    jdouble *vs = (*env)->GetDoubleArrayElements(env, values, 0);
    for (i = 0; i < len; i++) {
        jk = (*env)->GetObjectArrayElement(env, keys, i);
        k = GetString(env, jk);
        lua_pushstring(L, k);                   // -1:key --table
        ReleaseChar(env, jk, k);
        FREE(env, jk);
        lua_pushnumber(L, (lua_Number) vs[i]);  // -1:num --key-table
        lua_rawset(L, -3);                      // -1:table
    }
    lua_pop(L, 1);
    (*env)->ReleaseDoubleArrayElements(env, values, vs, 0);
    lua_unlock(L);
}

void jni_registerStringEnum(JNIEnv *env, jobject jobj, jlong LS, jstring lcn, jobjectArray keys,
                            jobjectArray values) {
    lua_State *L = (lua_State *) LS;
    lua_lock(L);
    const char *name = GetString(env, lcn);
    int len = GetArrLen(env, keys);
    findOrCreateTable(L, name, len);
    ReleaseChar(env, lcn, name);

    int i;
    jstring jk, jv;
    const char *k;
    const char *v;
    for (i = 0; i < len; i++) {
        jk = (*env)->GetObjectArrayElement(env, keys, i);
        k = GetString(env, jk);
        lua_pushstring(L, k);
        ReleaseChar(env, jk, k);
        FREE(env, jk);
        jv = (*env)->GetObjectArrayElement(env, values, i);
        v = GetString(env, jv);
        lua_pushstring(L, v);
        ReleaseChar(env, jv, v);
        FREE(env, jv);
        lua_rawset(L, -3);
    }
    lua_pop(L, 1);
    lua_unlock(L);
}

/**
 * 对应executeJavaStaticFunction
 */
static void pushStaticClosure(lua_State *L, jclass clz, jmethodID m, const char *name, int pc) {
    UDjclass udclz = (UDjclass) lua_newuserdata(L, sizeof(jclass));
    *udclz = clz;

    UDjmethod udm = (UDjmethod) lua_newuserdata(L, sizeof(jmethodID));
    *udm = m;

    if (name) {
        lua_pushstring(L, name);
    } else {
        lua_pushstring(L, "unknown");
    }
    lua_pushinteger(L, (lua_Integer) pc);
    lua_pushcclosure(L, executeJavaStaticFunction, 4);
}

/**
 * 对应pushStaticClosure
 * upvalue顺序为:
 *              1:UDjclass, 
 *              2:UDjmethod,
 *              3:name
 *              4:parmaCount
 */
static int executeJavaStaticFunction(lua_State *L) {
    JNIEnv *env;
    getEnv(&env);

    lua_lock(L);
    /// 第1个参数为Java静态类
    int idx = lua_upvalueindex(1);
    UDjclass udclz = (UDjclass) lua_touserdata(L, idx);

    /// 第2个参数为Java静态方法
    idx = lua_upvalueindex(2);
    UDjmethod udmethod = (UDjmethod) lua_touserdata(L, idx);

    /// 第2个参数为Java静态方法
    idx = lua_upvalueindex(3);
    const char *name = lua_tostring(L, idx);

    /// 第3个参数为方法需要的参数个数
    /// -1表示可变个数
    int pc = lua_tointeger(L, lua_upvalueindex(4));
    if (pc == -1) {
        pc = lua_gettop(L) - 1; ///去掉栈底的table
    }

    if (!lua_istable(L, 1)) {
        lua_pushstring(L, "use ':' instead of '.' to call method!!");
        lua_unlock(L);
        return lua_error(L);
    }

    jobjectArray p = newLuaValueArrayFromStack(env, L, pc, 2);

    jobjectArray result = (jobjectArray) (*env)->CallStaticObjectMethod(env, getuserdata(udclz),
                                                                        getuserdata(udmethod),
                                                                        (jlong) L, p);
    if (catchJavaException(env, L, name)) {
        FREE(env, p);
        lua_error(L);
        lua_unlock(L);
        return 1;
    }

    FREE(env, p);
    if (!result) {
        lua_settop(L, 1);
        lua_unlock(L);
        return 1;
    }
    int rc = pushJavaArray(env, L, result);
    FREE(env, result);
    lua_unlock(L);
    return rc;
}

static void pushLuaIndexClosure(lua_State *L, jclass clz, jmethodID m) {
    UDjclass udclz = (UDjclass) lua_newuserdata(L, sizeof(jclass));
    *udclz = clz;

    UDjmethod udm = (UDjmethod) lua_newuserdata(L, sizeof(jmethodID));
    *udm = m;

    lua_pushcclosure(L, executeLuaIndexFunction, 2);
}

static int executeLuaIndexFunction(lua_State *L) {
    JNIEnv *env;
    getEnv(&env);

    lua_lock(L);
    /// 第1个参数为Java静态类
    int idx = lua_upvalueindex(1);
    lua_pushvalue(L, idx);

    /// 第2个参数为Java静态方法
    idx = lua_upvalueindex(2);
    lua_pushvalue(L, idx);

    lua_pushvalue(L, 2);
    lua_pushcclosure(L, executeJavaIndexFunction, 3);

    lua_unlock(L);
    return 1;
}

/**
 * pushJavaIndexClosure
 * @param L upvalue: 1: class 2: method 3: name
 * call java method and return
 */
static int executeJavaIndexFunction(lua_State *L) {
    JNIEnv *env;
    getEnv(&env);

    lua_lock(L);
    /// 第1个参数为Java静态类
    int idx = lua_upvalueindex(1);
    UDjclass udclz = (UDjclass) lua_touserdata(L, idx);

    /// 第2个参数为Java静态方法
    idx = lua_upvalueindex(2);
    UDjmethod udmethod = (UDjmethod) lua_touserdata(L, idx);

    /// 第三个参数为函数名称
    idx = lua_upvalueindex(3);
    const char *mn = NULL;
    if (lua_isstring(L, idx)) {
        mn = lua_tostring(L, idx);
    }

    if (!mn) {
        lua_pushstring(L, "no method name");
        return lua_error(L);
    }

    jclass clz = getuserdata(udclz);
    jmethodID method = getuserdata(udmethod);

    int paramCount = lua_gettop(L);
    jobjectArray p = newLuaValueArrayFromStack(env, L, paramCount, 1);
    jstring jmn = newJString(env, mn);
    jobjectArray result = (jobjectArray) (*env)->CallStaticObjectMethod(env, clz, method, (jlong) L,
                                                                        jmn, p);
    if (catchJavaException(env, L, mn)) {
        FREE(env, p);
        FREE(env, jmn);
        const char *msg = lua_tostring(L, -1);
        lua_pop(L, 1);
        lua_pushfstring(L, "call method %s failed---%s", mn, msg);
        lua_error(L);
        lua_unlock(L);
        return 1;
    }

    FREE(env, p);
    FREE(env, jmn);
    if (!result) {
        lua_unlock(L);
        return 0;
    }

    int rc = pushJavaArray(env, L, result);
    FREE(env, result);
    lua_unlock(L);
    return rc;
}