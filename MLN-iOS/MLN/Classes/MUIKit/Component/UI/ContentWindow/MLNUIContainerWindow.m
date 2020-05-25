//
//  MLNUIContainerWindow.h
//  MLNUI
//
//  Created by MoMo on 2019/7/1.
//
#import "MLNUIContainerWindow.h"
#import "MLNUIExporter.h"
#import "MLNUIKitHeader.h"
#import "MLNUIBlock.h"
#import "UIView+MLNUIKit.h"
#import "UIView+MLNUILayout.h"
#import "MLNUIViewExporterMacro.h"
#import "MLNUILayoutContainerNode.h"
#import "MLNUIWindowContext.h"
#import "MLNUIKitInstance.h"

@interface MLNUIContainerWindow()

@property (nonatomic, assign) BOOL cancelable;

@property (nonatomic, strong) MLNUIBlock *disappearBlock;
@property (nonatomic, weak) UIView *fromLuaView;

@property (nonatomic, strong) MLNUILayoutContainerNode *virtualSuperNode;

@end

@implementation MLNUIContainerWindow

- (instancetype)initWithLuaCore:(MLNUILuaCore *)luaCore rectValue:(NSValue *)rectValue
{
    CGRect frame = rectValue ? rectValue.CGRectValue : CGRectZero;
    if (self = [super initWithLuaCore:luaCore frame:frame]) {
        [self defaultSettingWith:rectValue];
        [self.virtualSuperNode addSubnode:self.lua_node];
        self.lua_node.supernode = self.virtualSuperNode;
        self.windowLevel = UIWindowLevelAlert - 10;
        self.layer.masksToBounds = YES;
        self.lua_node.enable = YES;
        self.cancelable = YES;
        self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(mln_in_keWindowChanged:) name:UIWindowDidBecomeKeyNotification object:nil];
    }
    return self;
}

- (void)defaultSettingWith:(NSValue *)rectValue
{
    if (rectValue) {
        CGRect frame = rectValue.CGRectValue;
        [self setLua_marginTop:frame.origin.y];
        [self setLua_marginLeft:frame.origin.x];
        [self setLua_width:frame.size.width];
        [self setLua_height:frame.size.height];
    } else {
        [self setLua_width:MLNUILayoutMeasurementTypeWrapContent];
        [self setLua_height:MLNUILayoutMeasurementTypeWrapContent];
    }
}

- (void)lua_setCancelable:(BOOL)cancel
{
    self.cancelable = cancel;
}

- (BOOL)lua_cancelable
{
    return self.cancelable;
}

- (void)lua_show
{
    [self mln_in_showContentWindow:YES];
}

- (void)lua_dismiss
{
    [self mln_in_dismissContentWindow];
}

- (void)lua_setContent:(UIView *)view
{
    [self lua_removeAllSubViews];
    _fromLuaView = view;
    [self lua_addSubview:view];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
    CGPoint point = [touches.anyObject locationInView:self];
    if (!self.cancelable || (self.cancelable && [self isTouchPointInSubviews:point]))
        return;
    [self mln_in_dismissContentWindow];
}

#pragma mark - private method
- (void)mln_in_showContentWindow:(BOOL)notKeyWindow
{
    [MLNUI_KIT_INSTANCE(self.mln_luaCore) addRootnode:(MLNUILayoutContainerNode *)self.virtualSuperNode];
    [[MLNUIWindowContext sharedContext] pushKeyWindow:[UIApplication sharedApplication].keyWindow];
    self.hidden = NO;
    if (!notKeyWindow) {
        [self makeKeyWindow];
    }
}

- (void)mln_in_dismissContentWindow
{
    MLNUIWindowContext *context = [MLNUIWindowContext sharedContext];
    [MLNUI_KIT_INSTANCE(self.mln_luaCore) removeRootNode:(MLNUILayoutContainerNode *)self.virtualSuperNode];
    [context removeWithWindow:self];
    UIWindow *topWindw = nil;
    do{
        topWindw = [context popKeyWindow];
    } while (topWindw.hidden == YES && topWindw != nil);
    [topWindw makeKeyWindow];
    self.hidden = YES;
    [self mln_lua_didDisappear];
}

- (void)mln_lua_didDisappear
{
    if (_disappearBlock) {
        [_disappearBlock callIfCan];
    }
}

- (void)mln_in_keWindowChanged:(NSNotification *)noti
{
    if (![noti.object isKindOfClass:[UIWindow class]]) {
        return;
    }
    UIWindow *keyWindow = (UIWindow *)noti.object;
    if (keyWindow && keyWindow != self) {
        [[MLNUIWindowContext sharedContext] pushKeyWindow:keyWindow];
    }
}

- (BOOL)isTouchPointInSubviews:(CGPoint)pt
{
    BOOL result = NO;
    for (UIView *view in self.subviews) {
        if (CGRectContainsPoint(view.frame, pt) ) {
            result = YES;
            break;
        }
    }
    return result;
}

- (void)lua_setDisappearBlock:(MLNUIBlock *)disappearBlock
{
    _disappearBlock = disappearBlock;
}

- (void)mln_in_didDisappear
{
    if (_disappearBlock) {
        [_disappearBlock callIfCan];
    }
}

- (MLNUILayoutContainerNode *)virtualSuperNode
{
    if (!_virtualSuperNode) {
        _virtualSuperNode = [[MLNUILayoutContainerNode alloc] init];
        [_virtualSuperNode setRoot:YES];
        _virtualSuperNode.enable = NO;
        CGRect bounds = [UIScreen mainScreen].bounds;
        [_virtualSuperNode changeWidth:bounds.size.width];
        [_virtualSuperNode changeHeight:bounds.size.height];
        [MLNUI_KIT_INSTANCE(self.mln_luaCore) addRootnode:(MLNUILayoutContainerNode *)self.virtualSuperNode];
    }
    return _virtualSuperNode;
}

- (BOOL)lua_layoutEnable
{
    return YES;
}

- (BOOL)lua_isContainer
{
    return YES;
}

- (void)setLua_wrapContent:(BOOL)lua_wrapContent
{
    MLNUILuaAssert(self.mln_luaCore, NO, @"cann't set wrap content to window");
}

- (BOOL)isLua_wrapContent
{
    return NO;
}

- (void)lua_changedLayout
{
    [super lua_changedLayout];
}

#pragma mark -- life style
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Export For Lua
LUA_EXPORT_VIEW_BEGIN(MLNUIContainerWindow)
LUA_EXPORT_VIEW_METHOD(show, "lua_show", MLNUIContainerWindow)
LUA_EXPORT_VIEW_METHOD(dismiss, "lua_dismiss", MLNUIContainerWindow)
LUA_EXPORT_VIEW_METHOD(contentDisAppear, "lua_setDisappearBlock:", MLNUIContainerWindow)
LUA_EXPORT_VIEW_METHOD(setContent, "lua_setContent:", MLNUIContainerWindow)
LUA_EXPORT_VIEW_PROPERTY(cancelable, "setCancelable:", "cancelable", MLNUIContainerWindow)
LUA_EXPORT_VIEW_END(MLNUIContainerWindow, ContentWindow, YES, "MLNUIView", "initWithLuaCore:rectValue:")

@end
