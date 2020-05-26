//
//  MLNUICornerImageLoader.h
//  MLNUI
//
//  Created by MOMO on 2019/10/16.
//

#import <Foundation/Foundation.h>
#import "MLNUIViewConst.h"

NS_ASSUME_NONNULL_BEGIN

@interface MLNUICornerImageLoader : NSObject

+ (void)imageView:(UIImageView *)imageView setCornerImageWith:(NSString *)imageName placeHolderImage:(NSString *)placeHolder cornerRadius:(NSInteger)radius dircetion:(MLNUIRectCorner)direction;

@end

NS_ASSUME_NONNULL_END
