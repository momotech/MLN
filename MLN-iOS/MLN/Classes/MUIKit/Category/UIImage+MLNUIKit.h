//
//  UIImage+MLNUIKit.h
//  MLNUI
//
//  Created by MOMO on 2019/10/16.
//

#import <UIKit/UIKit.h>
#import "MLNUIViewConst.h"

NS_ASSUME_NONNULL_BEGIN

@interface UIImage (MLNUIKit)

+ (UIImage *)mlnui_imageWithColor:(UIColor *)color finalSize:(CGSize)size cornerRadius:(CGFloat)cornerRadius;

- (UIImage *)mlnui_ImageWithCornerRadius:(MLNUICornerRadius)cornerRadius;

@end

NS_ASSUME_NONNULL_END
