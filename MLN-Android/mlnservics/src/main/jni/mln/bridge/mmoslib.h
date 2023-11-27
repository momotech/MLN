/**
  * Created by MomoLuaNative.
  * Copyright (c) 2019, Momo Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */
//
// Created by XiongFangyu on 2019-08-14.
//

#ifndef MMLUA4ANDROID_MM_UTILS_H
#define MMLUA4ANDROID_MM_UTILS_H

#ifdef JAVA_ENV
#include "lua.h"
#else
#include "mil_lua.h"
#endif

LUALIB_API int luaopen_mmos (lua_State *L);


#endif //MMLUA4ANDROID_MM_UTILS_H