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
/// 是否为strong在第0位
#define JUD_FLAG_STRONG 0
/// 是否设置了key在第1位
#define JUD_FLAG_SKEY   1

struct javaUserdata {
#if defined(JAVA_CACHE_UD)
    jlong id;
#else
    jobject jobj;
#endif
    int flag;
    const char *name;
    int refCount;
};
typedef struct javaUserdata javaUserdata;
typedef javaUserdata *UDjavaobject;

#define setUDFlag(ud, f) ud->flag = (ud->flag | (1 << (f)))
#define clearUDFlag(ud, f) ud->flag = (ud->flag & ~(1 << (f)))
#define udHasFlag(ud, f) (ud->flag & (1 << (f)))

#if defined(JAVA_CACHE_UD)
#define isJavaUserdata(ud) ((ud) && (ud->id) && (strstr(ud->name, METATABLE_PREFIX)))
#else
#define isJavaUserdata(ud) ((ud) && (ud->jobj) && (strstr(ud->name, METATABLE_PREFIX)))
#endif

#endif //MMLUA4ANDROID_JUSERDATA_H