//
//  MLNUIGlobalFuncExporterMacro.h
//  MLNUICore
//
//  Created by MoMo on 2019/8/1.
//

#ifndef MLNUIGlobalFuncExporterMacro_h
#define MLNUIGlobalFuncExporterMacro_h

#import "MLNUIStaticExporterMacro.h"

/**
 导出全局函数类开始
 */
#define LUAUI_EXPORT_GLOBAL_FUNC_BEGIN(CLZ)\
LUAUI_EXPORT_MAKE_METHOD_LIST(mlnui_Global_Method_,CLZ)

#define LUAUI_NEW_EXPORT_GLOBAL_FUNC_BEGIN(CLZ)\
LUAUI_EXPORT_MAKE_METHOD_LIST(mlnui_Global_Method_,CLZ)

/**
 导出全局C方法到Lua
 
 @param LUA_FUNC 在Lua中使用的方法名称
 @param C_FUNC C的Function
 @param CLZ 原生类名称
 */
#define LUAUI_EXPORT_GLOBAL_C_FUNC(LUA_FUNC, C_FUNC, CLZ) \
LUAUI_EXPORT_METHOD_LIST_ADD(#LUA_FUNC, "NULL", #CLZ, NO, NULL, NULL, C_FUNC)

#define LUAUI_NEW_EXPORT_GLOBAL_C_FUNC(LUA_FUNC, C_FUNC, CLZ) \
LUAUI_EXPORT_METHOD_LIST_ADD(#LUA_FUNC, "NULL", #CLZ, NO, NULL, NULL, C_FUNC)

/**
 导出全局方法到Lua
 
 @param LUA_FUNC 在Lua中使用的方法名称
 @param SEL_NAME 在原生中类方法的方法名
 @param CLZ 原生类名称
 */
#define LUAUI_EXPORT_GLOBAL_FUNC(LUA_FUNC, SEL_NAME, CLZ) \
LUAUI_EXPORT_METHOD_LIST_ADD(#LUA_FUNC, SEL_NAME, #CLZ, NO, NULL, NULL, mlnui_luaui_global_func)

/**
 导出全局函数类导出结束
 
 @param CLZ 原生类名称
 @param LUA_CLZ 表名称 (例：package)
 */
#define LUAUI_EXPORT_GLOBAL_FUNC_WITH_NAME_END(CLZ, LUA_CLZ, PKG) \
LUAUI_EXPORT_METHOD_LIST_COMPLETED \
LUAUI_EXPORT_MAKE_INFO(#PKG, #CLZ, #LUA_CLZ, "MLNUIGlbalFunction", YES, NULL, NO, NULL,\
(struct mlnui_objc_method *)mlnui_Global_Method_ ## CLZ, NULL, CLZ)\
LUAUI_EXPORT_TYPE(MLNUIExportTypeGlobalFunc)\
LUAUI_EXPORT_STATIC_LUA_CORE(CLZ)

/**
 导出全局函数类导出结束
 
 @param CLZ 原生类名称
 @param LUA_CLZ 表名称 (例：package)
 */
#define LUAUI_NEW_EXPORT_GLOBAL_FUNC_WITH_NAME_END(CLZ, LUA_CLZ, PKG) \
LUAUI_EXPORT_METHOD_LIST_COMPLETED \
LUAUI_EXPORT_MAKE_INFO(#PKG, #CLZ, #LUA_CLZ, "MLNUIGlbalFunction", YES, NULL, NO, NULL,\
(struct mlnui_objc_method *)mlnui_Global_Method_ ## CLZ, NULL, CLZ)\
LUAUI_EXPORT_TYPE(MLNUIExportTypeStaticFunc)

/**
 导出全局函数类导出结束
 
 @param CLZ 类名称 (例：NSObject)
 @param LUA_CLZ 表名称 (例：package)
 */
#define LUAUI_EXPORT_GLOBAL_FUNC_END(CLZ) \
LUAUI_EXPORT_GLOBAL_FUNC_WITH_NAME_END(CLZ, NULL, NULL)

#endif /* MLNUIGlobalFuncExporterMacro_h */
