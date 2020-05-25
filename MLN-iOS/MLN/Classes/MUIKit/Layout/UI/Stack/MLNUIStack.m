//
//  MLNUIStack.m
//  MLNUI
//
//  Created by MOMO on 2020/3/23.
//

#import "MLNUIStack.h"
#import "MLNUIKitHeader.h"
#import "MLNUIStackNode.h"
#import "UIView+MLNUILayout.h"
#import "MLNUIViewExporterMacro.h"

@implementation MLNUIStack

- (MLNUILayoutNode *)createStackNodeWithTargetView:(UIView *)targetView {
    MLNUIAssert(self.mln_luaCore, false, @"The subclass of MLNUIStack should override this method.");
    return nil;
}

#pragma mark - Override

- (BOOL)lua_isContainer {
    return YES;
}

- (BOOL)lua_layoutEnable {
    return YES;
}

#pragma mark - Export Lua

- (void)lua_children:(NSArray<UIView *> *)subviews {
    if ([subviews isKindOfClass:[NSArray class]] == NO) {
        return;
    }
    [subviews enumerateObjectsUsingBlock:^(UIView *_Nonnull view, NSUInteger idx, BOOL *_Nonnull stop) {
        if ([view isKindOfClass:[UIView class]]) {
            [self lua_addSubview:view];
        }
    }];
}

LUA_EXPORT_VIEW_BEGIN(MLNUIStack)
LUA_EXPORT_VIEW_METHOD(children, "lua_children:", MLNUIStack)
LUA_EXPORT_VIEW_END(MLNUIStack, Stack, YES, "MLNUIView", "initWithLuaCore:frame:")

@end

@implementation MLNUIPlaneStack

- (MLNUIPlaneStackNode *)node {
    return (MLNUIPlaneStackNode *)self.lua_node;
}

#pragma mark - Export Lua

- (void)lua_setMainAxisAlignment:(MLNUIStackMainAlignment)alignment {
    self.node.mainAxisAlignment = alignment;
}

- (MLNUIStackMainAlignment)lua_mainAxisAlignment {
    return self.node.mainAxisAlignment;
}

- (void)lua_setCrossAxisAlignment:(MLNUIStackCrossAlignment)alignment {
    self.node.crossAxisAlignment = alignment;
}

- (MLNUIStackCrossAlignment)lua_crossAxisAlignment {
    return self.node.crossAxisAlignment;
}

- (void)lua_setStackWrap:(MLNUIStackWrapType)wrapType {
    self.node.wrapType = wrapType;
}

- (MLNUIStackWrapType)lua_stackWrap {
    return self.node.wrapType;
}

LUA_EXPORT_VIEW_BEGIN(MLNUIPlaneStack)
LUA_EXPORT_VIEW_PROPERTY(mainAxisAlignment, "lua_setMainAxisAlignment:", "lua_mainAxisAlignment", MLNUIPlaneStack)
LUA_EXPORT_VIEW_PROPERTY(crossAxisAlignment, "lua_setCrossAxisAlignment:", "lua_crossAxisAlignment", MLNUIPlaneStack)
LUA_EXPORT_VIEW_PROPERTY(wrap, "lua_setStackWrap:", "lua_stackWrap", MLNUIPlaneStack)
LUA_EXPORT_VIEW_END(MLNUIPlaneStack, PlaneStack, YES, "MLNUIStack", NULL)

@end
