//
//  MLNEntityExporter.m
//  MLNCore
//
//  Created by MoMo on 2019/7/23.
//

#import "MLNEntityExporter.h"
#import "NSError+MLNCore.h"
#import "NSObject+MLNCore.h"
#import "MLNLuaCore.h"
#import "MLNEntityExportProtocol.h"

@implementation MLNEntityExporter

static int mln_lua_user_data_gc (lua_State *L) {
    MLNUserData *user = (MLNUserData *)lua_touserdata(L, 1);
    if( user && user->object ){
        NSObject<MLNEntityExportProtocol> *obj = (__bridge NSObject<MLNEntityExportProtocol> *)(user->object);
        [obj mln_luaRelease];
        user->object = NULL;
        if ([obj mln_isConvertible] && [obj mln_luaRetainCount] == 0) {
            if ([obj respondsToSelector:@selector(mln_user_data_dealloc)]) {
                [(NSObject<MLNEntityExportProtocol> *)obj mln_user_data_dealloc];
            }
        }
    }
    return 0;
}

static int mln_lua_user_data_tostring (lua_State *L) {
    MLNUserData * user = (MLNUserData *)lua_touserdata(L, 1);
    if(user){
        NSObject * obj =  (__bridge NSObject *)(user->object);
        NSString* des = [NSString stringWithFormat:@"<[ UserData: %@ ]>", [obj description]];
        lua_pushstring(L, des.UTF8String);
        return 1;
    }
    return 0;
}

static int mln_lua_obj_equal (lua_State *L) {
    BOOL isEqual = NO;
    if (lua_gettop(L) == 2) {
        MLNUserData * user_1 = (MLNUserData *)lua_touserdata(L, 1);
        MLNUserData * user_2 = (MLNUserData *)lua_touserdata(L, 2);
        if (user_1 && user_2) {
            NSObject * obj_1 =  (__bridge NSObject *)(user_1->object);
            NSObject * obj_2 =  (__bridge NSObject *)(user_2->object);
            isEqual = obj_1 == obj_2;
        }
    }
    lua_pushboolean(L, isEqual);
    return 1;
}

static const struct luaL_Reg MLNUserDataBaseFuncs [] = {
    {"__gc", mln_lua_user_data_gc},
    {"__tostring", mln_lua_user_data_tostring},
    {"__eq", mln_lua_obj_equal},
    {NULL, NULL}
};

- (BOOL)exportClass:(Class<MLNExportProtocol>)clazz error:(NSError **)error
{
    NSParameterAssert(clazz);
    Class<MLNEntityExportProtocol> exportClazz = (Class<MLNEntityExportProtocol>)clazz;
    const mln_objc_class *classInfo = [exportClazz mln_clazzInfo];
    // 注册构造函数
    BOOL ret = [self registerConstructor:classInfo->constructor.func clazz:classInfo->clz constructor:classInfo->constructor.mn luaName:classInfo->l_clz error:error];
    if (!ret) {
        return ret;
    }
    // 创建元表
    ret = [self.luaCore createMetaTable:classInfo->l_name error:error];
    if (!ret) {
        return ret;
    }
    // 注册基础方法
    ret = [self.luaCore openCLib:NULL methodList:MLNUserDataBaseFuncs nup:0 error:error];
    if (!ret) {
        return ret;
    }
    // 注册方法
    return [self openlib:classInfo nativeClassName:classInfo->clz error:error];
}

- (BOOL)openlib:(const mln_objc_class *)libInfo nativeClassName:(const char *)nativeClassName error:(NSError **)error
{
    NSParameterAssert(libInfo != NULL);
    if (MLNHasSuperClass(libInfo)) {
        MLNAssert(self.luaCore, charpNotEmpty(libInfo->supreClz), @"%s's super not found!", libInfo->clz);
        NSAssert(libInfo->supreClz != NULL, @"%s'super class must not be null!", libInfo->clz);
        Class<MLNEntityExportProtocol> superClass = NSClassFromString([NSString stringWithUTF8String:libInfo->supreClz]);
        if (![self openlib:[superClass mln_clazzInfo] nativeClassName:nativeClassName error:error]) {
            return NO;
        }
    }
    return [self.luaCore openLib:NULL nativeClassName:nativeClassName methodList:libInfo->methods nup:0 error:error];
}

- (BOOL)registerConstructor:(lua_CFunction)cfunc clazz:(const char *)nativeClazzName constructor:(const char *)nativeConstructorName luaName:(const char *)luaName error:(NSError **)error
{
    NSParameterAssert(charpNotEmpty(nativeClazzName));
    NSParameterAssert(charpNotEmpty(luaName));
    lua_State *L = self.luaCore.state;
    if (!L) {
        if (error) {
            *error = [NSError mln_errorState:@"Lua state is released"];
            MLNError(self.luaCore, @"Lua state is released");
        }
        return NO;
    }
    lua_checkstack(L, 12);
    lua_pushstring(L, nativeClazzName);
    lua_pushboolean(L, NO); // 不是属性
    lua_pushstring(L, charpNotEmpty(nativeConstructorName) ? nativeConstructorName : "initWithLuaCore:");
    lua_pushcclosure(L, cfunc, 3);
    lua_setglobal(L, luaName);
    return YES;
}

@end
