//
//  MLNDialogView.m
//
//
//  Created by MoMo on 2018/12/12.
//

#import "MLNDialogView.h"
#import "MLNKitHeader.h"
#import "MLNViewExporterMacro.h"
#import "UIView+MLNKit.h"
#import "UIView+MLNLayout.h"
#import "MLNBlock.h"
#import "MLNLayoutContainerNode.h"
#import "MLNKeyboardViewHandler.h"
#import "MLNWindowContext.h"

@interface MLNDialogView()
{
    //  标记设置过Gravity，在setContent时，可以取改值
    BOOL _didSetGravity;
    MLNGravity _contentGravity;
}

@property (nonatomic, assign) BOOL cancelable;

@property (nonatomic, strong) UIWindow *contentWindow;
@property (nonatomic, strong) MLNBlock *disappearBlock;
@property (nonatomic, weak) UIView *fromLuaView;
@property (nonatomic, assign) CGFloat fromLuaStartY;

@end

@implementation MLNDialogView

- (instancetype)initWithLuaCore:(MLNLuaCore *)luaCore frame:(CGRect)frame
{
    self = [super initWithFrame:[[UIScreen mainScreen] bounds]];
    if (self) {
        self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0];
        MLNLayoutNode *node = self.lua_node;
        node.root = YES;
        node.enable = NO;
        CGSize size = [[UIScreen mainScreen] bounds].size;
        MLNCheckWidth(size.width);
        MLNCheckHeight(size.height);
        [node changeWidth:size.width];
        [node changeHeight:size.height];
        self.cancelable = YES;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(mln_in_keWindowChanged:) name:UIWindowDidBecomeKeyNotification object:nil];
    }
    return self;
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
    [self _showDialogView];
}

- (void)lua_dismiss
{
    [self _dismissDialogView];
}

- (void)lua_setContent:(UIView *)view
{
    MLNCheckTypeAndNilValue(view, @"View", [UIView class])
    [self lua_removeAllSubViews];
    _fromLuaView = view;
    if (_didSetGravity) {
        view.lua_gravity = _contentGravity;
    }
    if (view.lua_node.gravity == MLNGravityNone) {
        view.lua_node.gravity = MLNGravityCenter;
    }
    [self lua_addSubview:view];
}

- (void)initAdjustPosition
{
    __weak typeof(self) weakSelf = self;
    [_fromLuaView mln_in_setPositionAdjustForKeyboard:YES offsetY:0.0];
    self.fromLuaView.lua_keyboardViewHandler.positionBack = ^CGFloat(CGFloat keyboardHeight) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (!strongSelf.fromLuaView || strongSelf.fromLuaView.lua_node.marginTop != 0) {
            return 0.0f;
        }
        if (strongSelf.fromLuaStartY == 0) {
            strongSelf.fromLuaStartY = strongSelf.fromLuaView.frame.origin.y;
        }
        CGFloat differenceHeight = strongSelf.lua_height - strongSelf.fromLuaView.lua_height;
        if (differenceHeight == 0) {
            return 0.f;
        }
        CGFloat scaleY = strongSelf.fromLuaStartY / differenceHeight;
        CGFloat offsetY = scaleY * (differenceHeight - keyboardHeight) - strongSelf.fromLuaStartY ;
        return offsetY;
    };
    self.fromLuaView.lua_keyboardViewHandler.alwaysAdjustPositionKeyboardCoverView = YES;
}

- (BOOL)lua_layoutEnable {
    return YES;
}

- (void)setLua_wrapContent:(BOOL)lua_wrapContent
{
    // cann't set wrap content to window
}

- (BOOL)isLua_wrapContent
{
    return NO;
}

#pragma mark - private method
- (void)_showDialogView
{
    if (_fromLuaView && _fromLuaView.lua_node.gravity) {
        [self initAdjustPosition];
    }
    [MLN_KIT_INSTANCE(self.mln_luaCore) addRootnode:(MLNLayoutContainerNode *)self.lua_node];
    [self.contentWindow addSubview:self];
    [[MLNWindowContext sharedContext] pushKeyWindow:[UIApplication sharedApplication].keyWindow];
    self.contentWindow.hidden = NO;
    [self.contentWindow makeKeyWindow];
}

- (void)_dismissDialogView
{
    MLNWindowContext *context = [MLNWindowContext sharedContext];
    [MLN_KIT_INSTANCE(self.mln_luaCore) removeRootNode:(MLNLayoutContainerNode *)self.lua_node];
    [context removeWithWindow:self.contentWindow];
    UIWindow *topWindw = nil;
     do{
        topWindw = [context popKeyWindow];
     } while (topWindw.hidden == YES && topWindw != nil);
    [topWindw makeKeyWindow];
    _contentWindow.hidden = YES;
    [self _lua_didDisappear];
}

- (void)contentWindowClicked:(UIGestureRecognizer *)gesture
{
    CGPoint point = [gesture locationInView:self];
    if (!self.cancelable || (self.cancelable && [self isTouchPointInSubviews:point]))
        return;
    [self _dismissDialogView];
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

- (void)lua_setDimAmount:(CGFloat)amount
{
    amount = amount > 1 ? 1.0 : (amount < 0 ? 0 : amount);
    self.contentWindow.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:amount];
}

- (void)lua_setContentGravity:(MLNGravity)gravity
{
    _didSetGravity = YES;
    _contentGravity = gravity;
    self.fromLuaView.lua_gravity = gravity;
}

- (void)_lua_didDisappear
{
    _fromLuaView.lua_keyboardViewHandler.alwaysAdjustPositionKeyboardCoverView = NO;
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
    if (keyWindow && keyWindow != _contentWindow) {
        [[MLNWindowContext sharedContext] pushKeyWindow:keyWindow];
    }
}

#pragma mark - getter
- (UIWindow *)contentWindow
{
    if (!_contentWindow) {
        _contentWindow = [[UIWindow alloc] initWithFrame:self.bounds];
        _contentWindow.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.4];
        [_contentWindow addSubview:self];
        _contentWindow.windowLevel = UIWindowLevelAlert - 10;
        _contentWindow.layer.masksToBounds = YES;
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(contentWindowClicked:)];
        [_contentWindow addGestureRecognizer:tapGesture];
    }
    return _contentWindow;
}

#pragma mark -- life style
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Export For Lua
LUA_EXPORT_VIEW_BEGIN(MLNDialogView)
LUA_EXPORT_VIEW_PROPERTY(cancelable, "lua_setCancelable:", "lua_cancelable", MLNDialogView)
LUA_EXPORT_VIEW_METHOD(show, "lua_show", MLNDialogView)
LUA_EXPORT_VIEW_METHOD(dismiss, "lua_dismiss", MLNDialogView)
LUA_EXPORT_VIEW_METHOD(dialogDisAppear, "lua_setDisappearBlock:", MLNDialogView)
LUA_EXPORT_VIEW_METHOD(setContent, "lua_setContent:", MLNDialogView)
LUA_EXPORT_VIEW_METHOD(setDimAmount, "lua_setDimAmount:", MLNDialogView)
LUA_EXPORT_VIEW_METHOD(setContentGravity, "lua_setContentGravity:", MLNDialogView)
LUA_EXPORT_VIEW_END(MLNDialogView, Dialog, YES, "MLNView", "initWithLuaCore:frame:")

@end
