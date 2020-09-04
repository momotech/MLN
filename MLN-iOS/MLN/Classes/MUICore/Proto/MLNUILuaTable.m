//
//  MLNUILuaTable.m
//  MLNUICore
//
//  Created by MoMo on 2019/7/24.
//

#import "MLNUILuaTable.h"
#import "MLNUIHeader.h"
#import "MLNUILuaCore.h"
#import "NSObject+MLNUICore.h"

@interface MLNUILuaTable ()

@end
@implementation MLNUILuaTable

static MLNUI_FORCE_INLINE int mlnui_pushTable(lua_State *L, void * key, MLNUILuaTableEnvironment env) {
    lua_pushlightuserdata(L, key);
    lua_gettable(L, env); // [ ... | table ]
    mlnui_luaui_checktable(L, -1);
    return -1;
}

- (instancetype)initWithMLNUILuaCore:(MLNUILuaCore *)luaCore env:(MLNUILuaTableEnvironment)env
{
    if (self = [super init]) {
        _luaCore = luaCore;
        switch (env) {
            case MLNUILuaTableEnvRegister:
                _env = MLNUILuaTableEnvRegister;
                break;
            default:
                _env = MLNUILuaTableEnvGlobal;
                break;
        }
        [self createTableWithNumArray:0 numHash:0];
    }
    return self;
}

- (void)createTableWithNumArray:(NSInteger)narr numHash:(NSInteger)nrec
{
    lua_State *L = self.luaCore.state;
    MLNUIAssert(self.luaCore, L, @"The lua state must not be nil!");
    if (L) {
        lua_checkstack(L, 32);
        int oldTop = lua_gettop(L);
        // 创建
        lua_createtable(L, (int)narr, (int)nrec);
        // 挂载到目的环境表（注册表或全局表）
        lua_pushvalue(L, -1);    // value
        lua_pushlightuserdata(L, (__bridge void *)(self));   // key
        lua_insert(L, -2);    // key <==> value 互换
        lua_settable(L, self.env); // registry[&Key] = fucntion
        // 清理栈
        int popCount = lua_gettop(L) - oldTop;
        lua_pop(L, popCount);
    }
}

- (void)setObjectWithIndex:(int)objIndex key:(NSString *)key
{
    lua_State *L = self.luaCore.state;
    MLNUIAssert(self.luaCore, L, @"The lua state must not be nil!");
    if (!key || key.length <= 0) {
        MLNUIError(self.luaCore, @"the key of obj mustn't be nil");
        return;
    }
    int base = lua_gettop(L);
    lua_pushvalue(L, objIndex);
    // 将对应table压栈
    mlnui_pushTable(L, (__bridge void *)(self), self.env);
    // 设置key - value
    lua_pushstring(L, key.UTF8String); // [ ... | table | key ]
    lua_pushvalue(L, -3); // [ ... | table | key | ud ]
    lua_settable(L, -3); // [ ... | table ]
    // 清理栈
    lua_settop(L, base);
}

- (void)setObjectWithIndex:(int)objIndex cKey:(void *)cKey
{
    lua_State *L = self.luaCore.state;
    MLNUIAssert(self.luaCore, L, @"The lua state must not be nil!");
    if (cKey == NULL) {
        MLNUIError(self.luaCore, @"the key of obj mustn't be nil");
        return;
    }
    int base = lua_gettop(L);
    lua_pushvalue(L, objIndex);
    // 将对应table压栈
    mlnui_pushTable(L, (__bridge void *)(self), self.env);
    // 设置key - value
    lua_pushlightuserdata(L, cKey); // [ ... | table | key ]
    lua_pushvalue(L, -3); // [ ... | table | key | ud ]
    lua_settable(L, -3); // [ ... | table ]
    // 清理栈
    lua_settop(L, base);
}

- (void)setObject:(id<MLNUIEntityExportProtocol>)obj key:(NSString *)key
{
    lua_State *L = self.luaCore.state;
    MLNUIAssert(self.luaCore, L, @"The lua state must not be nil!");
    if (!key || key.length <= 0) {
        MLNUIError(self.luaCore, @"the key of %@ mustn't be nil",  obj);
        return;
    }
    // 将对应table压栈
    mlnui_pushTable(L, (__bridge void *)(self), self.env);
    // 设置key - value
    lua_pushstring(L, key.UTF8String); // [ ... | table | key ]
    [MLNUI_LUA_CORE(L) pushNativeObject:obj error:NULL]; // [ ... | table | key | ud ]
    lua_settable(L, -3); // [ ... | table ]
    // 清理栈
    lua_pop(L, 1);
}

- (void)rawsetObject:(NSObject *)obj key:(NSString *)key {
    lua_State *L = self.luaCore.state;
    MLNUIAssert(self.luaCore, L, @"The lua state must not be nil!");
    if (!key || key.length <= 0) {
        MLNUIError(self.luaCore, @"the key of %@ mustn't be nil",  obj);
        return;
    }
    // 将对应table压栈
    mlnui_pushTable(L, (__bridge void *)(self), self.env);
    // 设置key - value
    lua_pushstring(L, key.UTF8String); // [ ... | table | key ]
//    [MLNUI_LUA_CORE(L) pushNativeObject:obj error:NULL]; // [ ... | table | key | ud ]
    NSError *error;
    [MLNUI_LUA_CORE(L).convertor pushArgoBindingNativeObject:obj error:&error];
//    lua_settable(L, -3); // [ ... | table ]
    lua_rawset(L, -3);
    // 清理栈
    lua_pop(L, 1);
}

- (void)setObject:(id<MLNUIEntityExportProtocol>)obj index:(int)index {
    lua_State *L = self.luaCore.state;
    MLNUIAssert(self.luaCore, L, @"The lua state must not be nil!");
//    if (!key || key.length <= 0) {
//        MLNUIError(self.luaCore, @"the key of %@ mustn't be nil",  obj);
//        return;
//    }
    
    // 将对应table压栈
    mlnui_pushTable(L, (__bridge void *)(self), self.env);
    // 设置key - value
    lua_pushnumber(L, index);
    [MLNUI_LUA_CORE(L) pushNativeObject:obj error:NULL]; // [ ... | table | key | ud ]
    lua_settable(L, -3); // [ ... | table ]
    // 清理栈
    lua_pop(L, 1);
}

- (void)rawsetObject:(NSObject *)obj index:(int)index {
    lua_State *L = self.luaCore.state;
    MLNUIAssert(self.luaCore, L, @"The lua state must not be nil!");
//    if (!key || key.length <= 0) {
//        MLNUIError(self.luaCore, @"the key of %@ mustn't be nil",  obj);
//        return;
//    }
    
    // 将对应table压栈
    mlnui_pushTable(L, (__bridge void *)(self), self.env);
    // 设置key - value
//    lua_pushnumber(L, index);
//    [MLNUI_LUA_CORE(L) pushNativeObject:obj error:NULL]; // [ ... | table | key | ud ]
    NSError *error;
    [MLNUI_LUA_CORE(L).convertor pushArgoBindingNativeObject:obj error:&error];
//    lua_settable(L, -3); // [ ... | table ]
    lua_rawseti(L, -2, index);
    // 清理栈
    lua_pop(L, 1);
}

#define aux_getn(L,n)    (luaL_checktype(L, n, LUA_TTABLE), luaL_getn(L, n))
- (void)inseretObject:(NSObject *)obj index:(int)index {
    lua_State *L = self.luaCore.state;
    MLNUIAssert(self.luaCore, L, @"The lua state must not be nil!");
    mlnui_pushTable(L, (__bridge void *)(self), self.env);
    int e = luaL_getn(L, -1) + 1;
    if(index > e) e = index;
    for (int i = e; i > index; i--) {
        lua_rawgeti(L, -1, i - 1);
        lua_rawseti(L, -2, i); /**t[i] = t[i-1]*/
    }
    NSError *error;
    [MLNUI_LUA_CORE(L).convertor pushArgoBindingNativeObject:obj error:&error];
    if (error) {
        lua_pop(L, 1);
        return;
    }
    luaL_setn(L, -2, e);
    lua_rawseti(L, -2, index);
    lua_pop(L, 1);
}

- (void)setObject:(id<MLNUIEntityExportProtocol>)obj cKey:(void *)cKey
{
    lua_State *L = self.luaCore.state;
    MLNUIAssert(self.luaCore, L, @"The lua state must not be nil!");
    if (cKey == NULL) {
        MLNUIError(self.luaCore, @"the key of %@ mustn't be nil",  obj);
        return;
    }
    // 将对应table压栈
    mlnui_pushTable(L, (__bridge void *)(self), self.env);
    // 设置key - value
    lua_pushlightuserdata(L, cKey); // [ ... | table | key ]
    [MLNUI_LUA_CORE(L) pushNativeObject:obj error:NULL]; // [ ... | table | key | ud ]
    lua_settable(L, -3); // [ ... | table ]
    // 清理栈
    lua_pop(L, 1);
}

- (void)removeObject:(NSString *)key
{
    lua_State *L = self.luaCore.state;
    MLNUIAssert(self.luaCore, L, @"The lua state must not be nil!");
    if (key == NULL) {
        MLNUIError(self.luaCore, @"the key of obj mustn't be nil");
        return;
    }
    int oldTop = lua_gettop(L);
    mlnui_pushTable(L, (__bridge void *)(self), self.env); // [ ... | table ]
    // 设置key - nil
    lua_pushstring(L, key.UTF8String); // [ ... | table | key ]
    lua_pushnil(L); // [ ... | table | key | nil ]
    lua_settable(L, -3); // [ ... | table ]
    // 清理栈
    int popCount = lua_gettop(L) - oldTop;
    lua_pop(L, popCount);
}

- (void)removeObjectForCKey:(void *)cKey
{
    lua_State *L = self.luaCore.state;
    MLNUIAssert(self.luaCore, L, @"The lua state must not be nil!");
    if (cKey == NULL) {
        MLNUIError(self.luaCore, @"the key of obj mustn't be nil");
        return;
    }
    int oldTop = lua_gettop(L);
    mlnui_pushTable(L, (__bridge void *)(self), self.env); // [ ... | table ]
    // 设置key - nil
    lua_pushlightuserdata(L, cKey); // [ ... | table | key ]
    lua_pushnil(L); // [ ... | table | key | nil ]
    lua_settable(L, -3); // [ ... | table ]
    // 清理栈
    int popCount = lua_gettop(L) - oldTop;
    lua_pop(L, popCount);
}

- (NSInteger)pushObjectToLuaStack:(NSString *)key
{
    lua_State *L = self.luaCore.state;
    if (!L) {
        MLNUIError(self.luaCore, @"The lua state must not be nil!");
        return NSNotFound;
    }
    int oldTop = lua_gettop(L);
    mlnui_pushTable(L, (__bridge void *)(self), self.env);
    lua_pushstring(L, key.UTF8String);
    lua_gettable(L, -2);
    if (lua_type(L, -1) == LUA_TUSERDATA) {
        // 删除Table
        lua_remove(L, -2);
        return -1;
    }
    // 清理栈
    lua_settop(L, oldTop);
    return NSNotFound;
}

- (NSInteger)pushObjectToLuaStackForCKey:(void *)cKey
{
    lua_State *L = self.luaCore.state;
    if (!L) {
        MLNUIError(self.luaCore, @"The lua state must not be nil!");
        return NSNotFound;
    }
    int oldTop = lua_gettop(L);
    mlnui_pushTable(L, (__bridge void *)(self), self.env);
    lua_pushlightuserdata(L, cKey);
    lua_gettable(L, -2);
    if (lua_type(L, -1) == LUA_TUSERDATA) {
        // 删除Table
        lua_remove(L, -2);
        return -1;
    }
    // 清理栈
    lua_settop(L, oldTop);
    return NSNotFound;
}

- (NSInteger)pushToLuaStack
{
    lua_State *L = self.luaCore.state;
    if (!L) {
        MLNUIError(self.luaCore, @"The lua state must not be nil!");
        return NSNotFound;
    }
    return mlnui_pushTable(L, (__bridge void *)(self), self.env);
}

- (void)dealloc
{
    lua_State *L = self.luaCore.state;
    if(L) {
        lua_checkstack(L, 2);
        lua_pushlightuserdata(L, (__bridge void *)(self) );   // key
        lua_pushnil(L);                   // nil
        lua_settable(L, self.env); // registry[&Key] = nil
    }
}

#pragma mark - 自定义转换压栈
- (BOOL)mlnui_isConvertible
{
    return YES;
}

- (BOOL)mlnui_isCustomConversion
{
    return YES;
}

- (BOOL)mlnui_convertToLuaStack:(NSError **)error
{
    lua_State *L = self.luaCore.state;
    if (!L) {
        MLNUIError(self.luaCore, @"The lua state must not be nil!");
        return NO;
    }
    mlnui_pushTable(L, (__bridge void *)(self), self.env);
    return YES;
}


@end
