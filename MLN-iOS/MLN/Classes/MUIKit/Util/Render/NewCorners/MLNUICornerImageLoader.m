//
//  MLNUICornerImageLoader.m
//  MLNUI
//
//  Created by MOMO on 2019/10/16.
//

#import "MLNUICornerImageLoader.h"
#import "UIImage+MLNUIKit.h"
#import "MLNUIKitHeader.h"
#import "MLNUIImageLoaderProtocol.h"
#import <MLNUI/MLNUIKit.h>

@implementation MLNUICornerImageLoader

+ (void)imageView:(UIImageView<MLNUIEntityExportProtocol> *)imageView setCornerImageWith:(NSString *)imageName placeHolderImage:(NSString *)placeHolder cornerRadius:(NSInteger)radius dircetion:(MLNUIRectCorner)direction
{
    __block  NSUInteger loadStatus = 0;
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    
    id<MLNUIImageLoaderProtocol> imageLoder = [self imageLoaderWithImageView:imageView];
    MLNUILuaAssert(imageView.mln_luaCore, [imageLoder respondsToSelector:@selector(view:loadImageWithPath:completed:)], @"-[imageLoder view:loadImageWithPath:completed:] was not found!");
    MLNUICornerRadius cornerRadius = { .topLeft = 20, .topRight = 20, .bottomLeft = 20, .bottomRight = 20 };
    cornerRadius.topLeft = (direction & MLNUIRectCornerTopLeft) ? radius : 0;
    cornerRadius.topRight = (direction & MLNUIRectCornerTopRight) ? radius : 0;
    cornerRadius.bottomLeft = (direction & MLNUIRectCornerBottomLeft) ? radius : 0;
    cornerRadius.bottomRight = (direction & MLNUIRectCornerBottomRight) ? radius : 0;
    
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

+ (id<MLNUIImageLoaderProtocol>)imageLoaderWithImageView:(UIImageView<MLNUIEntityExportProtocol> *)imageView
{
    return MLNUI_KIT_INSTANCE(imageView.mln_luaCore).instanceHandlersManager.imageLoader;
}

@end
