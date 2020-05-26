//
//  MLNUIEntityExporter.m
//  MLNUICore
//
//  Created by MoMo on 2019/7/23.
//

#import "MLNUIEntityExporter.h"
#import "NSError+MLNUICore.h"
#import "NSObject+MLNUICore.h"
#import "MLNUILuaCore.h"
#import "MLNUIEntityExportProtocol.h"

@implementation MLNUIEntityExporter

static int mlnui_luaui_user_data_gc (lua_State *L) {
    MLNUIUserData *user = (MLNUIUserData *)lua_touserdata(L, 1);
    if( user && user->object ){
        NSObject<MLNUIEntityExportProtocol> *obj = (__bridge NSObject<MLNUIEntityExportProtocol> *)(user->object);
        [obj mlnui_luaRelease];
        user->object = NULL;
        if ([obj mlnui_isConvertible] && [obj mlnui_luaRetainCount] == 0) {
            if ([obj respondsToSelector:@selector(mlnui_user_data_dealloc)]) {
                [(NSObject<MLNUIEntityExportProtocol> *)obj mlnui_user_data_dealloc];
            }
        }
    }
    return 0;
}

static int mlnui_luaui_user_data_tostring (lua_State *L) {
    MLNUIUserData * user = (MLNUIUserData *)lua_touserdata(L, 1);
    if(user){
        NSObject * obj =  (__bridge NSObject *)(user->object);
        NSString* des = [NSString stringWithFormat:@"<[ UserData: %@ ]>", [obj description]];
        lua_pushstring(L, des.UTF8String);
        return 1;
    }
    return 0;
}

static int mlnui_luaui_obj_equal (lua_State *L) {
    BOOL isEqual = NO;
    if (lua_gettop(L) == 2) {
        MLNUIUserData * user_1 = (MLNUIUserData *)lua_touserdata(L, 1);
        MLNUIUserData * user_2 = (MLNUIUserData *)lua_touserdata(L, 2);
        if (user_1 && user_2) {
            NSObject * obj_1 =  (__bridge NSObject *)(user_1->object);
            NSObject * obj_2 =  (__bridge NSObject *)(user_2->object);
            isEqual = obj_1 == obj_2;
        }
    }
    lua_pushboolean(L, isEqual);
    return 1;
}

static const struct luaL_Reg MLNUIUserDataBaseFuncs [] = {
    {"__gc", mlnui_luaui_user_data_gc},
    {"__tostring", mlnui_luaui_user_data_tostring},
    {"__eq", mlnui_luaui_obj_equal},
    {NULL, NULL}
};

- (BOOL)exportClass:(Class<MLNUIExportProtocol>)clazz error:(NSError **)error
{
    NSParameterAssert(clazz);
    Class<MLNUIEntityExportProtocol> exportClazz = (Class<MLNUIEntityExportProtocol>)clazz;
    const mlnui_objc_class *classInfo = [exportClazz mlnui_clazzInfo];
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
    ret = [self.luaCore openCLib:NULL methodList:MLNUIUserDataBaseFuncs nup:0 error:error];
    if (!ret) {
        return ret;
    }
    // 注册方法
    return [self openlib:classInfo nativeClassName:classInfo->clz error:error];
}

- (BOOL)openlib:(const mlnui_objc_class *)libInfo nativeClassName:(const char *)nativeClassName error:(NSError **)error
{
    NSParameterAssert(libInfo != NULL);
    if (MLNUIHasSuperClass(libInfo)) {
        MLNUIAssert(self.luaCore, charpNotEmpty(libInfo->supreClz), @"%s's super not found!", libInfo->clz);
        NSAssert(libInfo->supreClz != NULL, @"%s'super class must not be null!", libInfo->clz);
        Class<MLNUIEntityExportProtocol> superClass = NSClassFromString([NSString stringWithUTF8String:libInfo->supreClz]);
        if (![self openlib:[superClass mlnui_clazzInfo] nativeClassName:nativeClassName error:error]) {
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
            *error = [NSError mlnui_errorState:@"Lua state is released"];
            MLNUIError(self.luaCore, @"Lua state is released");
        }
        return NO;
    }
    lua_checkstack(L, 12);
    lua_pushstring(L, nativeClazzName);
    lua_pushboolean(L, NO); // 不是属性
    lua_pushstring(L, charpNotEmpty(nativeConstructorName) ? nativeConstructorName : "initWithMLNUILuaCore:");
    lua_pushcclosure(L, cfunc, 3);
    lua_setglobal(L, luaName);
    return YES;
}

@end
