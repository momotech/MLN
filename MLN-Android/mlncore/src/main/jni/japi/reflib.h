//
// Created by XiongFangyu on 2020/10/29.
//

#ifndef MMLUA4ANDROID_REFLIB_H
#define MMLUA4ANDROID_REFLIB_H

#include "lua.h"

/**
 * 调用方法local sobj = strong(obj)
 * 将obj放入全局表，并返回obj本身
 * obj取值: table|function|userdata
 */
#define REF_LIB_STRONG "mstrong"
/*
 * 调用方法weak(obj)
 * 将obj从全局表中移除，并执行gc
 * obj取值: table|function|userdata
 */
#define REF_LIB_WEAK "mweak"
/**
 * 为虚拟机注册ref lib
 * 在全局提供函数strong和weak
 * @see REF_LIB_STRONG
 * @see REF_LIB_WEAK
 */
int ref_open(lua_State *);

#endif //MMLUA4ANDROID_REFLIB_H
