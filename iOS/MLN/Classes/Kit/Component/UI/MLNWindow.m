//
//  MLNWindow.m
//  MLN
//
//  Created by MoMo on 2019/8/5.
//

#import "MLNWindow.h"
#import "MLNViewExporterMacro.h"
#import "UIView+MLNKit.h"
#import "UIView+MLNLayout.h"
#import "MLNBlock.h"
#import "MLNLayoutNode.h"
#import "MLNSystem.h"

@interface MLNWindow ()

@property (nonatomic, strong) MLNBlock *viewAppearCallback;
@property (nonatomic, strong) MLNBlock *viewDisappearCallback;
@property (nonatomic, strong) MLNBlock *onSizeChangedCallback;
@property (nonatomic, strong) MLNBlock *onDestroyCallback;
@property (nonatomic, strong) MLNBlock *keyboardStatusCallback;
@property (nonatomic, assign) BOOL isAppear;
@property (nonatomic, assign) BOOL autoDoLuaViewDidDisappear;
@property (nonatomic, assign) BOOL autoDoSizeChanged;
@property (nonatomic, assign) BOOL autoDoDestroy;

@end

@implementation MLNWindow

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self addNotificationObservers];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Notification
- (void)addNotificationObservers
{
    // Keyboard
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWasShown:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillBeHiden:) name:UIKeyboardWillHideNotification object:nil];
    // Enter Foreground | Background
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(enterForground:) name:UIApplicationWillEnterForegroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(enterBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];
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

- (void)keyboardWasShown:(NSNotification *)notifi
{
    NSDictionary *keybordInfo = [notifi userInfo];
    CGRect keyBoardRect = [[keybordInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGFloat height = keyBoardRect.size.height;
    CGRect beginRect = [[keybordInfo objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue];
    CGRect endRect = [[keybordInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    // 第三方键盘回调三次问题，监听仅执行最后一次
    if(beginRect.size.height > 0 && (beginRect.origin.y - endRect.origin.y > 0)){
        if (_keyboardStatusCallback) {
            [_keyboardStatusCallback addBOOLArgument:YES];
            [_keyboardStatusCallback addFloatArgument:height];
            [_keyboardStatusCallback callIfCan];
        }
    }
}

- (void)keyboardWillBeHiden:(NSNotification *)notifi
{
    if (_keyboardStatusCallback) {
        [_keyboardStatusCallback addBOOLArgument:NO];
        [_keyboardStatusCallback addFloatArgument:0];
        [_keyboardStatusCallback callIfCan];
    }
}

#pragma mark - Export for lua
- (NSMutableDictionary *)lua_getExtraData
{
    return self.extraInfo;
}

- (CGFloat)lua_stateBarHeight
{
    return [MLNSystem lua_stateBarHeight];
}

- (CGFloat)lua_statusBarHeight
{
    return [MLNSystem lua_stateBarHeight];
}

- (CGFloat)lua_navBarHeight
{
    return [MLNSystem lua_navBarHeight];
}

- (CGFloat)lua_tabBarHeight
{
    return [MLNSystem lua_tabBarHeight];
}

- (CGFloat)lua_homeIndicatorHeight
{
    return [MLNSystem lua_homeIndicatorHeight];
}

- (CGFloat)lua_homeBarHeight
{
    return [MLNSystem lua_homeIndicatorHeight];
}

/**
 android 返回键回调方法，iOS空实现
 */
- (void)lua_backKeyPressed:(MLNBlock *)callback
{
    // android 返回键回调方法，iOS空实现
}

/**
 *android 是否执行返回到上一个页面的操作，默认为true，Android方法，iOS空实现
 **/
- (void)lua_backKeyEnabled:(BOOL)enable
{
    
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

- (void)lua_setViewAppearCallback:(MLNBlock *)callback
{
    self.viewAppearCallback = callback;
}

- (void)lua_setViewDidDisappear:(MLNBlock *)callback
{
    self.viewDisappearCallback = callback;
    if (self.autoDoLuaViewDidDisappear) {
        [self doLuaViewDidDisappear];
    }
}

- (void)lua_setOnSizeChanged:(MLNBlock *)callback
{
    self.onSizeChangedCallback = callback;
    if (self.autoDoSizeChanged) {
        [self doSizeChanged];
    }
}

- (void)lua_setOnDestroy:(MLNBlock *)callback
{
    self.onDestroyCallback = callback;
    if (self.autoDoDestroy) {
        [self doLuaViewDestroy];
    }
}

#pragma mark - Override
- (void)setFrame:(CGRect)frame
{
    BOOL isSizeChange = !CGSizeEqualToSize(self.frame.size, frame.size);
    [super setFrame:frame];
    if (isSizeChange) {
        MLNLayoutNode *node = self.lua_node;
        [node changeWidth:frame.size.width];
        [node changeHeight:frame.size.height];
        [self lua_requestLayout];
    }
    [self doSizeChanged];
}

- (BOOL)mln_nativeView
{
    return YES;
}

- (BOOL)lua_canClick
{
    return YES;
}

- (BOOL)lua_canLongPress
{
    return YES;
}

- (BOOL)lua_layoutEnable
{
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

- (void)lua_setKeyboardStatusCallback:(MLNBlock *)keyboardStatusCallback
{
    _keyboardStatusCallback = keyboardStatusCallback;
}

- (void)lua_setStatusBarStyle:(MLNStatusBarStyle)style
{
    [[UIApplication sharedApplication] setStatusBarStyle:(UIStatusBarStyle)style animated:NO];
}

- (MLNStatusBarStyle)lua_getStatusBarStyle
{
    return (MLNStatusBarStyle)[[UIApplication sharedApplication] statusBarStyle];
}

#pragma mark - Export
LUA_EXPORT_VIEW_BEGIN(MLNWindow)
LUA_EXPORT_VIEW_METHOD(viewAppear, "lua_setViewAppearCallback:", MLNWindow)
LUA_EXPORT_VIEW_METHOD(viewDisappear, "lua_setViewDidDisappear:", MLNWindow)
LUA_EXPORT_VIEW_METHOD(sizeChanged, "lua_setOnSizeChanged:", MLNWindow)
LUA_EXPORT_VIEW_METHOD(onDestroy, "lua_setOnDestroy:", MLNWindow)
LUA_EXPORT_VIEW_METHOD(onDestroy, "lua_setOnDestroy:", MLNWindow)
LUA_EXPORT_VIEW_METHOD(getExtra, "lua_getExtraData", MLNWindow)
LUA_EXPORT_VIEW_METHOD(keyboardShowing, "lua_setKeyboardStatusCallback:", MLNWindow)
LUA_EXPORT_VIEW_METHOD(setPageColor, "lua_setBackgroundColor:", MLNWindow)
LUA_EXPORT_VIEW_METHOD(stateBarHeight, "lua_stateBarHeight", MLNWindow)
LUA_EXPORT_VIEW_METHOD(statusBarHeight, "lua_statusBarHeight", MLNWindow)
LUA_EXPORT_VIEW_METHOD(navBarHeight, "lua_navBarHeight", MLNWindow)
LUA_EXPORT_VIEW_METHOD(tabBarHeight, "lua_tabBarHeight", MLNWindow)
LUA_EXPORT_VIEW_METHOD(homeHeight, "lua_homeIndicatorHeight", MLNWindow)
LUA_EXPORT_VIEW_METHOD(homeBarHeight, "lua_homeBarHeight", MLNWindow)
LUA_EXPORT_VIEW_METHOD(backKeyPressed, "lua_backKeyPressed:", MLNWindow)
LUA_EXPORT_VIEW_METHOD(backKeyEnabled, "lua_backKeyEnabled:", MLNWindow)
LUA_EXPORT_VIEW_METHOD(getStatusBarStyle, "lua_getStatusBarStyle", MLNWindow)
LUA_EXPORT_VIEW_METHOD(setStatusBarStyle, "lua_setStatusBarStyle:", MLNWindow)
LUA_EXPORT_VIEW_END(MLNWindow, Window, YES, "MLNView", NULL)

@end
