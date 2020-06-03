//
//  MLNUICornerMaskViewHandler.m
//
//
//  Created by MoMo on 2019/5/26.
//

#import "MLNUICornerMaskViewHandler.h"
#import "MLNUICornerManagerTool.h"
#import "UIView+MLNUILayout.h"
//#import "MLNUIContext.h"
#import "MLNUICornerMaskImageManager.h"

@interface MLNUICornerMaskViewHandler()

@property (nonatomic, strong) UIImageView *maskView;
@property (nonatomic, strong) UIColor *maskColor;
@property (nonatomic, assign) MLNUICornerRadius multiRadius;
@property (nonatomic, assign) MLNUICornerRadius lastMultiRadius;
@property (nonatomic, assign) UIRectCorner corners;

@end

@implementation MLNUICornerMaskViewHandler
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
    MLNUICornerRadius newMultiRadius = [MLNUICornerManagerTool multiRadius:_multiRadius append:corner cornerRadius:cornerRadius];
    if ([MLNUICornerManagerTool multiRadius:_multiRadius equalMultiRadius:newMultiRadius]) {
        return;
    }
    _needRemake = YES;
    _multiRadius = newMultiRadius;
    _corners |= corner;
    [self setMaskColor:maskColor];
}

- (CGFloat)cornerRadiusWithDirection:(UIRectCorner)corner
{
   return [MLNUICornerManagerTool cornerRadiusWithDirection:corner multiRadius:_multiRadius];
}

- (void)setMaskColor:(UIColor *)maskColor
{
    if (maskColor == nil || ![maskColor isKindOfClass:[UIColor class]]) {
//        MLNUILuaAssert(NO, @"The type of mask color should be Color!");
        maskColor = [UIColor clearColor];
    }
    if (!CGColorEqualToColor(maskColor.CGColor, _maskColor.CGColor)) {
        _maskColor = maskColor;
        _needRemake = YES;
    }
}

- (void)remakeIfNeed {
    CGRect frame = [MLNUICornerManagerTool viewFrame:self.targetView];
    MLNUICornerRadius realMultiRadius = [MLNUICornerManagerTool realMultiCornerRadiusWith:_multiRadius size:frame.size];
    if (self.needRemake) {
        UIImage *image = [[MLNUICornerMaskImageManager sharedManager] cornerMaskImageWithMultiRadius:realMultiRadius maskColor:_maskColor corners:_corners];
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
