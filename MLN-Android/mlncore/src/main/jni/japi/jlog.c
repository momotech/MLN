/**
  * Created by MomoLuaNative.
  * Copyright (c) 2019, Momo Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */
//
// Created by Xiong.Fangyu 2019/02/27.
//

#include "jlog.h"
#include "mlog.h"

static JavaVM *jvm;
// global ref
static jclass NativeLog;
static jmethodID NativeLog_log;
static int isInit = 0;

extern jstring newJString(JNIEnv *env, const char *s);

static int getEnv(JNIEnv **out) {
    int needDetach = 0;
    if ((*jvm)->GetEnv(jvm, (void **) out, JNI_VERSION_1_4) < 0 || !(*out)) {
        (*jvm)->AttachCurrentThread(jvm, out, NULL);
        needDetach = 1;
    }
    return needDetach;
}

static void detachEnv() {
    (*jvm)->DetachCurrentThread(jvm);
}

void initlog(JNIEnv *env) {
    if (isInit)
        return;
    NativeLog = (*env)->FindClass(env, "org/luaj/vm2/utils/NativeLog");
    NativeLog_log = (*env)->GetStaticMethodID(env, NativeLog, "log", "(JILjava/lang/String;)V");
    NativeLog = (jclass) (*env)->NewGlobalRef(env, NativeLog);
    isInit = (*env)->GetJavaVM(env, &jvm) == 0;
}

void log2java(jlong l, int type, const char *s, void *p) {
    JNIEnv *jnienv;
    int needDetach = getEnv(&jnienv);
    jstring jstr;
    char str[MAX_STRING_LENGTH];
    if (p) {
        if (snprintf(str, MAX_STRING_LENGTH, s, p) != -1) {
            jstr = newJString(jnienv, str);
        } else {
            LOGE("format error! %s", s);
            jstr = newJString(jnienv, "format error!");
        }
    } else if (s) {
        jstr = newJString(jnienv, s);
    } else {
        jstr = NULL;
    }
    (*jnienv)->CallStaticVoidMethod(jnienv, NativeLog, NativeLog_log, l, (jint) type, jstr);
    if (jstr) (*jnienv)->DeleteLocalRef(jnienv, jstr);

    if (needDetach) detachEnv();
}