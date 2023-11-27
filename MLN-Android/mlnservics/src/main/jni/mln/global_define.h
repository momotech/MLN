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
#include <stdio.h>
#include "lua.h"
#include "lstate.h"
#include "utils.h"
#include "luaconf.h"
#include "mempool.h"

#if defined(J_API_INFO)
#include <pthread.h>
#include "lstate.h"
#include "mlog.h"
#define _checkThread(ud) while((ud)->create_thread != pthread_self()) {\
LOGE("%s:函数%s(%d)执行线程和虚拟机创建线程不符",__FILE__, __FUNCTION__, __LINE__);\
exit(1);\
}
#define CheckThread(L) _checkThread((LuaJData *)(G((L))->ud))
#else
#define CheckThread(L) ((void) 0)
#endif

typedef enum ErrorType {
    no = 0,
    bridge = 1,
    require = 2,
    lua = 3
} ErrorType;

typedef struct LuaJData {
#if defined(J_API_INFO)
    /// lua使用内存
    size_t use_mem;
    pthread_t create_thread;
#endif
    ErrorType type;
    char vm_is_closing;
    mem_pool *pool;
} LuaJData;

#define clearErrorType(L) setErrorType(L, no)
#define getErrorType(L) ((LuaJData *)(G((L))->ud))->type
#define setErrorType(L, t) {if (getErrorType(L) == no) ((LuaJData *)(G((L))->ud))->type = (t);}

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

#define GLOBAL_KEY 0xffffffffffffffffL
#define isGlobal(k) (k == GLOBAL_KEY)

#define METATABLE_PREFIX "__M_"
#define JAVA_INSTANCE_META METATABLE_PREFIX "__JavaInstance"
#define JAVA_CLASS_META METATABLE_PREFIX "__JavaClass"
#define METATABLE_FORMAT METATABLE_PREFIX "%s"

#define DEFAULT_SIG "([" LUAVALUE_CLASS ")[" LUAVALUE_CLASS

#define GetString(env, js) (!js ? NULL : (*env)->GetStringUTFChars(env, js, 0))
#define ReleaseChar(env, js, c) ((js && c) ? (*env)->ReleaseStringUTFChars(env, js, c) : (void *)c)

#define FREE(env, obj) if ((obj) && (*env)->GetObjectRefType(env, obj) == JNILocalRefType) (*env)->DeleteLocalRef(env, obj);

#define GLOBAL(env, obj) (*env)->NewGlobalRef(env, obj)

#define ExceptionDescribe(env) (*env)->ExceptionDescribe(env)
#define ClearException(env)     if ((*env)->ExceptionCheck(env)) {  \
                                    ExceptionDescribe(env);         \
                                    (*env)->ExceptionClear(env);    \
                                }

typedef jclass *UDjclass;
typedef jmethodID *UDjmethod;
#define getuserdata(ud) (*ud)
#endif // GLOBAL_DEFINE_H