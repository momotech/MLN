//
//  MLNCornerImageLoader.h
//  MoMo
//
//  Created by MOMO on 2019/10/16.
//

#import <Foundation/Foundation.h>
#import "MLNViewConst.h"

NS_ASSUME_NONNULL_BEGIN

@interface MLNCornerImageLoader : NSObject

+ (instancetype)sharedInstance;

- (void)imageView:(UIImageView *)imageView setCornerImageWith:(NSString *)imageName placeHolderImage:(NSString *)placeHolder cornerRadius:(NSInteger)radius dircetion:(MLNRectCorner)direction;

@end

NS_ASSUME_NONNULL_END
