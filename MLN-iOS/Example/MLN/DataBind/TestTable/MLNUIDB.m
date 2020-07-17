//
//  MLNUIDB.m
//  LuaNative
//
//  Created by Dongpeng Dai on 2020/7/6.
//  Copyright © 2020 MoMo. All rights reserved.
//

#import "MLNUIDB.h"
#import "MLNUIKit.h"

@interface MLNUIDB ()
@property (nonatomic, weak) MLNUILuaCore *luaCore;
@end

@implementation MLNUIDB


//+ (char *)luaui_watchForKey:(NSString *)key handler:(id)handler {
//    NSLog(@"key %@ handler %@",key,handler);
//    return "sss";
//}

static int luaui_watch(lua_State *L) {
    mlnui_luaui_check_begin();
    mlnui_luaui_checkstring_rt(L, -2);
    mlnui_luaui_checkfunc_rt(L, -1);
    mlnui_luaui_check_end();
    
    MLNUILuaCore *luaCore = MLNUI_LUA_CORE(L);
    UIViewController<MLNUIDataBindingProtocol> *kitViewController = (UIViewController<MLNUIDataBindingProtocol> *)MLNUI_KIT_INSTANCE(luaCore).viewController;
    const char *key = lua_tostring(L, -2);
    
    lua_pushstring(L, "id=123");
    
    NSLog(@"key %p",L);
    return 1;
}

#if 0

//LUAUI_EXPORT_STATIC_BEGIN(MLNUIDB)
//LUAUI_EXPORT_STATIC_METHOD(watch, "luaui_watchForKey:handler:", MLNUIDB)
//LUAUI_EXPORT_STATIC_END(MLNUIDB, TestDB, NO, NULL)

LUAUI_EXPORT_GLOBAL_FUNC_BEGIN(MLNUIDB)
LUAUI_EXPORT_GLOBAL_C_FUNC(watch, luaui_watch, MLNUIDB)
LUAUI_EXPORT_GLOBAL_FUNC_WITH_NAME_END(MLNUIDB, NULL, NULL)

#else

static const struct mlnui_objc_method mlnui_Global_Method_MLNUIDB [] = {
    {("watch"), ("NULL"), ("MLNUIDB"), (__objc_no), (((void*)0)), (((void*)0)), (luaui_watch)},
    {((void*)0), ((void*)0), ((void*)0), __objc_no, ((void*)0), ((void*)0), ((void*)0)}
};

static const struct mlnui_objc_class mlnui_Clazz_Info_MLNUIDB = {
    "NULL","MLNUIDB","NULL","NULL" "." "NULL","MLNUIGlbalFunction",!(__objc_yes),((void*)0),__objc_no,((void*)0),(struct mlnui_objc_method *)mlnui_Global_Method_MLNUIDB,((void*)0)
};

+ (const mlnui_objc_class *)mlnui_clazzInfo{
    return &mlnui_Clazz_Info_MLNUIDB;
}

+ (MLNUIExportType)mlnui_exportType {
    return (MLNUIExportTypeGlobalFunc);
}

static __attribute__((objc_ownership(weak))) MLNUILuaCore *mlnui_currentLuaCore_MLNUIDB = ((void *)0);

+ (MLNUILuaCore *)mlnui_currentLuaCore{
    return mlnui_currentLuaCore_MLNUIDB;
}

+ (void)mlnui_updateCurrentLuaCore:(MLNUILuaCore *)luaCore{
    mlnui_currentLuaCore_MLNUIDB = luaCore;
}

#endif
@end
