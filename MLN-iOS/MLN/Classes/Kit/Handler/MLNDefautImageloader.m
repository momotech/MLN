//
//  MLNDefautImageloader.m
//  MLN
//
//  Created by Dai Dongpeng on 2020/5/13.
//

#import "MLNDefautImageloader.h"
#import <MLN/MLNKit.h>
#import "MLNCornerImageLoader.h"

@implementation MLNDefautImageloader

+ (instancetype)defaultIamgeLoader {
    static MLNDefautImageloader *loader;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        loader = [[MLNDefautImageloader alloc] init];
    });
    return loader;
}

- (void)imageView:(UIImageView<MLNEntityExportProtocol> *)imageView setImageWithPath:(NSString *)path {
    [self imageView:imageView setImageWithPath:path placeHolderImage:path completed:nil];
}

- (void)imageView:(UIImageView<MLNEntityExportProtocol> *)imageView setImageWithPath:(NSString *)path placeHolderImage:(NSString *)placeHolder completed:(void(^)(UIImage *__nullable image, NSError *__nullable error, NSString *__nullable imagePath))completed {
    UIImage *image = [self imageWithLocalPath:path instance:MLN_KIT_INSTANCE(imageView.mln_luaCore)];
    if (image) {
        [imageView setImage:image];
    }
    if (completed) {
        completed(image, nil, placeHolder);
    }
}

- (void)imageView:(UIImageView<MLNEntityExportProtocol> *)imageView setCornerImageWith:(NSString *)imageName placeHolderImage:(NSString *)placeHolder cornerRadius:(NSInteger)radius dircetion:(MLNRectCorner)direction {
    [MLNCornerImageLoader imageView:imageView setCornerImageWith:imageName placeHolderImage:placeHolder cornerRadius:radius dircetion:direction];
}

- (void)imageView:(UIImageView<MLNEntityExportProtocol> *)imageView setImageWithPath:(NSString *)path placeHolderImage:(NSString *)placeHolder {
    [self imageView:imageView setImageWithPath:path placeHolderImage:placeHolder completed:nil];
}

- (void)imageView:(UIImageView<MLNEntityExportProtocol> *)imageView setNineImageWithPath:(NSString *)path synchronized:(BOOL)synchronzied {
        //该模式必须是scaleToFill的
        imageView.contentMode = UIViewContentModeScaleToFill;
        __block BOOL isSynchronzied = synchronzied;
        __weak typeof(imageView) wkImgView = imageView;
        __block CGSize imgViewSize = imageView.frame.size;
        
        [self view:imageView loadImageWithPath:path completed:^(UIImage *image, NSError *error, NSString *imagePath) {
            __strong typeof(wkImgView) stImgView = wkImgView;
            if (image) {
                if (!isSynchronzied) {
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                        UIImage* resizedImage = [MLNNinePatchImageFactory mln_createResizableNinePatchImage:image imgViewSize:imgViewSize];
                        dispatch_async(dispatch_get_main_queue(), ^{
                            stImgView.image = resizedImage;
                        });
                    });
                } else {
                    stImgView.image = [MLNNinePatchImageFactory mln_createResizableNinePatchImage:image imgViewSize:imgViewSize];
                }
            } else {
                wkImgView.image = nil;
            }
        }];
}

- (void)button:(UIButton<MLNEntityExportProtocol> *)button setImageWithPath:(NSString *)path forState:(UIControlState)state {
    UIImage *image =  [self imageWithLocalPath:path instance:MLN_KIT_INSTANCE(button.mln_luaCore)];
    if (image) {
        [button setImage:image forState:state];
    }
}

- (void)view:(UIView<MLNEntityExportProtocol> *)view loadImageWithPath:(NSString *)imagePath completed:(void(^)(UIImage *__nullable image, NSError *__nullable error, NSString *__nullable imagePath))completed {
    if (completed) {
        UIImage *image = [self imageWithLocalPath:imagePath instance:MLN_KIT_INSTANCE(view.mln_luaCore)];
        completed(image, nil, imagePath);
    }
}

- (UIImage *)imageWithLocalPath:(NSString *)path instance:(MLNKitInstance *)instance
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

@end
