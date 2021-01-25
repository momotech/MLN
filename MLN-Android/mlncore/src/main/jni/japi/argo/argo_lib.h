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

#ifndef MMLUA4ANDROID_ARGO_LIB_H
#define MMLUA4ANDROID_ARGO_LIB_H

#include "lua.h"
/**
 * 为lua虚拟机注册Argo库
 * 将argo table返回到栈顶
 */
int argo_open(lua_State *L);
/**
 * 为lua虚拟机注册Argo库
 * 将argo库注册到preload表中，需要require才能使用
 */
void argo_preload(lua_State *L);
/**
 * 虚拟机销毁时需要做的清理工作
 */
void argo_close(lua_State *L);

#endif //MMLUA4ANDROID_ARGO_LIB_H
