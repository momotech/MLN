//
//  MLNCornerManagerTool.h
//
//
//  Created by MoMo on 2019/5/26.
//

#import <Foundation/Foundation.h>
#import "MLNViewConst.h"

NS_ASSUME_NONNULL_BEGIN

@interface MLNCornerManagerTool : NSObject

+ (CGFloat)realCornerRadiusWith:(UIView *)targetView
                   cornerRadius:(CGFloat)cornerRadius;

+ (MLNCornerRadius)realMultiCornerRadiusWith:(MLNCornerRadius)multiRadius
                                       size:(CGSize)size;

+ (MLNCornerRadius)multiRadius:(MLNCornerRadius)multiRadius
                        append:(UIRectCorner)corner
                  cornerRadius:(CGFloat)cornerRadius;
+ (BOOL)multiRadius:(MLNCornerRadius)multiRadius
             equalMultiRadius:(MLNCornerRadius)equalMultiRadius;

+ (BOOL)layerModeWith:(MLNCornerRadius)multiRadius;

+ (UIBezierPath *)bezierPathWithRect:(CGRect)frame multiRadius:(MLNCornerRadius)multiRadius;

+ (UIBezierPath *)bezierPathWithRect:(CGRect)frame multiRadius:(MLNCornerRadius)multiRadius lineWidth:(CGFloat)lineWidth;

+ (CGFloat)cornerRadiusWithDirection:(UIRectCorner)corner multiRadius:(MLNCornerRadius)multiRadius;

+ (CGRect)viewFrame:(UIView *)view;

@end

NS_ASSUME_NONNULL_END
