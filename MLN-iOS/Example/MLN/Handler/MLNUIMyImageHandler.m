//
//  MLNUIMyImageHandler.m
//  LuaNative
//
//  Created by Dai Dongpeng on 2020/5/27.
//  Copyright © 2020 MoMo. All rights reserved.
//

#import "MLNUIMyImageHandler.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import <SDWebImage/UIButton+WebCache.h>
#import <MLNUICornerImageLoader.h>
#import "MLNGalleryNative.h"

@implementation MLNUIMyImageHandler

- (void)imageView:(UIImageView<MLNUIEntityExportProtocol> *)imageView setImageWithPath:(NSString *)path
{
    if (kDisableImageLoad)  {
        return;
    }
    
    if ([self isHttpURL:path]) {
        NSURL *imgURL = [NSURL URLWithString:[path stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]]];
        [imageView sd_setImageWithURL:imgURL];
    } else {
        UIImage *image =  [self imageWithLocalPath:path instance:MLNUI_KIT_INSTANCE(imageView.mlnui_luaCore)];
        if (image) {
            [imageView setImage:image];
        }
    }
}

- (void)imageView:(UIImageView<MLNUIEntityExportProtocol> *)imageView setImageWithPath:(NSString *)path placeHolderImage:(NSString *)placeHolder
{
    
    [imageView sd_setImageWithURL:[NSURL URLWithString:path] placeholderImage:placeHolder.length > 0 ? [UIImage imageNamed:placeHolder] : nil];
}

- (void)imageView:(UIImageView<MLNUIEntityExportProtocol> *)imageView setCornerImageWith:(NSString *)imageName placeHolderImage:(NSString *)placeHolder cornerRadius:(NSInteger)radius dircetion:(MLNUIRectCorner)direction {
    [MLNUICornerImageLoader imageView:imageView setCornerImageWith:imageName placeHolderImage:placeHolder cornerRadius:radius dircetion:direction];
}

- (void)button:(UIButton<MLNUIEntityExportProtocol> *)button setImageWithPath:(NSString *)path forState:(UIControlState)state
{
    if ([self isHttpURL:path]) {
        NSURL *imgURL = [NSURL URLWithString:path];
        [button sd_setImageWithURL:imgURL forState:state];
    } else {
        UIImage *image =  [self imageWithLocalPath:path instance:MLNUI_KIT_INSTANCE(button.mlnui_luaCore)];
        if (image) {
            [button setImage:image forState:state];
        }
    }
}

- (void)view:(UIView<MLNUIEntityExportProtocol> *)view loadImageWithPath:(nonnull NSString *)imagePath completed:(nonnull void (^)(UIImage * _Nullable, NSError * _Nullable, NSString * _Nullable))completed
{
    if ([self isHttpURL:imagePath]) {
        NSURL *imgURL = [NSURL URLWithString:imagePath];
        [[SDWebImageManager sharedManager] loadImageWithURL:imgURL options:SDWebImageRetryFailed progress:nil completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, SDImageCacheType cacheType, BOOL finished, NSURL * _Nullable imageURL) {
            if (completed) {
                completed(image, error, imageURL.absoluteString);
            }
        }];
    } else {
        UIImage *image =  [self imageWithLocalPath:imagePath instance:MLNUI_KIT_INSTANCE(view.mlnui_luaCore)];
        if (completed) {
            completed(image, nil, imagePath);
        }
    }
}

- (void)imageView:(UIImageView<MLNUIEntityExportProtocol> *)imageView setImageWithPath:(NSString *)path placeHolderImage:(NSString *)placeHolder completed:(void (^)(UIImage *, NSError *, NSString *))completed {
    [imageView sd_setImageWithURL:[NSURL URLWithString:path] placeholderImage:[UIImage imageNamed:placeHolder] completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
        if (completed) {
            completed(image, error, imageURL.absoluteString);
        }
    }];
}


- (UIImage *)imageWithLocalPath:(NSString *)path instance:(MLNUIKitInstance *)instance
{
    // Main bundle' .xcassets
    UIImage *image = [UIImage imageNamed:path];
    if (image) {
        return image;
    }
    //Main Bundle
    NSString *filePath = [[NSBundle mainBundle] pathForResource:path ofType:nil];
    if (!filePath) {
        // Sandbox
        filePath = [instance.currentBundle filePathWithName:path];
    }
    return [UIImage imageWithContentsOfFile:filePath];
}

- (BOOL)isHttpURL:(NSString *)path
{
    return [path hasPrefix:@"https://"] || [path hasPrefix:@"http://"];
}


@end
