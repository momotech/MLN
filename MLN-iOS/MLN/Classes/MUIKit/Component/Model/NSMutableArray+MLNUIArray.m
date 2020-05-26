//
//  NSMutableArray+MLNUILua.m
//  
//
//  Created by MoMo on 2019/2/14.
//

#import "NSMutableArray+MLNUIArray.h"
#import "MLNUILuaCore.h"
#import "NSArray+MLNUISafety.h"

#define luaui_CheckIndexZero(INDEX)\
if ((INDEX) < 0) {\
    mlnui_luaui_error(L, @"The number of index must be greater than 0!");\
    return 0;\
}

@implementation NSMutableArray (MLNUIArray)

static MLNUI_FORCE_INLINE BOOL __mlnui_luaui_in_checkParams(lua_State *L, int countOfParams) {
    if (lua_gettop(L) != countOfParams + 1) {
        if (lua_isuserdata(L, 1)) {
            MLNUIUserData *ud = (MLNUIUserData *)lua_touserdata(L, 1);
            if (ud) {
                id array = (__bridge __unsafe_unretained id )ud->object;
                if ([array mlnui_nativeType] != MLNUINativeTypeMArray) {
                    mlnui_luaui_error(L, @"Must use ':' to call this method！\n number of arguments must be %d!", countOfParams);
                    return NO;
                }
            }
        }
        mlnui_luaui_error(L, @"number of arguments must be %d!", countOfParams);
        return NO;
    }
    return YES;
}

#pragma mark - Export To Lua
static int luaui_newArray(lua_State *L) {
    switch (lua_gettop(L)) {
        case 0: {
            NSMutableArray *array = [NSMutableArray array];
            array.mlnui_isLuaObject = YES;
            [MLNUI_LUA_CORE(L) pushNativeObject:array error:nil];
            return 1;
        }
        case 1: {
            if (lua_isnumber(L, -1)) {
                double capacity = lua_tonumber(L, -1);
                NSMutableArray *array = [NSMutableArray arrayWithCapacity:capacity];
                array.mlnui_isLuaObject = YES;
                [MLNUI_LUA_CORE(L) pushNativeObject:array error:nil];
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

static int luaui_array_addObject(lua_State *L) {
    if (!__mlnui_luaui_in_checkParams(L, 1)) {
        return 0;
    }
    MLNUIUserData *ud = (MLNUIUserData *)lua_touserdata(L, 1);
    if (ud) {
        NSMutableArray *array = (__bridge __unsafe_unretained NSMutableArray *)ud->object;
        id obj = [MLNUI_LUA_CORE(L) toNativeObject:2 error:nil];
        switch ([obj mlnui_nativeType]) {
            case MLNUINativeTypeDictionary:
            {
                obj = [NSMutableDictionary dictionaryWithDictionary:obj];
                break;
            }
            case MLNUINativeTypeArray: {
                obj = [NSMutableArray arrayWithArray:obj];
                break;
            }
            case MLNUINativeTypeNumber:
            case MLNUINativeTypeString:
            case MLNUINativeTypeMDictionary:
            case MLNUINativeTypeMArray:
                break;
            default: {
                mlnui_luaui_error(L, @"The value type must be one of types, as string, number, map or array!");
                break;
            }
        }
        if (obj) {
            [array addObject:obj];
        }
        lua_pushvalue(L, 1);
        return 1;
    }
    return 0;
}

static int luaui_array_addObjectsFromArray(lua_State *L) {
    if (!__mlnui_luaui_in_checkParams(L, 1)) {
        return 0;
    }
    MLNUIUserData *ud = (MLNUIUserData *)lua_touserdata(L, 1);
    if (ud) {
        NSMutableArray *array = (__bridge __unsafe_unretained NSMutableArray *)ud->object;
        NSMutableArray *obj = [MLNUI_LUA_CORE(L) toNativeObject:2 error:nil];
        switch ([obj mlnui_nativeType]) {
            case MLNUINativeTypeArray: {
                obj = [NSMutableArray arrayWithArray:obj];
            }
            case MLNUINativeTypeMArray: {
                [array mlnui_addObjectsFromArray:obj];
                break;
            }
            default: {
                mlnui_luaui_error(L, @"The argument must be a array!");
                break;
            }
        }
        lua_pushvalue(L, 1);
        return 1;
    }
    return 0;
}

static int luaui_array_removeObjectAtIndex(lua_State *L) {
    if (!__mlnui_luaui_in_checkParams(L, 1)) {
        return 0;
    }
    MLNUIUserData *ud = (MLNUIUserData *)lua_touserdata(L, 1);
    if (ud) {
        NSMutableArray *array = (__bridge __unsafe_unretained NSMutableArray *)ud->object;
        NSInteger realIndex = lua_tonumber(L, 2) -1;
        luaui_CheckIndexZero(realIndex);
        mlnui_luaui_assert(L, (realIndex < array.count), @"The index out of range!");
        if (realIndex < array.count) {
            [array removeObjectAtIndex:realIndex];
        }
        lua_pushvalue(L, 1);
        return 1;
    }
    return 0;
}

static int luaui_array_removeObject(lua_State *L) {
    if (!__mlnui_luaui_in_checkParams(L, 1)) {
        return 0;
    }
    MLNUIUserData *ud = (MLNUIUserData *)lua_touserdata(L, 1);
    if (ud) {
        NSMutableArray *array = (__bridge __unsafe_unretained NSMutableArray *)ud->object;
        id obj = [MLNUI_LUA_CORE(L) toNativeObject:2 error:nil];
        mlnui_luaui_assert(L, obj, @"The argument must not be nil!");
        if (obj) {
            [array removeObject:obj];
        }
        lua_pushvalue(L, 1);
        return 1;
    }
    return 0;
}

static int luaui_array_removeObjects(lua_State *L) {
    if (!__mlnui_luaui_in_checkParams(L, 1)) {
        return 0;
    }
    MLNUIUserData *ud = (MLNUIUserData *)lua_touserdata(L, 1);
    if (ud) {
        NSMutableArray *array = (__bridge __unsafe_unretained NSMutableArray *)ud->object;
        id objs = [MLNUI_LUA_CORE(L) toNativeObject:2 error:nil];
        mlnui_luaui_assert(L, objs, @"The argument must not be nil!");
        if (objs && [objs isKindOfClass:[NSArray class]]) {
            [array removeObjectsInArray:objs];
        }
        lua_pushvalue(L, 1);
        return 1;
    }
    return 0;
}

static int luaui_array_removeObjectsAtRange(lua_State *L) {
    if (!__mlnui_luaui_in_checkParams(L, 2)) {
        return 0;
    }
    MLNUIUserData *ud = (MLNUIUserData *)lua_touserdata(L, 1);
    if (ud) {
        NSMutableArray *array = (__bridge __unsafe_unretained NSMutableArray *)ud->object;
        NSInteger realFrom = lua_tonumber(L, 2) - 1;
        luaui_CheckIndexZero(realFrom);
        NSInteger realTo = lua_tonumber(L, 3) - 1;
        luaui_CheckIndexZero(realTo);
        
        mlnui_luaui_assert(L, array.count > realTo && realTo >= realFrom && realFrom >=0, @"The index out of range!");
        if (array.count > realTo && realTo >= realFrom && realFrom >=0) {
            [array mlnui_removeObjectsFromIndex:realFrom toIndex:realTo];
        }
        lua_pushvalue(L,1);
        return 1;
    }
    return 0;
}

static int luaui_array_removeAllObjects(lua_State *L) {
    if (!__mlnui_luaui_in_checkParams(L, 0)) {
        return 0;
    }
    MLNUIUserData *ud = (MLNUIUserData *)lua_touserdata(L, 1);
    if (ud) {
        NSMutableArray *array = (__bridge __unsafe_unretained NSMutableArray *)ud->object;
        [array removeAllObjects];
        lua_pushvalue(L,1);
        return 1;
    }
    return 0;
}

static int luaui_array_objectAtIndex(lua_State *L) {
    if (!__mlnui_luaui_in_checkParams(L, 1)) {
        return 0;
    }
    MLNUIUserData *ud = (MLNUIUserData *)lua_touserdata(L, 1);
    if (ud) {
        NSMutableArray *array = (__bridge __unsafe_unretained NSMutableArray *)ud->object;
        NSInteger realIndex = lua_tonumber(L, 2) -1;
        luaui_CheckIndexZero(realIndex);
        mlnui_luaui_assert(L, (realIndex < array.count), @"The index out of range!");
        id value = nil;
        if (realIndex < array.count) {
            value = [array objectAtIndex:realIndex];
        }
        switch ([value mlnui_nativeType]) {
            case MLNUINativeTypeDictionary: {
                value = [NSMutableDictionary dictionaryWithDictionary:value];
                [array mlnui_replaceObjectAtIndex:realIndex withObject:value];
                break;
            }
            case MLNUINativeTypeArray: {
                value = [NSMutableArray arrayWithArray:value];
                [array mlnui_replaceObjectAtIndex:realIndex withObject:value];
                break;
            }
            default:
                break;
        }
        [MLNUI_LUA_CORE(L) pushNativeObject:value error:nil];
        return 1;
    }
    return 0;
}

static int luaui_array_size(lua_State *L) {
    if (!__mlnui_luaui_in_checkParams(L, 0)) {
        return 0;
    }
    MLNUIUserData *ud = (MLNUIUserData *)lua_touserdata(L, 1);
    if (ud) {
        NSMutableArray *array = (__bridge __unsafe_unretained NSMutableArray *)ud->object;
        lua_pushnumber(L, array.count);
        return 1;
    }
    return 0;
}

static int luaui_array_contains(lua_State *L) {
    if (!__mlnui_luaui_in_checkParams(L, 1)) {
        return 0;
    }
    MLNUIUserData *ud = (MLNUIUserData *)lua_touserdata(L, 1);
    if (ud) {
        NSMutableArray *array = (__bridge __unsafe_unretained NSMutableArray *)ud->object;
        id value = [MLNUI_LUA_CORE(L) toNativeObject:2 error:nil];;
        BOOL isContains = [array containsObject:value];
        lua_pushboolean(L, isContains);
        return 1;
    }
    return 0;
}

static int luaui_array_insertObject(lua_State *L) {
    if (!__mlnui_luaui_in_checkParams(L, 2)) {
        return 0;
    }
    MLNUIUserData *ud = (MLNUIUserData *)lua_touserdata(L, 1);
    if (ud) {
        NSMutableArray *array = (__bridge __unsafe_unretained NSMutableArray *)ud->object;
        NSInteger realIndex = lua_tonumber(L, 2) -1;
        luaui_CheckIndexZero(realIndex);
        id obj = [MLNUI_LUA_CORE(L) toNativeObject:3 error:nil];;
        switch ([obj mlnui_nativeType]) {
            case MLNUINativeTypeDictionary: {
                obj = [NSMutableDictionary dictionaryWithDictionary:obj];
                break;
            }
            case MLNUINativeTypeArray: {
                obj = [NSMutableArray arrayWithArray:obj];
                break;
            }
            case MLNUINativeTypeNumber:
            case MLNUINativeTypeString:
            case MLNUINativeTypeMDictionary:
            case MLNUINativeTypeMArray:
                break;
            default: {
                mlnui_luaui_error(L, @"The value type must be one of types, as string, number, map or array!");
                break;
            }
        }
        mlnui_luaui_assert(L, (obj && (realIndex <= array.count)), @"The index out of range!");
        if ((obj && (realIndex <= array.count))) {
            [array insertObject:obj atIndex:realIndex];
        }
        lua_pushvalue(L, 1);
        return 1;
    }
    return 0;
}

static int luaui_array_insertObjects(lua_State *L) {
    // 参数校验
    if (!__mlnui_luaui_in_checkParams(L, 2)) {
        return 0;
    }
    // index 为零校验
    NSInteger fromIndex = lua_tonumber(L, 2) - 1;
    if (fromIndex < 0) {
        mlnui_luaui_error(L, @"The number of index must be greater than 0!");
        return 0;
    }
    MLNUIUserData *ud = (MLNUIUserData *)lua_touserdata(L, 1);
    if (ud) {
        NSMutableArray *array = (__bridge __unsafe_unretained NSMutableArray *)ud->object;
        NSUInteger count = array.count;
        // index 越界检查
        if (fromIndex > count) {
            mlnui_luaui_error(L, @"The number of index [%ld] out of array count [%lu]!", fromIndex + 1, (unsigned long)count);
            return 0;
        }
        NSArray *items = [MLNUI_LUA_CORE(L) toNativeObject:3 error:nil];
        if (!(items && items.count > 0)) {
            mlnui_luaui_error(L, @"The array must not be empty!");
            return 0;
        }
        [array mlnui_insertObjects:items fromIndex:fromIndex];
        lua_pushvalue(L,1);
        return 1;
    }
    return 0;
}

static int luaui_array_replaceObject(lua_State *L) {
    if (!__mlnui_luaui_in_checkParams(L, 2)) {
        return 0;
    }
    MLNUIUserData *ud = (MLNUIUserData *)lua_touserdata(L, 1);
    if (ud) {
        NSMutableArray *array = (__bridge __unsafe_unretained NSMutableArray *)ud->object;
        NSInteger realIndex = lua_tonumber(L, 2) -1;
        luaui_CheckIndexZero(realIndex);
        id obj =[MLNUI_LUA_CORE(L) toNativeObject:3 error:nil];
        switch ([obj mlnui_nativeType]) {
            case MLNUINativeTypeDictionary: {
                obj = [NSMutableDictionary dictionaryWithDictionary:obj];
                break;
            }
            case MLNUINativeTypeArray: {
                obj = [NSMutableArray arrayWithArray:obj];
                break;
            }
            case MLNUINativeTypeNumber:
            case MLNUINativeTypeString:
            case MLNUINativeTypeMDictionary:
            case MLNUINativeTypeMArray:
                break;
            default: {
                mlnui_luaui_error(L, @"The value type must be one of types, as string, number, map or array!");
                break;
            }
        }
        mlnui_luaui_assert(L, (obj && (realIndex < array.count)), @"The index out of range!");
        if ((obj && (realIndex < array.count))) {
            [array replaceObjectAtIndex:realIndex withObject:obj];
        }
        lua_pushvalue(L, 1);
        return 1;
    }
    return 0;
}

static int luaui_array_replaceObjects(lua_State *L) {
    // 参数校验
    if (!__mlnui_luaui_in_checkParams(L, 2)) {
        return 0;
    }
    // index 为零校验
    NSInteger fromIndex = lua_tonumber(L, 2) - 1;
    if (fromIndex < 0) {
        mlnui_luaui_error(L, @"The number of index must be greater than 0!");
        return 0;
    }
    MLNUIUserData *ud = (MLNUIUserData *)lua_touserdata(L, 1);
    if (ud) {
        NSMutableArray *array = (__bridge __unsafe_unretained NSMutableArray *)ud->object;
        NSUInteger count = array.count;
        // index 越界检查
        if (fromIndex >= count) {
            mlnui_luaui_error(L, @"The number of index [%ld] out of array count [%lu]!", fromIndex + 1, (unsigned long)count);
            return 0;
        }
        NSArray *items = [MLNUI_LUA_CORE(L) toNativeObject:3 error:nil];
        if (!(items && items.count > 0)) {
             mlnui_luaui_error(L, @"The objects must not be empty!");
            return 0;
        }
        if (!(items.count <= count - fromIndex)) {
            mlnui_luaui_error(L, @"The cout of objects [%lu] out of array count [%lu]!", (unsigned long)items.count, count - fromIndex);
            return 0;
        }
        [array mlnui_replaceObjects:items fromIndex:fromIndex];
        lua_pushvalue(L,1);
        return 1;
    }
    return 0;
}

static int luaui_array_exchange(lua_State *L) {
    if (!__mlnui_luaui_in_checkParams(L, 2)) {
        return 0;
    }
    MLNUIUserData *ud = (MLNUIUserData *)lua_touserdata(L, 1);
    if (ud) {
        NSMutableArray *array = (__bridge __unsafe_unretained NSMutableArray *)ud->object;
        NSInteger realIndex1 = lua_tonumber(L, 2) - 1;
        luaui_CheckIndexZero(realIndex1);
        NSInteger realIndex2 = lua_tonumber(L, 3) - 1;
        luaui_CheckIndexZero(realIndex2);
        mlnui_luaui_assert(L, (array.count > realIndex1 && array.count > realIndex2), @"The index out of range!");
        if (array.count > realIndex1 && array.count > realIndex2) {
            [array exchangeObjectAtIndex:realIndex1 withObjectAtIndex:realIndex2];
        }
        lua_pushvalue(L,1);
        return 1;
    }
    return 0;
}

static int luaui_array_sub(lua_State *L) {
    if (!__mlnui_luaui_in_checkParams(L, 2)) {
        return 0;
    }
    MLNUIUserData *ud = (MLNUIUserData *)lua_touserdata(L, 1);
    if (ud) {
        NSMutableArray *resultArray = nil;
        NSMutableArray *array = (__bridge __unsafe_unretained NSMutableArray *)ud->object;
        NSInteger fromIndex = lua_tonumber(L, 2) - 1;
        luaui_CheckIndexZero(fromIndex);
        NSInteger toIndex = lua_tonumber(L, 3) - 1;
        luaui_CheckIndexZero(toIndex);
        mlnui_luaui_assert(L, (array.count > fromIndex && array.count > toIndex), @"The index out of range!");
        if (array.count > fromIndex && array.count > toIndex) {
            NSInteger length = toIndex - fromIndex + 1;
            resultArray = [NSMutableArray arrayWithArray:[array subarrayWithRange:NSMakeRange(fromIndex, length)]];
        }
        [MLNUI_LUA_CORE(L) pushNativeObject:resultArray error:nil];
        return 1;
    }
    return 0;
}

static int luaui_array_copy(lua_State *L) {
    MLNUIUserData *ud = (MLNUIUserData *)lua_touserdata(L, 1);
    if (ud) {
        NSMutableArray *array = (__bridge __unsafe_unretained NSMutableArray *)ud->object;
        NSMutableArray *resultArray = [NSMutableArray arrayWithArray:array];
        [MLNUI_LUA_CORE(L) pushNativeObject:resultArray error:nil];
        return 1;
    }
    return 0;
}

LUAUI_EXPORT_BEGIN(NSMutableArray)
LUAUI_EXPORT_METHOD_WITH_CFUNC(add, luaui_array_addObject, NSMutableArray)
LUAUI_EXPORT_METHOD_WITH_CFUNC(addAll, luaui_array_addObjectsFromArray, NSMutableArray)
LUAUI_EXPORT_METHOD_WITH_CFUNC(remove, luaui_array_removeObjectAtIndex, NSMutableArray)
LUAUI_EXPORT_METHOD_WITH_CFUNC(removeObject, luaui_array_removeObject, NSMutableArray)
LUAUI_EXPORT_METHOD_WITH_CFUNC(removeObjects, luaui_array_removeObjects, NSMutableArray)
LUAUI_EXPORT_METHOD_WITH_CFUNC(removeObjectsAtRange, luaui_array_removeObjectsAtRange, NSMutableArray)
LUAUI_EXPORT_METHOD_WITH_CFUNC(removeAll, luaui_array_removeAllObjects, NSMutableArray)
LUAUI_EXPORT_METHOD_WITH_CFUNC(get, luaui_array_objectAtIndex, NSMutableArray)
LUAUI_EXPORT_METHOD_WITH_CFUNC(size, luaui_array_size, NSMutableArray)
LUAUI_EXPORT_METHOD_WITH_CFUNC(contains, luaui_array_contains, NSMutableArray)
LUAUI_EXPORT_METHOD_WITH_CFUNC(insert, luaui_array_insertObject, NSMutableArray)
LUAUI_EXPORT_METHOD_WITH_CFUNC(insertObjects, luaui_array_insertObjects, NSMutableArray)
LUAUI_EXPORT_METHOD_WITH_CFUNC(replace, luaui_array_replaceObject, NSMutableArray)
LUAUI_EXPORT_METHOD_WITH_CFUNC(replaceObjects, luaui_array_replaceObjects, NSMutableArray)
LUAUI_EXPORT_METHOD_WITH_CFUNC(exchange, luaui_array_exchange, NSMutableArray)
LUAUI_EXPORT_METHOD_WITH_CFUNC(subArray, luaui_array_sub, NSMutableArray)
LUAUI_EXPORT_METHOD_WITH_CFUNC(copyArray, luaui_array_copy, NSMutableArray)
LUAUI_EXPORT_END_WITH_CFUNC(NSMutableArray, Array, NO, NULL, luaui_newArray)

@end
