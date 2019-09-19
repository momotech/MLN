//
//  MLNLinearLayout.m
//
//
//  Created by MoMo on 2018/10/15.
//

#import "MLNLinearLayout.h"
#import "MLNViewExporterMacro.h"
#import "UIView+MLNKit.h"
#import "UIView+MLNLayout.h"

#define isGravityType(v,t) (((v).lua_gravity&(t)) == (t))

@interface MLNLinearLayout ()


@end
@implementation MLNLinearLayout

- (instancetype)initWithLuaCore:(MLNLuaCore *)luaCore LayoutDirectionNumber:(NSNumber *)directionNum
{
    if (self = [super initWithLuaCore:luaCore]) {
        _direction = directionNum ? directionNum.unsignedIntegerValue : MLNLayoutDirectionHorizontal;
    }
    return self;
}

- (instancetype)initWithLayoutDirection:(MLNLayoutDirection)direction
{
    if (self = [super initWithFrame:CGRectZero]) {
        _direction = direction ? direction : MLNLayoutDirectionHorizontal;
    }
    return self;
}

#pragma mark - Export For Lua
LUA_EXPORT_VIEW_BEGIN(MLNLinearLayout)
LUA_EXPORT_VIEW_METHOD(setWrapContent, "setLua_wrapContent:",MLNLinearLayout)
LUA_EXPORT_VIEW_METHOD(requestLayout, "lua_requestLayout", MLNLinearLayout)
LUA_EXPORT_VIEW_METHOD(setMaxWidth, "setLua_maxWidth:",MLNLinearLayout)
LUA_EXPORT_VIEW_METHOD(setMinWidth, "setLua_minWidth:",MLNLinearLayout)
LUA_EXPORT_VIEW_METHOD(setMaxHeight, "setLua_maxHieght:",MLNLinearLayout)
LUA_EXPORT_VIEW_METHOD(setMinHeight, "setLua_minHeight:",MLNLinearLayout)
LUA_EXPORT_VIEW_END(MLNLinearLayout, LinearLayout, YES, "MLNView", "initWithLuaCore:LayoutDirectionNumber:")

@end
