//
//  MLNUIWindow.m
//  MLNUI
//
//  Created by MoMo on 2019/8/5.
//

#import "MLNUIWindow.h"
#import "MLNUIViewExporterMacro.h"
#import "MLNUIKitHeader.h"
#import "UIView+MLNUIKit.h"
#import "UIView+MLNUILayout.h"
#import "MLNUIBlock.h"
#import "MLNUISystem.h"
#import "MLNUIDevice.h"
#import "MLNUISafeAreaProxy.h"
#import "MLNUISafeAreaAdapter.h"
#import <ArgoAnimation/UIView+AKFrame.h>

@interface MLNUIWindow ()

@property (nonatomic, strong) MLNUIBlock *viewAppearCallback;
@property (nonatomic, strong) MLNUIBlock *viewDisappearCallback;
@property (nonatomic, strong) MLNUIBlock *onSizeChangedCallback;
@property (nonatomic, strong) MLNUIBlock *onDestroyCallback;
@property (nonatomic, strong) MLNUIBlock *keyboardStatusCallback;
@property (nonatomic, strong) MLNUIBlock *keyboardFrameChangeCallback;
@property (nonatomic, assign) BOOL isAppear;
@property (nonatomic, assign) BOOL autoDoLuaViewDidDisappear;
@property (nonatomic, assign) BOOL autoDoSizeChanged;
@property (nonatomic, assign) BOOL autoDoDestroy;
@property (nonatomic, assign) BOOL keyboardIsShowing; // default is NO

@property (nonatomic, strong) MLNUISafeAreaProxy *safeAreaProxy;
@property (nonatomic, strong) NSMutableSet<UIView *> *beyondSuperviews; // 键盘弹起，跟随键盘上移而超出父视图frame的视图

@property (nonatomic, strong) UIView *statusBar;
@property (nonatomic, assign) MLNUIStatusBarMode statusBarMode; // default full screen
@property (nonatomic, strong) UIColor *statusBarColor;

@end

@implementation MLNUIWindow

- (instancetype)initWithMLNUILuaCore:(MLNUILuaCore *)luaCore frame:(CGRect)frame
{
    self = [super initWithMLNUILuaCore:luaCore frame:frame];
    if (self) {
        _keyboardIsShowing = NO;
        _statusBarMode = MLNUIStatusBarModeFullScreen;
        [self addNotificationObservers];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self.safeAreaProxy detachSafeAreaView:self];
}

- (CGRect)statusBarFrame {
    CGRect frame = CGRectZero;
    if (@available(iOS 13.0, *)) {
        frame = self.window.windowScene.statusBarManager.statusBarFrame;
    } else {
        frame = [UIApplication sharedApplication].statusBarFrame;
    }
    if (CGRectEqualToRect(frame, CGRectZero)) {
        frame = [UIApplication sharedApplication].statusBarFrame;
    }
    return frame;
}

#pragma mark - Notification
- (void)addNotificationObservers
{
    // Keyboard
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWasShown:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillBeHiden:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardFrameChanged:) name:UIKeyboardWillChangeFrameNotification object:nil];
    // Enter Foreground | Background
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(enterForground:) name:UIApplicationWillEnterForegroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(enterBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];
    // Safe Area
    UINavigationBar *navbar = MLNUI_KIT_INSTANCE(self.mlnui_luaCore).viewController.navigationController.navigationBar;
    self.safeAreaProxy = [[MLNUISafeAreaProxy alloc] initWithSafeAreaView:self navigationBar:navbar viewController:MLNUI_KIT_INSTANCE(self.mlnui_luaCore).viewController];
}

- (void)enterForground:(NSNotification *)notification
{
    if (self.isAppear) {
        [self doLuaViewDidAppear];
    }
}

- (void)enterBackground:(NSNotification *)notification
{
    if (self.isAppear) {
        [self doLuaViewDidDisappear];
        self.isAppear = YES;
    }
}

- (void)keyboardWasShown:(NSNotification *)notification
{
    if(!_keyboardIsShowing){
        NSDictionary *keybordInfo = [notification userInfo];
        CGRect keyBoardRect = [[keybordInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
        CGFloat height = keyBoardRect.size.height;
        if (_keyboardStatusCallback) {
            [_keyboardStatusCallback addBOOLArgument:YES];
            [_keyboardStatusCallback addFloatArgument:height];
            [_keyboardStatusCallback callIfCan];
            _keyboardIsShowing = YES;
        }
    }
}

- (void)keyboardWillBeHiden:(NSNotification *)notification
{
    if (_keyboardStatusCallback) {
        [_keyboardStatusCallback addBOOLArgument:NO];
        [_keyboardStatusCallback addFloatArgument:0];
        [_keyboardStatusCallback callIfCan];
        _keyboardIsShowing = NO;
    }
}

- (void)keyboardFrameChanged:(NSNotification *)notification
{
    if (self.keyboardFrameChangeCallback) {
        CGFloat oldHeight = [[notification.userInfo objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size.height;
        CGFloat newHeight = [[notification.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size.height;
        [self.keyboardFrameChangeCallback addFloatArgument:oldHeight];
        [self.keyboardFrameChangeCallback addFloatArgument:newHeight];
        [self.keyboardFrameChangeCallback callIfCan];
    }
}

#pragma mark - Override (Event Chain)

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    if (self.beyondSuperviews.count == 0) {
        return [super hitTest:point withEvent:event];
    }
    for (UIView *view in self.beyondSuperviews) {
        CGPoint pointRelativeToSuperview = [self convertPoint:point toView:view.superview];
        if (CGRectContainsPoint(view.frame, pointRelativeToSuperview)) {
            CGPoint pointRelativeToView = [self convertPoint:point toView:view];
            UIView *firstResponder = [view hitTest:pointRelativeToView withEvent:event]; // 寻找可响应的子视图
            return firstResponder ? firstResponder : view; // 若没有子视图可响应，则响应自己
        }
    }
    return [super hitTest:point withEvent:event];
}

#pragma mark - luaSafeArea
- (void)updateSafeAreaInsets:(UIEdgeInsets)safeAreaInsets
{
    self.mlnui_layoutNode.paddingTop = MLNUIPointValue(safeAreaInsets.top);
    self.mlnui_layoutNode.paddingLeft = MLNUIPointValue(safeAreaInsets.left);
    self.mlnui_layoutNode.paddingBottom = MLNUIPointValue(safeAreaInsets.bottom);
    self.mlnui_layoutNode.paddingRight = MLNUIPointValue(safeAreaInsets.right);
}

- (void)luaui_setSafeAreaAdapter:(MLNUISafeAreaAdapter *)adapter
{
    self.safeAreaProxy.adapter = adapter;
}

- (void)luaui_setSafeArea:(MLNUISafeArea)safeArea
{
    self.safeAreaProxy.safeArea = safeArea;
}

- (MLNUISafeArea)luaui_getSafeArea
{
    return self.safeAreaProxy.safeArea;
}

- (CGFloat)luaui_safeAreaInsetsTop
{
    return self.safeAreaProxy.safeAreaTop;
}

- (CGFloat)luaui_safeAreaInsetsBottom
{
    return self.safeAreaProxy.safeAreaBottom;
}

- (CGFloat)luaui_safeAreaInsetsLeft
{
    return self.safeAreaProxy.safeAreaLeft;
}

- (CGFloat)luaui_safeAreaInsetsRight
{
    return self.safeAreaProxy.safeAreaRight;
}

#pragma mark - Export for lua
- (NSMutableDictionary *)luaui_getExtraData
{
    return self.extraInfo;
}

- (CGFloat)luaui_stateBarHeight
{
    return [MLNUISystem luaui_stateBarHeight];
}

- (CGFloat)luaui_statusBarHeight
{
    return [MLNUISystem luaui_stateBarHeight];
}

- (CGFloat)luaui_navBarHeight
{
    return [MLNUISystem luaui_navBarHeight];
}

- (CGFloat)luaui_tabBarHeight
{
    return [MLNUISystem luaui_tabBarHeight];
}

- (CGFloat)luaui_homeIndicatorHeight
{
    return [MLNUISystem luaui_homeIndicatorHeight];
}

- (CGFloat)luaui_homeBarHeight
{
    return [MLNUISystem luaui_homeIndicatorHeight];
}

/**
 android 返回键回调方法，iOS空实现
 */
- (void)luaui_backKeyPressed:(MLNUIBlock *)callback
{
    // android 返回键回调方法，iOS空实现
}

/**
 *android 是否执行返回到上一个页面的操作，默认为true，Android方法，iOS用来表示是否开启侧滑返回手势
 **/
- (void)luaui_backKeyEnabled:(BOOL)enable
{
    UIViewController *currentController = MLNUI_KIT_INSTANCE(self.mlnui_luaCore).viewController;
    if (currentController) {
        UINavigationController *navigationController = [currentController navigationController];
        if (navigationController) {
            navigationController.interactivePopGestureRecognizer.enabled = enable;
        }
    }
}

- (void)luaui_cachePushView:(UIView *)view {
    if (view) {
        [self.beyondSuperviews addObject:view];
    }
}

- (void)luaui_clearPushView {
    [self.beyondSuperviews removeAllObjects];
}

- (void)luaui_setStatusBarMode:(MLNUIStatusBarMode)mode {
    self.statusBarMode = mode;
    switch (mode) {
        case MLNUIStatusBarModeFullScreen:
            [self updateStatusBarHierarchy:nil changeWindowFrame:NO];
            break;
            
        case MLNUIStatusBarModeTransparency:
            [self updateStatusBarHierarchy:self.superview changeWindowFrame:NO];
            break;
            
        case MLNUIStatusBarModeNoneFullScreen:
            [self updateStatusBarHierarchy:self.superview changeWindowFrame:YES];
            break;
            
        default:
            break;
    }
}

- (MLNUIStatusBarMode)luaui_getStatusBarMode {
    return self.statusBarMode;
}

- (void)luaui_setStatusBarColor:(UIColor *)color {
    self.statusBarColor = color;
    _statusBar.backgroundColor = color; // if statusBar isn't nil and set color, or do nothing.
}

- (UIColor *)luaui_getStatusBarColor {
    return self.statusBarColor;
}

#pragma mark - StatusBar

- (void)updateStatusBarHierarchy:(UIView *)superview changeWindowFrame:(BOOL)changeFrame {
    if (!superview) {
        [_statusBar removeFromSuperview];
        _statusBar = nil;
        return;
    }
    if (self.statusBar.superview == superview) {
        return;
    }
    [self.statusBar removeFromSuperview];
    [superview addSubview:self.statusBar];
    [self changeLuaWindowFrameIfNeeded:changeFrame];
}

- (void)changeLuaWindowFrameIfNeeded:(BOOL)change {
    if (change) {
        if (CGRectEqualToRect(self.frame, [UIScreen mainScreen].bounds)) {
            CGFloat statusBarHeight = self.statusBar.frame.size.height;
            CGRect frame = self.frame;
            frame.origin.y += statusBarHeight;
            frame.size.height -= statusBarHeight;
            self.akLayoutFrame = frame;
        }
    } else {
        if (!CGRectEqualToRect(self.frame, [UIScreen mainScreen].bounds)) {
            self.akLayoutFrame = [UIScreen mainScreen].bounds;
        }
    }
}

#pragma mark - Lazy Loading

- (NSMutableSet *)beyondSuperviews {
    if (!_beyondSuperviews) {
        _beyondSuperviews = [NSMutableSet set];
    }
    return _beyondSuperviews;
}

- (UIView *)statusBar {
    if (!_statusBar) {
        CGRect frame = [self statusBarFrame];
        _statusBar = [[UIView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        _statusBar.backgroundColor = self.statusBarColor;
    }
    return _statusBar;
}

#pragma mark - Appear & Disappear

- (BOOL)canDoLuaViewDidAppear
{
    return self.viewAppearCallback!=nil;
}

- (void)doLuaViewDidAppear
{
    self.isAppear = YES;
    if ([self canDoLuaViewDidAppear]) {
        [self.viewAppearCallback callIfCan];
    }
}

- (BOOL)canDoLuaViewDidDisappear
{
    return self.viewDisappearCallback!=nil;
}

- (void)doLuaViewDidDisappear
{
    self.isAppear = NO;
    if ([self canDoLuaViewDidDisappear]) {
        [self.viewDisappearCallback callIfCan];
    } else {
        self.autoDoLuaViewDidDisappear = YES;
    }
}

- (void)doSizeChanged
{
    if (self.onSizeChangedCallback) {
        [self.onSizeChangedCallback addFloatArgument:self.bounds.size.width];
        [self.onSizeChangedCallback addFloatArgument:self.bounds.size.height];
        [self.onSizeChangedCallback callIfCan];
    } else {
        self.autoDoSizeChanged = YES;
    }
}

- (void)doLuaViewDestroy
{
    if (self.onDestroyCallback) {
        [self.onDestroyCallback callIfCan];
        self.autoDoDestroy = NO;
    } else {
        self.autoDoDestroy = YES;
    }
}

- (void)luaui_setViewAppearCallback:(MLNUIBlock *)callback
{
    MLNUICheckTypeAndNilValue(callback, @"function", MLNUIBlock);
    self.viewAppearCallback = callback;
}

- (void)luaui_setViewDidDisappear:(MLNUIBlock *)callback
{
    MLNUICheckTypeAndNilValue(callback, @"function", MLNUIBlock);
    self.viewDisappearCallback = callback;
    if (self.autoDoLuaViewDidDisappear) {
        [self doLuaViewDidDisappear];
    }
}

- (void)luaui_setOnSizeChanged:(MLNUIBlock *)callback
{
    MLNUICheckTypeAndNilValue(callback, @"function", MLNUIBlock);
    self.onSizeChangedCallback = callback;
    if (self.autoDoSizeChanged) {
        [self doSizeChanged];
    }
}

- (void)luaui_setOnDestroy:(MLNUIBlock *)callback
{
    MLNUICheckTypeAndNilValue(callback, @"function", MLNUIBlock);
    self.onDestroyCallback = callback;
    if (self.autoDoDestroy) {
        [self doLuaViewDestroy];
    }
}

- (void)luaui_keyBoardHeightChangeCallback:(MLNUIBlock *)callback
{
    MLNUICheckTypeAndNilValue(callback, @"function", MLNUIBlock);
    self.keyboardFrameChangeCallback = callback;
}

#pragma mark - Override

- (BOOL)mlnui_isRootView {
    return YES;
}

- (BOOL)mlnui_resetOriginAfterLayout {
    return NO;
}

- (void)setFrame:(CGRect)frame
{
    BOOL isSizeChange = !CGSizeEqualToSize(self.frame.size, frame.size);
    [super setFrame:frame];
    if (isSizeChange) {
        MLNUILayoutNode *layout = self.mlnui_layoutNode;
        layout.width = MLNUIPointValue(frame.size.width);
        layout.height = MLNUIPointValue(frame.size.height);
        [self mlnui_requestLayoutIfNeed];
    }
    [self doSizeChanged];
}

- (BOOL)mlnui_nativeView
{
    return YES;
}

- (BOOL)luaui_canClick
{
    return YES;
}

- (BOOL)luaui_canLongPress
{
    return YES;
}

- (BOOL)mlnui_layoutEnable
{
    return YES;
}

- (void)setLuaui_wrapContent:(BOOL)luaui_wrapContent
{
    // cann't set wrap content to window
}

- (BOOL)isLua_wrapContent
{
    return NO;
}

- (void)luaui_setKeyboardStatusCallback:(MLNUIBlock *)keyboardStatusCallback
{
    _keyboardStatusCallback = keyboardStatusCallback;
}

- (void)luaui_setStatusBarStyle:(MLNUIStatusBarStyle)style
{
    [[UIApplication sharedApplication] setStatusBarStyle:(UIStatusBarStyle)style animated:NO];
}

- (MLNUIStatusBarStyle)luaui_getStatusBarStyle
{
    return (MLNUIStatusBarStyle)[[UIApplication sharedApplication] statusBarStyle];
}

#pragma mark - Export

LUAUI_EXPORT_VIEW_BEGIN(MLNUIWindow)
LUAUI_EXPORT_VIEW_PROPERTY(safeArea, "luaui_setSafeArea:", "luaui_getSafeArea", MLNUIWindow)
LUAUI_EXPORT_VIEW_PROPERTY(statusBarMode, "luaui_setStatusBarMode:", "luaui_getStatusBarMode", MLNUIWindow)
LUAUI_EXPORT_VIEW_PROPERTY(statusBarColor, "luaui_setStatusBarColor:", "luaui_getStatusBarColor", MLNUIWindow)
LUAUI_EXPORT_VIEW_METHOD(safeAreaAdapter, "luaui_setSafeAreaAdapter:", MLNUIWindow)
LUAUI_EXPORT_VIEW_METHOD(safeAreaInsetsTop, "luaui_safeAreaInsetsTop", MLNUIWindow)
LUAUI_EXPORT_VIEW_METHOD(safeAreaInsetsBottom, "luaui_safeAreaInsetsBottom", MLNUIWindow)
LUAUI_EXPORT_VIEW_METHOD(safeAreaInsetsLeft, "luaui_safeAreaInsetsLeft", MLNUIWindow)
LUAUI_EXPORT_VIEW_METHOD(safeAreaInsetsRight, "luaui_safeAreaInsetsRight", MLNUIWindow)
LUAUI_EXPORT_VIEW_METHOD(viewAppear, "luaui_setViewAppearCallback:", MLNUIWindow)
LUAUI_EXPORT_VIEW_METHOD(viewDisappear, "luaui_setViewDidDisappear:", MLNUIWindow)
LUAUI_EXPORT_VIEW_METHOD(sizeChanged, "luaui_setOnSizeChanged:", MLNUIWindow)
LUAUI_EXPORT_VIEW_METHOD(onDestroy, "luaui_setOnDestroy:", MLNUIWindow)
LUAUI_EXPORT_VIEW_METHOD(getExtra, "luaui_getExtraData", MLNUIWindow)
LUAUI_EXPORT_VIEW_METHOD(keyboardShowing, "luaui_setKeyboardStatusCallback:", MLNUIWindow)
LUAUI_EXPORT_VIEW_METHOD(stateBarHeight, "luaui_stateBarHeight", MLNUIWindow)
LUAUI_EXPORT_VIEW_METHOD(statusBarHeight, "luaui_statusBarHeight", MLNUIWindow)
LUAUI_EXPORT_VIEW_METHOD(navBarHeight, "luaui_navBarHeight", MLNUIWindow)
LUAUI_EXPORT_VIEW_METHOD(tabBarHeight, "luaui_tabBarHeight", MLNUIWindow)
LUAUI_EXPORT_VIEW_METHOD(homeHeight, "luaui_homeIndicatorHeight", MLNUIWindow)
LUAUI_EXPORT_VIEW_METHOD(homeBarHeight, "luaui_homeBarHeight", MLNUIWindow)
LUAUI_EXPORT_VIEW_METHOD(backKeyPressed, "luaui_backKeyPressed:", MLNUIWindow)
LUAUI_EXPORT_VIEW_METHOD(backKeyEnabled, "luaui_backKeyEnabled:", MLNUIWindow)
LUAUI_EXPORT_VIEW_METHOD(getStatusBarStyle, "luaui_getStatusBarStyle", MLNUIWindow)
LUAUI_EXPORT_VIEW_METHOD(setStatusBarStyle, "luaui_setStatusBarStyle:", MLNUIWindow)
LUAUI_EXPORT_VIEW_METHOD(keyBoardHeightChange, "luaui_keyBoardHeightChangeCallback:", MLNUIWindow)
LUAUI_EXPORT_VIEW_METHOD(cachePushView, "luaui_cachePushView:", MLNUIWindow)
LUAUI_EXPORT_VIEW_METHOD(clearPushView, "luaui_clearPushView", MLNUIWindow)
LUAUI_EXPORT_VIEW_END(MLNUIWindow, Window, YES, "MLNUIView", NULL)

@end
