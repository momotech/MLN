//
//  MLNUIRenderContext.h
//  MMLNUIua
//
//  Created by MoMo on 2019/4/16.
//

#import <UIKit/UIKit.h>
#import "MLNUIViewConst.h"

NS_ASSUME_NONNULL_BEGIN

@interface MLNUIRenderContext : NSObject

- (instancetype)initWithTargetView:(UIView *)targetView;

@property (nonatomic, weak, readonly) UIView *targetView;
@property (nonatomic, assign) BOOL clipToBounds;
@property (nonatomic, assign) BOOL didSetClipToChildren;
@property (nonatomic, assign) BOOL clipToChildren;
@property (nonatomic, assign) BOOL didSetClipToBounds;

- (void)resetCornerRadius:(CGFloat)cornerRadius;
- (void)resetCornerRadius:(CGFloat)cornerRadius byRoundingCorners:(MLNUIRectCorner)corners;
- (void)resetCornerMaskViewWithRadius:(CGFloat)cornerRadius maskColor:(UIColor *)maskColor corners:(UIRectCorner)corners;
- (void)resetGradientColor:(UIColor *)startColor endColor:(UIColor *)endColor direction:(MLNUIGradientType)direction;
- (void)resetShadow:(UIColor *)shadowColor shadowOffset:(CGSize)offset shadowRadius:(CGFloat)radius shadowOpacity:(CGFloat)opacity isOval:(BOOL)isOval;
- (void)resetBorderWithBorderWidth:(CGFloat)borderWidth borderColor:(UIColor *)borderColor;

- (void)updateIfNeed;
- (void)cleanGradientColorIfNeed;
- (void)cleanLayerContentsIfNeed;
- (void)resetClipWithTask;

- (CGFloat)cornerRadius;
- (CGFloat)cornerRadiusWithDirection:(MLNUIRectCorner)corner;

@end

NS_ASSUME_NONNULL_END
