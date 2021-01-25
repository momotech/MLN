//
//  MLNUIInteractiveBehavior+Bridge.m
//  ArgoUI
//
//  Created by MOMO on 2020/6/22.
//

#import "MLNUIInteractiveBehavior+Bridge.h"
#import "MLNUIViewExporterMacro.h"
#import "UIView+MLNUIKit.h"

@implementation MLNUIInteractiveBehavior (Bridge)

- (MLNUILuaCore *)luaCore {
    return self.mlnui_luaCore;
}

#pragma - Lua Bridge

LUAUI_EXPORT_BEGIN(MLNUIInteractiveBehavior)

LUAUI_EXPORT_PROPERTY(direction, "setDirection:","direction", MLNUIInteractiveBehavior)
LUAUI_EXPORT_PROPERTY(max, "setMax:", "max", MLNUIInteractiveBehavior)
LUAUI_EXPORT_PROPERTY(overBoundary, "setOverBoundary:","overBoundary", MLNUIInteractiveBehavior)
LUAUI_EXPORT_PROPERTY(enable, "setEnable:","enable", MLNUIInteractiveBehavior)
LUAUI_EXPORT_PROPERTY(touchBlock, "setLuaTouchBlock:","luaTouchBlock", MLNUIInteractiveBehavior)
LUAUI_EXPORT_PROPERTY(targetView, "setTargetView:","targetView", MLNUIInteractiveBehavior)
LUAUI_EXPORT_PROPERTY(followEnable, "setFollowEnable:","followEnable", MLNUIInteractiveBehavior)
LUAUI_EXPORT_METHOD(clearAnim, "lua_clearAnimation", MLNUIInteractiveBehavior)

LUAUI_EXPORT_END(MLNUIInteractiveBehavior, InteractiveBehavior, NO, NULL, "initWithLuaCore:type:")

@end
