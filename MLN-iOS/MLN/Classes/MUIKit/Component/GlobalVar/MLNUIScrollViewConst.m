//
//  MLNUIScrollViewGlobalVar.m
//  MLNUI
//
//  Created by MoMo on 2019/8/5.
//

#import "MLNUIScrollViewConst.h"
#import "MLNUIGlobalVarExporterMacro.h"

@implementation MLNUIScrollViewConst

#pragma mark - Setup For Lua
LUA_EXPORT_GLOBAL_VAR_BEGIN()
LUA_EXPORT_GLOBAL_VAR(ScrollDirection, (@{@"VERTICAL":@(MLNUIScrollDirectionVertical),
                                          @"HORIZONTAL":@(MLNUIScrollDirectionHorizontal)}))
LUA_EXPORT_GLOBAL_VAR_END()

@end
