//
//  MLNCanvasConst.m
//
//
//  Created by MoMo on 2019/7/19.
//

#import "MLNCanvasConst.h"
#import "MLNGlobalVarExporterMacro.h"

@implementation MLNCanvasConst

#pragma mark - Setup For Lua
LUA_EXPORT_GLOBAL_VAR_BEGIN()
LUA_EXPORT_GLOBAL_VAR(DrawStyle, (@{ @"Stroke": @(MLNCanvasDrawStyleStroke),
                                     @"Fill": @(MLNCanvasDrawStyleFill),
                                     @"FillStroke": @(MLNCanvasDrawStyleFillStroke)}))
LUA_EXPORT_GLOBAL_VAR(FillType, (@{@"WINDING": @(MLNCanvasFillTypeWinding),
                                   @"EVEN_ODD": @(MLNCanvasFillTypeEvenOdd)}))
LUA_EXPORT_GLOBAL_VAR_END()


@end
