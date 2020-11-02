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

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "jinfo.h"
#include "cache.h"
#include "jfunction.h"
#include "compiler.h"
#include "jbridge.h"
#include "jtable.h"
#include "juserdata.h"
#include "m_mem.h"
#ifdef ANDROID
#include "assets_reader.h"
#endif

// ------------------------------------------------------------------------------
// -------------------------------JNI METHOD ------------------------------------
// ------------------------------------------------------------------------------
void jni_setStatisticsOpen(JNIEnv *env, jobject jobj, jboolean open);
void jni_notifyStatisticsCallback(JNIEnv *env, jobject jobj);
void jni_notifyRequireCallback(JNIEnv *env, jobject jobj);
void jni_setAndroidVersion(JNIEnv *env, jobject jobj, jint v);
jboolean jni_check32bit(JNIEnv *env, jobject jobj);
jboolean jni_isSAESFile(JNIEnv *env, jobject jobj, jstring path);
jlong jni_lvmMemUse(JNIEnv * env, jobject jobj, jlong L);
void jni_setGcOffset(JNIEnv *env, jobject jobj, int offset);
void jni_setDatabasePath(JNIEnv *env, jobject jobj, jstring path);
void jni_setBasePath(JNIEnv *env, jobject jobj, jlong LS, jstring path, jboolean autosave);
void jni_setSoPath(JNIEnv *env, jobject jobj, jlong LS, jstring path);
// --------------------------L State--------------------------
jlong jni_createLState(JNIEnv *env, jobject jobj, jboolean debug);
void jni_openDebug(JNIEnv *env, jobject jobj, jlong L);
void jni_close(JNIEnv *env, jobject jobj, jlong L_state_pointer);
jobjectArray jni_dumpStack(JNIEnv *env, jobject jobj, jlong L);
jstring jni_traceback(JNIEnv *env, jobject jobj, jlong L);
void jni_lgc(JNIEnv *env, jobject jobj, jlong L);
void jni_callMethod(JNIEnv * env, jobject jobj, jlong L, jlong method, jlong arg);

static JNINativeMethod jni_methods[] = {
    {"_setAndroidVersion", "(I)V", (void *)jni_setAndroidVersion},
    {"_setStatisticsOpen", "(Z)V", (void *)jni_setStatisticsOpen},
    {"_notifyStatisticsCallback", "()V", (void *)jni_notifyStatisticsCallback},
    {"_notifyRequireCallback", "()V", (void *)jni_notifyRequireCallback},
    {"_check32bit", "()Z", (void *)jni_check32bit},
    {"_isSAESFile", "(" STRING_CLASS ")Z", (void *)jni_isSAESFile},
    {"_openSAES", "(Z)V", (void *)jni_openSAES},
    {"_lvmMemUse", "(J)J", (void *)jni_lvmMemUse},
    {"_allLvmMemUse", "()J", (void *)jni_allLvmMemUse},
    {"_logMemoryInfo", "()V", (void *)jni_logMemoryInfo},
    {"_setGcOffset", "(I)V", (void *)jni_setGcOffset},
    {"_setDatabasePath", "(" STRING_CLASS ")V", (void *)jni_setDatabasePath},
    {"_preRegisterEmptyMethods", "([" STRING_CLASS ")V", (void *)jni_preRegisterEmptyMethods},
    {"_preRegisterUD", "(" STRING_CLASS "[" STRING_CLASS ")V", (void *)jni_preRegisterUD},
    {"_preRegisterStatic", "(" STRING_CLASS "[" STRING_CLASS ")V", (void *)jni_preRegisterStatic},
#ifdef ANDROID
    {"_setAssetManager", "(Landroid/content/res/AssetManager;)V", (void *)jni_setAssetManager},
#endif

    {"_createLState", "(Z)J", (void *)jni_createLState},
    {"_openDebug", "(J)V", (void *)jni_openDebug},
    {"_setBasePath", "(J" STRING_CLASS "Z)V", (void *)jni_setBasePath},
    {"_setSoPath", "(J" STRING_CLASS ")V", (void *)jni_setSoPath},
    {"_close", "(J)V", (void *)jni_close},
    {"_dumpStack", "(J)[" LUAVALUE_CLASS, (void *)jni_dumpStack},
    {"_traceback", "(J)" STRING_CLASS, (void *)jni_traceback},
    {"_removeNativeValue", "(JJI)I", (void *)jni_removeNativeValue},
    {"_hasNativeValue", "(JJI)Z", (void *)jni_hasNativeValue},
    {"_lgc", "(J)V", (void *)jni_lgc},

    {"_loadData", "(J" STRING_CLASS "[B)I", (void *)jni_loadData},
    {"_loadFile", "(J" STRING_CLASS "" STRING_CLASS ")I", (void *)jni_loadFile},
#ifdef ANDROID
    {"_loadAssetsFile", "(J" STRING_CLASS "" STRING_CLASS ")I", (void *)jni_loadAssetsFile},
#endif
    {"_doLoadedData", "(J)I", (void *)jni_doLoadedData},
    {"_doLoadedDataAndGetResult", "(J)[" LUAVALUE_CLASS, (void *)jni_doLoadedDataAndGetResult},
    {"_startDebug", "(J[B" STRING_CLASS "I)I", (void *)jni_startDebug},
    {"_setMainEntryFromPreload", "(J" STRING_CLASS ")Z", (void *)jni_setMainEntryFromPreload},
    {"_preloadData", "(J" STRING_CLASS "[B)V", (void *)jni_preloadData},
    {"_preloadFile", "(J" STRING_CLASS "" STRING_CLASS ")V", (void *)jni_preloadFile},
    {"_preloadAssets", "(J" STRING_CLASS "" STRING_CLASS ")V", (void *)jni_preloadAssets},
    {"_preloadAssetsAndSave", "(J" STRING_CLASS "" STRING_CLASS "" STRING_CLASS ")I", (void *)jni_preloadAssetsAndSave},
    {"_require", "(J" STRING_CLASS ")I", (void *)jni_require},
    {"_dumpFunction", "(JJ" STRING_CLASS ")I", (void *)jni_dumpFunction},

    {"_createTable", "(J)J", (void *)jni_createTable},
    {"_isEmpty", "(JJ)Z", (void *)jni_isEmpty},
    {"_getTableSize", "(JJ)I", (void *)jni_getTableSize},
    {"_clearTableArray", "(JJII)V", (void *)jni_clearTableArray},
    {"_removeTableIndex", "(JJI)V", (void *)jni_removeTableIndex},
    {"_clearTable","(JJ)V", (void *)jni_clearTable},
    {"_setMetatable","(JJJ)J", (void *)jni_setMetatable},
    {"_getMetatable","(JJ)J", (void *)jni_getMetatable},

    {"_setTableNumber", "(JJID)V", (void *)jni_setTableNumber},
    {"_setTableBoolean", "(JJIZ)V", (void *)jni_setTableBoolean},
    {"_setTableString", "(JJI" STRING_CLASS ")V", (void *)jni_setTableString},
    {"_setTableNil", "(JJI)V", (void *)jni_setTableNil},
    {"_setTableChild", "(JJI" OBJECT_CLASS ")V", (void *)jni_setTableChild},
    {"_setTableChild", "(JJIJI)V", (void *)jni_setTableChildN},
    {"_setTableMethod", "(JJI" STRING_CLASS "" STRING_CLASS ")V", (void *)jni_setTableMethod},

    {"_setTableNumber", "(JJ" STRING_CLASS "D)V", (void *)jni_setTableSNumber},
    {"_setTableBoolean", "(JJ" STRING_CLASS "Z)V", (void *)jni_setTableSBoolean},
    {"_setTableString", "(JJ" STRING_CLASS "" STRING_CLASS ")V", (void *)jni_setTableSString},
    {"_setTableNil", "(JJ" STRING_CLASS ")V", (void *)jni_setTableSNil},
    {"_setTableChild", "(JJ" STRING_CLASS "" OBJECT_CLASS ")V", (void *)jni_setTableSChild},
    {"_setTableChild", "(JJ" STRING_CLASS "JI)V", (void *)jni_setTableSChildN},
    {"_setTableMethod", "(JJ" STRING_CLASS "" STRING_CLASS "" STRING_CLASS ")V", (void *)jni_setTableSMethod},

    {"_getTableValue", "(JJI)" OBJECT_CLASS, (void *)jni_getTableValue},
    {"_getTableValue", "(JJ" STRING_CLASS ")" OBJECT_CLASS, (void *)jni_getTableSValue},

    {"_getTableEntry", "(JJ)" OBJECT_CLASS, (void *)jni_getTableEntry},
    {"_startTraverseTable", "(JJ)Z", (void *)jni_startTraverseTable},
    {"_nextEntry", "(JZ)[" LUAVALUE_CLASS, (void *)jni_nextEntry},
    {"_endTraverseTable", "(J)V", (void *)jni_endTraverseTable},

    {"_invoke", "(JJ[" LUAVALUE_CLASS "I)[" LUAVALUE_CLASS, (void *)jni_invoke},
    {"_getFunctionSource", "(JJ)" STRING_CLASS, (void *)jni_getFunctionSource},
    {"_registerAllStaticClass", "(J[" STRING_CLASS "[" STRING_CLASS "[" STRING_CLASS ")V", (void *)jni_registerAllStaticClass},
    {"_registerJavaMetatable", "(J" STRING_CLASS "" STRING_CLASS ")V", (void *)jni_registerJavaMetatable},
    {"_registerAllUserdata", "(J[" STRING_CLASS "[" STRING_CLASS "[" STRING_CLASS "[Z" ")V", (void *)jni_registerAllUserdata},

    {"_registerNumberEnum", "(J" STRING_CLASS "[" STRING_CLASS "[D)V", (void *)jni_registerNumberEnum},
    {"_registerStringEnum", "(J" STRING_CLASS "[" STRING_CLASS "[" STRING_CLASS ")V", (void *)jni_registerStringEnum},
    {"_createUserdataAndSet", "(J" STRING_CLASS "" STRING_CLASS "[" LUAVALUE_CLASS ")" OBJECT_CLASS, (void *)jni_createUserdataAndSet},

    {"_callMethod", "(JJJ)V", (void *)jni_callMethod},

};
#endif //LUA_J_API_H