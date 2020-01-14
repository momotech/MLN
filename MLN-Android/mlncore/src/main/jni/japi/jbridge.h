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

void jni_registerStaticClassSimple(JNIEnv *env, jobject jobj, jlong L, jstring jn, jstring ln, jstring lpcn);

void jni_registerJavaMetatable(JNIEnv * env, jobject jobj, jlong LS, jstring jn, jstring ln);

void jni_registerNumberEnum(JNIEnv *env, jobject jobj, jlong L, jstring lcn, jobjectArray keys, jdoubleArray values);

void jni_registerStringEnum(JNIEnv *env, jobject jobj, jlong L, jstring lcn, jobjectArray keys, jobjectArray values);
#endif //MMLUA4ANDROID_JBRIDGE_H
