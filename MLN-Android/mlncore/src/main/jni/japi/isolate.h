/**
  * Created by MomoLuaNative.
  * Copyright (c) 2019, Momo Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */
//
// Created by Xiong.Fangyu 2019/06/17.
//

#ifndef ISOLATE_H
#define ISOLATE_H
#if defined(iOS_ENV)
#include "mil_lua.h"
#else
#include "lua.h"
#endif
#include <stdlib.h>

#define ISOLATE_LIB_NAME "isolate"

int isolate_open (lua_State *L);

int luaopen_isolate(lua_State *L);
#endif  //ISOLATE_H