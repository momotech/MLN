//
//  MLNCornerImageLoader.m
//  MLN
//
//  Created by MOMO on 2019/10/16.
//

#import "MLNCornerImageLoader.h"
#import "UIImage+MLNKit.h"
#import "MLNKitHeader.h"
#import "MLNImageLoaderProtocol.h"
#import <MLN/MLNKit.h>

@implementation MLNCornerImageLoader

+ (void)imageView:(UIImageView<MLNEntityExportProtocol> *)imageView setCornerImageWith:(NSString *)imageName placeHolderImage:(NSString *)placeHolder cornerRadius:(NSInteger)radius dircetion:(MLNRectCorner)direction
{
    __block  NSUInteger loadStatus = 0;
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    
    id<MLNImageLoaderProtocol> imageLoder = [self imageLoaderWithImageView:imageView];
    MLNLuaAssert(imageView.mln_luaCore, [imageLoder respondsToSelector:@selector(view:loadImageWithPath:completed:)], @"-[imageLoder view:loadImageWithPath:completed:] was not found!");
    MLNCornerRadius cornerRadius = { .topLeft = 20, .topRight = 20, .bottomLeft = 20, .bottomRight = 20 };
    cornerRadius.topLeft = (direction & MLNRectCornerTopLeft) ? radius : 0;
    cornerRadius.topRight = (direction & MLNRectCornerTopRight) ? radius : 0;
    cornerRadius.bottomLeft = (direction & MLNRectCornerBottomLeft) ? radius : 0;
    cornerRadius.bottomRight = (direction & MLNRectCornerBottomRight) ? radius : 0;
    
    if (placeHolder.length > 0) {
        [imageLoder view:imageView loadImageWithPath:placeHolder completed:^(UIImage * _Nullable image, NSError * _Nullable error, NSString * _Nullable imagePath) {
            loadStatus += 1;
            if (loadStatus == 1 && image) {
                dispatch_async(queue, ^{
                    UIImage *cornerImage = [image mln_ImageWithCornerRadius:cornerRadius];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if (loadStatus == 1) {
                            imageView.image = cornerImage;
                        }
                    });
                });
            }
        }];
    }
    
    if (imageName.length > 0) {
        [imageLoder view:imageView loadImageWithPath:imageName completed:^(UIImage *image, NSError *error, NSString *imagePath) {
            loadStatus += 1;
            if (image) {
                dispatch_async(queue, ^{
                    UIImage *cornerImage = [image mln_ImageWithCornerRadius:cornerRadius];
                    dispatch_async(dispatch_get_main_queue(), ^{
                            imageView.image = cornerImage;
                    });
                });
            }
        }];
    } else {
        imageView.image = nil;
    }
    
}

+ (id<MLNImageLoaderProtocol>)imageLoaderWithImageView:(UIImageView<MLNEntityExportProtocol> *)imageView
{
    return MLN_KIT_INSTANCE(imageView.mln_luaCore).instanceHandlersManager.imageLoader;
}

@end
