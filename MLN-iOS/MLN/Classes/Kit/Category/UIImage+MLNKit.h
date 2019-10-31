//
//  UIImage+MMILua.h
//  MoMo
//
//  Created by MOMO on 2019/10/16.
//

#import <UIKit/UIKit.h>
#import "MLNViewConst.h"

NS_ASSUME_NONNULL_BEGIN

@interface UIImage (MLNKit)

+ (UIImage *)mln_in_imageWithColor:(UIColor *)color finalSize:(CGSize)size cornerRadius:(CGFloat)cornerRadius;

- (UIImage *)mln_in_ImageWithCornerRadius:(MLNCornerRadius)cornerRadius;

@end

NS_ASSUME_NONNULL_END
