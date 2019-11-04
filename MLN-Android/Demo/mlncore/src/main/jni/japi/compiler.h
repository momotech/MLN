//
//  compiler.h
//
//  Created by XiongFangyu on 2019/6/13.
//  Copyright © 2019 XiongFangyu. All rights reserved.
//

#ifndef _Compiler_h
#define _Compiler_h

#include "lua.h"
#include <jni.h>

/**
 * require时调用函数
 */
int searcher_java(lua_State *);
/**
 * loadlib.c createsearcherstable
 */
int searcher_Lua(lua_State *);
/**
 * require时调用
 */
int searcher_Lua_asset(lua_State *);
#endif  //_Compiler_h