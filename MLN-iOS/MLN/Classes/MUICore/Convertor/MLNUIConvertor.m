//
//  MLNUIConvertor.m
//  MLNUICore
//
//  Created by MoMo on 2019/7/25.
//

#import "MLNUIConvertor.h"
#import "MLNUILuaCore.h"
#import "NSObject+MLNUICore.h"
#import "NSValue+MLNUICore.h"
#import "MLNUILuaTable.h"
#import "MLNUIEntityExportProtocol.h"
#import "NSError+MLNUICore.h"
#import <objc/runtime.h>
#import "MLNUIBlock.h"

#define mlnui_strcmp(a, b) (strcmp((a), (b)) == 0)

static MLNUI_FORCE_INLINE void __mlnui_luaui_createUDLuatable(lua_State *L, int index) {
    lua_checkstack(L, 8);
    lua_pushvalue(L, index);
    lua_createtable(L, 8, 0);
    if(lua_isuserdata(L, -2)){
        lua_setfenv(L, index);
    }
    lua_pop(L, 1);
}

static MLNUI_FORCE_INLINE void __mlnui_luaui_pushentity(lua_State *L, id<MLNUIEntityExportProtocol> obj) {
    int base = lua_gettop(L);
    // cache
    if ([MLNUI_LUA_CORE(L) pushStrongObjectForCKey:(__bridge void *)obj]) {
        return;
    }
    lua_settop(L, base);
    
    const mlnui_objc_class *classInfo = [[obj class] mlnui_clazzInfo];
    // 创建Userdata对象
    MLNUIUserData *userData = ((MLNUIUserData *)lua_newuserdata(L, sizeof(MLNUIUserData)));
    __mlnui_luaui_createUDLuatable(L, -1);
    userData->type = classInfo->l_type;
    // 引用native对象
    [obj mlnui_luaRetain:userData];
    obj.mlnui_luaCore = MLNUI_LUA_CORE(L);
    // 设置方法表
    luaL_getmetatable(L, classInfo->l_name);
    lua_setmetatable(L, -2);
}

static MLNUI_FORCE_INLINE BOOL __mlnui_luaui_pushtable(lua_State *L, __unsafe_unretained id obj, NSError **error);

static MLNUI_FORCE_INLINE int __mlnui_luaui_pushobj(lua_State *L, __unsafe_unretained id obj, NSError **error) {
    int ret = 1;
    lua_checkstack(L, 4);
    // 是否需要转换为多参数压栈
    if ([obj mlnui_isMultiple]) {
        for (id param in [obj mlnui_multipleParams]) {
            BOOL ret = __mlnui_luaui_pushobj(L, param, error);
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
            __mlnui_luaui_pushentity(L, obj);
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
            if (!__mlnui_luaui_pushtable(L, obj, error)) {
                return 0;
            }
            break;
        }
        case MLNUINativeTypeDictionary:
        {
            if (!__mlnui_luaui_pushtable(L, obj, error)) {
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

#define __mlnui_luaui_push(value) \
switch ([value mlnui_nativeType]) {\
case MLNUINativeTypeMArray:\
case MLNUINativeTypeArray:\
case MLNUINativeTypeMDictionary:\
case MLNUINativeTypeDictionary:\
ret = __mlnui_luaui_pushtable(L, value, error);\
break;\
default:\
ret = __mlnui_luaui_pushobj(L, value, error);\
break;\
}

static MLNUI_FORCE_INLINE BOOL __mlnui_luaui_pushtable(lua_State *L, __unsafe_unretained id obj, NSError **error) {
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
                __mlnui_luaui_push(value);
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
                __mlnui_luaui_push(value);
                lua_settable(L, -3);
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

static MLNUI_FORCE_INLINE id __mlnui_luaui_toobj(lua_State* L, int idx, NSError **error);

static MLNUI_FORCE_INLINE CGRect __mlnui_luaui__tocgrect(lua_State *L, int idx,  NSError **error) {
    if (lua_isuserdata(L, idx)) {
        MLNUIUserData* user =  (MLNUIUserData*)lua_touserdata(L, idx);
        NSValue *value = (__bridge NSValue *)(user->object);
        if(strcmp(value.objCType, @encode(CGRect)) != 0){
            if (error) {
                *error = [NSError mlnui_errorConvert:@"Rect not found！"];
                mlnui_luaui_error(L, @"Rect not found！");
            }
            return CGRectZero;
        }
        return [value CGRectValue];
    } else if (lua_istable(L, idx)) {
        id ret = __mlnui_luaui_toobj(L, idx, error);
        if (*error) {
            return CGRectZero;
        }
        switch ([ret mlnui_nativeType]) {
            case MLNUINativeTypeMArray:
            case MLNUINativeTypeArray: {
                if ([ret count] == 4) {
                    CGFloat x = CGFloatValueFromNumber([ret objectAtIndex:0]);
                    CGFloat y = CGFloatValueFromNumber([ret objectAtIndex:1]);
                    CGFloat w = CGFloatValueFromNumber([ret objectAtIndex:2]);
                    CGFloat h = CGFloatValueFromNumber([ret objectAtIndex:3]);
                    return CGRectMake(x, y, w, h);
                }
            }
            case MLNUINativeTypeMDictionary:
            case MLNUINativeTypeDictionary: {
                CGFloat x = CGFloatValueFromNumber([(NSDictionary *)ret objectForKey:@"x"]);
                CGFloat y = CGFloatValueFromNumber([(NSDictionary *)ret objectForKey:@"y"]);
                CGFloat w = CGFloatValueFromNumber([(NSDictionary *)ret objectForKey:@"width"]);
                CGFloat h = CGFloatValueFromNumber([(NSDictionary *)ret objectForKey:@"height"]);
                return CGRectMake(x, y, w, h);
            }
            default:
                break;
        }
    } else if (lua_isnil(L, idx) || lua_isnone(L, idx)) {
        return CGRectZero;
    }
    if (error) {
        *error = [NSError mlnui_errorConvert:@"Rect not found！"];
        mlnui_luaui_error(L, @"Rect not found！");
    }
    return CGRectZero;
}

static MLNUI_FORCE_INLINE CGPoint __mlnui_luaui__tocgpoint(lua_State *L, int idx,  NSError **error) {
    if (lua_isuserdata(L, idx)) {
        MLNUIUserData* user =  (MLNUIUserData*)lua_touserdata(L, idx);
        NSValue *value = (__bridge NSValue *)(user->object);
        if(strcmp(value.objCType, @encode(CGPoint)) != 0){
            if (error) {
                *error = [NSError mlnui_errorConvert:@"Point not found！"];
                mlnui_luaui_error(L, @"Point not found！");
            }
            return CGPointZero;
        }
        return [value CGPointValue];
    } else if (lua_istable(L, idx)) {
        id ret = __mlnui_luaui_toobj(L, idx, error);
        if (*error) {
            return CGPointZero;
        }
        switch ([ret mlnui_nativeType]) {
            case MLNUINativeTypeMArray:
            case MLNUINativeTypeArray: {
                if ([ret count] == 2) {
                    CGFloat x = CGFloatValueFromNumber([ret objectAtIndex:0]);
                    CGFloat y = CGFloatValueFromNumber([ret objectAtIndex:1]);
                    return CGPointMake(x, y);
                }
            }
            case MLNUINativeTypeMDictionary:
            case MLNUINativeTypeDictionary: {
                CGFloat x = CGFloatValueFromNumber([(NSDictionary *)ret objectForKey:@"x"]);
                CGFloat y = CGFloatValueFromNumber([(NSDictionary *)ret objectForKey:@"y"]);
                return CGPointMake(x, y);
            }
            default:
                break;
        }
    } else if (lua_isnil(L, idx) || lua_isnone(L, idx)) {
        return CGPointZero;
    }
    if (error) {
        *error = [NSError mlnui_errorConvert:@"Point not found！"];
        mlnui_luaui_error(L, @"Point not found！");
    }
    return CGPointZero;
}

static MLNUI_FORCE_INLINE CGSize __mlnui_luaui_tocgsize(lua_State *L, int idx, NSError **error) {
    if (lua_isuserdata(L, idx)) {
        MLNUIUserData* user = lua_touserdata(L, idx);
        NSValue *value = (__bridge NSValue *)(user->object);
        if(strcmp(value.objCType, @encode(CGSize)) != 0){
            if (error) {
                *error = [NSError mlnui_errorConvert:@"Size not found！"];
                mlnui_luaui_error(L, @"Size not found！");
            }
            return CGSizeZero;
        }
        return [value CGSizeValue];
    } else if (lua_istable(L, idx)) {
        id ret = __mlnui_luaui_toobj(L, idx, error);
        if (*error) {
            return CGSizeZero;
        }
        switch ([ret mlnui_nativeType]) {
            case MLNUINativeTypeMArray:
            case MLNUINativeTypeArray: {
                if ([ret count] == 2) {
                    CGFloat w = CGFloatValueFromNumber([ret objectAtIndex:0]);
                    CGFloat h = CGFloatValueFromNumber([ret objectAtIndex:1]);
                    return CGSizeMake(w, h);
                }
            }
            case MLNUINativeTypeMDictionary:
            case MLNUINativeTypeDictionary: {
                CGFloat w = CGFloatValueFromNumber([(NSDictionary *)ret objectForKey:@"width"]);
                CGFloat h = CGFloatValueFromNumber([(NSDictionary *)ret objectForKey:@"height"]);
                return CGSizeMake(w, h);
            }
            default:
                break;
        }
    } else if (lua_isnil(L, idx) || lua_isnone(L, idx)) {
        return CGSizeZero;
    }
    if (error) {
        *error = [NSError mlnui_errorConvert:@"Size not found！"];
        mlnui_luaui_error(L, @"Size not found！");
    }
    return CGSizeZero;
}

static MLNUI_FORCE_INLINE NSString * __mlnui_luaui_tonsstring (lua_State *L, int idx, NSError **error) {
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

static MLNUI_FORCE_INLINE id __mlnui_luaui_toobj(lua_State* L, int idx, NSError **error) {
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
            return __mlnui_luaui_tonsstring(L, idx, error);
        }
        case LUA_TTABLE: {
            lua_checkstack(L, 128);
            NSMutableDictionary *dic = nil;
            MLNUITable *dicMeta = nil;
            NSMutableArray *array = nil;
            MLNUITable *arrayMeta = nil;
            lua_pushvalue(L, idx);
            // stack now contains: -1 => table
            
            int ret = lua_getmetatable(L, -1);
            if (ret != 0) {
                lua_pushnil(L);
                while (lua_next(L, -2)) {
                    id value = __mlnui_luaui_toobj(L, -1, error);
                    if(value) {
                        if(lua_isnumber(L, -2)) {
                            if(!arrayMeta) arrayMeta = [MLNUITable array];
                            [arrayMeta addObject:value];
                        } else {
                            NSString *key = __mlnui_luaui_tonsstring(L, -2, error);
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
                id value = __mlnui_luaui_toobj(L, -1, error);
                // stack now contains: -1 => value; -2 => key; -3 => table
                if(value) {
                    if(lua_isnumber(L, -2)) {
                        // number key
                        if(!array) {
                            array = [NSMutableArray array];
                        }
                        [array addObject:value];
                    } else { // string
                        NSString* key = __mlnui_luaui_tonsstring(L, -2, error);
                        if(key) {
                            if(!dic) {
                                dic = [NSMutableDictionary dictionary];
                            }
                            [dic setObject:value forKey:key];
                        }
                    }
                }
                lua_pop(L, 1);
                // stack now contains: -1 => key; -2 => table
            }
            lua_pop(L, 1);
            if([dic count] > 0) {
                if (dicMeta) {
                    dic.mlnui_metaTable = dicMeta;
                }
                if (arrayMeta) {
                    dic.mlnui_metaTable = arrayMeta;
                }
                return [dic copy];
            }
            if ([array count] > 0) {
                if (dicMeta) {
                    array.mlnui_metaTable = dicMeta;
                }
                if (arrayMeta) {
                    array.mlnui_metaTable = arrayMeta;
                }
                return [array copy];
            }
            // Stack is now the same as it was on entry to this function
            return @{};
        }
        case LUA_TFUNCTION: {
            return [[MLNUIBlock alloc] initWithMLNUILuaCore:MLNUI_LUA_CORE(L) indexOnLuaStack:idx];
        }
        default: {
            if (error) {
                *error = [NSError mlnui_errorConvert:@"The type is not defined！"];
                mlnui_luaui_error(L, @"he type is not defined！");
            }
            return nil;
        }
    }
}

MLNUI_Objc_Type mlnui_objctype(const char *type) {
    switch (type[0]) {
        case _C_ID: //#define _C_ID       '@'
            if (type[1] == _C_UNDEF) {  //#define _C_UNDEF       '?'
                return MLNUI_OBJCType_block;
            }
            return MLNUI_OBJCType_id;
        case _C_CLASS: //#define _C_CLASS    '#'
            return MLNUI_OBJCType_class;
        case _C_SEL:  //#define _C_SEL      ':'
            return MLNUI_OBJCType_SEL;
        case _C_CHR:  //#define _C_CHR      'c'
            return MLNUI_OBJCType_char;
        case _C_UCHR: //#define _C_UCHR     'C'
            return MLNUI_OBJCType_uchar;
        case _C_SHT:  //#define _C_SHT      's'
            return MLNUI_OBJCType_short;
        case _C_USHT: //#define _C_USHT     'S'
            return MLNUI_OBJCType_ushort;
        case _C_INT:  //#define _C_INT      'i'
            return MLNUI_OBJCType_int;
        case _C_UINT: //#define _C_UINT     'I'
            return MLNUI_OBJCType_uint;
        case _C_LNG:  //#define _C_LNG      'l'
            return MLNUI_OBJCType_long;
        case _C_ULNG: //#define _C_ULNG     'L'
            return MLNUI_OBJCType_ulong;
        case _C_LNG_LNG: //#define _C_LNG_LNG  'q'
            return MLNUI_OBJCType_llong;
        case _C_ULNG_LNG: //#define _C_ULNG_LNG 'Q'
            return MLNUI_OBJCType_ullong;
        case _C_FLT: //#define _C_FLT      'f'
            return MLNUI_OBJCType_float;
        case _C_DBL: //#define _C_DBL      'd'
            return MLNUI_OBJCType_double;
        case _C_BOOL: //#define _C_BOOL     'B'
            return MLNUI_OBJCType_BOOL;
        case _C_VOID: //#define _C_VOID     'v'
            return MLNUI_OBJCType_void;
        case _C_CHARPTR: //#define _C_CHARPTR  '*'
            return MLNUI_OBJCType_char_ptr;
        case _C_STRUCT_B: { //#define _C_STRUCT_B '{' 结构体
            if (mlnui_strcmp(type, @encode(CGRect))) {
                return MLNUI_OBJCType_rect;
            } else if (mlnui_strcmp(type, @encode(CGSize))) {
                return MLNUI_OBJCType_size;
            } else if (mlnui_strcmp(type, @encode(CGPoint))) {
                return MLNUI_OBJCType_point;
            }
            return MLNUI_OBJCType_struct;
        }
        case _C_PTR: { //#define _C_PTR      '^'
            if (type[1] == _C_ID) {
                return MLNUI_OBJCType_id_ptr;
            }  else if (type[1] == _C_STRUCT_B) {
                return MLNUI_OBJCType_struct_ptr;
            }  else if (mlnui_strcmp(type, @encode(void *))) {
                return MLNUI_OBJCType_void_ptr;
            }
            //TODO: 待支持其他类型
            return MLNUI_OBJCType_ndef;
        }
        case _C_CONST: { //#define _C_CONST    'r' 常量
            if (mlnui_strcmp(type, @encode(const char *))) {
                return MLNUI_OBJCType_const_char_ptr;
            }
            //TODO: 待支持其他类型
            return MLNUI_OBJCType_ndef;
        }
        default:  //#define _C_UNDEF    '?'
            return MLNUI_OBJCType_ndef;
    }
}

@implementation MLNUIConvertor

@synthesize luaCore = _luaCore;

- (instancetype)initWithMLNUILuaCore:(MLNUILuaCore *)luaCore
{
    NSParameterAssert(luaCore);
    if (self = [super init]) {
        _luaCore = luaCore;
    }
    return self;
}

- (int)pushNativeObject:(id)obj error:(NSError **)error
{
    lua_State *L = self.luaCore.state;
    if (!L) {
        if (error) {
            *error = [NSError mlnui_errorState:@"Lua state is released"];
            MLNUIError(self.luaCore, @"Lua state is released");
        }
        return 0;
    }
    return __mlnui_luaui_pushobj(L, obj, error);
}

- (BOOL)pushLuaTable:(id)collection error:(NSError **)error
{
    lua_State *L = self.luaCore.state;
    if (!L) {
        if (error) {
            *error = [NSError mlnui_errorState:@"Lua state is released"];
            MLNUIError(self.luaCore, @"Lua state is released");
        }
        return NO;
    }
    return __mlnui_luaui_pushtable(L, collection, error);
}

- (BOOL)pushString:(NSString *)aStr error:(NSError **)error
{
    lua_State *L = self.luaCore.state;
    if (!L) {
        if (error) {
            *error = [NSError mlnui_errorState:@"Lua state is released"];
            MLNUIError(self.luaCore, @"Lua state is released");
        }
        return NO;
    }
    if (!aStr) {
        if (error) {
            *error = [NSError mlnui_errorState:@"stirng must not be nil"];
            MLNUIError(self.luaCore, @"stirng must not be nil");
        }
        return NO;
    }
    lua_pushstring(L, aStr.UTF8String);
    return YES;
}

- (int)pushValua:(NSValue *)value error:(NSError **)error
{
    lua_State *L = self.luaCore.state;
    if (!L) {
        if (error) {
            *error = [NSError mlnui_errorState:@"Lua state is released"];
            MLNUIError(self.luaCore, @"Lua state is released");
        }
        return 0;
    }
    return __mlnui_luaui_pushobj(L, value, error);
}

- (int)pushCGRect:(CGRect)rect error:(NSError **)error
{
    lua_State *L = self.luaCore.state;
    if (!L) {
        if (error) {
            *error = [NSError mlnui_errorState:@"Lua state is released"];
            MLNUIError(self.luaCore, @"Lua state is released");
        }
        return 0;
    }
    return __mlnui_luaui_pushobj(L, @(rect), error);
}

- (int)pushCGPoint:(CGPoint)point error:(NSError **)error
{
    lua_State *L = self.luaCore.state;
    if (!L) {
        if (error) {
            *error = [NSError mlnui_errorState:@"Lua state is released"];
            MLNUIError(self.luaCore, @"Lua state is released");
        }
        return 0;
    }
    return __mlnui_luaui_pushobj(L, @(point), error);
}

- (int)pushCGSize:(CGSize)size error:(NSError **)error
{
    lua_State *L = self.luaCore.state;
    if (!L) {
        if (error) {
            *error = [NSError mlnui_errorState:@"Lua state is released"];
            MLNUIError(self.luaCore, @"Lua state is released");
        }
        return 0;
    }
    return __mlnui_luaui_pushobj(L, @(size), error);
}

- (id)toNativeObject:(int)idx error:(NSError **)error
{
    lua_State *L = self.luaCore.state;
    if (!L) {
        if (error) {
            *error = [NSError mlnui_errorState:@"Lua state is released"];
            MLNUIError(self.luaCore, @"Lua state is released");
        }
        return nil;
    }
    return __mlnui_luaui_toobj(L, idx, error);
}

- (NSString *)toString:(int)idx error:(NSError **)error
{
    lua_State *L = self.luaCore.state;
    if (!L) {
        if (error) {
            *error = [NSError mlnui_errorState:@"Lua state is released"];
            MLNUIError(self.luaCore, @"Lua state is released");
        }
        return nil;
    }
    return __mlnui_luaui_tonsstring(L, idx, error);
}

- (CGRect)toCGRect:(int)idx error:(NSError **)error
{
    lua_State *L = self.luaCore.state;
    if (!L) {
        if (error) {
            *error = [NSError mlnui_errorState:@"Lua state is released"];
            MLNUIError(self.luaCore, @"Lua state is released");
        }
        return CGRectZero;
    }
    return __mlnui_luaui__tocgrect(L, idx, error);
}

- (CGPoint)toCGPoint:(int)idx error:(NSError **)error
{
    lua_State *L = self.luaCore.state;
    if (!L) {
        if (error) {
            *error = [NSError mlnui_errorState:@"Lua state is released"];
            MLNUIError(self.luaCore, @"Lua state is released");
        }
        return CGPointZero;
    }
    return __mlnui_luaui__tocgpoint(L, idx, error);
}

- (CGSize)toCGSize:(int)idx error:(NSError **)error
{
    lua_State *L = self.luaCore.state;
    if (!L) {
        if (error) {
            *error = [NSError mlnui_errorState:@"Lua state is released"];
            MLNUIError(self.luaCore, @"Lua state is released");
        }
        return CGSizeZero;
    }
    return __mlnui_luaui_tocgsize(L, idx, error);
}

@end
