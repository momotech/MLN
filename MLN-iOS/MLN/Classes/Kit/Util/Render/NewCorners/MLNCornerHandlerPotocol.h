//
//  MLNCornerHandlerPotocol.h
//
//
//  Created by MoMo on 2019/5/26.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol MLNCornerHandlerPotocol <NSObject>

@property (nonatomic, assign) BOOL needRemake;
@property (nonatomic, weak, readonly) UIView *targetView;

- (instancetype)initWithTargetView:(UIView *)targetView;
- (void)setCornerRadius:(CGFloat)cornerRadius;
- (void)addCorner:(UIRectCorner)corner
     cornerRadius:(CGFloat)cornerRadius;
- (void)addCorner:(UIRectCorner)corner
     cornerRadius:(CGFloat)cornerRadius
        maskColor:(nullable UIColor *)maskColor;
- (CGFloat)cornerRadiusWithDirection:(UIRectCorner)corner;
- (void)remakeIfNeed;
- (void)clean;

@end

NS_ASSUME_NONNULL_END
