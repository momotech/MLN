//
//  MLNTypeUtil.m
//  MLN
//
//  Created by MoMo on 2018/9/19.
//

#import "MLNTypeUtil.h"
#import "MLNStaticExporterMacro.h"

@implementation MLNTypeUtil

static int mln_isMap(lua_State *L)
{
    BOOL ret = NO;
    if (mln_lua_gettop(L) > 1 && lua_isuserdata(L, 2)) {
        MLNUserData *ud = lua_touserdata(L, 2);
        id obj = (__bridge id)(ud->object);
        ret = [obj isKindOfClass:[NSMutableDictionary class]];
    }
    lua_pushboolean(L, ret);
    return 1;
}

static int mln_isArray(lua_State *L)
{
    BOOL ret = NO;
    if (mln_lua_gettop(L) > 1 && lua_isuserdata(L, 2)) {
        MLNUserData *ud = lua_touserdata(L, 2);
        id obj = (__bridge id)(ud->object);
        ret = [obj isKindOfClass:[NSMutableArray class]];
    }
    lua_pushboolean(L, ret);
    return 1;
}

#pragma mark - Export
LUA_EXPORT_STATIC_BEGIN(MLNTypeUtil)
LUA_EXPORT_STATIC_C_FUNC(isMap, mln_isMap, MLNTypeUtil)
LUA_EXPORT_STATIC_C_FUNC(isArray, mln_isArray, MLNTypeUtil)
LUA_EXPORT_STATIC_END(MLNTypeUtil, TypeUtils, NO, NULL)

@end
