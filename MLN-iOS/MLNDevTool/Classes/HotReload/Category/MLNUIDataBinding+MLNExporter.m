//
//  MLNUIDataBinding+MLNExporter.m
//  MLNDevTool
//
//  Created by Dai Dongpeng on 2020/5/26.
//

#import "MLNUIDataBinding+MLNExporter.h"
#import "MLNStaticExporterMacro.h"
#import "MLNUIStaticExporterMacro.h"

@implementation MLNUIDataBinding (MLNExporter)

LUA_EXPORT_STATIC_BEGIN(MLNUIDataBinding)
LUA_EXPORT_STATIC_METHOD(bind, "luaui_watchDataForKeys:handler:", MLNUIDataBinding)
LUA_EXPORT_STATIC_METHOD(update, "luaui_updateDataForKeys:value:", MLNUIDataBinding)
LUA_EXPORT_STATIC_METHOD(get, "luaui_dataForKeys:", MLNUIDataBinding)
LUA_EXPORT_STATIC_METHOD(remove, "luaui_removeMLNUIObserverByID:", MLNUIDataBinding)

LUA_EXPORT_STATIC_METHOD(mock, "luaui_mockForKey:data:", MLNUIDataBinding)
LUA_EXPORT_STATIC_METHOD(mockArray, "luaui_mockArrayForKey:data:callbackDic:", MLNUIDataBinding)

LUA_EXPORT_STATIC_METHOD(bindListView, "luaui_bindListViewForKey:listView:", MLNUIDataBinding)
LUA_EXPORT_STATIC_METHOD(getSectionCount, "luaui_sectionCountForKey:", MLNUIDataBinding)
LUA_EXPORT_STATIC_METHOD(getRowCount, "luaui_rowCountForKey:section:", MLNUIDataBinding)
LUA_EXPORT_STATIC_METHOD(getModel, "luaui_modelForKey:section:row:path:", MLNUIDataBinding)
LUA_EXPORT_STATIC_METHOD(updateModel, "luaui_updateModelForKey:section:row:path:value:", MLNUIDataBinding)
//LUA_EXPORT_STATIC_METHOD(getReuseId, "luaui_reuseIdForKey:section:row:", MLNUIDataBinding)
//LUA_EXPORT_STATIC_METHOD(getHeight, "luaui_heightForKey:section:row:", MLNUIDataBinding)
LUA_EXPORT_STATIC_METHOD(bindCell, "luaui_bindCellForKey:section:row:paths:", MLNUIDataBinding)

//LUA_EXPORT_STATIC_METHOD(getSize, "luaui_sizeForKey:section:row:", MLNUIDataBinding)
LUA_EXPORT_STATIC_METHOD(bindArray, "luaui_bindArrayForKeyPath:handler:", MLNUIDataBinding)
LUA_EXPORT_STATIC_METHOD(bindArrayData, "luaui_bindArrayDataForKey:index:dataKeyPath:handler:", MLNUIDataBinding)
LUA_EXPORT_STATIC_METHOD(updateArrayData, "luaui_updateArrayDataForKey:index:dataKeyPath:newValue:", MLNUIDataBinding)
LUA_EXPORT_STATIC_METHOD(getArrayData, "luaui_getArrayDataForKey:index:dataKeyPath:", MLNUIDataBinding)
LUA_EXPORT_STATIC_METHOD(aliasArrayData, "luaui_aliasArrayDataForKey:index:alias:", MLNUIDataBinding)

LUA_EXPORT_STATIC_END(MLNUIDataBinding, DataBinding, NO, NULL)


LUAUI_EXPORT_STATIC_BEGIN(MLNUIDataBinding)
LUAUI_EXPORT_STATIC_METHOD(bind, "luaui_watchDataForKeys:handler:", MLNUIDataBinding)
LUAUI_EXPORT_STATIC_METHOD(update, "luaui_updateDataForKeys:value:", MLNUIDataBinding)
LUAUI_EXPORT_STATIC_METHOD(get, "luaui_dataForKeys:", MLNUIDataBinding)
LUAUI_EXPORT_STATIC_METHOD(remove, "luaui_removeMLNUIObserverByID:", MLNUIDataBinding)

LUAUI_EXPORT_STATIC_METHOD(mock, "luaui_mockForKey:data:", MLNUIDataBinding)
LUAUI_EXPORT_STATIC_METHOD(mockArray, "luaui_mockArrayForKey:data:callbackDic:", MLNUIDataBinding)

LUAUI_EXPORT_STATIC_METHOD(bindListView, "luaui_bindListViewForKey:listView:", MLNUIDataBinding)
LUAUI_EXPORT_STATIC_METHOD(getSectionCount, "luaui_sectionCountForKey:", MLNUIDataBinding)
LUAUI_EXPORT_STATIC_METHOD(getRowCount, "luaui_rowCountForKey:section:", MLNUIDataBinding)
LUAUI_EXPORT_STATIC_METHOD(getModel, "luaui_modelForKey:section:row:path:", MLNUIDataBinding)
LUAUI_EXPORT_STATIC_METHOD(updateModel, "luaui_updateModelForKey:section:row:path:value:", MLNUIDataBinding)
//LUAUI_EXPORT_STATIC_METHOD(getReuseId, "luaui_reuseIdForKey:section:row:", MLNUIDataBinding)
//LUAUI_EXPORT_STATIC_METHOD(getHeight, "luaui_heightForKey:section:row:", MLNUIDataBinding)
LUAUI_EXPORT_STATIC_METHOD(bindCell, "luaui_bindCellForKey:section:row:paths:", MLNUIDataBinding)

//LUAUI_EXPORT_STATIC_METHOD(getSize, "luaui_sizeForKey:section:row:", MLNUIDataBinding)
LUAUI_EXPORT_STATIC_METHOD(bindArray, "luaui_bindArrayForKeyPath:handler:", MLNUIDataBinding)
LUAUI_EXPORT_STATIC_METHOD(bindArrayData, "luaui_bindArrayDataForKey:index:dataKeyPath:handler:", MLNUIDataBinding)
LUAUI_EXPORT_STATIC_METHOD(updateArrayData, "luaui_updateArrayDataForKey:index:dataKeyPath:newValue:", MLNUIDataBinding)
LUAUI_EXPORT_STATIC_METHOD(getArrayData, "luaui_getArrayDataForKey:index:dataKeyPath:", MLNUIDataBinding)
LUAUI_EXPORT_STATIC_METHOD(aliasArrayData, "luaui_aliasArrayDataForKey:index:alias:", MLNUIDataBinding)

LUAUI_EXPORT_STATIC_END(MLNUIDataBinding, DataBinding, NO, NULL)

@end
