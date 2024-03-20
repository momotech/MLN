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

#ifndef MMLUA4ANDROID_JTABLE_H
#define MMLUA4ANDROID_JTABLE_H

#include <jni.h>
#include "lua.h"
/**
 * 将src table中的数据拷贝到desc table中
 */
void copyTable(lua_State *L, int src, int desc);
/**
 * 将parent设置为t的metatable，并用__index指向
 * t.metatable = {__index=parent}
 */
void setParentTable(lua_State *L, int t, int parent);

jlong jni_createTable(JNIEnv *env, jobject jobj, jlong L);
jboolean jni_isEmpty(JNIEnv *env, jobject jobj, jlong L, jlong table);

jint jni_getTableSize(JNIEnv *env, jobject jobj, jlong L, jlong table);
void jni_clearTableArray(JNIEnv *env, jobject jobj, jlong L, jlong table, jint from, jint to);
void jni_removeTableIndex(JNIEnv *env, jobject jobj,jlong L,jlong table,jint index);
void jni_clearTable(JNIEnv *env, jobject jobj,jlong L,jlong table);
jlong jni_setMetatable(JNIEnv *env, jobject jobj, jlong Ls, jlong table, jlong meta);
jlong jni_getMetatable(JNIEnv *env,jobject jobj,jlong Ls, jlong table);

void jni_setTableNumber(JNIEnv *env, jobject jobj, jlong L, jlong table, jint k, jdouble v);
void jni_setTableBoolean(JNIEnv *env, jobject jobj, jlong L, jlong table, jint k, jboolean v);
void jni_setTableString(JNIEnv *env, jobject jobj, jlong L, jlong table, jint k, jstring v);
void jni_setTableNil(JNIEnv *env, jobject jobj, jlong L, jlong table, jint k);
void jni_setTableChild(JNIEnv *env, jobject jobj, jlong L, jlong table, jint k, jobject c);
void jni_setTableChildN(JNIEnv *env, jobject jobj, jlong L, jlong table, jint k, jlong c, jint type);

void jni_setTableSNumber(JNIEnv *env, jobject jobj, jlong L, jlong table, jstring k, jdouble v);
void jni_setTableSBoolean(JNIEnv *env, jobject jobj, jlong L, jlong table, jstring k, jboolean v);
void jni_setTableSString(JNIEnv *env, jobject jobj, jlong L, jlong table, jstring k, jstring v);
void jni_setTableSNil(JNIEnv *env, jobject jobj, jlong L, jlong table, jstring k);
void jni_setTableSChild(JNIEnv *env, jobject jobj, jlong L, jlong table, jstring k, jobject c);
void jni_setTableSChildN(JNIEnv *env, jobject jobj, jlong L, jlong table, jstring k, jlong c, jint type);

void jni_setTableMethod(JNIEnv *env, jobject jobj, jlong L, jlong table, jint k, jstring clz, jstring methodName);
void jni_setTableSMethod(JNIEnv *env, jobject jobj, jlong L, jlong table, jstring k, jstring clz, jstring methodName);

jobject jni_getTableValue(JNIEnv *env, jobject jobj, jlong L, jlong table, jint k);
jobject jni_getTableSValue(JNIEnv *env, jobject jobj, jlong L, jlong table, jstring k);

jobject jni_getTableEntry(JNIEnv *env, jobject jobj, jlong L, jlong table);

jboolean jni_startTraverseTable(JNIEnv *env, jobject jobj, jlong L, jlong table);
jobjectArray jni_nextEntry(JNIEnv *env, jobject jobj, jlong L, jboolean isGlobal);
void jni_endTraverseTable(JNIEnv *env, jobject jobj, jlong L);
#endif //MMLUA4ANDROID_JTABLE_H
