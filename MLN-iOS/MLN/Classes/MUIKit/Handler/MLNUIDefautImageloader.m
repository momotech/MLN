//
//  MLNUIDefautImageloader.m
//  MLNUI
//
//  Created by Dai Dongpeng on 2020/5/13.
//

#import "MLNUIDefautImageloader.h"
#import "MLNUIKit.h"
#import "MLNUICornerImageLoader.h"

@implementation MLNUIDefautImageloader

+ (instancetype)defaultIamgeLoader {
    static MLNUIDefautImageloader *loader;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        loader = [[MLNUIDefautImageloader alloc] init];
    });
    return loader;
}

- (void)imageView:(UIImageView<MLNUIEntityExportProtocol> *)imageView setImageWithPath:(NSString *)path {
    [self imageView:imageView setImageWithPath:path placeHolderImage:path completed:nil];
}

- (void)imageView:(UIImageView<MLNUIEntityExportProtocol> *)imageView setImageWithPath:(NSString *)path placeHolderImage:(NSString *)placeHolder completed:(void(^)(UIImage *__nullable image, NSError *__nullable error, NSString *__nullable imagePath))completed {
    UIImage *image = [self imageWithLocalPath:path instance:MLNUI_KIT_INSTANCE(imageView.mlnui_luaCore)];
    if (image) {
        [imageView setImage:image];
    }
    if (completed) {
        completed(image, nil, placeHolder);
    }
}

- (void)imageView:(UIImageView<MLNUIEntityExportProtocol> *)imageView setCornerImageWith:(NSString *)imageName placeHolderImage:(NSString *)placeHolder cornerRadius:(NSInteger)radius dircetion:(MLNUIRectCorner)direction {
    [MLNUICornerImageLoader imageView:imageView setCornerImageWith:imageName placeHolderImage:placeHolder cornerRadius:radius dircetion:direction];
}

- (void)imageView:(UIImageView<MLNUIEntityExportProtocol> *)imageView setImageWithPath:(NSString *)path placeHolderImage:(NSString *)placeHolder {
    [self imageView:imageView setImageWithPath:path placeHolderImage:placeHolder completed:nil];
}

- (void)imageView:(UIImageView<MLNUIEntityExportProtocol> *)imageView setNineImageWithPath:(NSString *)path synchronized:(BOOL)synchronzied {
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
                        UIImage* resizedImage = [MLNUINinePatchImageFactory mlnui_createResizableNinePatchImage:image imgViewSize:imgViewSize];
                        dispatch_async(dispatch_get_main_queue(), ^{
                            stImgView.image = resizedImage;
                        });
                    });
                } else {
                    stImgView.image = [MLNUINinePatchImageFactory mlnui_createResizableNinePatchImage:image imgViewSize:imgViewSize];
                }
            } else {
                wkImgView.image = nil;
            }
        }];
}

- (void)button:(UIButton<MLNUIEntityExportProtocol> *)button setImageWithPath:(NSString *)path forState:(UIControlState)state {
    UIImage *image =  [self imageWithLocalPath:path instance:MLNUI_KIT_INSTANCE(button.mlnui_luaCore)];
    if (image) {
        [button setImage:image forState:state];
    }
}

- (void)view:(UIView<MLNUIEntityExportProtocol> *)view loadImageWithPath:(NSString *)imagePath completed:(void(^)(UIImage *__nullable image, NSError *__nullable error, NSString *__nullable imagePath))completed {
    if (completed) {
        UIImage *image = [self imageWithLocalPath:imagePath instance:MLNUI_KIT_INSTANCE(view.mlnui_luaCore)];
        completed(image, nil, imagePath);
    }
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

@end
