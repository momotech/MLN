//
//  MLNUILinearLayout.m
//
//
//  Created by MoMo on 2018/10/15.
//

#import "MLNUILinearLayout.h"
#import "MLNUIViewExporterMacro.h"
#import "UIView+MLNUIKit.h"
#import "UIView+MLNUILayout.h"
#import "MLNUIKitHeader.h"

#define isGravityType(v,t) (((v).lua_gravity&(t)) == (t))

@interface MLNUILinearLayout ()


@end
@implementation MLNUILinearLayout

- (instancetype)initWithLuaCore:(MLNUILuaCore *)luaCore LayoutDirectionNumber:(NSNumber *)directionNum
{
    if (self = [super initWithLuaCore:luaCore]) {
        _direction = directionNum ? directionNum.unsignedIntegerValue : MLNUILayoutDirectionHorizontal;
    }
    return self;
}

- (instancetype)initWithLayoutDirection:(MLNUILayoutDirection)direction
{
    if (self = [super initWithFrame:CGRectZero]) {
        _direction = direction ? direction : MLNUILayoutDirectionHorizontal;
    }
    return self;
}

#pragma mark - Override
- (void)lua_bringSubviewToFront:(UIView *)view
{
    MLNUIKitLuaAssert(NO, @"LinearLayout does not support bringSubviewToFront method");
}

- (void)lua_sendSubviewToBack:(UIView *)view
{
    MLNUIKitLuaAssert(NO, @"LinearLayout does not support sendSubviewToBack method");
}

#pragma mark - Export For Lua
LUA_EXPORT_VIEW_BEGIN(MLNUILinearLayout)
LUA_EXPORT_VIEW_METHOD(setWrapContent, "setLua_wrapContent:",MLNUILinearLayout)
LUA_EXPORT_VIEW_METHOD(requestLayout, "lua_requestLayout", MLNUILinearLayout)
LUA_EXPORT_VIEW_METHOD(setMaxWidth, "setLua_maxWidth:",MLNUILinearLayout)
LUA_EXPORT_VIEW_METHOD(setMinWidth, "setLua_minWidth:",MLNUILinearLayout)
LUA_EXPORT_VIEW_METHOD(setMaxHeight, "setLua_maxHieght:",MLNUILinearLayout)
LUA_EXPORT_VIEW_METHOD(setMinHeight, "setLua_minHeight:",MLNUILinearLayout)
LUA_EXPORT_VIEW_END(MLNUILinearLayout, LinearLayout, YES, "MLNUIView", "initWithLuaCore:LayoutDirectionNumber:")

@end
