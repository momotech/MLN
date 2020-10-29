/**
  * Created by MomoLuaNative.
  * Copyright (c) 2019, Momo Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */
//
// Created by XiongFangyu on 2019-12-13.
//

#ifndef MMLUA4ANDROID_JBRIDGE_H
#define MMLUA4ANDROID_JBRIDGE_H

#include <jni.h>
void jni_registerAllStaticClass(JNIEnv *env, jobject jobj, jlong Ls, jobjectArray lcns, jobjectArray lpcns, jobjectArray jcns);

void jni_registerJavaMetatable(JNIEnv * env, jobject jobj, jlong LS, jstring jn, jstring ln);

void jni_registerNumberEnum(JNIEnv *env, jobject jobj, jlong L, jstring lcn, jobjectArray keys, jdoubleArray values);

void jni_registerStringEnum(JNIEnv *env, jobject jobj, jlong L, jstring lcn, jobjectArray keys, jobjectArray values);
/**
 * 将java的class和method组成一个c函数，并push到栈顶
 */
void pushStaticClosure(lua_State *L, jclass clz, jmethodID m, const char *clzName, const char *methodName, int pc, int colonCall);
#endif //MMLUA4ANDROID_JBRIDGE_H
