//
//  MLNCornerMaskImageManager.h
//
//
//  Created by MoMo on 2018/10/12.
//

#import <UIKit/UIKit.h>
#import "MLNViewConst.h"

NS_ASSUME_NONNULL_BEGIN

@interface MLNCornerMaskImageManager : NSObject

+ (instancetype)sharedManager;

- (UIImage *)cornerMaskImageWithRadius:(CGFloat)cornerRadius maskColor:(UIColor *)maskColor corners:(UIRectCorner)corners;
- (UIImage *)cornerMaskImageWithMultiRadius:(MLNCornerRadius)cornerRadius maskColor:(UIColor *)maskColor corners:(UIRectCorner)corners;

@end

NS_ASSUME_NONNULL_END
