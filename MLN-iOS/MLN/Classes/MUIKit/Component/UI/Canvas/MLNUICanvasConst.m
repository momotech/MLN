//
//  MLNUICanvasConst.m
//
//
//  Created by MoMo on 2019/7/19.
//

#import "MLNUICanvasConst.h"
#import "MLNUIGlobalVarExporterMacro.h"

@implementation MLNUICanvasConst

#pragma mark - Setup For Lua
LUAUI_EXPORT_GLOBAL_VAR_BEGIN()
LUAUI_EXPORT_GLOBAL_VAR(DrawStyle, (@{ @"Stroke": @(MLNUICanvasDrawStyleStroke),
                                     @"Fill": @(MLNUICanvasDrawStyleFill),
                                     @"FillStroke": @(MLNUICanvasDrawStyleFillStroke)}))
LUAUI_EXPORT_GLOBAL_VAR(FillType, (@{@"WINDING": @(MLNUICanvasFillTypeWinding),
                                   @"EVEN_ODD": @(MLNUICanvasFillTypeEvenOdd)}))
LUAUI_EXPORT_GLOBAL_VAR_END()


@end
