//
//  MLNImageView.h
//  
//
//  Created by MoMo on 2018/7/6.
//

#import <UIKit/UIKit.h>
#import "MLNEntityExportProtocol.h"

NS_ASSUME_NONNULL_BEGIN
@class MLNBlock;
@interface MLNImageView : UIImageView <MLNEntityExportProtocol>

- (void)lua_setImageWith:(NSString *)imageName;
- (void)lua_setImageWith:(NSString *)imageName placeHolderImage:(NSString *)placeHolder;
- (void)lua_setImageWith:(NSString *)imageName placeHolderImage:(NSString *)placeHolder callback:(MLNBlock *)callback;

@end

NS_ASSUME_NONNULL_END
