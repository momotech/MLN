//
//  MLNConvertor.m
//  MLNCore
//
//  Created by MoMo on 2019/7/25.
//

#import "MLNConvertor.h"
#import "MLNLuaCore.h"
#import "NSObject+MLNCore.h"
#import "NSValue+MLNCore.h"
#import "MLNLuaTable.h"
#import "MLNEntityExportProtocol.h"
#import "NSError+MLNCore.h"
#import <objc/runtime.h>
#import "MLNBlock.h"

#define mln_strcmp(a, b) (strcmp((a), (b)) == 0)

static MLN_FORCE_INLINE void __mln_lua_createUDLuatable(lua_State *L, int index) {
    lua_checkstack(L, 8);
    lua_pushvalue(L, index);
    lua_createtable(L, 8, 0);
    if(lua_isuserdata(L, -2)){
        lua_setfenv(L, index);
    }
    lua_pop(L, 1);
}

static MLN_FORCE_INLINE void __mln_lua_pushentity(lua_State *L, id<MLNEntityExportProtocol> obj) {
    int base = lua_gettop(L);
    // cache
    if ([MLN_LUA_CORE(L) pushStrongObjectForCKey:(__bridge void *)obj]) {
        return;
    }
    lua_settop(L, base);
    
    const mln_objc_class *classInfo = [[obj class] mln_clazzInfo];
    // 创建Userdata对象
    MLNUserData *userData = ((MLNUserData *)lua_newuserdata(L, sizeof(MLNUserData)));
    __mln_lua_createUDLuatable(L, -1);
    userData->type = classInfo->l_type;
    // 引用native对象
    [obj mln_luaRetain:userData];
    obj.mln_luaCore = MLN_LUA_CORE(L);
    // 设置方法表
    luaL_getmetatable(L, classInfo->l_name);
    lua_setmetatable(L, -2);
}

static MLN_FORCE_INLINE BOOL __mln_lua_pushtable(lua_State *L, __unsafe_unretained id obj, NSError **error);

static MLN_FORCE_INLINE int __mln_lua_pushobj(lua_State *L, __unsafe_unretained id obj, NSError **error) {
    int ret = 1;
    lua_checkstack(L, 4);
    // 是否需要转换为多参数压栈
    if ([obj mln_isMultiple]) {
        for (id param in [obj mln_multipleParams]) {
            BOOL ret = __mln_lua_pushobj(L, param, error);
            if (!ret) {
                mln_lua_error(L, "An error occurred about %@ parameter type！", obj);
                return 0;
            }
        }
        return (int)[[obj mln_multipleParams] count];
    }
    // 是否可转换为UserData
    if ([obj mln_isConvertible]) {
        // 是否自定义转换压栈的方式
        if ([obj mln_isCustomConversion]) {
            [obj mln_convertToLuaStack:NULL];
        } else {
            __mln_lua_pushentity(L, obj);
        }
    } else
    // 不需要转换为多参数压栈的对象
    switch ([obj mln_nativeType]) {
        case MLNNativeTypeString:
        {
            NSString *s = obj;
            lua_pushstring(L, s.UTF8String);
            break;
        }
        case MLNNativeTypeNumber:
        {
            NSNumber *number = obj;
            if (MLNNumberIsBool(number)) {
                lua_pushboolean(L, number.boolValue);
            } else {
                lua_pushnumber(L, number.doubleValue);
            }
            break;
        }
        case MLNNativeTypeArray:
        {
            if (!__mln_lua_pushtable(L, obj, error)) {
                return 0;
            }
            break;
        }
        case MLNNativeTypeDictionary:
        {
            if (!__mln_lua_pushtable(L, obj, error)) {
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
                    *error = [NSError mln_errorConvert:@"An error occurred about the parameter type！"];
                    mln_lua_error(L, "An error occurred about the parameter type！");
                }
            }
            break;
        }
    }
    return ret;
}

#define __mln_lua_push(value) \
switch ([value mln_nativeType]) {\
case MLNNativeTypeMArray:\
case MLNNativeTypeArray:\
case MLNNativeTypeMDictionary:\
case MLNNativeTypeDictionary:\
ret = __mln_lua_pushtable(L, value, error);\
break;\
default:\
ret = __mln_lua_pushobj(L, value, error);\
break;\
}

static MLN_FORCE_INLINE BOOL __mln_lua_pushtable(lua_State *L, __unsafe_unretained id obj, NSError **error) {
    BOOL ret = YES;
    switch ([obj mln_nativeType]) {
        case MLNNativeTypeMArray:
        case MLNNativeTypeArray:
        {
            NSArray *array = obj;
            lua_newtable(L);
            for (int i=0; i<array.count; i++) {
                id value = array[i];
                lua_pushnumber(L, i+1);
                __mln_lua_push(value);
                lua_settable(L, -3);
            }
            break;
        }
        case MLNNativeTypeMDictionary:
        case MLNNativeTypeDictionary:
        {
            NSDictionary* dictionary = obj;
            lua_newtable(L);
            for (NSString *key in dictionary) {
                NSString* value = dictionary[key];
                lua_checkstack(L, 4);
                lua_pushstring(L, key.UTF8String);
                __mln_lua_push(value);
                lua_settable(L, -3);
            }
            break;
        }
        default: {
            ret = NO;
            if (error) {
                *error = [NSError mln_errorConvert:@"An error occurred about the parameter type！"];
                mln_lua_error(L, "An error occurred about the parameter type！");
            }
            break;
        }
    }
    return ret;
}

static MLN_FORCE_INLINE id __mln_lua_toobj(lua_State* L, int idx, NSError **error);

static MLN_FORCE_INLINE CGRect __mln_lua__tocgrect(lua_State *L, int idx,  NSError **error) {
    if (lua_isuserdata(L, idx)) {
        MLNUserData* user =  (MLNUserData*)lua_touserdata(L, idx);
        NSValue *value = (__bridge NSValue *)(user->object);
        if(strcmp(value.objCType, @encode(CGRect)) != 0){
            if (error) {
                *error = [NSError mln_errorConvert:@"Rect not found！"];
                mln_lua_error(L, "Rect not found！");
            }
            return CGRectZero;
        }
        return [value CGRectValue];
    } else if (lua_istable(L, idx)) {
        id ret = __mln_lua_toobj(L, idx, error);
        if (*error) {
            return CGRectZero;
        }
        switch ([ret mln_nativeType]) {
            case MLNNativeTypeMArray:
            case MLNNativeTypeArray: {
                if ([ret count] == 4) {
                    CGFloat x = CGFloatValueFromNumber([ret objectAtIndex:0]);
                    CGFloat y = CGFloatValueFromNumber([ret objectAtIndex:1]);
                    CGFloat w = CGFloatValueFromNumber([ret objectAtIndex:2]);
                    CGFloat h = CGFloatValueFromNumber([ret objectAtIndex:3]);
                    return CGRectMake(x, y, w, h);
                }
            }
            case MLNNativeTypeMDictionary:
            case MLNNativeTypeDictionary: {
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
        *error = [NSError mln_errorConvert:@"Rect not found！"];
        mln_lua_error(L, "Rect not found！");
    }
    return CGRectZero;
}

static MLN_FORCE_INLINE CGPoint __mln_lua__tocgpoint(lua_State *L, int idx,  NSError **error) {
    if (lua_isuserdata(L, idx)) {
        MLNUserData* user =  (MLNUserData*)lua_touserdata(L, idx);
        NSValue *value = (__bridge NSValue *)(user->object);
        if(strcmp(value.objCType, @encode(CGPoint)) != 0){
            if (error) {
                *error = [NSError mln_errorConvert:@"Point not found！"];
                mln_lua_error(L, "Point not found！");
            }
            return CGPointZero;
        }
        return [value CGPointValue];
    } else if (lua_istable(L, idx)) {
        id ret = __mln_lua_toobj(L, idx, error);
        if (*error) {
            return CGPointZero;
        }
        switch ([ret mln_nativeType]) {
            case MLNNativeTypeMArray:
            case MLNNativeTypeArray: {
                if ([ret count] == 2) {
                    CGFloat x = CGFloatValueFromNumber([ret objectAtIndex:0]);
                    CGFloat y = CGFloatValueFromNumber([ret objectAtIndex:1]);
                    return CGPointMake(x, y);
                }
            }
            case MLNNativeTypeMDictionary:
            case MLNNativeTypeDictionary: {
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
        *error = [NSError mln_errorConvert:@"Point not found！"];
        mln_lua_error(L, "Point not found！");
    }
    return CGPointZero;
}

static MLN_FORCE_INLINE CGSize __mln_lua_tocgsize(lua_State *L, int idx, NSError **error) {
    if (lua_isuserdata(L, idx)) {
        MLNUserData* user = lua_touserdata(L, idx);
        NSValue *value = (__bridge NSValue *)(user->object);
        if(strcmp(value.objCType, @encode(CGSize)) != 0){
            if (error) {
                *error = [NSError mln_errorConvert:@"Size not found！"];
                mln_lua_error(L, "Size not found！");
            }
            return CGSizeZero;
        }
        return [value CGSizeValue];
    } else if (lua_istable(L, idx)) {
        id ret = __mln_lua_toobj(L, idx, error);
        if (*error) {
            return CGSizeZero;
        }
        switch ([ret mln_nativeType]) {
            case MLNNativeTypeMArray:
            case MLNNativeTypeArray: {
                if ([ret count] == 2) {
                    CGFloat w = CGFloatValueFromNumber([ret objectAtIndex:0]);
                    CGFloat h = CGFloatValueFromNumber([ret objectAtIndex:1]);
                    return CGSizeMake(w, h);
                }
            }
            case MLNNativeTypeMDictionary:
            case MLNNativeTypeDictionary: {
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
        *error = [NSError mln_errorConvert:@"Size not found！"];
        mln_lua_error(L, "Size not found！");
    }
    return CGSizeZero;
}

static MLN_FORCE_INLINE NSString * __mln_lua_tonsstring (lua_State *L, int idx, NSError **error) {
    if(lua_isstring(L, idx)) {
        size_t size = 0;
        const char * chars = luaL_checklstring(L, idx, &size);
        if(chars && size > 0) {
            return [NSString stringWithUTF8String:chars];
        }
        return @"";
    } else {
        if (error) {
            *error = [NSError mln_errorConvert:@"string not found！"];
            mln_lua_error(L, "string not found！");
        }
    }
    return nil;
}

static MLN_FORCE_INLINE id __mln_lua_toobj(lua_State* L, int idx, NSError **error) {
    int type = lua_type(L, idx);
    switch ( type ) {
        case LUA_TNONE:
        case LUA_TNIL: {
            return nil;
        }
        case LUA_TUSERDATA: {
            MLNUserData* user =  (MLNUserData*)lua_touserdata(L, idx);
            id obj =  (__bridge id)(user->object);
            if ([obj mln_isConvertible]) {
                return [(id<MLNEntityExportProtocol>)obj mln_rawNativeData];
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
            number = isnan(number) ? 0 : number;
            return @(number);
        }
        case LUA_TSTRING: {
            return __mln_lua_tonsstring(L, idx, error);
        }
        case LUA_TTABLE: {
            lua_checkstack(L, 128);
            NSMutableDictionary* dic = nil;
            NSMutableArray* array = nil;
            lua_pushvalue(L, idx);
            // stack now contains: -1 => table
            lua_pushnil(L);
            // stack now contains: -1 => nil; -2 => table
            while (lua_next(L, -2)) {
                id value = __mln_lua_toobj(L, -1, error);
                // stack now contains: -1 => value; -2 => key; -3 => table
                if(value) {
                    if(lua_isnumber(L, -2)) {
                        // number key
                        if(!array) {
                            array = [NSMutableArray array];
                        }
                        [array addObject:value];
                    } else { // string
                        NSString* key = __mln_lua_tonsstring(L, -2, error);
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
                return [dic copy];
            }
            if ([array count] > 0) {
                return [array copy];
            }
            // Stack is now the same as it was on entry to this function
            return @{};
        }
        case LUA_TFUNCTION: {
            return [[MLNBlock alloc] initWithLuaCore:MLN_LUA_CORE(L) indexOnLuaStack:idx];
        }
        default: {
            if (error) {
                *error = [NSError mln_errorConvert:@"The type is not defined！"];
                mln_lua_error(L, "he type is not defined！");
            }
            return nil;
        }
    }
}

MLN_Objc_Type mln_objctype(const char *type) {
    switch (type[0]) {
        case _C_ID: //#define _C_ID       '@'
            if (type[1] == _C_UNDEF) {  //#define _C_UNDEF       '?'
                return MLN_OBJCType_block;
            }
            return MLN_OBJCType_id;
        case _C_CLASS: //#define _C_CLASS    '#'
            return MLN_OBJCType_class;
        case _C_SEL:  //#define _C_SEL      ':'
            return MLN_OBJCType_SEL;
        case _C_CHR:  //#define _C_CHR      'c'
            return MLN_OBJCType_char;
        case _C_UCHR: //#define _C_UCHR     'C'
            return MLN_OBJCType_uchar;
        case _C_SHT:  //#define _C_SHT      's'
            return MLN_OBJCType_short;
        case _C_USHT: //#define _C_USHT     'S'
            return MLN_OBJCType_ushort;
        case _C_INT:  //#define _C_INT      'i'
            return MLN_OBJCType_int;
        case _C_UINT: //#define _C_UINT     'I'
            return MLN_OBJCType_uint;
        case _C_LNG:  //#define _C_LNG      'l'
            return MLN_OBJCType_long;
        case _C_ULNG: //#define _C_ULNG     'L'
            return MLN_OBJCType_ulong;
        case _C_LNG_LNG: //#define _C_LNG_LNG  'q'
            return MLN_OBJCType_llong;
        case _C_ULNG_LNG: //#define _C_ULNG_LNG 'Q'
            return MLN_OBJCType_ullong;
        case _C_FLT: //#define _C_FLT      'f'
            return MLN_OBJCType_float;
        case _C_DBL: //#define _C_DBL      'd'
            return MLN_OBJCType_double;
        case _C_BOOL: //#define _C_BOOL     'B'
            return MLN_OBJCType_BOOL;
        case _C_VOID: //#define _C_VOID     'v'
            return MLN_OBJCType_void;
        case _C_CHARPTR: //#define _C_CHARPTR  '*'
            return MLN_OBJCType_char_ptr;
        case _C_STRUCT_B: { //#define _C_STRUCT_B '{' 结构体
            if (mln_strcmp(type, @encode(CGRect))) {
                return MLN_OBJCType_rect;
            } else if (mln_strcmp(type, @encode(CGSize))) {
                return MLN_OBJCType_size;
            } else if (mln_strcmp(type, @encode(CGPoint))) {
                return MLN_OBJCType_point;
            }
            return MLN_OBJCType_struct;
        }
        case _C_PTR: { //#define _C_PTR      '^'
            if (type[1] == _C_ID) {
                return MLN_OBJCType_id_ptr;
            }  else if (type[1] == _C_STRUCT_B) {
                return MLN_OBJCType_struct_ptr;
            }  else if (mln_strcmp(type, @encode(void *))) {
                return MLN_OBJCType_void_ptr;
            }
            //TODO: 待支持其他类型
            return MLN_OBJCType_ndef;
        }
        case _C_CONST: { //#define _C_CONST    'r' 常量
            if (mln_strcmp(type, @encode(const char *))) {
                return MLN_OBJCType_const_char_ptr;
            }
            //TODO: 待支持其他类型
            return MLN_OBJCType_ndef;
        }
        default:  //#define _C_UNDEF    '?'
            return MLN_OBJCType_ndef;
    }
}

@implementation MLNConvertor

@synthesize luaCore = _luaCore;

- (instancetype)initWithLuaCore:(MLNLuaCore *)luaCore
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
            *error = [NSError mln_errorState:@"Lua state is released"];
            MLNError(self.luaCore, @"Lua state is released");
        }
        return 0;
    }
    return __mln_lua_pushobj(L, obj, error);
}

- (BOOL)pushLuaTable:(id)collection error:(NSError **)error
{
    lua_State *L = self.luaCore.state;
    if (!L) {
        if (error) {
            *error = [NSError mln_errorState:@"Lua state is released"];
            MLNError(self.luaCore, @"Lua state is released");
        }
        return NO;
    }
    return __mln_lua_pushtable(L, collection, error);
}

- (BOOL)pushString:(NSString *)aStr error:(NSError **)error
{
    lua_State *L = self.luaCore.state;
    if (!L) {
        if (error) {
            *error = [NSError mln_errorState:@"Lua state is released"];
            MLNError(self.luaCore, @"Lua state is released");
        }
        return NO;
    }
    if (!aStr) {
        if (error) {
            *error = [NSError mln_errorState:@"stirng must not be nil"];
            MLNError(self.luaCore, @"stirng must not be nil");
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
            *error = [NSError mln_errorState:@"Lua state is released"];
            MLNError(self.luaCore, @"Lua state is released");
        }
        return 0;
    }
    return __mln_lua_pushobj(L, value, error);
}

- (int)pushCGRect:(CGRect)rect error:(NSError **)error
{
    lua_State *L = self.luaCore.state;
    if (!L) {
        if (error) {
            *error = [NSError mln_errorState:@"Lua state is released"];
            MLNError(self.luaCore, @"Lua state is released");
        }
        return 0;
    }
    return __mln_lua_pushobj(L, @(rect), error);
}

- (int)pushCGPoint:(CGPoint)point error:(NSError **)error
{
    lua_State *L = self.luaCore.state;
    if (!L) {
        if (error) {
            *error = [NSError mln_errorState:@"Lua state is released"];
            MLNError(self.luaCore, @"Lua state is released");
        }
        return 0;
    }
    return __mln_lua_pushobj(L, @(point), error);
}

- (int)pushCGSize:(CGSize)size error:(NSError **)error
{
    lua_State *L = self.luaCore.state;
    if (!L) {
        if (error) {
            *error = [NSError mln_errorState:@"Lua state is released"];
            MLNError(self.luaCore, @"Lua state is released");
        }
        return 0;
    }
    return __mln_lua_pushobj(L, @(size), error);
}

- (id)toNativeObject:(int)idx error:(NSError **)error
{
    lua_State *L = self.luaCore.state;
    if (!L) {
        if (error) {
            *error = [NSError mln_errorState:@"Lua state is released"];
            MLNError(self.luaCore, @"Lua state is released");
        }
        return nil;
    }
    return __mln_lua_toobj(L, idx, error);
}

- (NSString *)toString:(int)idx error:(NSError **)error
{
    lua_State *L = self.luaCore.state;
    if (!L) {
        if (error) {
            *error = [NSError mln_errorState:@"Lua state is released"];
            MLNError(self.luaCore, @"Lua state is released");
        }
        return nil;
    }
    return __mln_lua_tonsstring(L, idx, error);
}

- (CGRect)toCGRect:(int)idx error:(NSError **)error
{
    lua_State *L = self.luaCore.state;
    if (!L) {
        if (error) {
            *error = [NSError mln_errorState:@"Lua state is released"];
            MLNError(self.luaCore, @"Lua state is released");
        }
        return CGRectZero;
    }
    return __mln_lua__tocgrect(L, idx, error);
}

- (CGPoint)toCGPoint:(int)idx error:(NSError **)error
{
    lua_State *L = self.luaCore.state;
    if (!L) {
        if (error) {
            *error = [NSError mln_errorState:@"Lua state is released"];
            MLNError(self.luaCore, @"Lua state is released");
        }
        return CGPointZero;
    }
    return __mln_lua__tocgpoint(L, idx, error);
}

- (CGSize)toCGSize:(int)idx error:(NSError **)error
{
    lua_State *L = self.luaCore.state;
    if (!L) {
        if (error) {
            *error = [NSError mln_errorState:@"Lua state is released"];
            MLNError(self.luaCore, @"Lua state is released");
        }
        return CGSizeZero;
    }
    return __mln_lua_tocgsize(L, idx, error);
}

@end
