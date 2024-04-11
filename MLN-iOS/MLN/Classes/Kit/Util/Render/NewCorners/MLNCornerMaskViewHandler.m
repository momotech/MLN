//
//  MLNCornerMaskViewHandler.m
//
//
//  Created by MoMo on 2019/5/26.
//

#import "MLNCornerMaskViewHandler.h"
#import "MLNCornerManagerTool.h"
#import "UIView+MLNLayout.h"
//#import "MLNContext.h"
#import "MLNCornerMaskImageManager.h"

@interface MLNCornerMaskViewHandler()

@property (nonatomic, strong) UIImageView *maskView;
@property (nonatomic, strong) UIColor *maskColor;
@property (nonatomic, assign) MLNCornerRadius multiRadius;
@property (nonatomic, assign) MLNCornerRadius lastMultiRadius;
@property (nonatomic, assign) UIRectCorner corners;

@end

@implementation MLNCornerMaskViewHandler
@synthesize targetView = _targetView;
@synthesize needRemake = _needRemake;

- (instancetype)initWithTargetView:(UIView *)view;
{
    if (self = [super init]) {
        _targetView = view;
        _needRemake = NO;
    }
    return self;
}

- (void)setCornerRadius:(CGFloat)cornerRadius
{
    [self addCorner:UIRectCornerAllCorners cornerRadius:cornerRadius];
}

- (void)addCorner:(UIRectCorner)corner cornerRadius:(CGFloat)cornerRadius
{
    [self addCorner:corner cornerRadius:cornerRadius maskColor:[UIColor clearColor]];
}

- (void)addCorner:(UIRectCorner)corner cornerRadius:(CGFloat)cornerRadius maskColor:(nullable UIColor *)maskColor {
    MLNCornerRadius newMultiRadius = [MLNCornerManagerTool multiRadius:_multiRadius append:corner cornerRadius:cornerRadius];
    if ([MLNCornerManagerTool multiRadius:_multiRadius equalMultiRadius:newMultiRadius]) {
        return;
    }
    _needRemake = YES;
    _multiRadius = newMultiRadius;
    _corners |= corner;
    [self setMaskColor:maskColor];
}

- (CGFloat)cornerRadiusWithDirection:(UIRectCorner)corner
{
   return [MLNCornerManagerTool cornerRadiusWithDirection:corner multiRadius:_multiRadius];
}

- (void)setMaskColor:(UIColor *)maskColor
{
    if (maskColor == nil || ![maskColor isKindOfClass:[UIColor class]]) {
//        MLNLuaAssert(NO, @"The type of mask color should be Color!");
        maskColor = [UIColor clearColor];
    }
    if (!CGColorEqualToColor(maskColor.CGColor, _maskColor.CGColor)) {
        _maskColor = maskColor;
        _needRemake = YES;
    }
}

- (void)remakeIfNeed {
    CGRect frame = [MLNCornerManagerTool viewFrame:self.targetView];
    MLNCornerRadius realMultiRadius = [MLNCornerManagerTool realMultiCornerRadiusWith:_multiRadius size:frame.size];
    if (self.needRemake) {
        UIImage *image = [[MLNCornerMaskImageManager sharedManager] cornerMaskImageWithMultiRadius:realMultiRadius maskColor:_maskColor corners:_corners];
        if (!_maskView) {
            _maskView = [[UIImageView alloc] initWithImage:image];
            _maskView.frame = self.targetView.bounds;
            [_targetView addSubview:self.maskView];
        } else {
            _maskView.image = image;
        }
    }
    if (self.targetView && !CGRectEqualToRect(frame, self.maskView.frame)) {
        _maskView.frame = frame;
    }
    if (_maskView && _targetView.subviews.lastObject != self.maskView) {
        [_targetView bringSubviewToFront:self.maskView];
    }
}

- (void)clean {
    _maskView.image = nil;
    [_maskView removeFromSuperview];
    _maskColor = nil;
    _needRemake = NO;
    _corners = 0;
}

@end
