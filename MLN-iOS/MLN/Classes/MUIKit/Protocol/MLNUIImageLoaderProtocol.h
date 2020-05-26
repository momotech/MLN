//
//  MLNUIImageLoaderProtocol.h
//  MLNUI
//
//  Created by MoMo on 2019/8/27.
//

#import <Foundation/Foundation.h>
#import "MLNUIViewConst.h"
#import "MLNUIEntityExportProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@protocol MLNUIImageLoaderProtocol <NSObject>

@required
- (void)imageView:(UIImageView<MLNUIEntityExportProtocol> *)imageView setImageWithPath:(NSString *)path;
- (void)imageView:(UIImageView<MLNUIEntityExportProtocol> *)imageView setImageWithPath:(NSString *)path placeHolderImage:(NSString *)placeHolder completed:(void(^)(UIImage *__nullable image, NSError *__nullable error, NSString *__nullable imagePath))completed;
- (void)imageView:(UIImageView<MLNUIEntityExportProtocol> *)imageView setCornerImageWith:(NSString *)imageName placeHolderImage:(NSString *)placeHolder cornerRadius:(NSInteger)radius dircetion:(MLNUIRectCorner)direction;
- (void)imageView:(UIImageView<MLNUIEntityExportProtocol> *)imageView setImageWithPath:(NSString *)path placeHolderImage:(NSString *)placeHolder;
- (void)imageView:(UIImageView<MLNUIEntityExportProtocol> *)imageView setNineImageWithPath:(NSString *)path synchronized:(BOOL)synchronzied;
- (void)button:(UIButton<MLNUIEntityExportProtocol> *)button setImageWithPath:(NSString *)path forState:(UIControlState)state;
- (void)view:(UIView<MLNUIEntityExportProtocol> *)view loadImageWithPath:(NSString *)imagePath completed:(void(^)(UIImage *__nullable image, NSError *__nullable error, NSString *__nullable imagePath))completed;

@end

NS_ASSUME_NONNULL_END
