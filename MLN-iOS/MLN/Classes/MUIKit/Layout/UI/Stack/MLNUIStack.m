//
//  MLNUIStack.m
//  MLNUI
//
//  Created by MOMO on 2020/3/23.
//

#import "MLNUIStack.h"
#import "MLNUIKitHeader.h"
#import "UIView+MLNUILayout.h"
#import "MLNUIViewExporterMacro.h"

@implementation MLNUIStack {
    BOOL _disableVirtualLayout;
}

- (instancetype)initWithMLNUILuaCore:(MLNUILuaCore *)luaCore disableVirtualLayout:(NSNumber *)disableVirtualLayout {
    if (self = [super initWithMLNUILuaCore:luaCore]) {
        _disableVirtualLayout = [disableVirtualLayout boolValue];
    }
    return self;
}

#pragma mark - Override

- (BOOL)luaui_isContainer {
    return YES;
}

- (BOOL)mlnui_layoutEnable {
    return YES;
}

- (BOOL)mlnui_allowVirtualLayout {
    return !_disableVirtualLayout;
}

#pragma mark - Export Lua

- (void)luaui_children:(NSArray<UIView *> *)subviews {
    if ([subviews isKindOfClass:[NSArray class]] == NO) {
        return;
    }
    /**
     * -[UView luaui_addSubview:] 方法会将 view 对应的 userdata 保存在 lua 表中，从而实现 retain + 1，
     * 详见 MLNUI_Lua_UserData_Retain_With_Index(2, view)。index 为2，即从栈中 index 为2的位置取出 view 对应的 userdata，
     * 而当前方法中，栈中 index 为2的值为 table(即参数subviews)，所以这里将子视图入栈，并且将 index 调整为2
     */
    MLNUILuaCore *luaCore = self.mlnui_luaCore;
    lua_State *L = luaCore.state;
    
    [subviews enumerateObjectsUsingBlock:^(UIView *_Nonnull view, NSUInteger idx, BOOL *_Nonnull stop) {
        if ([view isKindOfClass:[UIView class]]) {
            lua_pushnumber(L, idx + 1);       // caller | table | idx+1
            lua_gettable(L, -2);              // caller | table | view
            lua_insert(L, 2);                 // caller | view  | table
            [self luaui_addSubview:view];     // caller | view  | table | ...
            lua_remove(L, 2);                 // caller | table
        }
    }];
}

- (void)setArgo_eventCross:(BOOL)cross {
    objc_setAssociatedObject(self, @selector(argo_eventCross), @(cross), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)argo_eventCross {
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}

LUAUI_EXPORT_VIEW_BEGIN(MLNUIStack)
LUAUI_EXPORT_VIEW_METHOD(children, "luaui_children:", MLNUIStack)
LUAUI_EXPORT_VIEW_PROPERTY(eventCross, "setArgo_eventCross:", "argo_eventCross", MLNUIStack)
LUAUI_EXPORT_VIEW_END(MLNUIStack, Stack, YES, "MLNUIView", "initWithMLNUILuaCore:disableVirtualLayout:")

@end

@implementation MLNUIPlaneStack

- (void)setLuaui_reverse:(BOOL)reverse {
    NSAssert(false, @"@Note: subclass should override this method.");
}

- (void)setCrossAxisSize:(CGSize)size {
    NSAssert(false, @"@Note: subclass should override this method.");
}

- (void)setCrossAxisMaxSize:(CGSize)maxSize {
    NSAssert(false, @"@Note: subclass should override this method.");
}

#pragma mark - Export Lua

LUAUI_EXPORT_VIEW_BEGIN(MLNUIPlaneStack)
LUAUI_EXPORT_VIEW_METHOD(reverse, "setLuaui_reverse:", MLNUIPlaneStack)
LUAUI_EXPORT_VIEW_END(MLNUIPlaneStack, PlaneStack, YES, "MLNUIStack", "initWithMLNUILuaCore:disableVirtualLayout:")

@end
