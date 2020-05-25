//
//  MLNUIKeyboardViewHandler.m
//  MLNUI
//
//  Created by MoMo on 2019/8/5.
//

#import "MLNUIKeyboardViewHandler.h"
#import "UIView+MLNUILayout.h"
#import "MLNUILayoutNode.h"

@interface MLNUIKeyboardViewHandler()

@property (nonatomic, weak) UIView *attachView;
@property (nonatomic, assign) CGFloat lua_node_offsetY;
@property (nonatomic, assign) NSInteger triggerTime;
@property (nonatomic, assign) BOOL remainOriginOffset;

@end
@implementation MLNUIKeyboardViewHandler

- (instancetype)initWithView:(UIView *)view
{
    if (self = [super init]) {
        _attachView = view;
    }
    return self;
}

- (void)setPositionAdjust:(BOOL)bAdjust
{
    if (bAdjust) {
        [self addKeyboardObserver];
    } else {
        [self removeKeyboardObserver];
    }
}


- (void)addKeyboardObserver
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)removeKeyboardObserver
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)dealloc
{
    [self removeKeyboardObserver];
}

- (void)keyboardWillShow:(NSNotification *)notification
{
    [self viewControlAnimationWithNotification:notification];
}

- (void)viewControlAnimationWithNotification:(NSNotification *)notification
{
    UIView *superView = [UIApplication sharedApplication].keyWindow;
    CGPoint relativePoint = [self.attachView convertPoint:CGPointZero toView:superView];
    CGFloat keyboardHeight = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue].size.height;
    CGFloat duration= [notification.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    
    CGFloat actualHeight = CGRectGetHeight(self.attachView.frame) + relativePoint.y + keyboardHeight;
    CGFloat overstep = actualHeight - CGRectGetHeight([UIScreen mainScreen].bounds);
    
    if (self.triggerTime == 0) {
        self.beforePositionAdjustViewFrame = self.attachView.frame;
        self.triggerTime ++;
    }
    
    if (_alwaysAdjustPositionKeyboardCoverView) {
        if (self.beforePositionAdjustViewFrame.origin.y == self.attachView.frame.origin.y) {
            self.positionAdjustOffsetY = _positionBack(keyboardHeight);
        } else {
            self.positionAdjustOffsetY = 0;
        }
        [self adjustPositionUseCallBackWith:duration];
    } else {
        [self adjustPositionWith:duration overstep:overstep];
    }
    
}

- (void)adjustPositionUseCallBackWith:(CGFloat)duration
{
    if (!_positionBack) {
        return;
    }
    CGRect frame = self.attachView.frame;
    frame.origin.y += self.positionAdjustOffsetY;
    if (self.attachView.lua_node.enable) {
        self.lua_node_offsetY = self.attachView.lua_node.offsetY;
        self.attachView.lua_node.offsetY += self.positionAdjustOffsetY;
    }
    
    [UIView animateWithDuration:duration animations:^{
        self.attachView.frame = frame;
    }];
}

- (void)adjustPositionWith:(CGFloat)duration overstep:(CGFloat)overstep
{
    if (overstep > 0) {
        CGRect frame = self.attachView.frame;
        
        frame.origin.y -= overstep;
        frame.origin.y += self.positionAdjustOffsetY;
        // @note 变量remainOriginOffset 是为了解决键盘willshow有时会回调两次，导致记录的偏移量不正确
        if (!self.remainOriginOffset) {
            self.lua_node_offsetY = self.attachView.lua_node.offsetY;
            self.remainOriginOffset = YES;
        }
        self.attachView.lua_node.offsetY -= overstep;
        self.attachView.lua_node.offsetY += self.positionAdjustOffsetY;
        [UIView animateWithDuration:duration animations:^{
            self.attachView.frame = frame;
        }];
    }
}

- (void)keyboardWillHide:(NSNotification *)notification
{
    self.triggerTime = 0;
    CGFloat duration = [notification.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    CGRect frame = self.beforePositionAdjustViewFrame;
    self.attachView.lua_node.offsetY = self.lua_node_offsetY;
    self.remainOriginOffset = NO;
    [UIView animateWithDuration:duration animations:^{
        self.attachView.frame = frame;
    }];
}

@end
