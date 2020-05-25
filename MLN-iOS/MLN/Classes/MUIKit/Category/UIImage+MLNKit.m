//
//  UIImage+MLNKit.m
//  MLN
//
//  Created by MOMO on 2019/10/16.
//

#import "UIImage+MLNKit.h"
#import "MLNCornerManagerTool.h"

@implementation UIImage (MLNKit)

- (UIImage *)mln_ImageWithCornerRadius:(MLNCornerRadius)cornerRadius
{
    CGRect rect = (CGRect){0.f, 0.f, self.size};
    UIImage *image = nil;
    // 根据矩形画带圆角的曲线
    CGPathRef path  = [MLNCornerManagerTool bezierPathWithRect:rect multiRadius:cornerRadius].CGPath;
    if (@available(iOS 10.0, *)) {
        UIGraphicsImageRendererFormat *format = [[UIGraphicsImageRendererFormat alloc] init];
        format.prefersExtendedRange = YES;
        UIGraphicsImageRenderer *renderer = [[UIGraphicsImageRenderer alloc] initWithSize:self.size format:format];
        __weak typeof(self) weakSelf = self;
        image = [renderer imageWithActions:^(UIGraphicsImageRendererContext * _Nonnull rendererContext) {
            CGContextAddPath(rendererContext.CGContext, path);
            CGContextClip(rendererContext.CGContext);
            [weakSelf drawInRect:rect];
        }];
    } else {
        // size——同UIGraphicsBeginImageContext,参数size为新创建的位图上下文的大小
        // opaque—透明开关，如果图形完全不用透明，设置为YES以优化位图的存储。
        // scale—–缩放因子
        UIGraphicsBeginImageContextWithOptions(self.size, NO, UIScreen.mainScreen.scale);
        // 根据矩形画带圆角的曲线
        CGContextAddPath(UIGraphicsGetCurrentContext(), path);
        CGContextClip(UIGraphicsGetCurrentContext());
        [self drawInRect:rect];
        image = UIGraphicsGetImageFromCurrentImageContext();
        // 关闭上下文
        UIGraphicsEndImageContext();
    }
    return image;
}

+ (UIImage *)mln_imageWithColor:(UIColor *)color finalSize:(CGSize)size cornerRadius:(CGFloat)cornerRadius
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
