//
//  MLNUICornerMaskLayerHndler.m
//
//
//  Created by MoMo on 2019/5/26.
//

#import "MLNUICornerMaskLayerHndler.h"
#import "MLNUICornerManagerTool.h"
#import "MLNUILayoutNode.h"
#import "UIView+MLNUILayout.h"
#import "UIView+MLNUIKit.h"
#import "MLNUIRenderContext.h"

@interface MLNUICornerMaskLayerHndler()

@property (nonatomic, assign) MLNUICornerRadius multiRadius;
@property (nonatomic, assign) MLNUICornerRadius lastMultiRadius;

@end

@implementation MLNUICornerMaskLayerHndler
@synthesize needRemake = _needRemake;
@synthesize targetView = _targetView;

- (nonnull instancetype)initWithTargetView:(nonnull UIView *)targetView {
    if (self = [super init]) {
        _targetView = targetView;
    }
    return self;
}

- (void)setCornerRadius:(CGFloat)cornerRadius {
    [self addCorner:UIRectCornerAllCorners cornerRadius:cornerRadius];
}

- (void)addCorner:(UIRectCorner)corner cornerRadius:(CGFloat)cornerRadius {
    [self addCorner:corner cornerRadius:cornerRadius maskColor:nil];
}

- (void)addCorner:(UIRectCorner)corner cornerRadius:(CGFloat)cornerRadius maskColor:(nullable UIColor *)maskColor {
    MLNUICornerRadius newMultiRadius = [MLNUICornerManagerTool multiRadius:_multiRadius append:corner cornerRadius:cornerRadius];
    if ([MLNUICornerManagerTool multiRadius:_multiRadius equalMultiRadius:newMultiRadius]) {
        return;
    }
    _needRemake = YES;
    _multiRadius = newMultiRadius;
}

- (CGFloat)cornerRadiusWithDirection:(UIRectCorner)corner
{
    return [MLNUICornerManagerTool cornerRadiusWithDirection:corner multiRadius:_multiRadius];
}

- (void)remakeIfNeed {
    CGRect frame = [MLNUICornerManagerTool viewFrame:self.targetView];
    if (_needRemake) {
        UIBezierPath *maskPath = [MLNUICornerManagerTool bezierPathWithRect:frame multiRadius:_multiRadius];
        CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
        maskLayer.frame = frame;
        maskLayer.path = maskPath.CGPath;
        self.targetView.layer.mask = maskLayer;
        if (!self.targetView.clipsToBounds) {
            self.targetView.clipsToBounds = YES;
        }
    } else if (_targetView.layer.mask && !CGRectEqualToRect(_targetView.layer.mask.frame,frame))
               {
                   [UIView performWithoutAnimation:^{
                       self.targetView.layer.mask.frame = self.targetView.bounds;
                   }];
               }
}

- (void)clean {
    _targetView.clipsToBounds = _targetView.mlnui_renderContext.clipToBounds;
    _targetView.layer.mask = nil;
    _needRemake = NO;
}

@end
