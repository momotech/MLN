//
//  MLNUIViewGlobalVar.m
//  MLNUI
//
//  Created by MoMo on 2019/8/3.
//

#import "MLNUIViewConst.h"
#import "MLNUIGlobalVarExporterMacro.h"

@implementation MLNUIViewConst

+ (UIRectCorner)convertToRectCorner:(MLNUIRectCorner)corners
{
    return UIRectCornerAllCorners;
}

#pragma mark - Setup For Lua
LUA_EXPORT_GLOBAL_VAR_BEGIN()
LUA_EXPORT_GLOBAL_VAR(StatusBarStyle, (@{@"Default": @(MLNUIStatusBarStyleDefault),
                                         @"Light": @(MLNUIStatusBarStyleLight)}))
LUA_EXPORT_GLOBAL_VAR(RectCorner, (@{@"TOP_LEFT":@(MLNUIRectCornerTopLeft),
                                     @"TOP_RIGHT":@(MLNUIRectCornerTopRight),
                                     @"BOTTOM_RIGHT":@(MLNUIRectCornerBottomRight),
                                     @"BOTTOM_LEFT":@(MLNUIRectCornerBottomLeft),
                                     @"ALL_CORNERS":@(MLNUIRectCornerAllCorners)}))
LUA_EXPORT_GLOBAL_VAR(LinearType, (@{@"HORIZONTAL":@(MLNUILayoutDirectionHorizontal),
                                     @"VERTICAL":@(MLNUILayoutDirectionVertical)}))
LUA_EXPORT_GLOBAL_VAR(Gravity, (@{@"LEFT":@(MLNUIGravityLeft),
                                  @"TOP":@(MLNUIGravityTop),
                                  @"RIGHT":@(MLNUIGravityRight),
                                  @"BOTTOM":@(MLNUIGravityBottom),
                                  @"CENTER_HORIZONTAL":@(MLNUIGravityCenterHorizontal),
                                  @"CENTER_VERTICAL":@(MLNUIGravityCenterVertical),
                                  @"CENTER":@(MLNUIGravityCenter)}))
LUA_EXPORT_GLOBAL_VAR(MeasurementType, (@{@"MATCH_PARENT":@(MLNUILayoutMeasurementTypeMatchParent),
                                          @"WRAP_CONTENT":@(MLNUILayoutMeasurementTypeWrapContent)}))
LUA_EXPORT_GLOBAL_VAR(ValueType, (@{@"NONE":@(MLNUIValueTypeNone),
                                    @"CURRENT":@(MLNUIValueTypeCurrent)}))
LUA_EXPORT_GLOBAL_VAR(GradientType, (@{@"LEFT_TO_RIGHT":@(MLNUIGradientTypeLeftToRight),
                                       @"RIGHT_TO_LEFT":@(MLNUIGradientTypeRightToLeft),
                                       @"TOP_TO_BOTTOM":@(MLNUIGradientTypeTopToBottom),
                                       @"BOTTOM_TO_TOP":@(MLNUIGradientTypeBottomToTop)}))
LUA_EXPORT_GLOBAL_VAR(TabSegmentAlignment, (@{@"LEFT":@(MLNUITabSegmentAlignmentLeft),
                                              @"CENTER":@(MLNUITabSegmentAlignmentCenter),
                                              @"RIGHT":@(MLNUITabSegmentAlignmentRight)}))
LUA_EXPORT_GLOBAL_VAR(SafeArea, (@{@"CLOSE":@(MLNUISafeAreaClose),
                                   @"LEFT":@(MLNUISafeAreaLeft),
                                   @"TOP":@(MLNUISafeAreaTop),
                                   @"RIGHT":@(MLNUISafeAreaRight),
                                   @"BOTTOM":@(MLNUISafeAreaBottom)}))

LUA_EXPORT_GLOBAL_VAR_END()


@end
