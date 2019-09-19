//
//  MLNLuaTable.m
//  MLNCore
//
//  Created by MoMo on 2019/7/24.
//

#import "MLNLuaTable.h"
#import "MLNHeader.h"
#import "MLNLuaCore.h"
#import "NSObject+MLNCore.h"

@interface MLNLuaTable ()

@end
@implementation MLNLuaTable

static MLN_FORCE_INLINE int mln_pushTable(lua_State *L, void * key, MLNLuaTableEnvironment env) {
    lua_pushlightuserdata(L, key);
    lua_gettable(L, LUA_REGISTRYINDEX); // [ ... | table ]
    mln_lua_checktable(L, -1);
    return -1;
}

- (instancetype)initWithLuaCore:(MLNLuaCore *)luaCore env:(MLNLuaTableEnvironment)env
{
    if (self = [super init]) {
        _luaCore = luaCore;
        switch (env) {
            case MLNLuaTableEnvRegister:
                _env = MLNLuaTableEnvRegister;
                break;
            default:
                _env = MLNLuaTableEnvGlobal;
                break;
        }
        [self createTableWithNumArray:0 numHash:0];
    }
    return self;
}

- (void)createTableWithNumArray:(NSInteger)narr numHash:(NSInteger)nrec
{
    NSAssert([NSThread isMainThread], @"This method to be executed in the main thread!");
    lua_State *L = self.luaCore.state;
    MLNAssert(self.luaCore, L, @"The lua state must not be nil!");
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

- (void)setObject:(id<MLNEntityExportProtocol>)obj key:(NSString *)key
{
    NSAssert([NSThread isMainThread], @"This method to be executed in the main thread!");
    lua_State *L = self.luaCore.state;
    MLNAssert(self.luaCore, L, @"The lua state must not be nil!");
    // 将对应table压栈
    mln_pushTable(L, (__bridge void *)(self), self.env);
    // 设置key - value
    lua_pushstring(L, key.UTF8String); // [ ... | table | key ]
    [MLN_LUA_CORE(L) pushNativeObject:obj error:NULL]; // [ ... | table | key | ud ]
    lua_settable(L, -3); // [ ... | table ]
    // 清理栈
    lua_pop(L, 1);
}

- (void)removeObject:(NSString *)key
{
    NSAssert([NSThread isMainThread], @"This method to be executed in the main thread!");
    lua_State *L = self.luaCore.state;
    MLNAssert(self.luaCore, L, @"The lua state must not be nil!");
    int oldTop = lua_gettop(L);
    mln_pushTable(L, (__bridge void *)(self), self.env); // [ ... | table ]
    // 设置key - nil
    lua_pushstring(L, key.UTF8String); // [ ... | table | key ]
    lua_pushnil(L); // [ ... | table | key | nil ]
    lua_settable(L, -3); // [ ... | table ]
    // 清理栈
    int popCount = lua_gettop(L) - oldTop;
    lua_pop(L, popCount);
}

- (NSInteger)pushToLuaStack
{
    NSAssert([NSThread isMainThread], @"This method to be executed in the main thread!");
    lua_State *L = self.luaCore.state;
    if (!L) {
        MLNError(self.luaCore, @"The lua state must not be nil!");
        return NSNotFound;
    }
    return mln_pushTable(L, (__bridge void *)(self), self.env);
}

- (void)dealloc
{
    NSAssert([NSThread isMainThread], @"This method to be executed in the main thread!");
    lua_State *L = self.luaCore.state;
    if(L) {
        lua_checkstack(L, 2);
        lua_pushlightuserdata(L, (__bridge void *)(self) );   // key
        lua_pushnil(L);                   // nil
        lua_settable(L, self.env); // registry[&Key] = nil
    }
}

#pragma mark - 自定义转换压栈
- (BOOL)mln_isConvertible
{
    return YES;
}

- (BOOL)mln_isCustomConversion
{
    return YES;
}

- (BOOL)mln_convertToLuaStack:(NSError **)error
{
    lua_State *L = self.luaCore.state;
    if (!L) {
        MLNError(self.luaCore, @"The lua state must not be nil!");
        return NO;
    }
    mln_pushTable(L, (__bridge void *)(self), self.env);
    return YES;
}


@end
