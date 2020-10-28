/**
 * Created by MomoLuaNative.
 * Copyright (c) 2020, Momo Group. All rights reserved.
 *
 * This source code is licensed under the MIT.
 * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
 */
//
// Created by XiongFangyu on 2020/8/28.
//

#include "lapi.h"
#include "jse.h"
#include "juserdata.h"
#include "global_define.h"
#include "jinfo.h"
#include "m_mem.h"
#include "lauxlib.h"

#define PACKAGE_NAME "org/luaj/vm2/jse/"
#define JAVA_INSTANCE PACKAGE_NAME "JavaInstance"
#define JAVA_CLASS PACKAGE_NAME "JavaClass"
static jclass javaInstanceClz = NULL;
static jclass javaClassClz = NULL;

/**
 * 对应executeLuaIndexFunction
 * 查找类中 LuaValue[] __index(String name, LuaValue[] args)方法
 */
static void pushUserdataIndexClosure(JNIEnv *env, lua_State *L, jclass clz);
/**
 * 对应pushUserdataIndexClosure
 * upvalues: 1: class 2: method
 * push executeJavaIndexFunction 并返回
 */
static int executeLuaIndexFunction(lua_State *L);

/**
 * 真正执行java __index方法
 * upvalue: 1: class 2: method 3: name
 */
static int executeJavaIndexFunction(lua_State *L);

/**
 * 对应executeLuaIndexFunction
 */
static void pushUserdataIndexOrNewindexClosure(lua_State *L, jmethodID m, int getter) {
    /// -1: table
    const char *name = getter ? LUA_INDEX : LUA_NEWINDEX;

    lua_pushstring(L, name);        //-1: name   table

    UDjmethod udm = (UDjmethod) lua_newuserdata(L, sizeof(jmethodID));
    *udm = m;
    lua_pushboolean(L, getter);

    /// -1: getter -2: method -3 name -4 table
    lua_pushcclosure(L, executeLuaIndexFunction, 2);
    /// -1: function -2 name -3 table
    lua_rawset(L, -3);
}

/**
 * 对应executeLuaIndexFunction
 * 查找类中 LuaValue[] __index(String name, LuaValue[] args)方法
 * 或 void __newindex(String name, LuaValue arg)
 */
static void pushUserdataIndexClosure(JNIEnv *env, lua_State *L, jclass clz) {
    /// -1: metatable
    lua_pushstring(L, LUA_INDEX);
    lua_pushvalue(L, -2);
    /// metatable.__index=metatable
    lua_rawset(L, -3);
    /// -1: metatable
    jmethodID _index = (*env)->GetMethodID(env, clz, LUA_INDEX,
    "(" STRING_CLASS "[" LUAVALUE_CLASS ")[" LUAVALUE_CLASS);
    if (_index)
        pushUserdataIndexOrNewindexClosure(L, _index, 1);
    /// -1:metatable
    jmethodID _newindex = (*env)->GetMethodID(env, clz, LUA_NEWINDEX,
    "(" STRING_CLASS "" LUAVALUE_CLASS ")V");
    if (_newindex)
        pushUserdataIndexOrNewindexClosure(L, _newindex, 0);
}

static int
executeJavaIndexOrNewindexFunction(JNIEnv *env, lua_State *L, jmethodID m, const char *mn,
                                   int getter);

/**
 * 对应pushUserdataIndexClosure
 * upvalues: 1: method 2: getter
 * push executeJavaIndexFunction 并返回
 */
static int executeLuaIndexFunction(lua_State *L) {
    lua_lock(L);
    /// 第2个参数为bool
    int idx = lua_upvalueindex(2);
    int getter = lua_toboolean(L, idx);
    if (getter) {
        lua_pushvalue(L, lua_upvalueindex(1));
        lua_pushvalue(L, idx);
        lua_pushvalue(L, 2);    //method name
        lua_pushcclosure(L, executeJavaIndexFunction, 3);
        lua_unlock(L);
        return 1;
    } else {
        JNIEnv *env;
        getEnv(&env);
        /// 第1个参数为Java方法
        idx = lua_upvalueindex(1);
        UDjmethod udmethod = (UDjmethod) lua_touserdata(L, idx);
        const char *mn = lua_tostring(L, 2);
        lua_remove(L, 2);

        executeJavaIndexOrNewindexFunction(env, L, getuserdata(udmethod), mn, 0);
        lua_unlock(L);
        return 0;
    }
}

static int
executeJavaIndexOrNewindexFunction(JNIEnv *env, lua_State *L, jmethodID m, const char *mn,
                                   int getter) {
    UDjavaobject udjobj = (UDjavaobject) lua_touserdata(L, 1);
    jobject jobj = getUserdata(env, L, udjobj);
    if (!jobj) {
        lua_pushfstring(L, "get java object from java failed, id: %d", udjobj->id);
        lua_error(L);
        return 1;
    }
    int paramCount = lua_gettop(L) - 1;
    jobject p = NULL;
    jstring jmn = newJString(env, mn);
    jobjectArray result = NULL;
    if (getter) {
        p = newLuaValueArrayFromStack(env, L, paramCount, 2);
        result = (jobjectArray) (*env)->CallObjectMethod(env, jobj, m, jmn, p);
    } else {
        p = toJavaValue(env, L, 2);
        (*env)->CallVoidMethod(env, jobj, m, jmn, p);
    }
    FREE(env, jobj);
    char *info = join3str(udjobj->name + strlen(METATABLE_PREFIX), ".", mn);
    if (catchJavaException(env, L, info)) {
        if (info)
            m_malloc(info, sizeof(char) * (strlen(info) + 1), 0);
        FREE(env, p);
        FREE(env, jmn);
        const char *msg = lua_tostring(L, -1);
        lua_pop(L, 1);
        lua_pushfstring(L, "call method %s failed---%s", mn, msg);
        lua_error(L);
        return 1;
    }
    if (info)
        m_malloc(info, sizeof(char) * (strlen(info) + 1), 0);
    FREE(env, p);
    FREE(env, jmn);
    if (!result) {
        return 0;
    }

    int rc = pushJavaArray(env, L, result);
    FREE(env, result);
    return rc;
}

/**
 * 真正执行java __index方法
 * upvalue: 1: method 2: getter 3: name
 */
static int executeJavaIndexFunction(lua_State *L) {
    lua_lock(L);
    if (!lua_isuserdata(L, 1)) {
        lua_pushstring(L, "use ':' instead of '.' to call method!!");
        lua_unlock(L);
        lua_error(L);
        return 1;
    }

    JNIEnv *env;
    getEnv(&env);

    /// 第1个参数为Java方法
    int idx = lua_upvalueindex(1);
    UDjmethod udmethod = (UDjmethod) lua_touserdata(L, idx);

    /// 第2个参数为getter
    idx = lua_upvalueindex(2);
    int getter = lua_toboolean(L, idx);

    /// 第3个参数为函数名称
    idx = lua_upvalueindex(3);
    const char *mn = NULL;
    if (lua_isstring(L, idx)) {
        mn = lua_tostring(L, idx);
    }

    if (!mn) {
        lua_pushstring(L, "no method name");
        return lua_error(L);
    }

    jmethodID method = getuserdata(udmethod);

    int rc = executeJavaIndexOrNewindexFunction(env, L, method, mn, getter);
    lua_unlock(L);
    return rc;
}

JNIEXPORT void JNICALL Java_org_luaj_vm2_jse_JSERegister__1registerJSE
        (JNIEnv *env, jclass cls, jlong Ls) {
    if (!javaInstanceClz) {
        javaInstanceClz = GLOBAL(env, (*env)->FindClass(env, JAVA_INSTANCE));
    }
    if (!javaClassClz) {
        javaClassClz = GLOBAL(env, (*env)->FindClass(env, JAVA_CLASS));
    }
    lua_State *L = (lua_State *)Ls;
    if (u_newmetatable(L, JAVA_INSTANCE_META)) {
        pushUserdataIndexClosure(env, L, javaInstanceClz);
        lua_setfield(L, LUA_REGISTRYINDEX, JAVA_CLASS_META);  /* registry.name = metatable */
    }
}