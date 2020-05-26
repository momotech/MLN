//
//  MLNUIDialogView.m
//
//
//  Created by MoMo on 2018/12/12.
//

#import "MLNUIDialogView.h"
#import "MLNUIKitHeader.h"
#import "MLNUIViewExporterMacro.h"
#import "UIView+MLNUIKit.h"
#import "UIView+MLNUILayout.h"
#import "MLNUIBlock.h"
#import "MLNUILayoutContainerNode.h"
#import "MLNUIKeyboardViewHandler.h"
#import "MLNUIWindowContext.h"

@interface MLNUIDialogView()
{
    //  标记设置过Gravity，在setContent时，可以取改值
    BOOL _didSetGravity;
    MLNUIGravity _contentGravity;
}

@property (nonatomic, assign) BOOL cancelable;

@property (nonatomic, strong) UIWindow *contentWindow;
@property (nonatomic, strong) MLNUIBlock *disappearBlock;
@property (nonatomic, weak) UIView *fromLuaView;
@property (nonatomic, assign) CGFloat fromLuaStartY;

@end

@implementation MLNUIDialogView

- (instancetype)initWithMLNUILuaCore:(MLNUILuaCore *)luaCore frame:(CGRect)frame
{
    self = [super initWithFrame:[[UIScreen mainScreen] bounds]];
    if (self) {
        self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0];
        MLNUILayoutNode *node = self.luaui_node;
        node.root = YES;
        node.enable = NO;
        CGSize size = [[UIScreen mainScreen] bounds].size;
        MLNUICheckWidth(size.width);
        MLNUICheckHeight(size.height);
        [node changeWidth:size.width];
        [node changeHeight:size.height];
        self.cancelable = YES;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(mlnui_in_keWindowChanged:) name:UIWindowDidBecomeKeyNotification object:nil];
    }
    return self;
}

- (void)luaui_setCancelable:(BOOL)cancel
{
    self.cancelable = cancel;
}

 - (BOOL)luaui_cancelable
{
    return self.cancelable;
}

- (void)luaui_show
{
    [self _showDialogView];
}

- (void)luaui_dismiss
{
    [self _dismissDialogView];
}

- (void)luaui_setContent:(UIView *)view
{
    MLNUICheckTypeAndNilValue(view, @"View", [UIView class])
    [self luaui_removeAllSubViews];
    _fromLuaView = view;
    if (_didSetGravity) {
        view.luaui_gravity = _contentGravity;
    }
    if (view.luaui_node.gravity == MLNUIGravityNone) {
        view.luaui_node.gravity = MLNUIGravityCenter;
    }
    [self luaui_addSubview:view];
}

- (void)initAdjustPosition
{
    __weak typeof(self) weakSelf = self;
    [_fromLuaView mlnui_in_setPositionAdjustForKeyboard:YES offsetY:0.0];
    self.fromLuaView.luaui_keyboardViewHandler.positionBack = ^CGFloat(CGFloat keyboardHeight) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (!strongSelf.fromLuaView || strongSelf.fromLuaView.luaui_node.marginTop != 0) {
            return 0.0f;
        }
        if (strongSelf.fromLuaStartY == 0) {
            strongSelf.fromLuaStartY = strongSelf.fromLuaView.frame.origin.y;
        }
        CGFloat differenceHeight = strongSelf.luaui_height - strongSelf.fromLuaView.luaui_height;
        if (differenceHeight == 0) {
            return 0.f;
        }
        CGFloat scaleY = strongSelf.fromLuaStartY / differenceHeight;
        CGFloat offsetY = scaleY * (differenceHeight - keyboardHeight) - strongSelf.fromLuaStartY ;
        return offsetY;
    };
    self.fromLuaView.luaui_keyboardViewHandler.alwaysAdjustPositionKeyboardCoverView = YES;
}

- (BOOL)luaui_layoutEnable {
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

#pragma mark - private method
- (void)_showDialogView
{
    if (_fromLuaView && _fromLuaView.luaui_node.gravity) {
        [self initAdjustPosition];
    }
    [MLNUI_KIT_INSTANCE(self.mlnui_luaCore) addRootnode:(MLNUILayoutContainerNode *)self.luaui_node];
    [self.contentWindow addSubview:self];
    [[MLNUIWindowContext sharedContext] pushKeyWindow:[UIApplication sharedApplication].keyWindow];
    self.contentWindow.hidden = NO;
    [self.contentWindow makeKeyWindow];
}

- (void)_dismissDialogView
{
    MLNUIWindowContext *context = [MLNUIWindowContext sharedContext];
    [MLNUI_KIT_INSTANCE(self.mlnui_luaCore) removeRootNode:(MLNUILayoutContainerNode *)self.luaui_node];
    [context removeWithWindow:self.contentWindow];
    UIWindow *topWindw = nil;
     do{
        topWindw = [context popKeyWindow];
     } while (topWindw.hidden == YES && topWindw != nil);
    [topWindw makeKeyWindow];
    _contentWindow.hidden = YES;
    [self _luaui_didDisappear];
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

- (void)luaui_setDisappearBlock:(MLNUIBlock *)disappearBlock
{
    _disappearBlock = disappearBlock;
}

- (void)luaui_setDimAmount:(CGFloat)amount
{
    amount = amount > 1 ? 1.0 : (amount < 0 ? 0 : amount);
    self.contentWindow.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:amount];
}

- (void)luaui_setContentGravity:(MLNUIGravity)gravity
{
    _didSetGravity = YES;
    _contentGravity = gravity;
    self.fromLuaView.luaui_gravity = gravity;
}

- (void)_luaui_didDisappear
{
    _fromLuaView.luaui_keyboardViewHandler.alwaysAdjustPositionKeyboardCoverView = NO;
    if (_disappearBlock) {
        [_disappearBlock callIfCan];
    }
}

- (void)mlnui_in_keWindowChanged:(NSNotification *)noti
{
    if (![noti.object isKindOfClass:[UIWindow class]]) {
        return;
    }
    UIWindow *keyWindow = (UIWindow *)noti.object;
    if (keyWindow && keyWindow != _contentWindow) {
        [[MLNUIWindowContext sharedContext] pushKeyWindow:keyWindow];
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
LUAUI_EXPORT_VIEW_BEGIN(MLNUIDialogView)
LUAUI_EXPORT_VIEW_PROPERTY(cancelable, "luaui_setCancelable:", "luaui_cancelable", MLNUIDialogView)
LUAUI_EXPORT_VIEW_METHOD(show, "luaui_show", MLNUIDialogView)
LUAUI_EXPORT_VIEW_METHOD(dismiss, "luaui_dismiss", MLNUIDialogView)
LUAUI_EXPORT_VIEW_METHOD(dialogDisAppear, "luaui_setDisappearBlock:", MLNUIDialogView)
LUAUI_EXPORT_VIEW_METHOD(setContent, "luaui_setContent:", MLNUIDialogView)
LUAUI_EXPORT_VIEW_METHOD(setDimAmount, "luaui_setDimAmount:", MLNUIDialogView)
LUAUI_EXPORT_VIEW_METHOD(setContentGravity, "luaui_setContentGravity:", MLNUIDialogView)
LUAUI_EXPORT_VIEW_END(MLNUIDialogView, Dialog, YES, "MLNUIView", "initWithMLNUILuaCore:frame:")

@end
