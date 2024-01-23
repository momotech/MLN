//
//  MLNViewGlobalVar.m
//  MLN
//
//  Created by MoMo on 2019/8/3.
//

#import "MLNViewConst.h"
#import "MLNGlobalVarExporterMacro.h"

@implementation MLNViewConst

+ (UIRectCorner)convertToRectCorner:(MLNRectCorner)corners
{
    return UIRectCornerAllCorners;
}

#pragma mark - Setup For Lua
LUA_EXPORT_GLOBAL_VAR_BEGIN()
LUA_EXPORT_GLOBAL_VAR(StatusBarStyle, (@{@"Default": @(MLNStatusBarStyleDefault),
                                         @"Light": @(MLNStatusBarStyleLight)}))
LUA_EXPORT_GLOBAL_VAR(RectCorner, (@{@"TOP_LEFT":@(MLNRectCornerTopLeft),
                                     @"TOP_RIGHT":@(MLNRectCornerTopRight),
                                     @"BOTTOM_RIGHT":@(MLNRectCornerBottomRight),
                                     @"BOTTOM_LEFT":@(MLNRectCornerBottomLeft),
                                     @"ALL_CORNERS":@(MLNRectCornerAllCorners)}))
LUA_EXPORT_GLOBAL_VAR(LinearType, (@{@"HORIZONTAL":@(MLNLayoutDirectionHorizontal),
                                     @"VERTICAL":@(MLNLayoutDirectionVertical)}))
LUA_EXPORT_GLOBAL_VAR(Gravity, (@{@"LEFT":@(MLNGravityLeft),
                                  @"TOP":@(MLNGravityTop),
                                  @"RIGHT":@(MLNGravityRight),
                                  @"BOTTOM":@(MLNGravityBottom),
                                  @"CENTER_HORIZONTAL":@(MLNGravityCenterHorizontal),
                                  @"CENTER_VERTICAL":@(MLNGravityCenterVertical),
                                  @"CENTER":@(MLNGravityCenter)}))
LUA_EXPORT_GLOBAL_VAR(MeasurementType, (@{@"MATCH_PARENT":@(MLNLayoutMeasurementTypeMatchParent),
                                          @"WRAP_CONTENT":@(MLNLayoutMeasurementTypeWrapContent)}))
LUA_EXPORT_GLOBAL_VAR(ValueType, (@{@"NONE":@(MLNValueTypeNone),
                                    @"CURRENT":@(MLNValueTypeCurrent)}))
LUA_EXPORT_GLOBAL_VAR(GradientType, (@{@"LEFT_TO_RIGHT":@(MLNGradientTypeLeftToRight),
                                       @"RIGHT_TO_LEFT":@(MLNGradientTypeRightToLeft),
                                       @"TOP_TO_BOTTOM":@(MLNGradientTypeTopToBottom),
                                       @"BOTTOM_TO_TOP":@(MLNGradientTypeBottomToTop)}))
LUA_EXPORT_GLOBAL_VAR(TabSegmentAlignment, (@{@"LEFT":@(MLNTabSegmentAlignmentLeft),
                                              @"CENTER":@(MLNTabSegmentAlignmentCenter),
                                              @"RIGHT":@(MLNTabSegmentAlignmentRight)}))
LUA_EXPORT_GLOBAL_VAR(SafeArea, (@{@"CLOSE":@(MLNSafeAreaClose),
                                   @"LEFT":@(MLNSafeAreaLeft),
                                   @"TOP":@(MLNSafeAreaTop),
                                   @"RIGHT":@(MLNSafeAreaRight),
                                   @"BOTTOM":@(MLNSafeAreaBottom)}))

LUA_EXPORT_GLOBAL_VAR_END(MLNViewConst)


@end
