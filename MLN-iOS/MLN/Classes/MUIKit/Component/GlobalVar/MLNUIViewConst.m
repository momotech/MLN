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
LUAUI_EXPORT_GLOBAL_VAR_BEGIN()
LUAUI_EXPORT_GLOBAL_VAR(StatusBarStyle, (@{@"Default": @(MLNUIStatusBarStyleDefault),
                                         @"Light": @(MLNUIStatusBarStyleLight)}))
LUAUI_EXPORT_GLOBAL_VAR(RectCorner, (@{@"TOP_LEFT":@(MLNUIRectCornerTopLeft),
                                     @"TOP_RIGHT":@(MLNUIRectCornerTopRight),
                                     @"BOTTOM_RIGHT":@(MLNUIRectCornerBottomRight),
                                     @"BOTTOM_LEFT":@(MLNUIRectCornerBottomLeft),
                                     @"ALL_CORNERS":@(MLNUIRectCornerAllCorners)}))
LUAUI_EXPORT_GLOBAL_VAR(LinearType, (@{@"HORIZONTAL":@(MLNUILayoutDirectionHorizontal),
                                     @"VERTICAL":@(MLNUILayoutDirectionVertical)}))
LUAUI_EXPORT_GLOBAL_VAR(Gravity, (@{@"LEFT":@(MLNUIGravityLeft),
                                  @"TOP":@(MLNUIGravityTop),
                                  @"RIGHT":@(MLNUIGravityRight),
                                  @"BOTTOM":@(MLNUIGravityBottom),
                                  @"CENTER_HORIZONTAL":@(MLNUIGravityCenterHorizontal),
                                  @"CENTER_VERTICAL":@(MLNUIGravityCenterVertical),
                                  @"CENTER":@(MLNUIGravityCenter)}))
LUAUI_EXPORT_GLOBAL_VAR(MeasurementType, (@{@"MATCH_PARENT":@(MLNUILayoutMeasurementTypeMatchParent),
                                          @"WRAP_CONTENT":@(MLNUILayoutMeasurementTypeWrapContent)}))
LUAUI_EXPORT_GLOBAL_VAR(ValueType, (@{@"NONE":@(MLNUIValueTypeNone),
                                    @"CURRENT":@(MLNUIValueTypeCurrent)}))
LUAUI_EXPORT_GLOBAL_VAR(GradientType, (@{@"LEFT_TO_RIGHT":@(MLNUIGradientTypeLeftToRight),
                                       @"RIGHT_TO_LEFT":@(MLNUIGradientTypeRightToLeft),
                                       @"TOP_TO_BOTTOM":@(MLNUIGradientTypeTopToBottom),
                                       @"BOTTOM_TO_TOP":@(MLNUIGradientTypeBottomToTop)}))
LUAUI_EXPORT_GLOBAL_VAR(TabSegmentAlignment, (@{@"LEFT":@(MLNUITabSegmentAlignmentLeft),
                                              @"CENTER":@(MLNUITabSegmentAlignmentCenter),
                                              @"RIGHT":@(MLNUITabSegmentAlignmentRight)}))
LUAUI_EXPORT_GLOBAL_VAR(SafeArea, (@{@"CLOSE":@(MLNUISafeAreaClose),
                                   @"LEFT":@(MLNUISafeAreaLeft),
                                   @"TOP":@(MLNUISafeAreaTop),
                                   @"RIGHT":@(MLNUISafeAreaRight),
                                   @"BOTTOM":@(MLNUISafeAreaBottom)}))

LUAUI_EXPORT_GLOBAL_VAR_END()


@end
