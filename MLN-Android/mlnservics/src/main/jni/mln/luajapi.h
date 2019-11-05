/**
  * Created by MomoLuaNative.
  * Copyright (c) 2019, Momo Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */
/**
 * Created by Xiong.Fangyu 2019/02/22
 */

#ifndef LUA_J_API_H
#define LUA_J_API_H

#include "global_define.h"
#include "jlog.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "lauxlib.h"
#include "lualib.h"
#include "lobject.h"
#include "lstate.h"
#include "mlog.h"
#include "jinfo.h"
#include "cache.h"
#include "assets_reader.h"

// ------------------------------------------------------------------------------
// -------------------------------JNI METHOD ------------------------------------
// ------------------------------------------------------------------------------

void jni_setAndroidVersion(JNIEnv *env, jobject jobj, jint v);
jboolean jni_check32bit(JNIEnv *env, jobject jobj);
jboolean jni_isSAESFile(JNIEnv *env, jobject jobj, jstring path);
void jni_openSAES(JNIEnv *env, jobject jobj, jboolean open);
jlong jni_lvmMemUse(JNIEnv * env, jobject jobj, jlong L);
jlong jni_allLvmMemUse(JNIEnv *env, jobject jobj);
jlong jni_globalObjectSize(JNIEnv *env, jobject jobj);
void jni_logMemoryInfo(JNIEnv *env, jobject jobj);
void jni_setGcOffset(JNIEnv *env, jobject jobj, int offset);
void jni_setDatabasePath(JNIEnv *env, jobject jobj, jstring path);
void jni_preRegisterUD(JNIEnv *env, jobject jobj, jstring className, jobjectArray methods);
void jni_preRegisterStatic(JNIEnv *env, jobject jobj, jstring className, jobjectArray methods);
// --------------------------compile --------------------------
jint jni_compileAndSave(JNIEnv *env, jobject jobj, jlong L, jstring fn, jstring chunkname, jbyteArray data);
jint jni_compilePathAndSave(JNIEnv *env, jobject jobj, jlong L, jstring fn, jstring src, jstring chunkname);
jint jni_savePreloadData(JNIEnv *env, jobject jobj, jlong LS, jstring savePath, jstring chunkname);
jint jni_saveChunk(JNIEnv *env, jobject jobj, jlong LS, jstring path, jstring chunkname);
// --------------------------L State--------------------------
jlong jni_createLState(JNIEnv *env, jobject jobj, jboolean debug);
void jni_setBasePath(JNIEnv *env, jobject jobj, jlong LS, jstring path, jboolean autosave);
void jni_setSoPath(JNIEnv *env, jobject jobj, jlong LS, jstring path);
jint jni_registerIndex(JNIEnv *env, jobject jobj);
void jni_reset(JNIEnv *env, jobject jobj, jlong L);
void jni_close(JNIEnv *env, jobject jobj, jlong L_state_pointer);
jobjectArray jni_dumpStack(JNIEnv *env, jobject jobj, jlong L);
void jni_removeStack(JNIEnv *env, jobject jobj, jlong L, jint idx);
void jni_pop(JNIEnv *env, jobject jobj, jlong L, jint c);
jint jni_getTop(JNIEnv *env, jobject jobj, jlong L);
jint jni_removeNativeValue(JNIEnv *env, jobject job, jlong L, jlong k, jint lt);
jboolean jni_hasNativeValue(JNIEnv *env, jobject obj, jlong L, jlong key, jint lt);
void jni_lgc(JNIEnv *env, jobject jobj, jlong L);
// --------------------------load execute--------------------------
jint jni_loadData(JNIEnv *env, jobject jobj, jlong L_state_pointer, jstring name, jbyteArray data);
jint jni_loadFile(JNIEnv *env, jobject jobj, jlong L_state_pointer, jstring path, jstring chunkname);
jint jni_doLoadedData(JNIEnv *env, jobject jobj, jlong L_state_pointer);
jint jni_startDebug(JNIEnv *env, jobject jobj, jlong LS, jbyteArray data, jstring ip, jint port);
jboolean jni_setMainEntryFromPreload(JNIEnv *env, jobject jobj, jlong L, jstring name);
void jni_preloadData(JNIEnv *env, jobject jobj, jlong L, jstring name, jbyteArray data);
void jni_preloadFile(JNIEnv *env, jobject jobj, jlong L, jstring name, jstring path);
// --------------------------table--------------------------
jlong jni_createTable(JNIEnv *env, jobject jobj, jlong L);

jint jni_getTableSize(JNIEnv *env, jobject jobj, jlong L, jlong table);
void jni_clearTableArray(JNIEnv *env, jobject jobj, jlong L, jlong table, jint from, jint to);

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

jobject jni_getTableValue(JNIEnv *env, jobject jobj, jlong L, jlong table, jint k);
jobject jni_getTableSValue(JNIEnv *env, jobject jobj, jlong L, jlong table, jstring k);

jobject jni_getTableEntry(JNIEnv *env, jobject jobj, jlong L, jlong table);

jboolean jni_startTraverseTable(JNIEnv *env, jobject jobj, jlong L, jlong table);
jobjectArray jni_nextEntry(JNIEnv *env, jobject jobj, jlong L, jboolean isGlobal);
void jni_endTraverseTable(JNIEnv *env, jobject jobj, jlong L);
// --------------------------function--------------------------
jobjectArray jni_invoke(JNIEnv *env, jobject jobj, jlong L, jlong function, jobjectArray params, jint rc);

void jni_registerStaticClassSimple(JNIEnv *env, jobject jobj, jlong L, jstring jn, jstring ln, jstring lpcn);

void jni_registerJavaMetatable(JNIEnv * env, jobject jobj, jlong LS, jstring jn, jstring ln);

void jni_registerUserdata(JNIEnv *env, jobject jobj, jlong L, jstring lcn, jstring lpcn, jstring jcn);
void jni_registerAllUserdata(JNIEnv *env, jobject jobj, jlong L, jobjectArray lcns, jobjectArray lpcns, jobjectArray jcns, jbooleanArray lazy);

void jni_registerUserdataLazy(JNIEnv *env, jobject jobj, jlong L, jstring lcn, jstring lpcn, jstring jcn);

void jni_registerNumberEnum(JNIEnv *env, jobject jobj, jlong L, jstring lcn, jobjectArray keys, jdoubleArray values);
void jni_registerStringEnum(JNIEnv *env, jobject jobj, jlong L, jstring lcn, jobjectArray keys, jobjectArray values);

jobject jni_createUserdataAndSet(JNIEnv *env, jobject jobj, jlong L, jstring key, jstring lcn, jobjectArray p);
// --------------------------end--------------------------
void jni_callMethod(JNIEnv * env, jobject jobj, jlong L, jlong method, jlong arg);

static JNINativeMethod jni_methods[] = {
    {"_setAndroidVersion", "(I)V", (void *)jni_setAndroidVersion},
    {"_check32bit", "()Z", (void *)jni_check32bit},
    {"_isSAESFile", "(" STRING_CLASS ")Z", (void *)jni_isSAESFile},
    {"_openSAES", "(Z)V", (void *)jni_openSAES},
    {"_lvmMemUse", "(J)J", (void *)jni_lvmMemUse},
    {"_allLvmMemUse", "()J", (void *)jni_allLvmMemUse},
    {"_globalObjectSize", "()J", (void *)jni_globalObjectSize},
    {"_logMemoryInfo", "()V", (void *)jni_logMemoryInfo},
    {"_setGcOffset", "(I)V", (void *)jni_setGcOffset},
    {"_setDatabasePath", "(" STRING_CLASS ")V", (void *)jni_setDatabasePath},
    {"_preRegisterUD", "(" STRING_CLASS "[" STRING_CLASS ")V", (void *)jni_preRegisterUD},
    {"_preRegisterStatic", "(" STRING_CLASS "[" STRING_CLASS ")V", (void *)jni_preRegisterStatic},
    {"_setAssetManager", "(Landroid/content/res/AssetManager;)V", (void *)jni_setAssetManager},

    {"_compileAndSave", "(J" STRING_CLASS "" STRING_CLASS "[B)I", (void *)jni_compileAndSave},
    {"_compilePathAndSave", "(J" STRING_CLASS "" STRING_CLASS "" STRING_CLASS ")I", (void *)jni_compilePathAndSave},
    {"_savePreloadData", "(J" STRING_CLASS "" STRING_CLASS ")I", (void *)jni_savePreloadData},
    {"_saveChunk", "(J" STRING_CLASS "" STRING_CLASS ")I", (void *)jni_saveChunk},
    
    {"_createLState", "(Z)J", (void *)jni_createLState},
    {"_setBasePath", "(J" STRING_CLASS "Z)V", (void *)jni_setBasePath},
    {"_setSoPath", "(J" STRING_CLASS ")V", (void *)jni_setSoPath},
    {"_registerIndex", "()I", (void *)jni_registerIndex},
    {"_reset", "(J)V", (void *)jni_reset},
    {"_close", "(J)V", (void *)jni_close},
    {"_dumpStack", "(J)[" LUAVALUE_CLASS, (void *)jni_dumpStack},
    {"_removeStack", "(JI)V", (void *)jni_removeStack},
    {"_pop", "(JI)V", (void *)jni_pop},
    {"_getTop", "(J)I", (void *)jni_getTop},
    {"_removeNativeValue", "(JJI)I", (void *)jni_removeNativeValue},
    {"_hasNativeValue", "(JJI)Z", (void *)jni_hasNativeValue},
    {"_lgc", "(J)V", (void *)jni_lgc},

    {"_loadData", "(J" STRING_CLASS "[B)I", (void *)jni_loadData},
    {"_loadFile", "(J" STRING_CLASS "" STRING_CLASS ")I", (void *)jni_loadFile},
    {"_doLoadedData", "(J)I", (void *)jni_doLoadedData},
    {"_startDebug", "(J[B" STRING_CLASS "I)I", (void *)jni_startDebug},
    {"_setMainEntryFromPreload", "(J" STRING_CLASS ")Z", (void *)jni_setMainEntryFromPreload},
    {"_preloadData", "(J" STRING_CLASS "[B)V", (void *)jni_preloadData},
    {"_preloadFile", "(J" STRING_CLASS "" STRING_CLASS ")V", (void *)jni_preloadFile},

    {"_createTable", "(J)J", (void *)jni_createTable},
    {"_getTableSize", "(JJ)I", (void *)jni_getTableSize},
    {"_clearTableArray", "(JJII)V", (void *)jni_clearTableArray},

    {"_setTableNumber", "(JJID)V", (void *)jni_setTableNumber},
    {"_setTableBoolean", "(JJIZ)V", (void *)jni_setTableBoolean},
    {"_setTableString", "(JJI" STRING_CLASS ")V", (void *)jni_setTableString},
    {"_setTableNil", "(JJI)V", (void *)jni_setTableNil},
    {"_setTableChild", "(JJI" OBJECT_CLASS ")V", (void *)jni_setTableChild},
    {"_setTableChild", "(JJIJI)V", (void *)jni_setTableChildN},

    {"_setTableNumber", "(JJ" STRING_CLASS "D)V", (void *)jni_setTableSNumber},
    {"_setTableBoolean", "(JJ" STRING_CLASS "Z)V", (void *)jni_setTableSBoolean},
    {"_setTableString", "(JJ" STRING_CLASS "" STRING_CLASS ")V", (void *)jni_setTableSString},
    {"_setTableNil", "(JJ" STRING_CLASS ")V", (void *)jni_setTableSNil},
    {"_setTableChild", "(JJ" STRING_CLASS "" OBJECT_CLASS ")V", (void *)jni_setTableSChild},
    {"_setTableChild", "(JJ" STRING_CLASS "JI)V", (void *)jni_setTableSChildN},

    {"_getTableValue", "(JJI)" OBJECT_CLASS, (void *)jni_getTableValue},
    {"_getTableValue", "(JJ" STRING_CLASS ")" OBJECT_CLASS, (void *)jni_getTableSValue},

    {"_getTableEntry", "(JJ)" OBJECT_CLASS, (void *)jni_getTableEntry},
    {"_startTraverseTable", "(JJ)Z", (void *)jni_startTraverseTable},
    {"_nextEntry", "(JZ)[" LUAVALUE_CLASS, (void *)jni_nextEntry},
    {"_endTraverseTable", "(J)V", (void *)jni_endTraverseTable},

    {"_invoke", "(JJ[" LUAVALUE_CLASS "I)[" LUAVALUE_CLASS, (void *)jni_invoke},
    {"_registerStaticClassSimple", "(J" STRING_CLASS "" STRING_CLASS "" STRING_CLASS ")V", (void *)jni_registerStaticClassSimple},
    {"_registerJavaMetatable", "(J" STRING_CLASS "" STRING_CLASS ")V", (void *)jni_registerJavaMetatable},
    {"_registerUserdata", "(J" STRING_CLASS "" STRING_CLASS "" STRING_CLASS ")V", (void *)jni_registerUserdata},
    {"_registerAllUserdata", "(J[" STRING_CLASS "[" STRING_CLASS "[" STRING_CLASS "[Z" ")V", (void *)jni_registerAllUserdata},
    {"_registerUserdataLazy", "(J" STRING_CLASS "" STRING_CLASS "" STRING_CLASS ")V", (void *)jni_registerUserdataLazy},

    {"_registerNumberEnum", "(J" STRING_CLASS "[" STRING_CLASS "[D)V", (void *)jni_registerNumberEnum},
    {"_registerStringEnum", "(J" STRING_CLASS "[" STRING_CLASS "[" STRING_CLASS ")V", (void *)jni_registerStringEnum},
    {"_createUserdataAndSet", "(J" STRING_CLASS "" STRING_CLASS "[" LUAVALUE_CLASS ")" OBJECT_CLASS, (void *)jni_createUserdataAndSet},

    {"_callMethod", "(JJJ)V", (void *)jni_callMethod},

};
#endif //LUA_J_API_H