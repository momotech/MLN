//
//  MLNStyleStringConst.m
//
//
//  Created by MoMo on 2019/7/30.
//

#import "MLNStyleStringConst.h"
#import "MLNGlobalVarExporterMacro.h"

@implementation MLNStyleStringConst

#pragma mark - Setup For Lua
LUA_EXPORT_GLOBAL_VAR_BEGIN()
LUA_EXPORT_GLOBAL_VAR(StyleImageAlign, (@{@"Default": @(MLNStyleImageAlignTypeDefault),
                                         @"Top": @(MLNStyleImageAlignTypeTop),
                                         @"Center": @(MLNStyleImageAlignTypeCenter),
                                         @"Bottom": @(MLNStyleImageAlignTypeBottom)}))
LUA_EXPORT_GLOBAL_VAR_END()
@end
