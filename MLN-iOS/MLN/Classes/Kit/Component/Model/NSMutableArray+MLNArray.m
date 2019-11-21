//
//  NSMutableArray+MLNLua.m
//  
//
//  Created by MoMo on 2019/2/14.
//

#import "NSMutableArray+MLNArray.h"
#import "MLNLuaCore.h"
#import "NSArray+MLNSafety.h"

#define lua_CheckIndexZero(INDEX)\
if ((INDEX) < 0) {\
    mln_lua_error(L, @"The number of index must be greater than 0!");\
    return 0;\
}

@implementation NSMutableArray (MLNArray)

static MLN_FORCE_INLINE BOOL __mln_lua_in_checkParams(lua_State *L, int countOfParams) {
    if (lua_gettop(L) != countOfParams + 1) {
        if (lua_isuserdata(L, 1)) {
            MLNUserData *ud = (MLNUserData *)lua_touserdata(L, 1);
            if (ud) {
                id array = (__bridge __unsafe_unretained id )ud->object;
                if ([array mln_nativeType] != MLNNativeTypeMArray) {
                    mln_lua_error(L, @"Must use ':' to call this method！\n number of argments must be %d!", countOfParams);
                    return NO;
                }
            }
        }
        mln_lua_error(L, @"number of argments must be %d!", countOfParams);
        return NO;
    }
    return YES;
}

#pragma mark - Export To Lua
static int lua_newArray(lua_State *L) {
    switch (lua_gettop(L)) {
        case 0: {
            NSMutableArray *array = [NSMutableArray array];
            array.mln_isLuaObject = YES;
            [MLN_LUA_CORE(L) pushNativeObject:array error:nil];
            return 1;
        }
        case 1: {
            if (lua_isnumber(L, -1)) {
                double capacity = lua_tonumber(L, -1);
                NSMutableArray *array = [NSMutableArray arrayWithCapacity:capacity];
                array.mln_isLuaObject = YES;
                [MLN_LUA_CORE(L) pushNativeObject:array error:nil];
                return 1;
            }
            mln_lua_error(L, @"error type of argment, capacity must be number");
            break;
        }
        default: {
            mln_lua_error(L, @"number of argment more than 1");
            break;
        }
    }
    return 0;
}

static int lua_array_addObject(lua_State *L) {
    if (!__mln_lua_in_checkParams(L, 1)) {
        return 0;
    }
    MLNUserData *ud = (MLNUserData *)lua_touserdata(L, 1);
    if (ud) {
        NSMutableArray *array = (__bridge __unsafe_unretained NSMutableArray *)ud->object;
        id obj = [MLN_LUA_CORE(L) toNativeObject:2 error:nil];
        switch ([obj mln_nativeType]) {
            case MLNNativeTypeDictionary:
            {
                obj = [NSMutableDictionary dictionaryWithDictionary:obj];
                break;
            }
            case MLNNativeTypeArray: {
                obj = [NSMutableArray arrayWithArray:obj];
                break;
            }
            case MLNNativeTypeNumber:
            case MLNNativeTypeString:
            case MLNNativeTypeMDictionary:
            case MLNNativeTypeMArray:
                break;
            default: {
                mln_lua_error(L, @"The value type must be one of types, as string, number, map or array!");
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

static int lua_array_addObjectsFromArray(lua_State *L) {
    if (!__mln_lua_in_checkParams(L, 1)) {
        return 0;
    }
    MLNUserData *ud = (MLNUserData *)lua_touserdata(L, 1);
    if (ud) {
        NSMutableArray *array = (__bridge __unsafe_unretained NSMutableArray *)ud->object;
        NSMutableArray *obj = [MLN_LUA_CORE(L) toNativeObject:2 error:nil];
        switch ([obj mln_nativeType]) {
            case MLNNativeTypeArray: {
                obj = [NSMutableArray arrayWithArray:obj];
            }
            case MLNNativeTypeMArray: {
                [array mln_addObjectsFromArray:obj];
                break;
            }
            default: {
                mln_lua_error(L, @"The argment must be a array!");
                break;
            }
        }
        lua_pushvalue(L, 1);
        return 1;
    }
    return 0;
}

static int lua_array_removeObjectAtIndex(lua_State *L) {
    if (!__mln_lua_in_checkParams(L, 1)) {
        return 0;
    }
    MLNUserData *ud = (MLNUserData *)lua_touserdata(L, 1);
    if (ud) {
        NSMutableArray *array = (__bridge __unsafe_unretained NSMutableArray *)ud->object;
        NSInteger realIndex = lua_tonumber(L, 2) -1;
        lua_CheckIndexZero(realIndex);
        mln_lua_assert(L, (realIndex < array.count), "The index out of range!");
        if (realIndex < array.count) {
            [array removeObjectAtIndex:realIndex];
        }
        lua_pushvalue(L, 1);
        return 1;
    }
    return 0;
}

static int lua_array_removeObject(lua_State *L) {
    if (!__mln_lua_in_checkParams(L, 1)) {
        return 0;
    }
    MLNUserData *ud = (MLNUserData *)lua_touserdata(L, 1);
    if (ud) {
        NSMutableArray *array = (__bridge __unsafe_unretained NSMutableArray *)ud->object;
        id obj = [MLN_LUA_CORE(L) toNativeObject:2 error:nil];
        mln_lua_assert(L, obj, "The argment must not be nil!");
        if (obj) {
            [array removeObject:obj];
        }
        lua_pushvalue(L, 1);
        return 1;
    }
    return 0;
}

static int lua_array_removeObjects(lua_State *L) {
    if (!__mln_lua_in_checkParams(L, 1)) {
        return 0;
    }
    MLNUserData *ud = (MLNUserData *)lua_touserdata(L, 1);
    if (ud) {
        NSMutableArray *array = (__bridge __unsafe_unretained NSMutableArray *)ud->object;
        id objs = [MLN_LUA_CORE(L) toNativeObject:2 error:nil];
        mln_lua_assert(L, objs, "The argment must not be nil!");
        if (objs && [objs isKindOfClass:[NSArray class]]) {
            [array removeObjectsInArray:objs];
        }
        lua_pushvalue(L, 1);
        return 1;
    }
    return 0;
}

static int lua_array_removeObjectsAtRange(lua_State *L) {
    if (!__mln_lua_in_checkParams(L, 2)) {
        return 0;
    }
    MLNUserData *ud = (MLNUserData *)lua_touserdata(L, 1);
    if (ud) {
        NSMutableArray *array = (__bridge __unsafe_unretained NSMutableArray *)ud->object;
        NSInteger realFrom = lua_tonumber(L, 2) - 1;
        lua_CheckIndexZero(realFrom);
        NSInteger realTo = lua_tonumber(L, 3) - 1;
        lua_CheckIndexZero(realTo);
        
        mln_lua_assert(L, array.count > realTo && realTo >= realFrom && realFrom >=0, "The index out of range!");
        if (array.count > realTo && realTo >= realFrom && realFrom >=0) {
            [array mln_removeObjectsFromIndex:realFrom toIndex:realTo];
        }
        lua_pushvalue(L,1);
        return 1;
    }
    return 0;
}

static int lua_array_removeAllObjects(lua_State *L) {
    if (!__mln_lua_in_checkParams(L, 0)) {
        return 0;
    }
    MLNUserData *ud = (MLNUserData *)lua_touserdata(L, 1);
    if (ud) {
        NSMutableArray *array = (__bridge __unsafe_unretained NSMutableArray *)ud->object;
        [array removeAllObjects];
        lua_pushvalue(L,1);
        return 1;
    }
    return 0;
}

static int lua_array_objectAtIndex(lua_State *L) {
    if (!__mln_lua_in_checkParams(L, 1)) {
        return 0;
    }
    MLNUserData *ud = (MLNUserData *)lua_touserdata(L, 1);
    if (ud) {
        NSMutableArray *array = (__bridge __unsafe_unretained NSMutableArray *)ud->object;
        NSInteger realIndex = lua_tonumber(L, 2) -1;
        lua_CheckIndexZero(realIndex);
        mln_lua_assert(L, (realIndex < array.count), "The index out of range!");
        id value = nil;
        if (realIndex < array.count) {
            value = [array objectAtIndex:realIndex];
        }
        switch ([value mln_nativeType]) {
            case MLNNativeTypeDictionary: {
                value = [NSMutableDictionary dictionaryWithDictionary:value];
                [array mln_replaceObjectAtIndex:realIndex withObject:value];
                break;
            }
            case MLNNativeTypeArray: {
                value = [NSMutableArray arrayWithArray:value];
                [array mln_replaceObjectAtIndex:realIndex withObject:value];
                break;
            }
            default:
                break;
        }
        [MLN_LUA_CORE(L) pushNativeObject:value error:nil];
        return 1;
    }
    return 0;
}

static int lua_array_size(lua_State *L) {
    if (!__mln_lua_in_checkParams(L, 0)) {
        return 0;
    }
    MLNUserData *ud = (MLNUserData *)lua_touserdata(L, 1);
    if (ud) {
        NSMutableArray *array = (__bridge __unsafe_unretained NSMutableArray *)ud->object;
        lua_pushnumber(L, array.count);
        return 1;
    }
    return 0;
}

static int lua_array_contains(lua_State *L) {
    if (!__mln_lua_in_checkParams(L, 1)) {
        return 0;
    }
    MLNUserData *ud = (MLNUserData *)lua_touserdata(L, 1);
    if (ud) {
        NSMutableArray *array = (__bridge __unsafe_unretained NSMutableArray *)ud->object;
        id value = [MLN_LUA_CORE(L) toNativeObject:2 error:nil];;
        BOOL isContains = [array containsObject:value];
        lua_pushboolean(L, isContains);
        return 1;
    }
    return 0;
}

static int lua_array_insertObject(lua_State *L) {
    if (!__mln_lua_in_checkParams(L, 2)) {
        return 0;
    }
    MLNUserData *ud = (MLNUserData *)lua_touserdata(L, 1);
    if (ud) {
        NSMutableArray *array = (__bridge __unsafe_unretained NSMutableArray *)ud->object;
        NSInteger realIndex = lua_tonumber(L, 2) -1;
        lua_CheckIndexZero(realIndex);
        id obj = [MLN_LUA_CORE(L) toNativeObject:3 error:nil];;
        switch ([obj mln_nativeType]) {
            case MLNNativeTypeDictionary: {
                obj = [NSMutableDictionary dictionaryWithDictionary:obj];
                break;
            }
            case MLNNativeTypeArray: {
                obj = [NSMutableArray arrayWithArray:obj];
                break;
            }
            case MLNNativeTypeNumber:
            case MLNNativeTypeString:
            case MLNNativeTypeMDictionary:
            case MLNNativeTypeMArray:
                break;
            default: {
                mln_lua_error(L, @"The value type must be one of types, as string, number, map or array!");
                break;
            }
        }
        mln_lua_assert(L, (obj && (realIndex <= array.count)), "The index out of range!");
        if ((obj && (realIndex <= array.count))) {
            [array insertObject:obj atIndex:realIndex];
        }
        lua_pushvalue(L, 1);
        return 1;
    }
    return 0;
}

static int lua_array_insertObjects(lua_State *L) {
    // 参数校验
    if (!__mln_lua_in_checkParams(L, 2)) {
        return 0;
    }
    // index 为零校验
    NSInteger fromIndex = lua_tonumber(L, 2) - 1;
    if (fromIndex < 0) {
        mln_lua_error(L, @"The number of index must be greater than 0!");
        return 0;
    }
    MLNUserData *ud = (MLNUserData *)lua_touserdata(L, 1);
    if (ud) {
        NSMutableArray *array = (__bridge __unsafe_unretained NSMutableArray *)ud->object;
        NSUInteger count = array.count;
        // index 越界检查
        if (fromIndex > count) {
            mln_lua_error(L, @"The number of index [%ld] out of array count [%lu]!", fromIndex + 1, (unsigned long)count);
            return 0;
        }
        NSArray *items = [MLN_LUA_CORE(L) toNativeObject:3 error:nil];
        if (!(items && items.count > 0)) {
            mln_lua_error(L, @"The array must not be empty!");
            return 0;
        }
        [array mln_insertObjects:items fromIndex:fromIndex];
        lua_pushvalue(L,1);
        return 1;
    }
    return 0;
}

static int lua_array_replaceObject(lua_State *L) {
    if (!__mln_lua_in_checkParams(L, 2)) {
        return 0;
    }
    MLNUserData *ud = (MLNUserData *)lua_touserdata(L, 1);
    if (ud) {
        NSMutableArray *array = (__bridge __unsafe_unretained NSMutableArray *)ud->object;
        NSInteger realIndex = lua_tonumber(L, 2) -1;
        lua_CheckIndexZero(realIndex);
        id obj =[MLN_LUA_CORE(L) toNativeObject:3 error:nil];
        switch ([obj mln_nativeType]) {
            case MLNNativeTypeDictionary: {
                obj = [NSMutableDictionary dictionaryWithDictionary:obj];
                break;
            }
            case MLNNativeTypeArray: {
                obj = [NSMutableArray arrayWithArray:obj];
                break;
            }
            case MLNNativeTypeNumber:
            case MLNNativeTypeString:
            case MLNNativeTypeMDictionary:
            case MLNNativeTypeMArray:
                break;
            default: {
                mln_lua_error(L, @"The value type must be one of types, as string, number, map or array!");
                break;
            }
        }
        mln_lua_assert(L, (obj && (realIndex < array.count)), "The index out of range!");
        if ((obj && (realIndex < array.count))) {
            [array replaceObjectAtIndex:realIndex withObject:obj];
        }
        lua_pushvalue(L, 1);
        return 1;
    }
    return 0;
}

static int lua_array_replaceObjects(lua_State *L) {
    // 参数校验
    if (!__mln_lua_in_checkParams(L, 2)) {
        return 0;
    }
    // index 为零校验
    NSInteger fromIndex = lua_tonumber(L, 2) - 1;
    if (fromIndex < 0) {
        mln_lua_error(L, @"The number of index must be greater than 0!");
        return 0;
    }
    MLNUserData *ud = (MLNUserData *)lua_touserdata(L, 1);
    if (ud) {
        NSMutableArray *array = (__bridge __unsafe_unretained NSMutableArray *)ud->object;
        NSUInteger count = array.count;
        // index 越界检查
        if (fromIndex >= count) {
            mln_lua_error(L, @"The number of index [%ld] out of array count [%lu]!", fromIndex + 1, (unsigned long)count);
            return 0;
        }
        NSArray *items = [MLN_LUA_CORE(L) toNativeObject:3 error:nil];
        if (!(items && items.count > 0)) {
             mln_lua_error(L, @"The objects must not be empty!");
            return 0;
        }
        if (!(items.count <= count - fromIndex)) {
            mln_lua_error(L, @"The cout of objects [%lu] out of array count [%lu]!", (unsigned long)items.count, count - fromIndex);
            return 0;
        }
        [array mln_replaceObjects:items fromIndex:fromIndex];
        lua_pushvalue(L,1);
        return 1;
    }
    return 0;
}

static int lua_array_exchange(lua_State *L) {
    if (!__mln_lua_in_checkParams(L, 2)) {
        return 0;
    }
    MLNUserData *ud = (MLNUserData *)lua_touserdata(L, 1);
    if (ud) {
        NSMutableArray *array = (__bridge __unsafe_unretained NSMutableArray *)ud->object;
        NSInteger realIndex1 = lua_tonumber(L, 2) - 1;
        lua_CheckIndexZero(realIndex1);
        NSInteger realIndex2 = lua_tonumber(L, 3) - 1;
        lua_CheckIndexZero(realIndex2);
        mln_lua_assert(L, (array.count > realIndex1 && array.count > realIndex2), "The index out of range!");
        if (array.count > realIndex1 && array.count > realIndex2) {
            [array exchangeObjectAtIndex:realIndex1 withObjectAtIndex:realIndex2];
        }
        lua_pushvalue(L,1);
        return 1;
    }
    return 0;
}

static int lua_array_sub(lua_State *L) {
    if (!__mln_lua_in_checkParams(L, 2)) {
        return 0;
    }
    MLNUserData *ud = (MLNUserData *)lua_touserdata(L, 1);
    if (ud) {
        NSMutableArray *resultArray = nil;
        NSMutableArray *array = (__bridge __unsafe_unretained NSMutableArray *)ud->object;
        NSInteger fromIndex = lua_tonumber(L, 2) - 1;
        lua_CheckIndexZero(fromIndex);
        NSInteger toIndex = lua_tonumber(L, 3) - 1;
        lua_CheckIndexZero(toIndex);
        mln_lua_assert(L, (array.count > fromIndex && array.count > toIndex), "The index out of range!");
        if (array.count > fromIndex && array.count > toIndex) {
            NSInteger length = toIndex - fromIndex + 1;
            resultArray = [NSMutableArray arrayWithArray:[array subarrayWithRange:NSMakeRange(fromIndex, length)]];
        }
        [MLN_LUA_CORE(L) pushNativeObject:resultArray error:nil];
        return 1;
    }
    return 0;
}

static int lua_array_copy(lua_State *L) {
    MLNUserData *ud = (MLNUserData *)lua_touserdata(L, 1);
    if (ud) {
        NSMutableArray *array = (__bridge __unsafe_unretained NSMutableArray *)ud->object;
        NSMutableArray *resultArray = [NSMutableArray arrayWithArray:array];
        [MLN_LUA_CORE(L) pushNativeObject:resultArray error:nil];
        return 1;
    }
    return 0;
}

LUA_EXPORT_BEGIN(NSMutableArray)
LUA_EXPORT_METHOD_WITH_CFUNC(add, lua_array_addObject, NSMutableArray)
LUA_EXPORT_METHOD_WITH_CFUNC(addAll, lua_array_addObjectsFromArray, NSMutableArray)
LUA_EXPORT_METHOD_WITH_CFUNC(remove, lua_array_removeObjectAtIndex, NSMutableArray)
LUA_EXPORT_METHOD_WITH_CFUNC(removeObject, lua_array_removeObject, NSMutableArray)
LUA_EXPORT_METHOD_WITH_CFUNC(removeObjects, lua_array_removeObjects, NSMutableArray)
LUA_EXPORT_METHOD_WITH_CFUNC(removeObjectsAtRange, lua_array_removeObjectsAtRange, NSMutableArray)
LUA_EXPORT_METHOD_WITH_CFUNC(removeAll, lua_array_removeAllObjects, NSMutableArray)
LUA_EXPORT_METHOD_WITH_CFUNC(get, lua_array_objectAtIndex, NSMutableArray)
LUA_EXPORT_METHOD_WITH_CFUNC(size, lua_array_size, NSMutableArray)
LUA_EXPORT_METHOD_WITH_CFUNC(contains, lua_array_contains, NSMutableArray)
LUA_EXPORT_METHOD_WITH_CFUNC(insert, lua_array_insertObject, NSMutableArray)
LUA_EXPORT_METHOD_WITH_CFUNC(insertObjects, lua_array_insertObjects, NSMutableArray)
LUA_EXPORT_METHOD_WITH_CFUNC(replace, lua_array_replaceObject, NSMutableArray)
LUA_EXPORT_METHOD_WITH_CFUNC(replaceObjects, lua_array_replaceObjects, NSMutableArray)
LUA_EXPORT_METHOD_WITH_CFUNC(exchange, lua_array_exchange, NSMutableArray)
LUA_EXPORT_METHOD_WITH_CFUNC(subArray, lua_array_sub, NSMutableArray)
LUA_EXPORT_METHOD_WITH_CFUNC(copyArray, lua_array_copy, NSMutableArray)
LUA_EXPORT_END_WITH_CFUNC(NSMutableArray, Array, NO, NULL, lua_newArray)

@end
