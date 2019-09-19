//
//  MLNStaticExporterMacro.h
//  MLNCore
//
//  Created by MoMo on 2019/8/1.
//

#ifndef MLNStaticExporterMacro_h
#define MLNStaticExporterMacro_h

#import "MLNExporterMacro.h"

/**
 标记开始静态导出
 
 @param CLZ 原生类名
 */
#define LUA_EXPORT_STATIC_BEGIN(CLZ)  LUA_EXPORT_MAKE_METHOD_LIST(mln_Class_Method_, CLZ)

/**
 导出静态方法映射
 
 @param LUA_FUNC 在Lua中使用的方法名称
 @param SEL_NAME 在原生中类方法的方法名C字符串
 @param CLZ 类名称
 */
#define LUA_EXPORT_STATIC_METHOD(LUA_FUNC, SEL_NAME, CLZ) \
LUA_EXPORT_METHOD_LIST_ADD(#LUA_FUNC, SEL_NAME, #CLZ, NO, NULL, NULL, mln_lua_class_method)

/**
 导出C函数映射
 
 @param LUA_FUNC 在Lua中使用的方法名称
 @param FUNC C的Function
 @param CLZ 类名称
 */
#define LUA_EXPORT_STATIC_C_FUNC(LUA_FUNC, FUNC, CLZ) \
LUA_EXPORT_METHOD_LIST_ADD(#LUA_FUNC, "C_FUNC", #CLZ, NO, NULL, NULL, FUNC)

/**
 LuaCore相关方法注册

 @param CLZ 当前类
 */
#define LUA_EXPORT_STATIC_LUA_CORE(CLZ) \
static __weak MLNLuaCore *currentLuaCore_ ## CLZ = nil;\
+ (MLNLuaCore *)mln_currentLuaCore\
{\
    return currentLuaCore_ ## CLZ;\
}\
\
+ (void)mln_updateCurrentLuaCore:(MLNLuaCore *)luaCore\
{\
    currentLuaCore_ ## CLZ = luaCore;\
}

/**
  标记完成静态导出
 
 @param CLZ 原生类名称
 @param PACKAGE Lua中的包名
 @param LUA_NAME Lua中的类名称
 @param HAS_SUPER 是否有父类 (YES/NO)，这是在Lua中的继承关系，并非原生的继承关系
 @param SUPERCLZ 父类的原生类名字，可以没有原生的继承关系。
 */
#define LUA_EXPORT_PACKAGE_STATIC_END(CLZ, PACKAGE, LUA_CLZ, HAS_SUPER, SUPER_CLZ_NAME) \
LUA_EXPORT_METHOD_LIST_COMPLETED \
LUA_EXPORT_MAKE_INFO(PACKAGE, #CLZ, #LUA_CLZ, "MLN_UserDataNativeObject", HAS_SUPER, SUPER_CLZ_NAME, NO, NULL,\
(struct mln_objc_method *)mln_Class_Method_ ## CLZ, NULL, CLZ)\
LUA_EXPORT_TYPE(MLNExportTypeStatic)\
LUA_EXPORT_STATIC_LUA_CORE(CLZ)

/**
 标记完成静态导出
 
 @param CLZ 原生类名称
 @param LUA_NAME Lua中的类名称
 @param HAS_SUPER 是否有父类 (YES/NO)，这是在Lua中的继承关系，并非原生的继承关系
 @param SUPERCLZ 父类的原生类名字，可以没有原生的继承关系。
 */
#define LUA_EXPORT_STATIC_END(CLZ, LUA_CLZ, HAS_SUPER, SUPER_CLZ_NAME) \
LUA_EXPORT_PACKAGE_STATIC_END(CLZ, "mln", LUA_CLZ, HAS_SUPER, SUPER_CLZ_NAME)\

#endif /* MLNStaticExporterMacro_h */
