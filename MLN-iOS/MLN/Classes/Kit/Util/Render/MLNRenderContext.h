//
//  MLNRenderContext.h
//  MMLNua
//
//  Created by MoMo on 2019/4/16.
//

#import <UIKit/UIKit.h>
#import "MLNViewConst.h"

NS_ASSUME_NONNULL_BEGIN

@interface MLNRenderContext : NSObject

- (instancetype)initWithTargetView:(UIView *)targetView;

@property (nonatomic, weak, readonly) UIView *targetView;
@property (nonatomic, assign) BOOL clipToBounds;
@property (nonatomic, assign) BOOL didSetClipToBounds;

- (void)resetCornerRadius:(CGFloat)cornerRadius;
- (void)resetCornerRadius:(CGFloat)cornerRadius byRoundingCorners:(MLNRectCorner)corners;
- (void)resetCornerMaskViewWithRadius:(CGFloat)cornerRadius maskColor:(UIColor *)maskColor corners:(UIRectCorner)corners;
- (void)resetGradientColor:(UIColor *)startColor endColor:(UIColor *)endColor direction:(MLNGradientType)direction;
- (void)resetShadow:(UIColor *)shadowColor shadowOffset:(CGSize)offset shadowRadius:(CGFloat)radius shadowOpacity:(CGFloat)opacity;
- (void)resetBorderWithBorderWidth:(CGFloat)borderWidth borderColor:(UIColor *)borderColor;

- (void)updateIfNeed;
- (void)cleanGradientColorIfNeed;
- (void)cleanLayerContentsIfNeed;

- (CGFloat)cornerRadius;
- (CGFloat)cornerRadiusWithDirection:(MLNRectCorner)corner;

@end

NS_ASSUME_NONNULL_END
