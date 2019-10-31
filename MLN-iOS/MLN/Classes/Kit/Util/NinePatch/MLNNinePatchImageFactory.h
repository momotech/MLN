//
//  MLNNinePatchImageFactory.h
//  MoMo
//
//  Created by MOMO on 2019/3/19.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface MLNNinePatchImageFactory : NSObject

+ (UIImage *)mln_in_createResizableNinePatchImageNamed:(NSString *)name imgViewSize:(CGSize)imgViewSize;
+ (UIImage *)mln_in_createResizableNinePatchImage:(UIImage *)image imgViewSize:(CGSize)imgViewSize;

@end

#pragma mark - UIImage Extension

@interface UIImage (NineCrop)

- (UIImage *)mln_in_crop:(CGRect)rect;
- (UIImage *)mln_in_stretchHorizontalWithContainerSize:(CGSize)imageViewSize image:(UIImage *)originImage topCap:(NSInteger)top leftCap:(NSInteger)left bottomCap:(NSInteger)bottom rightCap:(NSInteger)right;
- (UIImage *)mln_in_stretchVerticalWithContainerSize:(CGSize)imageViewSize image:(UIImage *)originImage topCap:(NSInteger)top leftCap:(NSInteger)left bottomCap:(NSInteger)bottom rightCap:(NSInteger)right;

@end

NS_ASSUME_NONNULL_END
