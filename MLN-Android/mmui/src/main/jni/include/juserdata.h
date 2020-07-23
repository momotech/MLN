/**
  * Created by MomoLuaNative.
  * Copyright (c) 2019, Momo Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */
//
// Created by XiongFangyu on 2019-08-28.
//

#ifndef MMLUA4ANDROID_JUSERDATA_H
#define MMLUA4ANDROID_JUSERDATA_H

#include <jni.h>
#include "utils.h"
/// 是否为strong在第0位
#define JUD_FLAG_STRONG 0
/// 是否设置了key在第1位
#define JUD_FLAG_SKEY   1
/// 通过lua class name获取metatable名称，记得free
#define getUDMetaname(n) joinstr(METATABLE_PREFIX, n)

#define LUA_INDEX "__index"
/// 设置metatable
#define SET_METATABLE(L)          \
    lua_pushstring(L, LUA_INDEX); \
    lua_pushvalue(L, -2);         \
    lua_rawset(L, -3);

struct javaUserdata {
    jlong id;
    int flag;
    const char *name;
    int refCount;
};
typedef struct javaUserdata javaUserdata;
typedef javaUserdata *UDjavaobject;

#define setUDFlag(ud, f) ud->flag = (ud->flag | (1 << (f)))
#define clearUDFlag(ud, f) ud->flag = (ud->flag & ~(1 << (f)))
#define udHasFlag(ud, f) (ud->flag & (1 << (f)))

#define isJavaUserdata(ud) ((ud) && (ud->id) && (strstr(ud->name, METATABLE_PREFIX)))
/**
 * push构造函数
 * @param clz 类
 * @param con java构造函数
 * @param metaname 对应的meta name
 */
void pushConstructorMethod(lua_State *L, jclass clz, jmethodID con, const char *metaname);
/**
 * 对应userdata_tostring_fun
 */
void pushUserdataTostringClosure(JNIEnv *env, lua_State *L, jclass clz);

/**
 * 对应userdata_bool_fun
 */
void pushUserdataBoolClosure(JNIEnv *env, lua_State *L, jclass clz);

/**
 * 对应gc_userdata
 */
void pushUserdataGcClosure(JNIEnv *env, lua_State *L, jclass clz);
/**
 * 注册所有的userdata
 * @param lcns  lua类名数组
 * @param lpcns lua父类名数组
 * @param jcns  java类名数组
 * @param lazy  是否lazy数组
 */
void jni_registerAllUserdata(JNIEnv *env, jobject jobj, jlong L, jobjectArray lcns, jobjectArray lpcns, jobjectArray jcns, jbooleanArray lazy);
void jni_registerUserdata(JNIEnv *env, jobject jobj, jlong L, jstring lcn, jstring lpcn, jstring jcn);
void jni_registerUserdataLazy(JNIEnv *env, jobject jobj, jlong L, jstring lcn, jstring lpcn, jstring jcn);
/**
 * 创建userdata，然后设置到global表里
 * 用来创建单例，Lua代码中可直接用 ObjectName:method()调用
 * @param key global表里的键，lua代码可用 key:method 调用相关函数
 * @param lcn lua类名
 * @param p 初始化参数
 * @return 原生LuaUserdata对象
 */
jobject jni_createUserdataAndSet(JNIEnv *env, jobject jobj, jlong L, jstring key, jstring lcn, jobjectArray p);
#endif //MMLUA4ANDROID_JUSERDATA_H