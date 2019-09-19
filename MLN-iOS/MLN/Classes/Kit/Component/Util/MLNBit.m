//
//  MMLuaBit.m
//  MomoChat
//
//  Created by MoMo on 03/05/2018.
//  Copyright © 2018 wemomo.com. All rights reserved.
//

#import "MLNBit.h"
#import "MLNStaticExporterMacro.h"

@implementation MLNBit

// 按位或
static int lua_bor(lua_State *L) {
    int argCount = lua_gettop(L);
    if (argCount < 3) {
        mln_lua_error(L, "Must use ':' to call this method！\n The number of parameter must be greater than 2!");
        return 0;
    }
    NSInteger ret = lua_tonumber(L, 2);
    for (int i = 3; i <= argCount; i++) {
        ret = ret | (NSInteger)lua_tonumber(L, i);
    }
    mln_lua_pushnumber(L, ret);
    return 1;
}

// 按位与
static int lua_band(lua_State *L) {
    int argCount = lua_gettop(L);
    if (argCount < 3) {
        mln_lua_error(L, "Must use ':' to call this method！\n The number of parameter must be greater than 2!");
        return 0;
    }
    NSInteger ret = lua_tonumber(L, 2);
    for (int i = 3; i <= argCount; i++) {
        ret = ret & (NSInteger)lua_tonumber(L, i);
    }
    mln_lua_pushnumber(L, ret);
    return 1;
}

// 按位异或
static int lua_bxor(lua_State *L) {
    int argCount = lua_gettop(L);
    if (argCount < 3) {
        mln_lua_error(L, "Must use ':' to call this method！\n The number of parameter must be greater than 2!");
        return 0;
    }
    NSInteger ret = lua_tonumber(L, 2);
    for (int i = 3; i <= argCount; i++) {
        ret = ret ^ (NSInteger)lua_tonumber(L, i);
    }
    mln_lua_pushnumber(L, ret);
    return 1;
}

// 按位非
+ (NSInteger)lua_neg:(NSInteger)a
{
    return (~a);
}

// 左移
+ (NSInteger)lua_shl:(NSInteger)a bit:(NSInteger)bit
{
    return (a << bit);
}

// 右移
+ (NSInteger)lua_shr:(NSInteger)a bit:(NSInteger)bit
{
    return (a >> bit);
}

#pragma mark - Export To Lua
LUA_EXPORT_STATIC_BEGIN(MLNBit)
LUA_EXPORT_STATIC_C_FUNC(bor, lua_bor, MLNBit)
LUA_EXPORT_STATIC_C_FUNC(band, lua_band, MLNBit)
LUA_EXPORT_STATIC_C_FUNC(bxor, lua_bxor, MLNBit)
LUA_EXPORT_STATIC_METHOD(neg, "lua_neg:", MLNBit)
LUA_EXPORT_STATIC_METHOD(shl, "lua_shl:bit:", MLNBit)
LUA_EXPORT_STATIC_METHOD(shr, "lua_shr:bit:", MLNBit)
LUA_EXPORT_STATIC_END(MLNBit, MBit, NO, NULL)

@end
