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

#define Void_Call JNIEXPORT void JNICALL

jobjectArray jni_invoke(JNIEnv *env, jobject jobj, jlong L, jlong function, jobjectArray params, jint rc);

jstring jni_getFunctionSource(JNIEnv *env, jobject jobj, jlong LS, jlong function);
/**
 * 根据lua栈顶信息抛出java异常
 */
void throwJavaError(JNIEnv *env, lua_State *L);
//<editor-fold desc="fast call">
Void_Call Java_org_luaj_vm2_LuaFunction_nativeInvokeB(JNIEnv *env, jobject jobj, jlong L, jlong function, jboolean b);
Void_Call Java_org_luaj_vm2_LuaFunction_nativeInvokeN(JNIEnv *env, jobject jobj, jlong L, jlong function, jdouble num);
Void_Call Java_org_luaj_vm2_LuaFunction_nativeInvokeS(JNIEnv *env, jobject jobj, jlong L, jlong function, jstring s);
Void_Call Java_org_luaj_vm2_LuaFunction_nativeInvokeT(JNIEnv *env, jobject jobj, jlong L, jlong function, jlong table);
//</editor-fold>
#endif //MMLUA4ANDROID_JFUNCTION_H
