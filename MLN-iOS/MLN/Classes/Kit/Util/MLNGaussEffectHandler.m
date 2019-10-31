//
//  MLNGaussEffectHandler.m
//  MoMo
//
//  Created by MOMO on 2019/9/20.
//

#import "MLNGaussEffectHandler.h"

@interface MLNGaussEffectHandler()

@end

@implementation MLNGaussEffectHandler

+ (UIImage *)coreBlurImage:(UIImage *)image withBlurValue:(CGFloat)blurValue
{
    // 1.原图
    CIImage *inputImage = [CIImage imageWithCGImage:image.CGImage];
    // 2.设置filter
    CIFilter *filter = [CIFilter filterWithName:@"CIGaussianBlur"];
    [filter setValue:inputImage forKey:kCIInputImageKey];
    [filter setValue:@(blurValue) forKey:@"inputRadius"];
    
    // 3.context上下文合成
    CIImage *outputImage = filter.outputImage;
    CIContext *context = [CIContext contextWithOptions:nil];
    CGImageRef outImage = [context createCGImage:outputImage fromRect:inputImage.extent];
    UIImage *blurImage = [UIImage imageWithCGImage:outImage];
    CGImageRelease(outImage);
    return blurImage;
}


@end
