//
//  MLNCornerMaskImageManager.m
//
//
//  Created by MoMo on 2018/10/12.
//

#import "MLNCornerMaskImageManager.h"


@interface MLNCornerMaskImageManager ()

@property (nonatomic, strong) NSCache *imagesCacahe;

@end

@implementation MLNCornerMaskImageManager

static MLNCornerMaskImageManager *instance = nil;
+ (instancetype)sharedManager
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[MLNCornerMaskImageManager alloc] init];
    });
    return instance;
}

- (UIImage *)cornerMaskImageWithRadius:(CGFloat)cornerRadius maskColor:(UIColor *)maskColor corners:(UIRectCorner)corners
{
    MLNCornerRadius multiRadius = {cornerRadius,cornerRadius,cornerRadius,cornerRadius};
    UIImage *image = [self cornerMaskImageWithMultiRadius:multiRadius maskColor:maskColor corners:corners];
    return image;
}

- (UIImage *)cornerMaskImageWithMultiRadius:(MLNCornerRadius)cornerRadius maskColor:(UIColor *)maskColor corners:(UIRectCorner)corners
{
    NSString *key = [self keyWithMultiRadius:cornerRadius maskColor:maskColor corners:corners];
    // 1. cache
    UIImage *image = [self.imagesCacahe objectForKey:key];
    // TODO: - 2. main bundle
    // 3. create
    if (!image) {
        image = [self createCornerMaskImageWithMultiRadius:cornerRadius maskColor:maskColor corners:corners];
        if (image && key) {
            [self.imagesCacahe setObject:image forKey:key];
        }
    }
    return image;
}

- (NSString *)keyWithMultiRadius:(MLNCornerRadius)cornerRadius maskColor:(UIColor *)maskColor corners:(UIRectCorner)corners
{
    CGFloat red = 0.f;
    CGFloat green = 0.f;
    CGFloat blue = 0.f;
    CGFloat alpha = 0.f;
    [maskColor getRed:&red green:&green blue:&blue alpha:&alpha];
    return [NSString stringWithFormat:@"corner_mask_%f_%f_%f_%f_%f_%f_%f_%f_%lu",cornerRadius.topLeft,cornerRadius.topRight,cornerRadius.bottomLeft,cornerRadius.bottomRight, red, green, blue, alpha, (unsigned long)corners];
}

- (UIImage *)createCornerMaskImageWithMultiRadius:(MLNCornerRadius)multiCornerRadius maskColor:(UIColor *)maskColor corners:(UIRectCorner)corners
{
    CGFloat radius1 = MAX(multiCornerRadius.topLeft,0);
    CGFloat radius2 = MAX(multiCornerRadius.topRight,0);
    CGFloat radius3 = MAX(multiCornerRadius.bottomLeft,0);
    CGFloat radius4 = MAX(multiCornerRadius.bottomRight,0);
    CGFloat maxW = MAX(MAX(MAX(radius1, radius2), radius3),radius4);
    
    CGSize size = CGSizeMake(maxW * 2, maxW * 2);
    if (CGSizeEqualToSize(size, CGSizeZero)) {
        return nil;
    }
    
    UIGraphicsBeginImageContextWithOptions(size, NO, 0);
    CGContextRef cxt = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(cxt, maskColor.CGColor);
    CGContextBeginPath(cxt);
    
    if ((corners&UIRectCornerTopLeft) == UIRectCornerTopLeft) {
        CGContextMoveToPoint(cxt, radius1, 0.f);
        CGContextAddLineToPoint(cxt, 0.f, 0.f);
        CGContextAddLineToPoint(cxt, 0.f, radius1);
        CGContextAddArcToPoint(cxt, 0.f, 0.f, radius1, 0.f, radius1);
    }
    
    if ((corners&UIRectCornerTopRight) == UIRectCornerTopRight) {
        CGContextMoveToPoint(cxt, radius2, 0.f);
        CGContextAddLineToPoint(cxt, size.width, 0.f);
        CGContextAddLineToPoint(cxt, size.width, radius2);
        CGContextAddArcToPoint(cxt, size.width, 0.f, radius3, 0.f, radius2);
    }
    
    if ((corners&UIRectCornerBottomLeft) == UIRectCornerBottomLeft) {
        CGContextMoveToPoint(cxt, size.width / 2.0, size.height);
        CGContextAddLineToPoint(cxt, 0.f, size.height);
        CGContextAddLineToPoint(cxt, 0.f, size.height / 2.0);
        CGContextAddArcToPoint(cxt, 0.f, size.height, radius3, size.height, radius3);
    }
    
    if ((corners&UIRectCornerBottomRight) == UIRectCornerBottomRight) {
        CGContextMoveToPoint(cxt, size.width, radius4);
        CGContextAddLineToPoint(cxt, size.width, size.height);
        CGContextAddLineToPoint(cxt, radius4, size.height);
        CGContextAddArcToPoint(cxt, size.width, size.height, size.width, radius4, radius4);
    }
    
    CGContextClosePath(cxt);
    CGContextDrawPath(cxt, kCGPathFill);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    image = [image resizableImageWithCapInsets:UIEdgeInsetsMake(maxW, maxW, maxW, maxW)];
    UIGraphicsEndImageContext();
    return image;
}

- (NSCache *)imagesCacahe
{
    if (!_imagesCacahe) {
        _imagesCacahe = [[NSCache alloc] init];
    }
    return _imagesCacahe;
}

@end
