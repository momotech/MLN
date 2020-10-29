/**
  * Created by MomoLuaNative.
  * Copyright (c) 2020, Momo Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */
//
// Created by XiongFangyu on 2020/6/4.
//

#ifndef MMLUA4ANDROID_DATABINDENGINE_H
#define MMLUA4ANDROID_DATABINDENGINE_H

#include <stdlib.h>
#include "lua.h"
#include "map.h"
#include "list.h"

typedef void* (*D_malloc) (void* src, size_t os, size_t ns);
/**
 * 初始化DataBind，可初始化多次，其中会创建单例
 * @param m 内存申请释放接口
 * @return 0:成功; 1:失败
 */
int DataBindInit(D_malloc m);
/**
 * 清除和虚拟机相关的所有缓存
 */
void DB_Close(lua_State *);
/**
 * 将lua虚拟机中某个table和key绑定
 * @param L 虚拟机
 * @param key
 * @param valueIndex table在虚拟机栈中位置
 */
void DB_Bind(lua_State *L, const char *key, int valueIndex);
/**
 * 观察任何虚拟机中，key值对应的数据变化，变化后通过函数返回
 * @param L 调用的观察虚拟机
 * @param key 对应数据健值
 * @param type 类型，取值范围[0,2]，对应后续回调参数个数
 * @param functionIndex 函数在虚拟机栈中位置
 */
void DB_Watch(lua_State *L, const char *key, int type, int functionIndex);
void DB_WatchTable(lua_State *L, const char *key, int functionIndex);
/**
 * 释放对观察的key，
 * @param L 获取值的虚拟机
 * @param key 对数据健值
 */
void DB_UnWatch(lua_State *L, const char *key);
/**
 * 针对观察的key，改变其数据
 * @param L 改变值的虚拟机
 * @param key 对数据健值
 * @param valueIndex 新值在虚拟机栈中位置
 */
void DB_Update(lua_State *L, const char *key, int valueIndex);
/**
 * 针对观察的key，获取其数据
 * @param L 获取值的虚拟机
 * @param key 对数据健值
 */
void DB_Get(lua_State *L, const char *key);
/**
 * 针对观察的key，插入数据
 * @param L 插入数据的虚拟机
 * @param key 数据健值
 * @param insertindex 数据插入的位置
 * @param valueIndex 插入数据在虚拟机栈中位置
 */
void DB_Insert(lua_State *L, const char *key,int insertIndex, int valueIndex);
/**
 * 针对观察的key，删除其数据
 * @param L 删除数据的虚拟机
 * @param key 对数据健值
 * @param valueIndex 数据在虚拟机栈中位置
 */
void DB_Remove(lua_State *L, const char *key, int removeIndex);
/**
 * 针对观察的key，获取其数据长度
 * @param L 获取长度的虚拟机
 * @param key 对数据健值
 */
void DB_Len(lua_State *L, const char *key);
#endif //MMLUA4ANDROID_DATABINDENGINE_H
