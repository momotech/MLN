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

- (void)lua_stack_addSubview:(UIView *)view {
    MLNKitLuaAssert(NO, @"The \"addView\" method is invalid in HStack、VStack and ZStack.");
}

- (void)lua_stack_insertSubview:(UIView *)view atIndex:(NSInteger)index {
    MLNKitLuaAssert(NO, @"The \"insertView\" method is invalid in HStack、VStack and ZStack.");
}

- (void)lua_stack_removeFromSuperview {
    MLNKitLuaAssert(NO, @"The \"removeFromSuper\" method is invalid in HStack、VStack and ZStack.");
}

- (void)lua_stack_removeAllSubViews{
    MLNKitLuaAssert(NO, @"The \"removeAllSubviews\" method is invalid in HStack、VStack and ZStack.");
}

- (void)lua_children:(NSArray *)subviews {
    // do nothing
}

LUA_EXPORT_VIEW_BEGIN(MLNStack)
LUA_EXPORT_VIEW_METHOD(addView, "lua_stack_addSubview:", MLNStack)
LUA_EXPORT_VIEW_METHOD(insertView, "lua_stack_insertSubview:atIndex:", MLNStack)
LUA_EXPORT_VIEW_METHOD(removeFromSuper, "lua_stack_removeFromSuperview", MLNStack)
LUA_EXPORT_VIEW_METHOD(removeAllSubviews, "lua_stack_removeAllSubViews", MLNStack)
LUA_EXPORT_VIEW_METHOD(children, "lua_children:", MLNStack)
LUA_EXPORT_VIEW_END(MLNStack, Stack, YES, "MLNView", "initWithLuaCore:frame:")

@end
