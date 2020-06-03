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
    MLNUIAssert(self.mlnui_luaCore, false, @"The subclass of MLNUIStack should override this method.");
    return nil;
}

#pragma mark - Override

- (BOOL)luaui_isContainer {
    return YES;
}

- (BOOL)luaui_layoutEnable {
    return YES;
}

#pragma mark - Export Lua

- (void)luaui_children:(NSArray<UIView *> *)subviews {
    if ([subviews isKindOfClass:[NSArray class]] == NO) {
        return;
    }
    [subviews enumerateObjectsUsingBlock:^(UIView *_Nonnull view, NSUInteger idx, BOOL *_Nonnull stop) {
        if ([view isKindOfClass:[UIView class]]) {
            [self luaui_addSubview:view];
        }
    }];
}

LUAUI_EXPORT_VIEW_BEGIN(MLNUIStack)
LUAUI_EXPORT_VIEW_METHOD(children, "luaui_children:", MLNUIStack)
LUAUI_EXPORT_VIEW_END(MLNUIStack, Stack, YES, "MLNUIView", "initWithMLNUILuaCore:frame:")

@end

@implementation MLNUIPlaneStack

- (MLNUIPlaneStackNode *)node {
    return (MLNUIPlaneStackNode *)self.luaui_node;
}

#pragma mark - Export Lua

- (void)luaui_setMainAxisAlignment:(MLNUIStackMainAlignment)alignment {
    self.node.mainAxisAlignment = alignment;
}

- (MLNUIStackMainAlignment)luaui_mainAxisAlignment {
    return self.node.mainAxisAlignment;
}

- (void)luaui_setCrossAxisAlignment:(MLNUIStackCrossAlignment)alignment {
    self.node.crossAxisAlignment = alignment;
}

- (MLNUIStackCrossAlignment)luaui_crossAxisAlignment {
    return self.node.crossAxisAlignment;
}

- (void)luaui_setStackWrap:(MLNUIStackWrapType)wrapType {
    self.node.wrapType = wrapType;
}

- (MLNUIStackWrapType)luaui_stackWrap {
    return self.node.wrapType;
}

LUAUI_EXPORT_VIEW_BEGIN(MLNUIPlaneStack)
LUAUI_EXPORT_VIEW_PROPERTY(mainAxisAlignment, "luaui_setMainAxisAlignment:", "luaui_mainAxisAlignment", MLNUIPlaneStack)
LUAUI_EXPORT_VIEW_PROPERTY(crossAxisAlignment, "luaui_setCrossAxisAlignment:", "luaui_crossAxisAlignment", MLNUIPlaneStack)
LUAUI_EXPORT_VIEW_PROPERTY(wrap, "luaui_setStackWrap:", "luaui_stackWrap", MLNUIPlaneStack)
LUAUI_EXPORT_VIEW_END(MLNUIPlaneStack, PlaneStack, YES, "MLNUIStack", NULL)

@end
