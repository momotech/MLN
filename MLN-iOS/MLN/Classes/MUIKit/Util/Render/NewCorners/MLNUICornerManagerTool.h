//
//  MLNUICornerManagerTool.h
//
//
//  Created by MoMo on 2019/5/26.
//

#import <Foundation/Foundation.h>
#import "MLNUIViewConst.h"

NS_ASSUME_NONNULL_BEGIN

@interface MLNUICornerManagerTool : NSObject

+ (CGFloat)realCornerRadiusWith:(UIView *)targetView
                   cornerRadius:(CGFloat)cornerRadius;

+ (MLNUICornerRadius)realMultiCornerRadiusWith:(MLNUICornerRadius)multiRadius
                                       size:(CGSize)size;

+ (MLNUICornerRadius)multiRadius:(MLNUICornerRadius)multiRadius
                        append:(UIRectCorner)corner
                  cornerRadius:(CGFloat)cornerRadius;
+ (BOOL)multiRadius:(MLNUICornerRadius)multiRadius
             equalMultiRadius:(MLNUICornerRadius)equalMultiRadius;

+ (BOOL)layerModeWith:(MLNUICornerRadius)multiRadius;

+ (UIBezierPath *)bezierPathWithRect:(CGRect)frame multiRadius:(MLNUICornerRadius)multiRadius;

+ (UIBezierPath *)bezierPathWithRect:(CGRect)frame multiRadius:(MLNUICornerRadius)multiRadius lineWidth:(CGFloat)lineWidth;

+ (CGFloat)cornerRadiusWithDirection:(UIRectCorner)corner multiRadius:(MLNUICornerRadius)multiRadius;

+ (CGRect)viewFrame:(UIView *)view;

@end

NS_ASSUME_NONNULL_END
