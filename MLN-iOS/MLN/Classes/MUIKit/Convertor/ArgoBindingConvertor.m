//
//  ArgoBindingConvertor.m
//  ArgoUI
//
//  Created by Dongpeng Dai on 2020/9/2.
//

#import "ArgoBindingConvertor.h"
#import "MLNUIHeader.h"
#import "ArgoObservableMap.h"
#import "ArgoObservableArray.h"
#import "MLNUILuaTable.h"
#import "MLNUIColor.h"
#import "MLNUIRect.h"
#import "MLNUISize.h"
#import "MLNUIPoint.h"
#import "NSObject+ArgoListener.h"

#pragma mark - to obj
static MLNUI_FORCE_INLINE NSString * __argo__tonsstring (lua_State *L, int idx, NSError **error) {
    if(lua_isstring(L, idx)) {
        size_t size = 0;
        const char * chars = luaL_checklstring(L, idx, &size);
        if(chars && size > 0) {
            return [NSString stringWithUTF8String:chars];
        }
        return @"";
    } else {
        if (error) {
            *error = [NSError mlnui_errorConvert:@"string not found！"];
            mlnui_luaui_error(L, @"string not found！");
        }
    }
    return nil;
}
static MLNUI_FORCE_INLINE id __argo__toobj(lua_State* L, MLNUILuaCore *luaCore,int idx, NSError **error) {
    int type = lua_type(L, idx);
    switch ( type ) {
        case LUA_TNONE:
        case LUA_TNIL: {
            return nil;
        }
        case LUA_TUSERDATA: {
            MLNUIUserData* user =  (MLNUIUserData*)lua_touserdata(L, idx);
            id obj =  (__bridge id)(user->object);
            if ([obj mlnui_isConvertible]) {
                return [(id<MLNUIEntityExportProtocol>)obj mlnui_rawNativeData];
            }
            return nil;
        }
        case LUA_TLIGHTUSERDATA:{
            return (__bridge id)lua_topointer(L, idx);
        }
        case LUA_TBOOLEAN: {
            return [[NSNumber alloc] initWithBool:lua_toboolean(L, idx)];
        }
        case LUA_TNUMBER: {
            double number = lua_tonumber(L, idx);
            return @(number);
        }
        case LUA_TSTRING: {
            return __argo__tonsstring(L, idx, error);
        }
        case LUA_TTABLE: {
            lua_checkstack(L, 128);
            ArgoObservableMap* dic = nil;
            ArgoObservableArray* array = nil;
            MLNUITable *dicMeta = nil;
            MLNUITable *arrayMeta = nil;
            lua_pushvalue(L, idx);
            // stack now contains: -1 => table
            
            int ret = lua_getmetatable(L, -1);
            if (ret != 0) {
                lua_pushnil(L);
                while (lua_next(L, -2)) {
                    id value = __argo__toobj(L, luaCore, -1, error);
                    if(value) {
                        if(lua_isnumber(L, -2)) {
                            if(!arrayMeta) arrayMeta = [MLNUITable array];
                            [arrayMeta addObject:value];
                        } else {
                            NSString* key = __argo__tonsstring(L, -2, error);
                            if(key) {
                                if(!dicMeta) dicMeta = [MLNUITable dictionary];
                                [dicMeta setObject:value forKey:key];
                            }
                        }
                    }
                    lua_pop(L, 1);
                }
                lua_pop(L, 1); // remove meta table
            }
            
            lua_pushnil(L);
            // stack now contains: -1 => nil; -2 => table
            while (lua_next(L, -2)) {
                id value = __argo__toobj(L, luaCore,-1, error);
                // stack now contains: -1 => value; -2 => key; -3 => table
                if(value) {
                    if(lua_isnumber(L, -2)) {
                        // number key
                        if(!array) {
                            array = [ArgoObservableArray array];
                        }
                        [array addObject:value];
                    } else { // string
                        NSString* key = __argo__tonsstring(L, -2, error);
                        if(key) {
                            if(!dic) {
                                dic = [ArgoObservableMap dictionary];
                            }
                            [dic lua_rawPutValue:value forKey:key];
                        }
                    }
                }
                lua_pop(L, 1);
                // stack now contains: -1 => key; -2 => table
            }
            lua_pop(L, 1);
            if([dic count] > 0) {
//                return [dic copy];
                if (dicMeta) {
                    dic.mlnui_metaTable = dicMeta;
                }
                if (arrayMeta) {
                    dic.mlnui_metaTable = arrayMeta;
                }
                return dic;
            }
            if ([array count] > 0) {
//                return [array copy];
                if (dicMeta) {
                    array.mlnui_metaTable = dicMeta;
                }
                if (arrayMeta) {
                    array.mlnui_metaTable = arrayMeta;
                }
                return array;
            }
            // Stack is now the same as it was on entry to this function
//            return @{};
            //TODO: 通过元表来确定值
            int oldTop = lua_gettop(L);
            lua_pushvalue(L, idx);// table ...
            int r = lua_getmetatable(L, -1); // meta table ...
            if (r == 0) {
                lua_pop(L, 1);// ...
                NSString *err = @"empty table must use map() or array()!";
                if(error) *error = [NSError mlnui_errorConvert:err];
                mlnui_luaui_error(L, @"%@", err);
                return [ArgoObservableMap dictionary];
            }
            lua_pushstring(L, "collectionType"); //key meta table ...
            lua_rawget(L, -2);// value meta table ...
            int type = lua_tonumber(L, -1);
            int newTop = lua_gettop(L);
            lua_pop(L, newTop - oldTop); // lua_pop(L, 3)
            if (type == 1) {
                return [ArgoObservableMap dictionary];
            }
            if (type == 2) {
                return [ArgoObservableArray array];
            }
            NSString *err = @"get collectionType failed, empty table must use map() or array()!";
            if(error) *error = [NSError mlnui_errorConvert:err];
            mlnui_luaui_error(L, @"%@", err);
            return [ArgoObservableMap dictionary];
        }
        case LUA_TFUNCTION: {
            return [[MLNUIBlock alloc] initWithMLNUILuaCore:MLNUI_LUA_CORE(L) indexOnLuaStack:idx];
        }
        default: {
            if (error) {
                *error = [NSError mlnui_errorConvert:@"The type is not defined！"];
                mlnui_luaui_error(L, @"the type is not defined！");
            }
            return nil;
        }
    }
}

#pragma mark - OC
@implementation ArgoBindingConvertor

- (id)toArgoBindingNativeObject:(int)idx error:(NSError *__autoreleasing  _Nullable *)error {
    lua_State *L = self.luaCore.state;
    if (!L) {
        if (error) {
            *error = [NSError mlnui_errorState:@"Lua state is released"];
            MLNUIError(self.luaCore, @"Lua state is released");
        }
        return nil;
    }
    id result = __argo__toobj(L, self.luaCore, idx, error);
#if 0 //后续可支持
    if ([result isKindOfClass:[MLNUIRect class]]) {
        return [NSValue valueWithCGRect:[(MLNUIRect *)self CGRectValue]];
    } else if ([result isKindOfClass:[MLNUISize class]]) {
        return [NSValue valueWithCGSize:[(MLNUISize *)self CGSizeValue]];
    } else if ([result isKindOfClass:[MLNUIPoint class]]) {
        return [NSValue valueWithCGPoint:[(MLNUIPoint *)self CGPointValue]];
    }
#endif
    return result;
}

static MLNUI_FORCE_INLINE int __argo__pushobj(lua_State *L, MLNUILuaCore *luaCore ,__unsafe_unretained id obj, NSError **error);
- (int)pushArgoBindingNativeObject:(id)obj error:(NSError *__autoreleasing  _Nullable *)error {
    lua_State *L = self.luaCore.state;
    if (!L) {
        if (error) {
            *error = [NSError mlnui_errorState:@"Lua state is released"];
            MLNUIError(self.luaCore, @"Lua state is released");
        }
        return 0;
    }
    return __argo__pushobj(L, self.luaCore, obj, error);
}

@end

#pragma mark - push obj

static MLNUI_FORCE_INLINE void __argo__createUDLuatable(lua_State *L, int index) {
    lua_checkstack(L, 8);
    lua_pushvalue(L, index);
    lua_createtable(L, 8, 0);
    if(lua_isuserdata(L, -2)){
        lua_setfenv(L, index);
    }
    lua_pop(L, 1);
}

static MLNUI_FORCE_INLINE void __argo__pushentity(lua_State *L, id<MLNUIEntityExportProtocol> obj) {
    int base = lua_gettop(L);
    // cache
    if ([MLNUI_LUA_CORE(L) pushStrongObjectForCKey:(__bridge void *)obj]) {
        return;
    }
    lua_settop(L, base);
    
    const mlnui_objc_class *classInfo = [[obj class] mlnui_clazzInfo];
    // 创建Userdata对象
    MLNUIUserData *userData = ((MLNUIUserData *)lua_newuserdata(L, sizeof(MLNUIUserData)));
    __argo__createUDLuatable(L, -1);
    userData->type = classInfo->l_type;
    // 引用native对象
    [obj mlnui_luaRetain:userData];
    obj.mlnui_luaCore = MLNUI_LUA_CORE(L);
    // 设置方法表
    luaL_getmetatable(L, classInfo->l_name);
    lua_setmetatable(L, -2);
}

static MLNUI_FORCE_INLINE BOOL __argo__pushtable(lua_State *L, MLNUILuaCore *luaCore ,__unsafe_unretained id obj, NSError **error);
static MLNUI_FORCE_INLINE int __argo__pushobj(lua_State *L, MLNUILuaCore *luaCore , id obj, NSError **error) {
    if ([obj mlnui_nativeType] == MLNUINativeTypeColor) {
        obj = [[MLNUIColor alloc] initWithColor:(UIColor *)obj];
    }
    
    int ret = 1;
    lua_checkstack(L, 4);
    // 是否需要转换为多参数压栈
    if ([obj mlnui_isMultiple]) {
        for (id param in [obj mlnui_multipleParams]) {
            BOOL ret = __argo__pushobj(L, luaCore, param, error);
            if (!ret) {
                mlnui_luaui_error(L, @"An error occurred about %@ parameter type！", obj);
                return 0;
            }
        }
        return (int)[[obj mlnui_multipleParams] count];
    }
    // 是否可转换为UserData
    if ([obj mlnui_isConvertible]) {
        // 是否自定义转换压栈的方式
        if ([obj mlnui_isCustomConversion]) {
            [obj mlnui_convertToLuaStack:NULL];
        } else {
            __argo__pushentity(L, obj);
        }
    } else
    // 不需要转换为多参数压栈的对象
    switch ([obj mlnui_nativeType]) {
        case MLNUINativeTypeString:
        {
            NSString *s = obj;
            lua_pushstring(L, s.UTF8String);
            break;
        }
        case MLNUINativeTypeNumber:
        {
            NSNumber *number = obj;
            if (MLNUINumberIsBool(number)) {
                lua_pushboolean(L, number.boolValue);
            } else {
                lua_pushnumber(L, number.doubleValue);
            }
            break;
        }
        case MLNUINativeTypeArray:
        {
            if (!__argo__pushtable(L,luaCore,obj,error)) {
                return 0;
            }
            break;
        }
        case MLNUINativeTypeDictionary:
        {
            if (!__argo__pushtable(L, luaCore, obj, error)) {
                return 0;
            }
            break;
        }
        case MLNUINativeTypeObervableMap:
        case MLNUINativeTypeObervableArray:
        {
            if (!__argo__pushtable(L, luaCore, obj, error)) {
                return 0;
            }
            break;
        }
        default:
        {
            if(obj == nil || obj == [NSNull null]) {
                lua_pushnil(L);
            } else {
                ret = 0;
                if (error) {
                    *error = [NSError mlnui_errorConvert:@"An error occurred about the parameter type！"];
                    mlnui_luaui_error(L, @"An error occurred about the parameter type！");
                }
            }
            break;
        }
    }
    return ret;
}

#define __argo__push(value) \
switch ([value mlnui_nativeType]) {\
case MLNUINativeTypeMArray:\
case MLNUINativeTypeArray:\
case MLNUINativeTypeMDictionary:\
case MLNUINativeTypeDictionary:\
case MLNUINativeTypeObervableMap:\
case MLNUINativeTypeObervableArray:\
ret = __argo__pushtable(L, luaCore ,value, error);\
break;\
default:\
ret = __argo__pushobj(L, luaCore ,value, error);\
break;\
}

static MLNUI_FORCE_INLINE BOOL __argo__pushtable(lua_State *L, MLNUILuaCore *luaCore ,__unsafe_unretained id obj, NSError **error) {
    BOOL ret = YES;
    switch ([obj mlnui_nativeType]) {
        case MLNUINativeTypeMArray:
        case MLNUINativeTypeArray:
        {
            NSArray *array = obj;
            lua_newtable(L);
            for (int i=0; i<array.count; i++) {
                id value = array[i];
                lua_pushnumber(L, i+1);
                __argo__push(value);
                lua_settable(L, -3);
            }
            break;
        }
        case MLNUINativeTypeMDictionary:
        case MLNUINativeTypeDictionary:
        {
            NSDictionary* dictionary = obj;
            lua_newtable(L);
            for (NSString *key in dictionary) {
                NSString* value = dictionary[key];
                lua_checkstack(L, 4);
                lua_pushstring(L, key.UTF8String);
                __argo__push(value);
                lua_settable(L, -3);
            }
            break;
        }
        case MLNUINativeTypeObervableMap:
        {
            ArgoObservableMap *map = obj;
            MLNUILuaTable *table = [map getLuaTable:luaCore];
            if (!table) {
                table = [[MLNUILuaTable alloc] initWithMLNUILuaCore:luaCore env:MLNUILuaTableEnvRegister]; // create
                if ([table pushToLuaStack] != NSNotFound) { // push to top of stack
                    for (NSString *key in map) {
                        id value = [map objectForKey:key];
                        lua_checkstack(L, 4);
                        lua_pushstring(L, key.UTF8String);
                        __argo__push(value);
//                        lua_settable(L, -3);
                        lua_rawset(L, -3);
                    }
                }
                [map addLuaTabe:table]; // cache
            } else {
                ret = [table pushToLuaStack] != NSNotFound;
            }
            break;
        }
        case MLNUINativeTypeObervableArray:
        {
            ArgoObservableArray *array = obj;
            MLNUILuaTable *table = [array getLuaTable:luaCore];
            if (!table) {
                table = [[MLNUILuaTable alloc] initWithMLNUILuaCore:luaCore env:MLNUILuaTableEnvRegister];
                if ([table pushToLuaStack] != NSNotFound) {
                    for (int i=0; i<array.count; i++) {
                        id value = array[i];
//                        lua_pushnumber(L, i + 1);
//                        __argo__push(value);
////                        lua_settable(L, -3);
//                        lua_rawset(L, -3);
                        __argo__push(value);
                        lua_rawseti(L, -2, i + 1);
                    }
                }
                [array addLuaTabe:table];
            } else {
                ret = [table pushToLuaStack] != NSNotFound;
            }
            break;
        }
        default: {
            ret = NO;
            if (error) {
                *error = [NSError mlnui_errorConvert:@"An error occurred about the parameter type！"];
                mlnui_luaui_error(L, @"An error occurred about the parameter type！");
            }
            break;
        }
    }
    return ret;
}


