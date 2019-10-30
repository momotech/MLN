//
//  MLNNinePatchImageFactory
//  MomoChat
//
//  Created by MoMo on 2019/3/19.
//  Copyright © 2019年 wemomo.com. All rights reserved.
//

#import "MLNNinePatchImageFactory.h"
#import "MLNHeader.h"

typedef enum NSInteger{
    MLNNinePathTpeNormal = 1 << 0,
    MLNNinePathTpeVerticalCenter = 1 << 1,  //水平居中保护
    MLNNinePathTpeHorizontalCenter = 1 << 2, //垂直居中保护
}MLNNinePathTpe;

@interface MLNNinePatchImageFactory()

+ (NSArray*)mln_in_getRGBAsFromImage:(UIImage*)image atX:(int)xx andY:(int)yy count:(int)count;
+ (UIImage*)mln_in_createResizableImageFromNinePatchImage:(UIImage*)ninePatchImage imgViewSize:(CGSize)imgViewSize;

@end

@implementation MLNNinePatchImageFactory


+ (NSArray*)mln_in_getRGBAsFromImage:(UIImage*)image atX:(int)xx andY:(int)yy count:(int)count
{
    NSMutableArray* result = [NSMutableArray arrayWithCapacity:count];
    
    // First get the image into your data buffer
    CGImageRef imageRef = [image CGImage];
    NSUInteger width = CGImageGetWidth(imageRef);
    NSUInteger height = CGImageGetHeight(imageRef);
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    unsigned char* rawData = (unsigned char*)calloc(height * width * 4, sizeof(unsigned char));
    NSUInteger bytesPerPixel = 4;
    NSUInteger bytesPerRow = bytesPerPixel * width;
    NSUInteger bitsPerComponent = 8;
    CGContextRef context = CGBitmapContextCreate(rawData, width, height,
                                                 bitsPerComponent, bytesPerRow, colorSpace,
                                                 kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    CGColorSpaceRelease(colorSpace);
    
    CGContextDrawImage(context, CGRectMake(0, 0, width, height), imageRef);
    CGContextRelease(context);
    
    // Now your rawData contains the image data in the RGBA8888 pixel format.
    NSUInteger byteIndex = ((bytesPerRow * yy) + xx * bytesPerPixel);
    for (int ii = 0; ii < count; ++ii) {
        CGFloat red = (rawData[byteIndex] * 1.0) / 255.0;
        CGFloat green = (rawData[byteIndex + 1] * 1.0) / 255.0;
        CGFloat blue = (rawData[byteIndex + 2] * 1.0) / 255.0;
        CGFloat alpha = (rawData[byteIndex + 3] * 1.0) / 255.0;
        byteIndex += 4;
        
        NSArray* aColor = [NSArray arrayWithObjects:[NSNumber numberWithFloat:red], [NSNumber numberWithFloat:green], [NSNumber numberWithFloat:blue], [NSNumber numberWithFloat:alpha], nil];
        [result addObject:aColor];
    }
    
    free(rawData);
    
    return result;
}

+ (UIImage*)mln_in_createResizableNinePatchImageNamed:(NSString*)name  imgViewSize:(CGSize)imgViewSize
{
//    MLNLuaAssert([name hasSuffix:@".9"],@"The image name is not ended with .9");
    NSString* fixedImageFilename = [NSString stringWithFormat:@"%@%@", name, @".png"];
    UIImage* oriImage = [UIImage imageNamed:fixedImageFilename];
    
//    MLNLuaAssert(oriImage != nil, @"The input image is incorrect: ");
    
    NSString* fixed2xImageFilename = [NSString stringWithFormat:@"%@%@", [name substringWithRange:NSMakeRange(0, name.length - 2)], @"@2x.9.png"];
    UIImage* ori2xImage = [UIImage imageNamed:fixed2xImageFilename];
    if (ori2xImage != nil) {
        oriImage = ori2xImage;
    }
    
    return [self mln_in_createResizableImageFromNinePatchImage:oriImage imgViewSize:(CGSize)imgViewSize];
}

+ (UIImage *)mln_in_createResizableNinePatchImage:(UIImage*)image imgViewSize:(CGSize)imgViewSize
{
    return [self mln_in_createResizableImageFromNinePatchImage:image imgViewSize:(CGSize)imgViewSize];
}

+ (UIImage *)mln_in_createResizableImageFromNinePatchImage:(UIImage*)ninePatchImage imgViewSize:(CGSize)imgViewSize
{
    NSInteger scale = ninePatchImage.scale;
    CGSize realSize = CGSizeMake(ninePatchImage.size.width * scale, ninePatchImage.size.height * scale);
    
    MLNNinePathTpe type = MLNNinePathTpeNormal;
    NSArray* rgbaImage = [self mln_in_getRGBAsFromImage:ninePatchImage atX:0 andY:0 count:realSize.width * realSize.height];
    NSArray* topBarRgba = [rgbaImage subarrayWithRange:NSMakeRange(1, realSize.width - 2)];
    NSMutableArray* leftBarRgba = [NSMutableArray arrayWithCapacity:0];
    int count = (int)[rgbaImage count];
    int leftCount = 0, topCount = 0;
    for (int i = 0; i < count; i += realSize.width) {
        [leftBarRgba addObject:rgbaImage[i]];
    }
    
    int top = -1, left = -1, bottom = -1, right = -1;
    topCount = (int)[topBarRgba count];
    for (int i = 0; i <= topCount - 1; i++) {
        NSArray* aColor = topBarRgba[i];
        if (CGFloatValueFromNumber(aColor[3]) == 1) {
            left = i;
            break;
        }
    }
//    MLNLuaAssert(left != -1, @"The 9-patch PNG format is not correct.");
    for (int i = topCount - 1; i >= 0; i--) {
        NSArray* aColor = topBarRgba[i];
        if (CGFloatValueFromNumber(aColor[3]) == 1) {
            //这里的right值是索引值，不准确，应该是 总数 - right
            right = i;
            break;
        }
    }
//    MLNLuaAssert(right != -1, @"The 9-patch PNG format is not correct.");
    for (int i = left + 1; i <= right - 1; i++) {
        NSArray* aColor = topBarRgba[i];
        if (CGFloatValueFromNumber(aColor[3]) < 1) {
            //这种点9是保护中间的，需要特殊处理
            type = MLNNinePathTpeHorizontalCenter;
        }
    }
    leftCount = (int)[leftBarRgba count];
    for (int i = 0; i <= leftCount - 1; i++) {
        NSArray* aColor = leftBarRgba[i];
        if (CGFloatValueFromNumber(aColor[3]) == 1) {
            top = i;
            break;
        }
    }
//    MLNLuaAssert(top != -1, @"The 9-patch PNG format is not correct.");
    for (int i = leftCount - 1; i >= 0; i--) {
        NSArray* aColor = leftBarRgba[i];
        if (CGFloatValueFromNumber(aColor[3]) == 1) {
            //这里应该是倒数的第几个
            bottom = i;
            break;
        }
    }
//    MLNLuaAssert(bottom != -1, @"The 9-patch PNG format is not correct.");
    for (int i = top + 1; i <= bottom - 1; i++) {
        NSArray* aColor = leftBarRgba[i];
        if (CGFloatValueFromNumber(aColor[3]) == 0) {
            type = MLNNinePathTpeVerticalCenter;
          //  MLNLuaAssert(NO, @"The 9-patch PNG format is not support.");
        }
    }
    leftCount /= scale;
    topCount /= scale;
    top /= scale;
    left /= scale;
    bottom  /= scale;
    right /= scale;
    UIImage* cropImage = [ninePatchImage mln_in_crop:CGRectMake(1, 1, ninePatchImage.size.width - 2, ninePatchImage.size.height - 2)];
    switch (type) {
        case MLNNinePathTpeVerticalCenter:
        {
            return [cropImage mln_in_stretchVerticalWithContainerSize:imgViewSize image:cropImage topCap:top leftCap:left bottomCap:bottom rightCap:right];
             break;
        }
           case MLNNinePathTpeHorizontalCenter:
        {
            return [cropImage mln_in_stretchHorizontalWithContainerSize:imgViewSize image:cropImage topCap:top leftCap:left bottomCap:bottom rightCap:right];
            break;
        }
        default:
            return [cropImage resizableImageWithCapInsets:UIEdgeInsetsMake(top, left, leftCount - bottom, topCount - right) resizingMode:UIImageResizingModeStretch];
            break;
    }
    return cropImage;
}

@end

@implementation UIImage (NineCrop)

- (UIImage*)mln_in_crop:(CGRect)rect
{
    rect = CGRectMake(rect.origin.x * self.scale,
                      rect.origin.y * self.scale,
                      rect.size.width * self.scale,
                      rect.size.height * self.scale);
    
    CGImageRef imageRef = CGImageCreateWithImageInRect([self CGImage], rect);
    UIImage* result = [UIImage imageWithCGImage:imageRef
                                          scale:self.scale
                                    orientation:self.imageOrientation];
    CGImageRelease(imageRef);
    return result;
}

- (UIImage *)mln_in_stretchHorizontalWithContainerSize:(CGSize)imageViewSize image:(UIImage *)originImage topCap:(NSInteger)top leftCap:(NSInteger)left bottomCap:(NSInteger)bottom rightCap:(NSInteger)right {
    
    CGSize imageSize = originImage.size;
    CGSize bgSize = CGSizeMake(imageViewSize.width, imageViewSize.height); //imageView的宽高取整，否则会出现横竖两条缝
    //先往右边拉伸，保护左边
    UIImage *image = [originImage stretchableImageWithLeftCapWidth:floorf(right) topCapHeight:top];
    CGFloat tempWidth = (bgSize.width)/2 + (imageSize.width)/2;
    
    //绘制出一张右边拉伸为目标尺寸一半的图片
    UIGraphicsBeginImageContextWithOptions(CGSizeMake((NSInteger)tempWidth, (NSInteger)bgSize.height), NO,self.scale);
    [image drawInRect:CGRectMake(0, 0, (NSInteger)tempWidth, (NSInteger)bgSize.height)];
    UIImage *firstStrechImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    //此时拉伸左边，展示后即为中部不拉伸的图片
    UIImage *secondStrechImage = [firstStrechImage stretchableImageWithLeftCapWidth:left topCapHeight:top];
    
    return secondStrechImage;
}

- (UIImage *)mln_in_stretchVerticalWithContainerSize:(CGSize)imageViewSize image:(UIImage *)originImage topCap:(NSInteger)top leftCap:(NSInteger)left bottomCap:(NSInteger)bottom rightCap:(NSInteger)right {
    
    CGSize imageSize = originImage.size;
    CGSize bgSize = CGSizeMake(imageViewSize.width, imageViewSize.height); //imageView的宽高取整，否则会出现横竖两条缝
    //先往下边拉伸，保护上边
    UIImage *image = [originImage stretchableImageWithLeftCapWidth:floorf(left) topCapHeight:bottom];
    CGFloat tempHeight = (bgSize.height)/2 + (imageSize.height)/2;
    
    //绘制出一张下边拉伸为目标尺寸一半的图片
    UIGraphicsBeginImageContextWithOptions(CGSizeMake((NSInteger)bgSize.width, (NSInteger)tempHeight), NO,self.scale);
    [image drawInRect:CGRectMake(0, 0, (NSInteger)bgSize.width, (NSInteger)tempHeight)];
    UIImage *firstStrechImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    //此时拉伸上部，展示后即为中部不拉伸的图片
    UIImage *secondStrechImage = [firstStrechImage stretchableImageWithLeftCapWidth:left topCapHeight:top];
    
    return secondStrechImage;
}

@end
