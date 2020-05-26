//
//  MLNUITypeUtil.m
//  MLNUI
//
//  Created by MoMo on 2018/9/19.
//

#import "MLNUITypeUtil.h"
#import "MLNUIStaticExporterMacro.h"

@implementation MLNUITypeUtil

static int mlnui_isMap(lua_State *L)
{
    BOOL ret = NO;
    if (mln_lua_gettop(L) > 1 && lua_isuserdata(L, 2)) {
        MLNUIUserData *ud = lua_touserdata(L, 2);
        id obj = (__bridge id)(ud->object);
        ret = [obj isKindOfClass:[NSMutableDictionary class]];
    }
    lua_pushboolean(L, ret);
    return 1;
}

static int mlnui_isArray(lua_State *L)
{
    BOOL ret = NO;
    if (mln_lua_gettop(L) > 1 && lua_isuserdata(L, 2)) {
        MLNUIUserData *ud = lua_touserdata(L, 2);
        id obj = (__bridge id)(ud->object);
        ret = [obj isKindOfClass:[NSMutableArray class]];
    }
    lua_pushboolean(L, ret);
    return 1;
}

#pragma mark - Export
LUAUI_EXPORT_STATIC_BEGIN(MLNUITypeUtil)
LUAUI_EXPORT_STATIC_C_FUNC(isMap, mlnui_isMap, MLNUITypeUtil)
LUAUI_EXPORT_STATIC_C_FUNC(isArray, mlnui_isArray, MLNUITypeUtil)
LUAUI_EXPORT_STATIC_END(MLNUITypeUtil, TypeUtils, NO, NULL)

@end
