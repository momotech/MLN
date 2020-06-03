//
//  MLNUIScaleType.m
//  
//
//  Created by MoMo on 2018/7/5.
//

#import "MLNUIContentMode.h"
#import "MLNUIGlobalVarExporterMacro.h"

@implementation MLNUIContentMode

#pragma mark - Setup For Lua
LUAUI_EXPORT_GLOBAL_VAR_BEGIN()
LUAUI_EXPORT_GLOBAL_VAR(ContentMode, (@{@"SCALE_ASPECT_FILL":@(UIViewContentModeScaleAspectFill),
                                      @"SCALE_ASPECT_FIT":@(UIViewContentModeScaleAspectFit),
                                      @"SCALE_TO_FILL":@(UIViewContentModeScaleToFill),
                                      @"CENTER":@(UIViewContentModeCenter)}))
LUAUI_EXPORT_GLOBAL_VAR_END()
@end
