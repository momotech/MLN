//
//  MLNStack.m
//  MLN
//
//  Created by MOMO on 2020/3/23.
//

#import "MLNStack.h"
#import "MLNKitHeader.h"
#import "MLNStackNode.h"
#import "UIView+MLNLayout.h"
#import "MLNViewExporterMacro.h"

@implementation MLNStack

- (MLNLayoutNode *)createStackNodeWithTargetView:(UIView *)targetView {
    MLNAssert(self.mln_luaCore, false, @"The subclass of MLNStack should override this method.");
    return nil;
}

#pragma mark - Override

- (BOOL)lua_isContainer {
    return YES;
}

- (BOOL)lua_layoutEnable {
    return YES;
}

- (BOOL)lua_supportOverlay {
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

LUA_EXPORT_VIEW_BEGIN(MLNStack)
LUA_EXPORT_VIEW_METHOD(children, "lua_children:", MLNStack)
LUA_EXPORT_VIEW_END(MLNStack, Stack, YES, "MLNView", "initWithLuaCore:frame:")

@end

@implementation MLNPlaneStack

- (MLNPlaneStackNode *)node {
    return (MLNPlaneStackNode *)self.lua_node;
}

#pragma mark - Export Lua

- (void)lua_setMainAxisAlignment:(MLNStackMainAlignment)alignment {
    self.node.mainAxisAlignment = alignment;
}

- (MLNStackMainAlignment)lua_mainAxisAlignment {
    return self.node.mainAxisAlignment;
}

- (void)lua_setCrossAxisAlignment:(MLNStackCrossAlignment)alignment {
    self.node.crossAxisAlignment = alignment;
}

- (MLNStackCrossAlignment)lua_crossAxisAlignment {
    return self.node.crossAxisAlignment;
}

- (void)lua_setStackWrap:(MLNStackWrapType)wrapType {
    self.node.wrapType = wrapType;
}

- (MLNStackWrapType)lua_stackWrap {
    return self.node.wrapType;
}

LUA_EXPORT_VIEW_BEGIN(MLNPlaneStack)
LUA_EXPORT_VIEW_PROPERTY(mainAxisAlignment, "lua_setMainAxisAlignment:", "lua_mainAxisAlignment", MLNPlaneStack)
LUA_EXPORT_VIEW_PROPERTY(crossAxisAlignment, "lua_setCrossAxisAlignment:", "lua_crossAxisAlignment", MLNPlaneStack)
LUA_EXPORT_VIEW_PROPERTY(wrap, "lua_setStackWrap:", "lua_stackWrap", MLNPlaneStack)
LUA_EXPORT_VIEW_END(MLNPlaneStack, PlaneStack, YES, "MLNStack", NULL)

@end
