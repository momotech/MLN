//
//  MLNBorderLayerOperation.m
//  MLN
//
//  Created by MoMo on 2019/8/14.
//

#import "MLNBorderLayerOperation.h"
#import "MLNCornerManagerTool.h"

@interface MLNBorderLayerOperation()

@property (nonatomic, strong) CAShapeLayer *borderLayer;

@end

@implementation MLNBorderLayerOperation

- (instancetype)initWithTargetView:(UIView *)targetView
{
    if (self = [super init]) {
        _targetView = targetView;
    }
    return self;
}

- (void)setBorderWidth:(CGFloat)borderWidth
{
    if (_borderWidth != borderWidth) {
        _borderWidth = borderWidth;
        _needRemake = YES;
    }
}

- (void)setBorderColor:(UIColor *)borderColor
{
    if (!CGColorEqualToColor(_borderColor.CGColor, borderColor.CGColor)) {
        _borderColor = borderColor;
        _needRemake = YES;
    }
}

- (void)remakeIfNeed
{
    if (self.borderLayer && self.targetView && !CGRectEqualToRect(self.borderLayer.bounds, self.targetView.bounds)) {
        self.needRemake = YES;
    }
    if (self.needRemake) {
        [self remake];
        self.needRemake = NO;
        return;
    }
    
    CALayer *targetLayer = self.targetView.layer;
    CGFloat cornerRadius = targetLayer.cornerRadius;
    if (self.borderLayer.cornerRadius != cornerRadius) {
        [CATransaction begin];
        [CATransaction setDisableActions:YES];
        self.borderLayer.cornerRadius = cornerRadius;
        [CATransaction commit];
    }
    if (self.borderLayer && targetLayer.sublayers.lastObject != self.borderLayer) {
        [targetLayer insertSublayer:self.borderLayer atIndex:0];
    }
}

- (void)remake
{
    [self.borderLayer removeFromSuperlayer];
    self.borderLayer = nil;
    // 重绘border
    self.borderLayer = [[CAShapeLayer alloc] init];
    self.borderLayer.strokeColor = _borderColor == nil? [UIColor blackColor].CGColor : _borderColor.CGColor;
    self.borderLayer.fillColor = nil;
    CGFloat maxBorderWidth = MIN(self.targetView.bounds.size.width, self.targetView.bounds.size.height)/2.0;
    CGFloat borderWidth = _borderWidth < maxBorderWidth? _borderWidth : maxBorderWidth;
    self.borderLayer.path = [MLNCornerManagerTool bezierPathWithRect:self.targetView.bounds multiRadius:self.multiRadius  lineWidth:borderWidth].CGPath;
    self.borderLayer.frame = self.targetView.bounds;
    self.borderLayer.lineWidth = borderWidth+0.5;
    self.borderLayer.lineCap = [self existRoundCorner]? kCALineCapRound : kCALineCapSquare;
    self.borderLayer.allowsGroupOpacity = NO;
    [self.targetView.layer addSublayer:self.borderLayer];
}

- (void)updateCornerRadiusAndRemake:(MLNCornerRadius)radius
{
    self.multiRadius = radius;
    [self remakeIfNeed];
}


- (void)cleanBorderLayerIfNeed
{
    _needRemake = NO;
    if (_borderLayer) {
        [_borderLayer removeFromSuperlayer];
        _borderLayer = nil;
    }
}

#pragma mark - Util
- (BOOL)existRoundCorner
{
    return _multiRadius.topLeft != 0 || _multiRadius.topRight != 0 || _multiRadius.bottomLeft != 0 || _multiRadius.bottomRight != 0;
}

@end
