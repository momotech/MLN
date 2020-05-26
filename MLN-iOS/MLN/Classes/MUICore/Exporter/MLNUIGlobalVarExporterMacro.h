//
//  MLNUIGlobalVarExporterMacro.h
//  MLNUICore
//
//  Created by MoMo on 2019/8/1.
//

#ifndef MLNUIGlobalVarExporterMacro_h
#define MLNUIGlobalVarExporterMacro_h

#import "MLNUIExporterMacro.h"

/**
 标记导出全局变量类开始
 */
#define LUAUI_EXPORT_GLOBAL_VAR_BEGIN()\
+ (NSArray<NSDictionary *> *)mlnui_globalVarMap \
{\
return @[\

/**
 导出全局变量类到Lua
 
 @param LUA_NAME Lua中变量名称
 @param LUA_VALUES 包含所有变量的字典
 */
#define LUAUI_EXPORT_GLOBAL_VAR(LUA_NAME, LUA_VALUES) \
@{kGlobalVarLuaName: (@#LUA_NAME),\
kGlobalVarMap: LUA_VALUES},\

/**
 导出全局变量结束
 */
#define LUAUI_EXPORT_GLOBAL_VAR_END() \
];\
}\
LUAUI_EXPORT_TYPE(MLNUIExportTypeGlobalVar)

#endif /* MLNUIGlobalVarExporterMacro_h */
