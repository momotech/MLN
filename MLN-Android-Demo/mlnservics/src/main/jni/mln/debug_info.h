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
#define printTable(L, idx) _printTable(L, idx)
#define dumpStack(L) _dumpStack(L)
#define startTick() _startTick()
#define endTick()   _endTick()
#else
#define printTable(L, idx)
#define dumpStack(L)
#define startTick()
#define endTick()
#endif

#endif //DEBUG_INFO_H