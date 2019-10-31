//
//  MLNRenderContext.m
//  MMLNua
//
//  Created by MoMo on 2019/4/16.
//

#import "MLNRenderContext.h"
#import "MLNGradientLayerOperation.h"
#import "MLNShadowOperation.h"
#import "MLNBorderLayerOperation.h"
#import "MLNBeforeWaitingTask.h"
#import "MLNCornerManagerFactory.h"
#import "UIView+MLNKit.h"

@interface MLNRenderContext ()

@property (nonatomic, assign) MLNCornerMode newCornerMode;
@property (nonatomic, assign) MLNCornerMode lastCornerMode;
@property (nonatomic, strong) id<MLNCornerHandlerPotocol> layerOperation;
@property (nonatomic, strong) id<MLNCornerHandlerPotocol> maskLayerOperation;
@property (nonatomic, strong) id<MLNCornerHandlerPotocol> maskViewOperation;
@property (nonatomic, strong) MLNGradientLayerOperation *gradientLayerOperation;
@property (nonatomic, strong) MLNShadowOperation *shadowOperation;
@property (nonatomic, strong) MLNBorderLayerOperation *borderOperation;

@property (nonatomic, strong) MLNBeforeWaitingTask *beforeWaitingTask;

@end
@implementation MLNRenderContext

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
    self.newCornerMode = MLNCornerLayerMode;
    [self.layerOperation setCornerRadius:cornerRadius];
    [self.targetView mln_pushRenderTask:self.beforeWaitingTask];
}

- (void)resetCornerRadius:(CGFloat)cornerRadius byRoundingCorners:(MLNRectCorner)corners
{
    self.newCornerMode = MLNCornerMaskLayerMode;
    [self.maskLayerOperation addCorner:(UIRectCorner)corners cornerRadius:cornerRadius];
    [self.targetView mln_pushRenderTask:self.beforeWaitingTask];
}

- (void)resetCornerMaskViewWithRadius:(CGFloat)cornerRadius maskColor:(UIColor *)maskColor corners:(UIRectCorner)corners
{
    self.newCornerMode = MLNCornerMaskImageViewMode;
    [self.maskViewOperation addCorner:corners cornerRadius:cornerRadius maskColor:maskColor];
    [self.targetView mln_pushRenderTask:self.beforeWaitingTask];
}

- (void)resetShadow:(UIColor *)shadowColor shadowOffset:(CGSize)offset shadowRadius:(CGFloat)radius shadowOpacity:(CGFloat)opacity isOval:(BOOL)isOval
{
    __unsafe_unretained MLNShadowOperation *shadow = self.shadowOperation;
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

- (MLNCornerRadius)currentCornerRadiusWithCornerMode:(MLNCornerMode)cornerMode
{
    MLNCornerRadius cornerRadius = { .topLeft = 0, .topRight = 0, .bottomLeft = 0, .bottomRight = 0 };
    cornerRadius.topLeft = [self cornerRadiusWithDirection:MLNRectCornerTopLeft];
    cornerRadius.topRight = [self cornerRadiusWithDirection:MLNRectCornerTopRight];
    cornerRadius.bottomLeft = [self cornerRadiusWithDirection:MLNRectCornerBottomLeft];
    cornerRadius.bottomRight = [self cornerRadiusWithDirection:MLNRectCornerBottomRight];
    return  cornerRadius;
}

- (CGFloat)cornerRadius
{
    return [[self cornerOperationWithMode:self.newCornerMode] cornerRadiusWithDirection:UIRectCornerTopLeft];
}

- (CGFloat)cornerRadiusWithDirection:(MLNRectCorner)corner
{
    return [[self cornerOperationWithMode:self.newCornerMode] cornerRadiusWithDirection:(UIRectCorner)corner];
}

- (void)doCornerTask
{
    if (self.newCornerMode != self.lastCornerMode && self.lastCornerMode != MLNCornerModeNone) {
        [[self cornerOperationWithMode:self.lastCornerMode] clean];
    }
    [[self cornerOperationWithMode:self.newCornerMode] remakeIfNeed];
    self.lastCornerMode = self.newCornerMode;
}

#pragma mark - Layer
- (void)cleanLayerContentsIfNeed
{
    if (self.targetView.layer.contents) {
        self.targetView.layer.contents = nil;
    }
}

#pragma mark - Gradient
- (void)resetGradientColor:(UIColor *)startColor endColor:(UIColor *)endColor direction:(MLNGradientType)direction
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
    [self.gradientLayerOperation remakeIfNeed];
    MLNCornerRadius radius = [self currentCornerRadiusWithCornerMode:self.newCornerMode];
    [self.borderOperation updateCornerRadiusAndRemake:radius];
    [self.shadowOperation updateCornerRadiusAndRemake:radius];
}

- (MLNBeforeWaitingTask *)beforeWaitingTask
{
    if (!_beforeWaitingTask) {
        __weak typeof(self) wself = self;
        _beforeWaitingTask = [MLNBeforeWaitingTask taskWithCallback:^{
            __strong typeof(wself) sself = wself;
            [sself doTask];
        }];
    }
    return _beforeWaitingTask;
}

#pragma mark - Operations
- (id<MLNCornerHandlerPotocol>)cornerOperationWithMode:(MLNCornerMode)mode
{
    switch (mode) {
        case MLNCornerLayerMode:
            return self.layerOperation;
        case MLNCornerMaskLayerMode:
            return self.maskLayerOperation;
        case MLNCornerMaskImageViewMode:
            return self.maskViewOperation;
        default:
            return nil;
    }
}

- (id<MLNCornerHandlerPotocol>)layerOperation
{
    if (!_layerOperation) {
        _layerOperation = [MLNCornerManagerFactory handlerWithType:MLNCornerLayerMode targetView:self.targetView];
    }
    return _layerOperation;
}

- (id<MLNCornerHandlerPotocol>)maskLayerOperation
{
    if (!_maskLayerOperation) {
        _maskLayerOperation = [MLNCornerManagerFactory handlerWithType:MLNCornerMaskLayerMode targetView:self.targetView];
    }
    return _maskLayerOperation;
}

- (id<MLNCornerHandlerPotocol>)maskViewOperation
{
    if (!_maskViewOperation) {
        _maskViewOperation = [MLNCornerManagerFactory handlerWithType:MLNCornerMaskImageViewMode targetView:self.targetView];
    }
    return _maskViewOperation;
}

- (MLNGradientLayerOperation *)gradientLayerOperation
{
    if (!_gradientLayerOperation) {
        _gradientLayerOperation = [[MLNGradientLayerOperation alloc] initWithTargetView:self.targetView];
    }
    return _gradientLayerOperation;
}

- (MLNShadowOperation *)shadowOperation
{
    if (!_shadowOperation) {
        _shadowOperation = [[MLNShadowOperation alloc] initWithTargetView:self.targetView];
    }
    return _shadowOperation;
}

- (MLNBorderLayerOperation *)borderOperation
{
    if (!_borderOperation) {
        _borderOperation = [[MLNBorderLayerOperation alloc] initWithTargetView:self.targetView];
    }
    return _borderOperation;
}

@end
