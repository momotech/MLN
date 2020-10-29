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

#ifndef JAVA_ENV
#ifdef __APPLE__
#ifndef iOS_ENV
#define iOS_ENV 1
#endif
#endif
#endif

#if defined(iOS_ENV)
#include "mil_lua.h"
#else
#include "lua.h"
#endif
#include <stdlib.h>

#define ISOLATE_LIB_NAME "isolate"

int isolate_open (lua_State *L);

int luaopen_isolate(lua_State *L);

extern void* mln_thread_sync_to_main(lua_State *L, void*(*callback)(void *));

#endif  //ISOLATE_H