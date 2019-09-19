//
//  NSMutableDictionary+MLNLua.m
//  
//
//  Created by MoMo on 2019/2/14.
//

#import "NSMutableDictionary+MLNMap.h"
#import "MLNLuaCore.h"
#import "NSDictionary+MLNSafety.h"

#define LUA_ARG_CHECK(TOP) \
if (lua_gettop(L) != (TOP)) {\
mln_lua_error(L, "number of argments must be %d!", (TOP));\
return 0;\
}

#define LUA_MAP_DO(...)\
MLNUserData *ud = (MLNUserData *)lua_touserdata(L, 1);\
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
mln_lua_error(L, "The key must be a string!");\
lua_pushvalue(L, 1);\
return 1;\
}\
}

#define isNeedMutableCopyForMap(MAP) [(MAP) isKindOfClass:[NSDictionary class]] && !isMutableDictionary((MAP))

@implementation NSMutableDictionary (MLNMap)

#pragma mark - Export To Lua
static int lua_newMap(lua_State *L) {
    switch (lua_gettop(L)) {
        case 0: {
            NSMutableDictionary *map = [NSMutableDictionary dictionary];
            map.mln_isLuaObject = YES;
            [MLN_LUA_CORE(L) pushNativeObject:map error:nil];
            return 1;
        }
        case 1: {
            if (lua_isnumber(L, -1)) {
                double capacity = lua_tonumber(L, -1);
                NSMutableDictionary *map = [NSMutableDictionary dictionaryWithCapacity:capacity];
                map.mln_isLuaObject = YES;
                [MLN_LUA_CORE(L) pushNativeObject:map error:nil];
                return 1;
            }
            mln_lua_error(L, "error type of argment, capacity must be number");
            break;
        }
        default:
            mln_lua_error(L, "number of argment more than 1");
            break;
    }
    return 0;
}

static int lua_map_objectForKey(lua_State *L) {
    LUA_ARG_CHECK(2);
    LUA_MAP_DO(if (lua_isstring(L, 2)) {
        NSString *key = [NSString stringWithUTF8String:lua_tostring(L, 2)];
        id value = [map mln_objectForKey:key];
        switch ([value mln_nativeType]) {
            case MLNNativeTypeDictionary: {
                value = [NSMutableDictionary dictionaryWithDictionary:value];
                [map mln_setObject:value forKey:key];
                break;
            }
            case MLNNativeTypeArray: {
                value = [NSMutableArray arrayWithArray:value];
                [map mln_setObject:value forKey:key];
                break;
            }
            default:
                break;
        }
        [MLN_LUA_CORE(L) pushNativeObject:value error:NULL];
        return 1;
    } else {
        mln_lua_error(L, "The key must be a string!");
        mln_lua_pushnil(L);
        return 1;
    })
    return 0;
}

static int lua_map_setObjectForKey(lua_State *L) {
    LUA_ARG_CHECK(3);
    LUA_MAP_DO(LUA_MAP_GET_KEY(2);
               id value = [MLN_LUA_CORE(L) toNativeObject:3 error:NULL];
               switch ([value mln_nativeType]) {
                   case MLNNativeTypeDictionary:
                   {
                       value = [NSMutableDictionary dictionaryWithDictionary:value];
                       [map mln_setObject:value forKey:key];
                       break;
                   }
                   case MLNNativeTypeArray: {
                       value = [NSMutableArray arrayWithArray:value];
                       [map mln_setObject:value forKey:key];
                       break;
                   }
                   case MLNNativeTypeNumber:
                   case MLNNativeTypeString:
                   case MLNNativeTypeMDictionary:
                   case MLNNativeTypeMArray: {
                       [map mln_setObject:value forKey:key];
                       break;
                   }
                   default: {
                       mln_lua_error(L, "The value type must be one of types, as string, number, map or array!");
                       break;
                   }
               }
               lua_pushvalue(L, 1);
               return 1;)
    return 0;
}

static int lua_map_addEntriesFromDictionary(lua_State *L) {
    LUA_ARG_CHECK(2);
    LUA_MAP_DO(NSMutableDictionary *dictionary = [MLN_LUA_CORE(L) toNativeObject:2 error:NULL];
               switch ([dictionary mln_nativeType]) {
                   case MLNNativeTypeDictionary: {
                       dictionary = [NSMutableDictionary dictionaryWithDictionary:dictionary];
                   }
                   case MLNNativeTypeMDictionary: {
                       [map mln_addEntriesFromDictionary:dictionary];
                       break;
                   }
                   default: {
                       mln_lua_error(L, "The argment must be a array!");
                       break;
                   }
               }
               lua_pushvalue(L, 1);
               return 1;)
    return 0;
}

static int lua_map_removeObjectForKey(lua_State *L) {
    LUA_ARG_CHECK(2);
    LUA_MAP_DO(LUA_MAP_GET_KEY(2);
               [map mln_removeObjectForKey:key];
               lua_pushvalue(L, 1);
               return 1;)
    return 0;
}

static int lua_map_removeObjects(lua_State *L) {
    LUA_ARG_CHECK(2);
    LUA_MAP_DO(NSMutableArray *array = [MLN_LUA_CORE(L) toNativeObject:2 error:NULL];
               switch ([array mln_nativeType]) {
                   case MLNNativeTypeArray:
                   case MLNNativeTypeMArray: {
                       [map mln_removeObjectsForKeys:array];
                       break;
                   }
                   default: {
                       mln_lua_error(L, "The argument must be an array");
                       break;
                   }
               }
               lua_pushvalue(L, 1);
               return 1;)
    return 0;
}

static int lua_map_removeAllObjects(lua_State *L) {
    LUA_ARG_CHECK(1);
    LUA_MAP_DO([map removeAllObjects];
               lua_pushvalue(L, 1);
               return 1;)
    return 0;
}

static int lua_map_allKeys(lua_State *L) {
    LUA_ARG_CHECK(1);
    LUA_MAP_DO([MLN_LUA_CORE(L) pushNativeObject:[NSMutableArray arrayWithArray:[map allKeys]] error:NULL];
               return 1;)
    return 0;
}

static int lua_map_count(lua_State *L) {
    LUA_ARG_CHECK(1);
    LUA_MAP_DO(lua_pushnumber(L, map.count);
               return 1;)
    return 0;
}

#pragma mark - Export To Lua
LUA_EXPORT_BEGIN(NSMutableDictionary)
LUA_EXPORT_METHOD_WITH_CFUNC(put, lua_map_setObjectForKey, NSMutableDictionary)
LUA_EXPORT_METHOD_WITH_CFUNC(putAll, lua_map_addEntriesFromDictionary, NSMutableDictionary)
LUA_EXPORT_METHOD_WITH_CFUNC(putMap, lua_map_addEntriesFromDictionary, NSMutableDictionary)
LUA_EXPORT_METHOD_WITH_CFUNC(remove, lua_map_removeObjectForKey, NSMutableDictionary)
LUA_EXPORT_METHOD_WITH_CFUNC(removeAll, lua_map_removeAllObjects, NSMutableDictionary)
LUA_EXPORT_METHOD_WITH_CFUNC(removeObjects, lua_map_removeObjects, NSMutableDictionary)
LUA_EXPORT_METHOD_WITH_CFUNC(allKeys, lua_map_allKeys, NSMutableDictionary)
LUA_EXPORT_METHOD_WITH_CFUNC(get, lua_map_objectForKey, NSMutableDictionary)
LUA_EXPORT_METHOD_WITH_CFUNC(size, lua_map_count, NSMutableDictionary)
LUA_EXPORT_END_WITH_CFUNC(NSMutableDictionary, Map, NO, NULL, lua_newMap)

@end
