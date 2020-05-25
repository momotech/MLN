//
//  MLNUICornerMaskImageManager.h
//
//
//  Created by MoMo on 2018/10/12.
//

#import <UIKit/UIKit.h>
#import "MLNUIViewConst.h"

NS_ASSUME_NONNULL_BEGIN

@interface MLNUICornerMaskImageManager : NSObject

+ (instancetype)sharedManager;

- (UIImage *)cornerMaskImageWithRadius:(CGFloat)cornerRadius maskColor:(UIColor *)maskColor corners:(UIRectCorner)corners;
- (UIImage *)cornerMaskImageWithMultiRadius:(MLNUICornerRadius)cornerRadius maskColor:(UIColor *)maskColor corners:(UIRectCorner)corners;

@end

NS_ASSUME_NONNULL_END
