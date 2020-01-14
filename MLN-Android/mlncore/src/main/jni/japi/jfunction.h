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

jobjectArray jni_invoke(JNIEnv *env, jobject jobj, jlong L, jlong function, jobjectArray params, jint rc);

jstring jni_getFunctionSource(JNIEnv *env, jobject jobj, jlong LS, jlong function);
#endif //MMLUA4ANDROID_JFUNCTION_H
