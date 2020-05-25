//
//  UIImage+mln_in_util.m
//  MLNUI
//
//  Created by MoMo on 2019/1/16.
//

#import "UIImage+MLNUI_IN_UTIL.h"

@implementation UIImage (MLNUI_IN_UTIL)

+ (UIImage *)mln_in_imageWithColor:(UIColor *)color finalSize:(CGSize)size cornerRadius:(CGFloat)cornerRadius
{
    if (!color) {
        color = [UIColor clearColor];
    }
    
    UIImage *img = nil;
    CGRect rect = CGRectMake(0, 0, size.width, size.height);
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, [UIScreen mainScreen].scale);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    [[UIBezierPath bezierPathWithRoundedRect:rect cornerRadius:cornerRadius] addClip];
    CGContextSetFillColorWithColor(context,color.CGColor);
    CGContextFillRect(context, rect);
    img = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    return img;
}

@end
