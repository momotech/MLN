//
//  MLNShadowOperation
//
//
//  Created by MoMo on 2019/3/20.
//

#import "MLNShadowOperation.h"

@interface MLNShadowOperation()

@property (nonatomic, strong) UIBezierPath* shadowPath;

@property (nonatomic, assign) CGRect originRect;

@end

@implementation MLNShadowOperation

- (instancetype)initWithTargetView:(UIView *)targetView
{
    if (self = [super init]) {
        _targetView = targetView;
    }
    return self;
}

- (void)setShadowColor:(UIColor *)shadowColor
{
    if (_shadowColor != shadowColor) {
        _shadowColor = shadowColor;
        _needRemake = YES;
    }
}

- (void)setShadowOffset:(CGSize)shadowOffset
{
    if (!CGSizeEqualToSize(_shadowOffset, shadowOffset)) {
        _shadowOffset = shadowOffset;
        _needRemake = YES;
    }
}

- (void)setShadowRadius:(CGFloat)shadowRadius
{
    if (_shadowRadius != shadowRadius) {
        _shadowRadius = shadowRadius;
        _needRemake = YES;
    }
}

- (void)setShadowOpcity:(CGFloat)shadowOpcity
{
    if (_shadowOpcity != shadowOpcity) {
        _shadowOpcity = shadowOpcity;
        _needRemake = YES;
    }
}

- (void)remakeIfNeed
{
    //属性修改或者尺寸修改，重绘
    if (self.needRemake || !CGRectEqualToRect(_originRect, self.targetView.bounds)) {
        _originRect = self.targetView.bounds;
        [self remake];
        _needRemake = NO;
        return;
    }
}

- (void)remake
{
    self.targetView.layer.shadowColor = self.shadowColor.CGColor;
    self.targetView.layer.shadowOffset = self.shadowOffset;
    self.targetView.layer.shadowOpacity = self.shadowOpcity;
    self.targetView.layer.shadowRadius = self.shadowRadius;
    
    //阴影路径
    if (!_shadowPath) {
        _shadowPath = [UIBezierPath bezierPath];
    }
    [_shadowPath removeAllPoints];
    
    float width = self.targetView.bounds.size.width;
    float height = self.targetView.bounds.size.height;
    float x = self.targetView.bounds.origin.x;
    float y = self.targetView.bounds.origin.y;
    
    CGPoint topLeft      = self.targetView.bounds.origin;
    CGPoint topRight     = CGPointMake(x + width, y);
    CGPoint bottomRight  = CGPointMake(x + width, y + height);
    CGPoint bottomLeft   = CGPointMake(x, y + height);
    
    CGFloat offsetW = self.shadowOffset.width;
    CGFloat offsetH = self.shadowOffset.height;
    [_shadowPath moveToPoint:CGPointMake(topLeft.x - offsetW, topLeft.y - offsetH)];
    [_shadowPath addLineToPoint:CGPointMake(topRight.x + offsetW, topRight.y - offsetH)];
    [_shadowPath addLineToPoint:CGPointMake(bottomRight.x + offsetW, bottomRight.y + offsetH)];
    [_shadowPath addLineToPoint:CGPointMake(bottomLeft.x - offsetW, bottomLeft.y + offsetH)];
    [_shadowPath addLineToPoint:CGPointMake(topLeft.x - offsetW, topLeft.y - offsetH)];
    
    //设置阴影路径
    self.targetView.layer.shadowPath = _shadowPath.CGPath;
}


- (void)cleanShadowLayerIfNeed
{
    if (self.targetView.layer.shadowPath) {
        self.targetView.layer.shadowColor = nil;
        self.targetView.layer.shadowOffset = CGSizeZero;
        self.targetView.layer.shadowOpacity = 0;
        self.targetView.layer.shadowRadius = 0;
        self.targetView.layer.shadowPath = nil;
    }
}

@end
