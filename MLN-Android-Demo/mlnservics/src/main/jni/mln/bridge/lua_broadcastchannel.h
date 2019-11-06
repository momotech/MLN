//
//  lua_broadcastchannel.h
//  MMILuaDebugger_Example
//
//  Created by tamer on 2019/6/21.
//  Copyright © 2019 feng.xiaoning. All rights reserved.
//

#ifdef __cplusplus
#if __cplusplus
extern "C"{
#endif
#endif /* __cplusplus */
    
#ifndef lua_broadcastchannel_h
#define lua_broadcastchannel_h


#include <stdio.h>
/*=========================================================================*\
 * LuaSocket toolkit
 * Networking support for the Lua language
 * Diego Nehab
 * 9/11/1999
 \*=========================================================================*/
#include "lua.h" 

/*-------------------------------------------------------------------------*\
 * Current socket library version
 \*-------------------------------------------------------------------------*/
#define LUABROADCASTCHANNEL_VERSION    "LuaBroadcastChannel 3.0-rc1"
#define LUABROADCASTCHANNEL_COPYRIGHT  "Copyright (C) 1999-2013 Diego Nehab"

/*-------------------------------------------------------------------------*\
 * This macro prefixes all exported API functions
 \*-------------------------------------------------------------------------*/
#ifndef LUABROADCASTCHANNEL_API
#define LUABROADCASTCHANNEL_API extern
#endif

/*-------------------------------------------------------------------------*\
 * Initializes the library.
 \*-------------------------------------------------------------------------*/
LUABROADCASTCHANNEL_API int luaopen_broadcastchannel(lua_State *L);

#endif /* lua_broadcastchannel_h */

#ifdef __cplusplus
#if __cplusplus
}
#endif
#endif /* __cplusplus */
