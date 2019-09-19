//
//  MLNScrollViewGlobalVar.m
//  MLN
//
//  Created by MoMo on 2019/8/5.
//

#import "MLNScrollViewConst.h"
#import "MLNGlobalVarExporterMacro.h"

@implementation MLNScrollViewConst

#pragma mark - Setup For Lua
LUA_EXPORT_GLOBAL_VAR_BEGIN()
LUA_EXPORT_GLOBAL_VAR(ScrollDirection, (@{@"VERTICAL":@(MLNScrollDirectionVertical),
                                          @"HORIZONTAL":@(MLNScrollDirectionHorizontal)}))
LUA_EXPORT_GLOBAL_VAR_END()

@end
