//
//  MLNUIInteractiveBehavior+Bridge.m
//  ArgoUI
//
//  Created by Dongpeng Dai on 2020/6/22.
//

#import "MLNUIInteractiveBehavior+Bridge.h"
#import "MLNUIViewExporterMacro.h"
#import "UIView+MLNUIKit.h"

@implementation MLNUIInteractiveBehavior (Bridge)

#pragma - Lua Bridge

LUAUI_EXPORT_VIEW_BEGIN(MLNUIInteractiveBehavior)

LUAUI_EXPORT_VIEW_PROPERTY(direction, "setDirection:","direction", MLNUIInteractiveBehavior)
LUAUI_EXPORT_VIEW_PROPERTY(endDistance, "setEndDistance:","endDistance", MLNUIInteractiveBehavior)
LUAUI_EXPORT_VIEW_PROPERTY(overBoundary, "setOverBoundary:","overBoundary", MLNUIInteractiveBehavior)
LUAUI_EXPORT_VIEW_PROPERTY(enable, "setEnable:","enable", MLNUIInteractiveBehavior)
LUAUI_EXPORT_VIEW_PROPERTY(touchBlock, "setLuaTouchBlock:","luaTouchBlock", MLNUIInteractiveBehavior)
LUAUI_EXPORT_VIEW_PROPERTY(targetView, "setTargetView:","targetView", MLNUIInteractiveBehavior)
LUAUI_EXPORT_VIEW_PROPERTY(followEnable, "setFollowEnable:","followEnable", MLNUIInteractiveBehavior)

LUAUI_EXPORT_VIEW_END(MLNUIInteractiveBehavior, InteractiveBehavior, NO, NULL, "initWithMLNUILuaCore:type:")

@end
