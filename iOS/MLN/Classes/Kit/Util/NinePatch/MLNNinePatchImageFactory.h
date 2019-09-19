//
//  MDNinePatchImageFactory.h
//  MomoChat
//
//  Created by MoMo on 2019/3/19.
//  Copyright © 2019年 wemomo.com. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface MLNNinePatchImageFactory : NSObject

+ (UIImage*)mln_in_createResizableNinePatchImageNamed:(NSString*)name imgViewSize:(CGSize)imgViewSize;
+ (UIImage*)mln_in_createResizableNinePatchImage:(UIImage*)image imgViewSize:(CGSize)imgViewSize;

@end

#pragma mark - UIImage Extension

@interface UIImage (NineCrop)

- (UIImage*)mln_in_crop:(CGRect)rect;

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


NS_ASSUME_NONNULL_END
