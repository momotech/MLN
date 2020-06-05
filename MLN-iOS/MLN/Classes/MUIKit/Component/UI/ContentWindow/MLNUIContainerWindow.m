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
#import "MLNUIWindowContext.h"
#import "MLNUIKitInstance.h"

@interface MLNUIContainerWindow()

@property (nonatomic, assign) BOOL cancelable;

@property (nonatomic, strong) MLNUIBlock *disappearBlock;
@property (nonatomic, weak) UIView *fromLuaView;

//@property (nonatomic, strong) MLNUILayoutContainerNode *virtualSuperNode;
// TODO:__TODO 准备删除

@end

@implementation MLNUIContainerWindow

- (instancetype)initWithMLNUILuaCore:(MLNUILuaCore *)luaCore rectValue:(NSValue *)rectValue
{
    CGRect frame = rectValue ? rectValue.CGRectValue : CGRectZero;
    if (self = [super initWithMLNUILuaCore:luaCore frame:frame]) {
        [self defaultSettingWith:rectValue];
        self.windowLevel = UIWindowLevelAlert - 10;
        self.layer.masksToBounds = YES;
        self.cancelable = YES;
        self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(mlnui_in_keWindowChanged:) name:UIWindowDidBecomeKeyNotification object:nil];
    }
    return self;
}

- (void)defaultSettingWith:(NSValue *)rectValue
{
    if (rectValue) {
        CGRect frame = rectValue.CGRectValue;
        self.mlnui_layoutNode.marginTop = MLNUIPointValue(frame.origin.y);
        self.mlnui_layoutNode.marginLeft = MLNUIPointValue(frame.origin.x);
        self.mlnui_layoutNode.width = MLNUIPointValue(frame.size.width);
        self.mlnui_layoutNode.height = MLNUIPointValue(frame.size.height);
    } else {
//        [self setLuaui_width:MLNUILayoutMeasurementTypeWrapContent];
//        [self setLuaui_height:MLNUILayoutMeasurementTypeWrapContent];
        // TODO:__TODO
    }
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
    [self mlnui_in_showContentWindow:YES];
}

- (void)luaui_dismiss
{
    [self mlnui_in_dismissContentWindow];
}

- (void)luaui_setContent:(UIView *)view
{
    [self luaui_removeAllSubViews];
    _fromLuaView = view;
    [self luaui_addSubview:view];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
    CGPoint point = [touches.anyObject locationInView:self];
    if (!self.cancelable || (self.cancelable && [self isTouchPointInSubviews:point]))
        return;
    [self mlnui_in_dismissContentWindow];
}

#pragma mark - Override

- (BOOL)mlnui_isRootView {
    return YES;
}

#pragma mark - private method
- (void)mlnui_in_showContentWindow:(BOOL)notKeyWindow
{
//    [MLNUI_KIT_INSTANCE(self.mlnui_luaCore) addRootnode:(MLNUILayoutContainerNode *)self.virtualSuperNode]; // TODO:__TODO
    [MLNUI_KIT_INSTANCE(self.mlnui_luaCore) addRootnode:self.mlnui_layoutNode];
    [[MLNUIWindowContext sharedContext] pushKeyWindow:[UIApplication sharedApplication].keyWindow];
    self.hidden = NO;
    if (!notKeyWindow) {
        [self makeKeyWindow];
    }
}

- (void)mlnui_in_dismissContentWindow
{
    MLNUIWindowContext *context = [MLNUIWindowContext sharedContext];
//    [MLNUI_KIT_INSTANCE(self.mlnui_luaCore) removeRootNode:(MLNUILayoutNode *)self.virtualSuperNode]; // TODO:__TODO
    [MLNUI_KIT_INSTANCE(self.mlnui_luaCore) removeRootNode:self.mlnui_layoutNode];
    [context removeWithWindow:self];
    UIWindow *topWindw = nil;
    do{
        topWindw = [context popKeyWindow];
    } while (topWindw.hidden == YES && topWindw != nil);
    [topWindw makeKeyWindow];
    self.hidden = YES;
    [self mlnui_luaui_didDisappear];
}

- (void)mlnui_luaui_didDisappear
{
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

- (void)luaui_setDisappearBlock:(MLNUIBlock *)disappearBlock
{
    _disappearBlock = disappearBlock;
}

- (void)mlnui_in_didDisappear
{
    if (_disappearBlock) {
        [_disappearBlock callIfCan];
    }
}

- (BOOL)mlnui_layoutEnable
{
    return YES;
}

- (BOOL)luaui_isContainer
{
    return YES;
}

- (void)setLuaui_wrapContent:(BOOL)luaui_wrapContent
{
    MLNUILuaAssert(self.mlnui_luaCore, NO, @"cann't set wrap content to window");
}

- (BOOL)isLua_wrapContent
{
    return NO;
}

- (void)mlnui_layoutDidChange
{
    [super mlnui_layoutDidChange];
}

#pragma mark -- life style
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Export For Lua
LUAUI_EXPORT_VIEW_BEGIN(MLNUIContainerWindow)
LUAUI_EXPORT_VIEW_METHOD(show, "luaui_show", MLNUIContainerWindow)
LUAUI_EXPORT_VIEW_METHOD(dismiss, "luaui_dismiss", MLNUIContainerWindow)
LUAUI_EXPORT_VIEW_METHOD(contentDisAppear, "luaui_setDisappearBlock:", MLNUIContainerWindow)
LUAUI_EXPORT_VIEW_METHOD(setContent, "luaui_setContent:", MLNUIContainerWindow)
LUAUI_EXPORT_VIEW_PROPERTY(cancelable, "setCancelable:", "cancelable", MLNUIContainerWindow)
LUAUI_EXPORT_VIEW_END(MLNUIContainerWindow, ContentWindow, YES, "MLNUIView", "initWithMLNUILuaCore:rectValue:")

@end
