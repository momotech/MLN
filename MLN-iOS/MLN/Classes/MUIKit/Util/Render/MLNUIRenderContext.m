//
//  MLNUIRenderContext.m
//  MMLNUIua
//
//  Created by MoMo on 2019/4/16.
//

#import "MLNUIRenderContext.h"
#import "MLNUIGradientLayerOperation.h"
#import "MLNUIShadowOperation.h"
#import "MLNUIBorderLayerOperation.h"
#import "MLNUIBeforeWaitingTask.h"
#import "MLNUICornerManagerFactory.h"
#import "UIView+MLNUIKit.h"

@interface MLNUIRenderContext ()

@property (nonatomic, assign) MLNUICornerMode newCornerMode;
@property (nonatomic, assign) MLNUICornerMode lastCornerMode;
@property (nonatomic, strong) id<MLNUICornerHandlerPotocol> layerOperation;
@property (nonatomic, strong) id<MLNUICornerHandlerPotocol> maskLayerOperation;
@property (nonatomic, strong) id<MLNUICornerHandlerPotocol> maskViewOperation;
@property (nonatomic, strong) MLNUIGradientLayerOperation *gradientLayerOperation;
@property (nonatomic, strong) MLNUIShadowOperation *shadowOperation;
@property (nonatomic, strong) MLNUIBorderLayerOperation *borderOperation;

@property (nonatomic, strong) MLNUIBeforeWaitingTask *beforeWaitingTask;

@end
@implementation MLNUIRenderContext

- (instancetype)initWithTargetView:(UIView *)targetView
{
    if (self = [super init]) {
        _targetView = targetView;
        _clipToBounds = targetView.clipsToBounds;
    }
    return self;
}

#pragma mark - Corner
- (void)resetCornerRadius:(CGFloat)cornerRadius
{
    self.newCornerMode = MLNUICornerLayerMode;
    [self.layerOperation setCornerRadius:cornerRadius];
    [self.targetView mln_pushRenderTask:self.beforeWaitingTask];
}

- (void)resetCornerRadius:(CGFloat)cornerRadius byRoundingCorners:(MLNUIRectCorner)corners
{
    self.newCornerMode = MLNUICornerMaskLayerMode;
    [self.maskLayerOperation addCorner:(UIRectCorner)corners cornerRadius:cornerRadius];
    [self.targetView mln_pushRenderTask:self.beforeWaitingTask];
}

- (void)resetCornerMaskViewWithRadius:(CGFloat)cornerRadius maskColor:(UIColor *)maskColor corners:(UIRectCorner)corners
{
    self.newCornerMode = MLNUICornerMaskImageViewMode;
    [self.maskViewOperation addCorner:corners cornerRadius:cornerRadius maskColor:maskColor];
    [self.targetView mln_pushRenderTask:self.beforeWaitingTask];
}

- (void)resetShadow:(UIColor *)shadowColor shadowOffset:(CGSize)offset shadowRadius:(CGFloat)radius shadowOpacity:(CGFloat)opacity isOval:(BOOL)isOval
{
    __unsafe_unretained MLNUIShadowOperation *shadow = self.shadowOperation;
    shadow.shadowColor = shadowColor;
    shadow.shadowOffset = offset;
    shadow.shadowRadius = radius;
    shadow.shadowOpcity = opacity;
    [self.targetView mln_pushRenderTask:self.beforeWaitingTask];
}

- (void)resetBorderWithBorderWidth:(CGFloat)borderWidth borderColor:(UIColor *)borderColor
{
    self.borderOperation.borderWidth = borderWidth;
    self.borderOperation.borderColor = borderColor;
    [self.targetView mln_pushRenderTask:self.beforeWaitingTask];
}

- (MLNUICornerRadius)currentCornerRadiusWithCornerMode:(MLNUICornerMode)cornerMode
{
    MLNUICornerRadius cornerRadius = { .topLeft = 0, .topRight = 0, .bottomLeft = 0, .bottomRight = 0 };
    cornerRadius.topLeft = [self cornerRadiusWithDirection:MLNUIRectCornerTopLeft];
    cornerRadius.topRight = [self cornerRadiusWithDirection:MLNUIRectCornerTopRight];
    cornerRadius.bottomLeft = [self cornerRadiusWithDirection:MLNUIRectCornerBottomLeft];
    cornerRadius.bottomRight = [self cornerRadiusWithDirection:MLNUIRectCornerBottomRight];
    return  cornerRadius;
}

- (CGFloat)cornerRadius
{
    return [[self cornerOperationWithMode:self.newCornerMode] cornerRadiusWithDirection:UIRectCornerTopLeft];
}

- (CGFloat)cornerRadiusWithDirection:(MLNUIRectCorner)corner
{
    return [[self cornerOperationWithMode:self.newCornerMode] cornerRadiusWithDirection:(UIRectCorner)corner];
}

- (void)doCornerTask
{
    if (self.newCornerMode != self.lastCornerMode && self.lastCornerMode != MLNUICornerModeNone) {
        [[self cornerOperationWithMode:self.lastCornerMode] clean];
    }
    [[self cornerOperationWithMode:self.newCornerMode] remakeIfNeed];
    self.lastCornerMode = self.newCornerMode;
}

#pragma mark clipToBoundspo
- (void)resetClipWithTask
{
    [self.targetView mln_pushRenderTask:self.beforeWaitingTask];
}

- (void)doClipCheck
{
    if (!self.targetView.mln_renderContext.didSetClipToBounds && [self.targetView.superview lua_enable]) {
        MLNUIRenderContext *superContenx = [self.targetView.superview mln_renderContext];
        if (superContenx.didSetClipToChildren) {
            self.targetView.clipsToBounds = superContenx.clipToChildren;
        }
    }
}

#pragma mark - setter
- (void)setDidSetClipToChildren:(BOOL)didSetClipToChildren
{
    _didSetClipToChildren = didSetClipToChildren;
    if (!CGRectEqualToRect(self.targetView.frame, CGRectZero)) {
        for (UIView *subview in self.targetView.subviews) {
            [subview.mln_renderContext resetClipWithTask];
        }
    }
}

#pragma mark - Layer
- (void)cleanLayerContentsIfNeed
{
    if (![self.targetView isKindOfClass:[UIImageView class]] && self.targetView.layer.contents) {
        self.targetView.layer.contents = nil;
    }
}

#pragma mark - Gradient
- (void)resetGradientColor:(UIColor *)startColor endColor:(UIColor *)endColor direction:(MLNUIGradientType)direction
{
    self.gradientLayerOperation.startColor = startColor;
    self.gradientLayerOperation.endColor = endColor;
    self.gradientLayerOperation.direction = direction;
    [self.targetView mln_pushRenderTask:self.beforeWaitingTask];
}

- (void)updateIfNeed
{
    [self doTask];
}

- (void)cleanGradientColorIfNeed
{
    if (_gradientLayerOperation) {
        [self.gradientLayerOperation cleanGradientLayerIfNeed];
    }
}

#pragma mark - Before Waiting Task
- (void)doTask
{
    [self doCornerTask];
    [self doClipCheck];
    [self.gradientLayerOperation remakeIfNeed];
    MLNUICornerRadius radius = [self currentCornerRadiusWithCornerMode:self.newCornerMode];
    [self.borderOperation updateCornerRadiusAndRemake:radius];
    [self.shadowOperation updateCornerRadiusAndRemake:radius];
}

- (MLNUIBeforeWaitingTask *)beforeWaitingTask
{
    if (!_beforeWaitingTask) {
        __weak typeof(self) wself = self;
        _beforeWaitingTask = [MLNUIBeforeWaitingTask taskWithCallback:^{
            __strong typeof(wself) sself = wself;
            [sself doTask];
        }];
    }
    return _beforeWaitingTask;
}

#pragma mark - Operations
- (id<MLNUICornerHandlerPotocol>)cornerOperationWithMode:(MLNUICornerMode)mode
{
    switch (mode) {
        case MLNUICornerLayerMode:
            return self.layerOperation;
        case MLNUICornerMaskLayerMode:
            return self.maskLayerOperation;
        case MLNUICornerMaskImageViewMode:
            return self.maskViewOperation;
        default:
            return nil;
    }
}

- (id<MLNUICornerHandlerPotocol>)layerOperation
{
    if (!_layerOperation) {
        _layerOperation = [MLNUICornerManagerFactory handlerWithType:MLNUICornerLayerMode targetView:self.targetView];
    }
    return _layerOperation;
}

- (id<MLNUICornerHandlerPotocol>)maskLayerOperation
{
    if (!_maskLayerOperation) {
        _maskLayerOperation = [MLNUICornerManagerFactory handlerWithType:MLNUICornerMaskLayerMode targetView:self.targetView];
    }
    return _maskLayerOperation;
}

- (id<MLNUICornerHandlerPotocol>)maskViewOperation
{
    if (!_maskViewOperation) {
        _maskViewOperation = [MLNUICornerManagerFactory handlerWithType:MLNUICornerMaskImageViewMode targetView:self.targetView];
    }
    return _maskViewOperation;
}

- (MLNUIGradientLayerOperation *)gradientLayerOperation
{
    if (!_gradientLayerOperation) {
        _gradientLayerOperation = [[MLNUIGradientLayerOperation alloc] initWithTargetView:self.targetView];
    }
    return _gradientLayerOperation;
}

- (MLNUIShadowOperation *)shadowOperation
{
    if (!_shadowOperation) {
        _shadowOperation = [[MLNUIShadowOperation alloc] initWithTargetView:self.targetView];
    }
    return _shadowOperation;
}

- (MLNUIBorderLayerOperation *)borderOperation
{
    if (!_borderOperation) {
        _borderOperation = [[MLNUIBorderLayerOperation alloc] initWithTargetView:self.targetView];
    }
    return _borderOperation;
}

@end
