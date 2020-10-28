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

#ifndef MMLUA4ANDROID_JFUNCTION_H
#define MMLUA4ANDROID_JFUNCTION_H

#include <jni.h>
#include "llimits.h"
#include "jinfo.h"
#include "cache.h"

extern int getErrorFunctionIndex(lua_State *L);

#define call_method_return(L, n, p, params, jr, dr)                     \
            lua_lock(L);                                                \
            int erridx = getErrorFunctionIndex(L);                      \
            int oldTop = lua_gettop(L);                                 \
            getValueFromGNV(L, (ptrdiff_t) function, LUA_TFUNCTION);    \
            if (lua_isnil(L, -1)) {                                     \
                throwInvokeError(env, "function is destroyed.");        \
                lua_settop(L, oldTop);                                  \
                lua_unlock(L);                                          \
                dr;                                                     \
            }                                                           \
            params;                                                     \
            int ret = lua_pcall(L, n, p, erridx);                       \
            if (ret != 0) {                                             \
                throwJavaError(env, L);                                 \
                lua_settop(L, oldTop);                                  \
                lua_unlock(L);                                          \
                dr;                                                     \
            }                                                           \
            jr;                                                         \
            lua_settop(L, oldTop);                                      \
            lua_unlock(L);

#define check_and_call_method(L, n, params) call_method_return((L), (n), 0, params, ((void *)0), return)

jobjectArray jni_invoke(JNIEnv *env, jobject jobj, jlong L, jlong function, jobjectArray params, jint rc);

jstring jni_getFunctionSource(JNIEnv *env, jobject jobj, jlong LS, jlong function);
/**
 * 根据lua栈顶信息抛出java异常
 */
void throwJavaError(JNIEnv *env, lua_State *L);
#endif //MMLUA4ANDROID_JFUNCTION_H
