/**
  * Created by MomoLuaNative.
  * Copyright (c) 2019, Momo Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */
/**
 * Created by Xiong.Fangyu 2019/03/13
 */

#ifndef L_CACHE_H
#define L_CACHE_H

#include "global_define.h"
#include "map.h"
/**
 * Java调用，从GNV表中移除相关数据
 * @param k key，see copyValueToGNV
 * @param lt lua数据类型 Table, Function, Userdata, Thread
 * @return 相关对象引用计数
 */
jint jni_removeNativeValue(JNIEnv *env, jobject job, jlong L, jlong k, jint lt);
/**
 * Java调用，判断GNV表中是否又相关数据
 * @param key see copyValueToGNV
 * @param lt lua数据类型 Table, Function, Userdata, Thread
 */
jboolean jni_hasNativeValue(JNIEnv *env, jobject obj, jlong L, jlong key, jint lt);

/// GNV表，存放lua变量，防止被lua虚拟机回收
#define GNV "___Global_Native_Value"

/**
 * 初始化缓存相关工具，在创建新虚拟机后调用
 */
void init_cache(lua_State *L);
///---------------------------------------------------------------------------
///-------------------------------GNV-----------------------------------------
///---------------------------------------------------------------------------
/**
 * 获取保存在GNV表中的数据
 * @param key 键 see copyValueToGNV
 * @param ltype lua类型 Table, Function, Userdata, Thread
 */
void getValueFromGNV(lua_State *L, ptrdiff_t key, int ltype);

/**
 * 将idx位置的数据(Table, Function, Userdata, Thread)保存到GNV 表中
 * @return 表中的键
 */
ptrdiff_t copyValueToGNV(lua_State *L, int idx);

///---------------------------------------------------------------------------
///------------------------classname->jclass----------------------------------
///---------------------------------------------------------------------------
/**
 * 存储类名对应的jclass
 * @param name 类名
 * @param obj  jclass对象（global变量）
 */
void cj_put(const char *name, void *obj);

/**
 * 取出类名name 对应的jclass
 * @param name 类名
 * @return 对应的jclass(global变量)
 */
void *cj_get(const char *name);

#if defined(J_API_INFO) /// { //debug情况下，获取内存泄漏

/**
 * 打印map中内容
 */
void cj_log();

/**
 * 获取map消耗的内存
 */
size_t cj_mem_size();

#endif  /// } //J_API_INFO

///---------------------------------------------------------------------------
///------------------------jclsss->constructor--------------------------------
///---------------------------------------------------------------------------
/**
 * 存储类对应的构造函数
 */
void jc_put(jclass, jmethodID);

/**
 * 获取类对应的构造函数
 */
void *jc_get(jclass);
///---------------------------------------------------------------------------
///------------------------name->method---------------------------------------
///---------------------------------------------------------------------------
/**
 * 存储类对应的方法
 */
void jm_put(jclass, const char *, jmethodID);

/**
 * 获取类对应的方法
 */
void *jm_get(jclass, const char *);

/**
 * 遍历所有的方法，并回调给fun
 */
void jm_traverse_all_method(jclass clz, map_look_fun fun, void *ud);

#endif //L_CACHE_H