/**
  * Created by MomoLuaNative.
  * Copyright (c) 2019, Momo Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */
//
//  compiler.h
//
//  Created by XiongFangyu on 2019/6/13.
//  Copyright © 2019 XiongFangyu. All rights reserved.
//

#ifndef _Compiler_h
#define _Compiler_h

#include "lua.h"
#include <jni.h>

#define AUTO_SAVE "__autosave"
/**
 * 是否开启加密校验
 * 若开启，加载脚本前，会检查是否有相关加密
 */
void jni_openSAES(JNIEnv *env, jobject jobj, jboolean open);
// --------------------------compile --------------------------
jint jni_loadData(JNIEnv *env, jobject jobj, jlong L_state_pointer, jstring name, jbyteArray data);
jint jni_loadFile(JNIEnv *env, jobject jobj, jlong L_state_pointer, jstring path, jstring chunkname);
jint jni_loadAssetsFile(JNIEnv *env, jobject jobj, jlong L_state_pointer, jstring path, jstring chunkname);
jboolean jni_setMainEntryFromPreload(JNIEnv *env, jobject jobj, jlong L, jstring name);
void jni_preloadData(JNIEnv *env, jobject jobj, jlong L, jstring name, jbyteArray data);
void jni_preloadFile(JNIEnv *env, jobject jobj, jlong L, jstring name, jstring path);
jint jni_doLoadedData(JNIEnv *env, jobject jobj, jlong L_state_pointer);
jobjectArray jni_doLoadedDataAndGetResult(JNIEnv *env, jobject jobj, jlong LS);
jint jni_startDebug(JNIEnv *env, jobject jobj, jlong LS, jbyteArray data, jstring ip, jint port);

/// lua search 顺序：
/// searcher_preload, searcher_Lua, searcher_C, searcher_Croot
/// searcher_Lua_asset searcher_java

/**
 * require时调用函数
 */
int searcher_java(lua_State *);
/**
 * loadlib.c createsearcherstable
 */
int searcher_Lua(lua_State *);
/**
 * require时调用
 */
int searcher_Lua_asset(lua_State *);
#endif  //_Compiler_h