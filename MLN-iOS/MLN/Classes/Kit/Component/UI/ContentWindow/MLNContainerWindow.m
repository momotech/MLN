//
//  MLNContainerWindow.h
//  MLN
//
//  Created by MoMo on 2019/7/1.
//
#import "MLNContainerWindow.h"
#import "MLNExporter.h"
#import "MLNKitHeader.h"
#import "MLNBlock.h"
#import "UIView+MLNKit.h"
#import "UIView+MLNLayout.h"
#import "MLNViewExporterMacro.h"
#import "MLNLayoutContainerNode.h"
#import "MLNWindowContext.h"
#import "MLNKitInstance.h"

@interface MLNContainerWindow()

@property (nonatomic, assign) BOOL cancelable;

@property (nonatomic, strong) MLNBlock *disappearBlock;
@property (nonatomic, weak) UIView *fromLuaView;

@property (nonatomic, strong) MLNLayoutContainerNode *virtualSuperNode;

@end

@implementation MLNContainerWindow

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self defaultSettingWith:frame];
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

- (void)defaultSettingWith:(CGRect)frame
{
    [self setLua_marginTop:frame.origin.y];
    [self setLua_marginLeft:frame.origin.x];
    [self setLua_width:frame.size.width];
    [self setLua_height:frame.size.height];
    if (CGRectEqualToRect(frame, CGRectZero)) {
        [self setLua_width:MLNLayoutMeasurementTypeWrapContent];
        [self setLua_height:MLNLayoutMeasurementTypeWrapContent];
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

- (void)lua_show:(BOOL)notKeyWindow
{
    [self mln_in_showContentWindow:notKeyWindow];
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
    [MLN_KIT_INSTANCE(self.mln_luaCore) addRootnode:(MLNLayoutContainerNode *)self.virtualSuperNode];
    [[MLNWindowContext sharedContext] pushKeyWindow:[UIApplication sharedApplication].keyWindow];
    self.hidden = NO;
    if (!notKeyWindow) {
        [self makeKeyWindow];
    }
}

- (void)mln_in_dismissContentWindow
{
    MLNWindowContext *context = [MLNWindowContext sharedContext];
    [MLN_KIT_INSTANCE(self.mln_luaCore) removeRootNode:(MLNLayoutContainerNode *)self.virtualSuperNode];
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
        [[MLNWindowContext sharedContext] pushKeyWindow:keyWindow];
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

- (void)lua_setDisappearBlock:(MLNBlock *)disappearBlock
{
    _disappearBlock = disappearBlock;
}

- (void)mln_in_didDisappear
{
    if (_disappearBlock) {
        [_disappearBlock callIfCan];
    }
}

- (MLNLayoutContainerNode *)virtualSuperNode
{
    if (!_virtualSuperNode) {
        _virtualSuperNode = [[MLNLayoutContainerNode alloc] init];
        [_virtualSuperNode setRoot:YES];
        _virtualSuperNode.enable = NO;
        CGRect bounds = [UIScreen mainScreen].bounds;
        [_virtualSuperNode changeWidth:bounds.size.width];
        [_virtualSuperNode changeHeight:bounds.size.height];
        [MLN_KIT_INSTANCE(self.mln_luaCore) addRootnode:(MLNLayoutContainerNode *)self.virtualSuperNode];
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
    MLNLuaAssert(self.mln_luaCore, NO, @"cann't set wrap content to window");
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
LUA_EXPORT_VIEW_BEGIN(MLNContainerWindow)
LUA_EXPORT_VIEW_METHOD(show, "lua_show:", MLNContainerWindow)
LUA_EXPORT_VIEW_METHOD(dismiss, "lua_dismiss", MLNContainerWindow)
LUA_EXPORT_VIEW_METHOD(contentDisAppear, "lua_setDisappearBlock:", MLNContainerWindow)
LUA_EXPORT_VIEW_METHOD(setContent, "lua_setContent:", MLNContainerWindow)
LUA_EXPORT_VIEW_PROPERTY(cancelable, "setCancelable:", "cancelable", MLNContainerWindow)
LUA_EXPORT_VIEW_END(MLNContainerWindow, ContentWindow, NO, "MLNBaseView", "initWithFrame:")

@end
