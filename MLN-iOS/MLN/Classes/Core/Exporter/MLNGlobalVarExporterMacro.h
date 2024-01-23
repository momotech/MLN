//
//  MLNGlobalVarExporterMacro.h
//  MLNCore
//
//  Created by MoMo on 2019/8/1.
//

#ifndef MLNGlobalVarExporterMacro_h
#define MLNGlobalVarExporterMacro_h

#import "MLNExporterMacro.h"

/**
 标记导出全局变量类开始
 */
#define LUA_EXPORT_GLOBAL_VAR_BEGIN()\
+ (NSArray<NSDictionary *> *)mln_globalVarMap \
{\
return @[\

/**
 导出全局变量类到Lua
 
 @param LUA_NAME Lua中变量名称
 @param LUA_VALUES 包含所有变量的字典
 */
#define LUA_EXPORT_GLOBAL_VAR(LUA_NAME, LUA_VALUES) \
@{kGlobalVarLuaName: (@#LUA_NAME),\
kGlobalVarMap: LUA_VALUES},\

/**
 导出全局变量结束
 */
#define LUA_EXPORT_GLOBAL_VAR_END(CLZ) \
];\
}\
LUA_EXPORT_TYPE(MLNExportTypeGlobalVar)\
LUA_ExportBind(CLZ, CLZ)

#endif /* MLNGlobalVarExporterMacro_h */
