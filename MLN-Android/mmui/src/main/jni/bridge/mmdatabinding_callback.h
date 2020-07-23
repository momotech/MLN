/**
  * Created by MomoLuaNative.
  * Copyright (c) 2020, Momo Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */
//
// Created by XiongFangyu on 2020/7/20.
//

#ifndef MMLUA4ANDROID_MMDATABINDING_CALLBACK_H
#define MMLUA4ANDROID_MMDATABINDING_CALLBACK_H

#include <jni.h>

#define Void_Call JNIEXPORT void JNICALL

#define MMCALLBACK_Method(s) Java_com_immomo_mmui_databinding_DataBindingCallback_ ## s

#define MMCALLBACK_PRE4PARAMS JNIEnv *env, jobject jobj, jlong Ls, jlong function,

//<editor-fold desc="fast call">
Void_Call MMCALLBACK_Method(nativeInvokeB)(MMCALLBACK_PRE4PARAMS jboolean b1, jboolean b2);
Void_Call MMCALLBACK_Method(nativeInvokeN)(MMCALLBACK_PRE4PARAMS jdouble num1, jdouble num2);
Void_Call MMCALLBACK_Method(nativeInvokeS)(MMCALLBACK_PRE4PARAMS jstring s1, jstring s2);
Void_Call MMCALLBACK_Method(nativeInvokeT)(MMCALLBACK_PRE4PARAMS jlong table1, jlong table2);
//</editor-fold>
#endif //MMLUA4ANDROID_MMDATABINDING_CALLBACK_H
