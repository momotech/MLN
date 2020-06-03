//
//  MLNUIStyleStringConst.m
//
//
//  Created by MoMo on 2019/7/30.
//

#import "MLNUIStyleStringConst.h"
#import "MLNUIGlobalVarExporterMacro.h"

@implementation MLNUIStyleStringConst

#pragma mark - Setup For Lua
LUAUI_EXPORT_GLOBAL_VAR_BEGIN()
LUAUI_EXPORT_GLOBAL_VAR(StyleImageAlign, (@{@"Default": @(MLNUIStyleImageAlignTypeDefault),
                                         @"Top": @(MLNUIStyleImageAlignTypeTop),
                                         @"Center": @(MLNUIStyleImageAlignTypeCenter),
                                         @"Bottom": @(MLNUIStyleImageAlignTypeBottom)}))
LUAUI_EXPORT_GLOBAL_VAR_END()
@end
