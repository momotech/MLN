/**
  * Created by MomoLuaNative.
  * Copyright (c) 2019, Momo Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */
//
// Created by Xiong.Fangyu 2019/03/13.
//

#ifndef J_DEBUG_INFO_H
#define J_DEBUG_INFO_H

#if defined(J_API_INFO)
#include "lua.h"
#define LUA_TYPENAME(L, idx) lua_typename(L, lua_type(L, idx))
void _printTable(lua_State *L, int idx);    // for test
void _dumpStack(lua_State *L);              // for test
void _startTick();                          // for test
void _endTick();                            // for test
void _printTableReverse(lua_State *L, int idx, int level); // for test
/// 打印table
#define printTable(L, idx) _printTable(L, idx)
/// 会打印table中的metatable，及子table
#define printTableReverse(L, idx) _printTableReverse(L, idx, 0)
/// 打印当前栈
#define dumpStack(L) _dumpStack(L)
/// 计时开始
#define startTick() _startTick()
/// 计时结束
#define endTick()   _endTick()
#else
#define printTable(L, idx)
#define printTableReverse(L, idx)
#define dumpStack(L)
#define startTick()
#define endTick()
#endif //J_API_INFO

#endif //DEBUG_INFO_H