//
//  MLNUINinePatchImageFactory.h
//  MLNUI
//
//  Created by MOMO on 2019/3/19.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface MLNUINinePatchImageFactory : NSObject

+ (UIImage *)mlnui_createResizableNinePatchImageNamed:(NSString *)name imgViewSize:(CGSize)imgViewSize;
+ (UIImage *)mlnui_createResizableNinePatchImage:(UIImage *)image imgViewSize:(CGSize)imgViewSize;

@end

#pragma mark - UIImage Extension

@interface UIImage (MLNUINineCrop)

- (UIImage *)mlnui_crop:(CGRect)rect;
- (UIImage *)mlnui_stretchHorizontalWithContainerSize:(CGSize)imageViewSize image:(UIImage *)originImage topCap:(NSInteger)top leftCap:(NSInteger)left bottomCap:(NSInteger)bottom rightCap:(NSInteger)right;
- (UIImage *)mlnui_stretchVerticalWithContainerSize:(CGSize)imageViewSize image:(UIImage *)originImage topCap:(NSInteger)top leftCap:(NSInteger)left bottomCap:(NSInteger)bottom rightCap:(NSInteger)right;

@end

NS_ASSUME_NONNULL_END
