//
//  MLNNinePatchImageFactory.h
//  MLN
//
//  Created by MOMO on 2019/3/19.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface MLNNinePatchImageFactory : NSObject

+ (UIImage *)mln_createResizableNinePatchImageNamed:(NSString *)name imgViewSize:(CGSize)imgViewSize;
+ (UIImage *)mln_createResizableNinePatchImage:(UIImage *)image imgViewSize:(CGSize)imgViewSize;

@end

#pragma mark - UIImage Extension

@interface UIImage (MLNNineCrop)

- (UIImage *)mln_crop:(CGRect)rect;
- (UIImage *)mln_stretchHorizontalWithContainerSize:(CGSize)imageViewSize image:(UIImage *)originImage topCap:(NSInteger)top leftCap:(NSInteger)left bottomCap:(NSInteger)bottom rightCap:(NSInteger)right;
- (UIImage *)mln_stretchVerticalWithContainerSize:(CGSize)imageViewSize image:(UIImage *)originImage topCap:(NSInteger)top leftCap:(NSInteger)left bottomCap:(NSInteger)bottom rightCap:(NSInteger)right;

@end

NS_ASSUME_NONNULL_END
