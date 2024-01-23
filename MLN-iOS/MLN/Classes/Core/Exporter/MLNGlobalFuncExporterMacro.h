//
//  MLNGlobalFuncExporterMacro.h
//  MLNCore
//
//  Created by MoMo on 2019/8/1.
//

#ifndef MLNGlobalFuncExporterMacro_h
#define MLNGlobalFuncExporterMacro_h

#import "MLNStaticExporterMacro.h"

/**
 导出全局函数类开始
 */
#define LUA_EXPORT_GLOBAL_FUNC_BEGIN(CLZ)\
LUA_EXPORT_MAKE_METHOD_LIST(mln_Global_Method_,CLZ)

/**
 导出全局C方法到Lua
 
 @param LUA_FUNC 在Lua中使用的方法名称
 @param C_FUNC C的Function
 @param CLZ 原生类名称
 */
#define LUA_EXPORT_GLOBAL_C_FUNC(LUA_FUNC, C_FUNC, CLZ) \
LUA_EXPORT_METHOD_LIST_ADD(#LUA_FUNC, "NULL", #CLZ, NO, NULL, NULL, C_FUNC)

/**
 导出全局方法到Lua
 
 @param LUA_FUNC 在Lua中使用的方法名称
 @param SEL_NAME 在原生中类方法的方法名
 @param CLZ 原生类名称
 */
#define LUA_EXPORT_GLOBAL_FUNC(LUA_FUNC, SEL_NAME, CLZ) \
LUA_EXPORT_METHOD_LIST_ADD(#LUA_FUNC, SEL_NAME, #CLZ, NO, NULL, NULL, mln_lua_global_func)

/**
 导出全局函数类导出结束
 
 @param CLZ 原生类名称
 @param LUA_CLZ 表名称 (例：package)
 */
#define LUA_EXPORT_GLOBAL_FUNC_WITH_NAME_END(CLZ, LUA_CLZ, PKG) \
LUA_EXPORT_METHOD_LIST_COMPLETED \
LUA_EXPORT_MAKE_INFO(#PKG, #CLZ, #LUA_CLZ, "MLNGlbalFunction", YES, NULL, NO, NULL,\
(struct mln_objc_method *)mln_Global_Method_ ## CLZ, NULL, CLZ)\
LUA_EXPORT_TYPE(MLNExportTypeGlobalFunc)\
LUA_EXPORT_STATIC_LUA_CORE(CLZ)\
LUA_ExportBind(LUA_CLZ, CLZ)

/**
 导出全局函数类导出结束
 
 @param CLZ 类名称 (例：NSObject)
 @param LUA_CLZ 表名称 (例：package)
 */
#define LUA_EXPORT_GLOBAL_FUNC_END(CLZ) \
LUA_EXPORT_GLOBAL_FUNC_WITH_NAME_END(CLZ, CLZ, NULL)

#endif /* MLNGlobalFuncExporterMacro_h */
