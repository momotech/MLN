//
//  MLNUIViewGlobalVar.m
//  MLNUI
//
//  Created by MoMo on 2019/8/3.
//

#import "MLNUIViewConst.h"
#import "MLNUIGlobalVarExporterMacro.h"
#import "MLNUILayoutMacro.h"
#import <ArgoAnimation/MLAInteractiveBehaviorProtocol.h>

@implementation MLNUIViewConst

+ (UIRectCorner)convertToRectCorner:(MLNUIRectCorner)corners
{
    return UIRectCornerAllCorners;
}

#pragma mark - Setup For Lua
LUAUI_EXPORT_GLOBAL_VAR_BEGIN()
LUAUI_EXPORT_GLOBAL_VAR(StatusBarStyle, (@{@"Default": @(MLNUIStatusBarStyleDefault),
                                           @"Light": @(MLNUIStatusBarStyleLight)}))

LUAUI_EXPORT_GLOBAL_VAR(StatusMode, (@{@"NON_FULLSCREEN":@(MLNUIStatusBarModeNoneFullScreen),
                                       @"FULLSCREEN":@(MLNUIStatusBarModeFullScreen),
                                       @"TRANSLUCENT":@(MLNUIStatusBarModeTransparency)}))


LUAUI_EXPORT_GLOBAL_VAR(RectCorner, (@{@"TOP_LEFT":@(MLNUIRectCornerTopLeft),
                                       @"TOP_RIGHT":@(MLNUIRectCornerTopRight),
                                       @"BOTTOM_RIGHT":@(MLNUIRectCornerBottomRight),
                                       @"BOTTOM_LEFT":@(MLNUIRectCornerBottomLeft),
                                       @"ALL_CORNERS":@(MLNUIRectCornerAllCorners)}))

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

/**** MLNUILayout ****/
LUAUI_EXPORT_GLOBAL_VAR(MainAxis, (@{@"START":@(MLNUIJustifyFlexStart),
                                     @"CENTER":@(MLNUIJustifyCenter),
                                     @"END":@(MLNUIJustifyFlexEnd),
                                     @"SPACE_BETWEEN":@(MLNUIJustifySpaceBetween),
                                     @"SPACE_AROUND":@(MLNUIJustifySpaceAround),
                                     @"SPACE_EVENLY":@(MLNUIJustifySpaceEvenly)}))

LUAUI_EXPORT_GLOBAL_VAR(CrossAxis, (@{@"AUTO":@(MLNUIAlignAuto),
                                      @"START":@(MLNUIAlignStart),
                                      @"CENTER":@(MLNUIAlignCenter),
                                      @"END":@(MLNUIAlignEnd),
                                      @"STRETCH":@(MLNUIAlignStretch),
                                      @"BASELINE":@(MLNUIAlignBaseline),
                                      @"SPACE_BETWEEN":@(MLNUIAlignSpaceBetween),
                                      @"SPACE_AROUND":@(MLNUIAlignSpaceAround)}))

LUAUI_EXPORT_GLOBAL_VAR(Wrap, (@{@"NO_WRAP":@(MLNUIWrapNoWrap),
                                 @"WRAP":@(MLNUIWrapWrap),
                                 @"WRAP_REVERSE":@(MLNUIWrapWrapReverse)}))

LUAUI_EXPORT_GLOBAL_VAR(Flex, (@{@"UNDEFINED":@(NAN)}))

LUAUI_EXPORT_GLOBAL_VAR(PositionType, (@{@"RELATIVE":@(MLNUIPositionTypeRelative),
                                         @"ABSOLUTE":@(MLNUIPositionTypeAbsolute)}))

LUAUI_EXPORT_GLOBAL_VAR(InteractiveType, (@{@"GESTURE":@(InteractiveType_Gesture),
                                            @"SCALE":@(InteractiveType_Scale),
                                            @"ROTATE":@(InteractiveType_Rotate)}))
LUAUI_EXPORT_GLOBAL_VAR(InteractiveDirection, (@{@"X":@(InteractiveDirection_X),
                                                 @"Y":@(InteractiveDirection_Y)}))
LUAUI_EXPORT_GLOBAL_VAR(TouchType, (@{@"BEGIN" : @(MLNUITouchType_Begin),
                                      @"MOVE" : @(MLNUITouchType_Move),
                                      @"END" : @(MLNUITouchType_End)}))

LUAUI_EXPORT_GLOBAL_VAR_END()


@end
