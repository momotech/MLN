//
//  MLNStack.m
//  MLN
//
//  Created by MOMO on 2020/3/23.
//

#import "MLNStack.h"
#import "MLNKitHeader.h"
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

#pragma mark - Export Lua

- (void)lua_children:(NSArray<UIView *> *)subviews {
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
