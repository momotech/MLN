//
//  MLNShadowOperation
//
//
//  Created by MoMo on 2019/3/20.
//

#import "MLNShadowOperation.h"
#import "MLNCornerManagerTool.h"

@interface MLNShadowOperation()

@property (nonatomic, strong) UIBezierPath *shadowPath;
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

- (void)setOval:(BOOL)oval
{
    if (_oval != oval) {
        _oval = oval;
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
    }
}

- (void)remake
{
    self.targetView.layer.shadowColor = self.shadowColor.CGColor;
    self.targetView.layer.shadowOffset = self.shadowOffset;
    self.targetView.layer.shadowRadius = self.shadowRadius;
    self.targetView.layer.shadowOpacity = self.shadowRadius <= 0? 0.0 : self.shadowOpcity;
    _shadowPath = [MLNCornerManagerTool bezierPathWithRect:self.targetView.bounds multiRadius:self.multiRadius];
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

- (void)updateCornerRadiusAndRemake:(MLNCornerRadius)radius
{
    self.multiRadius = radius;
    [self remakeIfNeed];
}

@end
