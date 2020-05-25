//
//  MLNImageLoaderProtocol.h
//  MLN
//
//  Created by MoMo on 2019/8/27.
//

#import <Foundation/Foundation.h>
#import "MLNViewConst.h"
#import "MLNEntityExportProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@protocol MLNImageLoaderProtocol <NSObject>

@required
- (void)imageView:(UIImageView<MLNEntityExportProtocol> *)imageView setImageWithPath:(NSString *)path;
- (void)imageView:(UIImageView<MLNEntityExportProtocol> *)imageView setImageWithPath:(NSString *)path placeHolderImage:(NSString *)placeHolder completed:(void(^)(UIImage *__nullable image, NSError *__nullable error, NSString *__nullable imagePath))completed;
- (void)imageView:(UIImageView<MLNEntityExportProtocol> *)imageView setCornerImageWith:(NSString *)imageName placeHolderImage:(NSString *)placeHolder cornerRadius:(NSInteger)radius dircetion:(MLNRectCorner)direction;
- (void)imageView:(UIImageView<MLNEntityExportProtocol> *)imageView setImageWithPath:(NSString *)path placeHolderImage:(NSString *)placeHolder;
- (void)imageView:(UIImageView<MLNEntityExportProtocol> *)imageView setNineImageWithPath:(NSString *)path synchronized:(BOOL)synchronzied;
- (void)button:(UIButton<MLNEntityExportProtocol> *)button setImageWithPath:(NSString *)path forState:(UIControlState)state;
- (void)view:(UIView<MLNEntityExportProtocol> *)view loadImageWithPath:(NSString *)imagePath completed:(void(^)(UIImage *__nullable image, NSError *__nullable error, NSString *__nullable imagePath))completed;

@end

NS_ASSUME_NONNULL_END
