//
//  NSMutableDictionary+MLNUILua.m
//  
//
//  Created by MoMo on 2019/2/14.
//

#import "NSMutableDictionary+MLNUIMap.h"
#import "MLNUILuaCore.h"
#import "NSDictionary+MLNUISafety.h"

#define LUA_ARG_CHECK(TOP) \
if (lua_gettop(L) != (TOP)) {\
mlnui_luaui_error(L,  @"number of arguments must be %d!", (TOP));\
return 0;\
}

#define LUA_MAP_DO(...)\
MLNUIUserData *ud = (MLNUIUserData *)lua_touserdata(L, 1);\
if (ud) {\
NSMutableDictionary *map = (__bridge __unsafe_unretained NSMutableDictionary *)ud->object;\
__VA_ARGS__;\
}

#define LUA_MAP_GET_KEY(IDX)\
NSString *key = nil;\
switch (lua_type(L, (IDX))) {\
case LUA_TSTRING:{\
key = [NSString stringWithUTF8String:lua_tostring(L, IDX)];\
break;\
}\
default: {\
mlnui_luaui_error(L,  @"The key must be a string!");\
lua_pushvalue(L, 1);\
return 1;\
}\
}

#define isNeedMutableCopyForMap(MAP) [(MAP) isKindOfClass:[NSDictionary class]] && !isMutableDictionary((MAP))

@implementation NSMutableDictionary (MLNUIMap)

#pragma mark - Export To Lua
static int luaui_newMap(lua_State *L) {
    switch (lua_gettop(L)) {
        case 0: {
            NSMutableDictionary *map = [NSMutableDictionary dictionary];
            map.mlnui_isLuaObject = YES;
            [MLNUI_LUA_CORE(L) pushNativeObject:map error:nil];
            return 1;
        }
        case 1: {
            if (lua_isnumber(L, -1)) {
                double capacity = lua_tonumber(L, -1);
                NSMutableDictionary *map = [NSMutableDictionary dictionaryWithCapacity:capacity];
                map.mlnui_isLuaObject = YES;
                [MLNUI_LUA_CORE(L) pushNativeObject:map error:nil];
                return 1;
            }
            mlnui_luaui_error(L, @"error type of argument, capacity must be number");
            break;
        }
        default: {
            mlnui_luaui_error(L, @"number of argument more than 1");
            break;
        }
    }
    return 0;
}

static int luaui_map_objectForKey(lua_State *L) {
    LUA_ARG_CHECK(2);
    LUA_MAP_DO(if (lua_isstring(L, 2)) {
        NSString *key = [NSString stringWithUTF8String:lua_tostring(L, 2)];
        id value = [map mlnui_objectForKey:key];
        switch ([value mlnui_nativeType]) {
            case MLNUINativeTypeDictionary: {
                value = [NSMutableDictionary dictionaryWithDictionary:value];
                [map mlnui_setObject:value forKey:key];
                break;
            }
            case MLNUINativeTypeArray: {
                value = [NSMutableArray arrayWithArray:value];
                [map mlnui_setObject:value forKey:key];
                break;
            }
            default:
                break;
        }
        [MLNUI_LUA_CORE(L) pushNativeObject:value error:NULL];
        return 1;
    } else {
        mlnui_luaui_error(L,  @"The key must be a string!");
        mln_lua_pushnil(L);
        return 1;
    })
    return 0;
}

static int luaui_map_setObjectForKey(lua_State *L) {
    LUA_ARG_CHECK(3);
    LUA_MAP_DO(LUA_MAP_GET_KEY(2);
               id value = [MLNUI_LUA_CORE(L) toNativeObject:3 error:NULL];
               switch ([value mlnui_nativeType]) {
                   case MLNUINativeTypeDictionary:
                   {
                       value = [NSMutableDictionary dictionaryWithDictionary:value];
                       [map mlnui_setObject:value forKey:key];
                       break;
                   }
                   case MLNUINativeTypeArray: {
                       value = [NSMutableArray arrayWithArray:value];
                       [map mlnui_setObject:value forKey:key];
                       break;
                   }
                   case MLNUINativeTypeNumber:
                   case MLNUINativeTypeString:
                   case MLNUINativeTypeMDictionary:
                   case MLNUINativeTypeMArray: {
                       [map mlnui_setObject:value forKey:key];
                       break;
                   }
                   default: {
                       mlnui_luaui_error(L,  @"The value type must be one of types, as string, number, map or array!");
                       break;
                   }
               }
               lua_pushvalue(L, 1);
               return 1;)
    return 0;
}

static int luaui_map_addEntriesFromDictionary(lua_State *L) {
    LUA_ARG_CHECK(2);
    LUA_MAP_DO(NSMutableDictionary *dictionary = [MLNUI_LUA_CORE(L) toNativeObject:2 error:NULL];
               switch ([dictionary mlnui_nativeType]) {
                   case MLNUINativeTypeDictionary: {
                       dictionary = [NSMutableDictionary dictionaryWithDictionary:dictionary];
                   }
                   case MLNUINativeTypeMDictionary: {
                       [map mlnui_addEntriesFromDictionary:dictionary];
                       break;
                   }
                   default: {
                       mlnui_luaui_error(L,  @"The argument must be a array!");
                       break;
                   }
               }
               lua_pushvalue(L, 1);
               return 1;)
    return 0;
}

static int luaui_map_removeObjectForKey(lua_State *L) {
    LUA_ARG_CHECK(2);
    LUA_MAP_DO(LUA_MAP_GET_KEY(2);
               [map mlnui_removeObjectForKey:key];
               lua_pushvalue(L, 1);
               return 1;)
    return 0;
}

static int luaui_map_removeObjects(lua_State *L) {
    LUA_ARG_CHECK(2);
    LUA_MAP_DO(NSMutableArray *array = [MLNUI_LUA_CORE(L) toNativeObject:2 error:NULL];
               switch ([array mlnui_nativeType]) {
                   case MLNUINativeTypeArray:
                   case MLNUINativeTypeMArray: {
                       [map mlnui_removeObjectsForKeys:array];
                       break;
                   }
                   default: {
                       mlnui_luaui_error(L,  @"The argument must be an array");
                       break;
                   }
               }
               lua_pushvalue(L, 1);
               return 1;)
    return 0;
}

static int luaui_map_removeAllObjects(lua_State *L) {
    LUA_ARG_CHECK(1);
    LUA_MAP_DO([map removeAllObjects];
               lua_pushvalue(L, 1);
               return 1;)
    return 0;
}

static int luaui_map_allKeys(lua_State *L) {
    LUA_ARG_CHECK(1);
    LUA_MAP_DO([MLNUI_LUA_CORE(L) pushNativeObject:[NSMutableArray arrayWithArray:[map allKeys]] error:NULL];
               return 1;)
    return 0;
}

static int luaui_map_count(lua_State *L) {
    LUA_ARG_CHECK(1);
    LUA_MAP_DO(lua_pushnumber(L, map.count);
               return 1;)
    return 0;
}

#pragma mark - Export To Lua
LUAUI_EXPORT_BEGIN(NSMutableDictionary)
LUAUI_EXPORT_METHOD_WITH_CFUNC(put, luaui_map_setObjectForKey, NSMutableDictionary)
LUAUI_EXPORT_METHOD_WITH_CFUNC(putAll, luaui_map_addEntriesFromDictionary, NSMutableDictionary)
LUAUI_EXPORT_METHOD_WITH_CFUNC(putMap, luaui_map_addEntriesFromDictionary, NSMutableDictionary)
LUAUI_EXPORT_METHOD_WITH_CFUNC(remove, luaui_map_removeObjectForKey, NSMutableDictionary)
LUAUI_EXPORT_METHOD_WITH_CFUNC(removeAll, luaui_map_removeAllObjects, NSMutableDictionary)
LUAUI_EXPORT_METHOD_WITH_CFUNC(removeObjects, luaui_map_removeObjects, NSMutableDictionary)
LUAUI_EXPORT_METHOD_WITH_CFUNC(allKeys, luaui_map_allKeys, NSMutableDictionary)
LUAUI_EXPORT_METHOD_WITH_CFUNC(get, luaui_map_objectForKey, NSMutableDictionary)
LUAUI_EXPORT_METHOD_WITH_CFUNC(size, luaui_map_count, NSMutableDictionary)
LUAUI_EXPORT_END_WITH_CFUNC(NSMutableDictionary, Map, NO, NULL, luaui_newMap)

@end
