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

#ifndef J_USERDATA_H
#define J_USERDATA_H

#include "luajapi.h"

/// lua虚拟机gc到相应userdata时，调用
#define JAVA_GC_METHOD "__onLuaGc"
#define JAVA_TOSTRING "toString"
/// 构造函数标识
#define DEFAULT_CON_SIG "J[" LUAVALUE_CLASS

#define LUA_INDEX "__index"
#define LUA_NEWINDEX "__newindex"

/// 设置metatable
#define SET_METATABLE(L)          \
    lua_pushstring(L, LUA_INDEX); \
    lua_pushvalue(L, -2);         \
    lua_rawset(L, -3);

/// 判断是否是JavaUserdata的子类，由java控制内存(存储在)
#define IS_STRONG_REF(env, clz) (*env)->IsAssignableFrom(env, clz, JavaUserdata)
/// 通过lua class name获取metatable名称，记得free
#define getUDMetaname(n) joinstr(METATABLE_PREFIX, n)
#define clearException(env) (*env)->ExceptionClear(env);

extern jclass JavaUserdata;
extern jclass StringClass;

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
 * 对应userdata_tostring_fun
 */
static void pushUserdataTostringClosure(JNIEnv *env, lua_State *L, jclass clz);

/**
 * 对应pushUserdataTostringClosure
 * upvalue顺序为:
 *              1:UDjmethod
 */
static int userdata_tostring_fun(lua_State *L);

/**
 * 对应userdata_bool_fun
 */
static void pushUserdataBoolClosure(JNIEnv *env, lua_State *L, jclass clz);

/**
 * 对应pushUserdataBoolClosure
 * upvalue顺序为:
 *              1:UDjmethod
 */
static int userdata_bool_fun(lua_State *L);

/**
 * 对应gc_userdata
 */
static void pushUserdataGcClosure(JNIEnv *env, lua_State *L, jclass clz);

/**
 * 对应pushUserdataGcClosure
 * upvalue顺序为:
 *              1:UDjmethod gcmethod
 */
static int gc_userdata(lua_State *L);

/**
 * 对应executeJavaUDFunction
 */
static void pushMethodClosure(lua_State *L, jmethodID m, const char *mn);

/**
 * 对应pushMethodClosure
 * upvalue顺序为:
 *              1:UDjmethod
 *              2:string methodname
 */
static int executeJavaUDFunction(lua_State *L);

/**
 * 生成jms，要和释放对应j_ms_gc
 */
static char **get_methods_str(JNIEnv *env, jobjectArray ams, int methodCount, int methodStartIndex);

/**
 * 要和get_methods_str对应
 */
static inline void free_methods(char **methods, int len);
//// ----------------------------------------------------------------------------------------------------
//// ---------------------------------------------lazy---------------------------------------------------
//// ----------------------------------------------------------------------------------------------------
#define J_MS_METANAME "__J_MS_"
typedef struct j_ms {
    char **methods;
    int len;
    jclass clz;
    const char *p_meta;
} __LID;

/**
 * 释放j_ms相关内存
 * 需要和get_methods_str对应
 */
static int j_ms_gc(lua_State *L);

/**
 * 对应execute_new_ud_lazy
 */
static void push_lazy_init(lua_State *L, jclass clz, const char *metaname, const char *p_metaname,
                           char **methods, int len);

/**
 * 对应 push_lazy_init
 * upvalue顺序为:1: metaname
 */
static int execute_new_ud_lazy(lua_State *L);
//// ----------------------------------------------------------------------------------------------------
//// ----------------------------------------------------------------------------------------------------
/**
 * 对应execute_new_ud
 */
static void
push_init(JNIEnv *env, lua_State *L, jclass clz, const char *metaname, const char *p_metaname,
          char **methods, int len);

/**
 * 对应push_init
 * upvalue顺序为:
 *              1:UDjclass 
 *              2:constructor(UDjmethod)
 *              3:metaname(string)
 */
static int execute_new_ud(lua_State *L);

static void
fillUDMetatable(JNIEnv *env, lua_State *LS, jclass clz, char **jms, int len, const char *parent_mn);

#endif