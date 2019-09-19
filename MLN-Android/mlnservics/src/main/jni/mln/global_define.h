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

#ifndef GLOBAL_DEFINE_H
#define GLOBAL_DEFINE_H

#include <jni.h>
#include <string.h>
#include "lua.h"
#include "utils.h"
#include "luaconf.h"

#if defined(__arm64__) || defined(__aarch64__)
/**
 * 64位机器
 */
#define ENV_64
#endif

#define ERROR_FUN "__JAPI_ERROR_FUN"
#define OBJECT_CLASS "Ljava/lang/Object;"
#define STRING_CLASS "Ljava/lang/String;"
#define JAVA_PATH "org/luaj/vm2/"
#define LUAVALUE_CLASS "L" JAVA_PATH "LuaValue;"

#define GLOBAL_KEY "LUA_REGISTRYINDEX"
#define isGlobal(k) (strstr(k, GLOBAL_KEY) != NULL)

#define METATABLE_PREFIX "__M_"
#define JAVA_INSTANCE_META METATABLE_PREFIX "__JavaInstance"
#define JAVA_CLASS_META METATABLE_PREFIX "__JavaClass"
#define METATABLE_FORMAT METATABLE_PREFIX "%s"
#define isJavaUserdata(ud) ((ud) && (ud->jobj) && (strstr(ud->name, METATABLE_PREFIX)))

#define DEFAULT_SIG "([" LUAVALUE_CLASS ")[" LUAVALUE_CLASS

#define GetString(env, js) (!js ? NULL : (*env)->GetStringUTFChars(env, js, 0))
#define ReleaseChar(env, js, c) ((js && c) ? (*env)->ReleaseStringUTFChars(env, js, c) : (void *)c)

#define FREE(env, obj) if ((obj) && (*env)->GetObjectRefType(env, obj) == JNILocalRefType) (*env)->DeleteLocalRef(env, obj);
#if defined(J_API_INFO)
jobject _global(JNIEnv *, jobject);
void _unglobal(JNIEnv *, jobject);
#define GLOBAL(env, obj) _global(env, obj)
#define UNGLOBAL(env, obj) _unglobal(env, obj)
#else
#define GLOBAL(env, obj) (*env)->NewGlobalRef(env, obj)
#define UNGLOBAL(env, obj) (*env)->DeleteGlobalRef(env, obj)
#endif
#define ExceptionDescribe(env) (*env)->ExceptionDescribe(env)
#define ClearException(env)     if ((*env)->ExceptionCheck(env)) {  \
                                    ExceptionDescribe(env);         \
                                    (*env)->ExceptionClear(env);    \
                                }

typedef jclass *UDjclass;
typedef jmethodID *UDjmethod;
#define getuserdata(ud) (*ud)

/// 是否为strong在第0位
#define JUD_FLAG_STRONG 0
/// 是否设置了key在第1位
#define JUD_FLAG_SKEY   1

struct javaUserdata {
    jobject jobj;
    int flag;
    const char *name;
    int refCount;
};
typedef struct javaUserdata javaUserdata;
typedef javaUserdata *UDjavaobject;

#define setUDFlag(ud, f) ud->flag = (ud->flag | (1 << (f)))
#define clearUDFlag(ud, f) ud->flag = (ud->flag & ~(1 << (f)))
#define udHasFlag(ud, f) (ud->flag & (1 << (f)))

/**
 * 将src table中的数据拷贝到desc table中
 */
void copyTable(lua_State *L, int src, int desc);

#endif // GLOBAL_DEFINE_H