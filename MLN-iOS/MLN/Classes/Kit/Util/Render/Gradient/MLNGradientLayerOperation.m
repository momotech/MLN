//
//  MLNGradientLayerTask.m
//  MMLNua
//
//  Created by MoMo on 2019/4/16.
//

#import "MLNGradientLayerOperation.h"

@interface MLNGradientLayerOperation ()

@property (nonatomic, strong) CAGradientLayer *gradientLayer;

@end
@implementation MLNGradientLayerOperation

- (instancetype)initWithTargetView:(UIView *)targetView
{
    if (self = [super init]) {
        _targetView = targetView;
    }
    return self;
}

- (void)setStartColor:(UIColor *)startColor
{
    if (_startColor != startColor) {
        _startColor = startColor;
        self.needRemake = YES;
    }
}

- (void)setEndColor:(UIColor *)endColor
{
    if (_endColor != endColor) {
        _endColor = endColor;
        self.needRemake = YES;
    }
}

- (void)setDirection:(MLNGradientType)direction
{
    if (_direction != direction) {
        _direction = direction;
        self.needRemake = YES;
    }
}

- (void)remakeIfNeed
{
    if (self.needRemake) {
        [self remake];
        self.needRemake = NO;
        return;
    }
    CGRect frame = self.targetView.bounds;
    if (self.targetView && !CGRectEqualToRect(frame, self.gradientLayer.frame)) {
        [UIView performWithoutAnimation:^{
            self.gradientLayer.frame = frame;
        }];
    }
    CALayer *targetLayer = self.targetView.layer;
    CGFloat cornerRadius = targetLayer.cornerRadius;
    if (self.gradientLayer.cornerRadius != cornerRadius) {
        [UIView performWithoutAnimation:^{
            self.gradientLayer.cornerRadius = cornerRadius;
        }];
    }
    if (self.gradientLayer && targetLayer.sublayers.lastObject != self.gradientLayer) {
        [UIView performWithoutAnimation:^{
            [targetLayer insertSublayer:self.gradientLayer atIndex:0];
        }];
    }
}

- (void)remake
{
    // 1.清空之前的Layer
    [self.gradientLayer removeFromSuperlayer];
    self.gradientLayer = nil;
    // 2. 重新制作
    self.gradientLayer = [CAGradientLayer layer];
    self.gradientLayer.colors = @[(__bridge id)(self.startColor.CGColor),(__bridge id)(self.endColor.CGColor)];
    self.gradientLayer.locations = @[@0.0,@1.0];
    switch (self.direction) {
        case MLNGradientTypeRightToLeft:
            self.gradientLayer.startPoint = CGPointMake(1.0, 0.0);
            self.gradientLayer.endPoint = CGPointMake(0.0, 0.0);
            break;
        case MLNGradientTypeTopToBottom:
            self.gradientLayer.startPoint = CGPointMake(0.0, 0.0);
            self.gradientLayer.endPoint = CGPointMake(0.0, 1.0);
            break;
        case MLNGradientTypeBottomToTop:
            self.gradientLayer.startPoint = CGPointMake(0.0, 1.0);
            self.gradientLayer.endPoint = CGPointMake(0.0, 0.0);
            break;
        default:
            self.gradientLayer.startPoint = CGPointMake(0.0, 0.0);
            self.gradientLayer.endPoint = CGPointMake(1.0, 0.0);
            break;
    }
    CALayer *targetLayer = self.targetView.layer;
    [targetLayer insertSublayer:self.gradientLayer atIndex:0];
    self.gradientLayer.frame = targetLayer.bounds;
    self.gradientLayer.cornerRadius = targetLayer.cornerRadius;
    self.targetView.backgroundColor = [UIColor clearColor];
}

- (void)cleanGradientLayerIfNeed
{
    _needRemake = NO;
    if (_gradientLayer) {
        [_gradientLayer removeFromSuperlayer];
        _gradientLayer = nil;
    }
}

@end
