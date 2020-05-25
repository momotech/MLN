//
//  MLNUIImageView.h
//  
//
//  Created by MoMo on 2018/7/6.
//

#import <UIKit/UIKit.h>
#import "MLNUIEntityExportProtocol.h"

NS_ASSUME_NONNULL_BEGIN
@class MLNUIBlock;
@interface MLNUIImageView : UIImageView <MLNUIEntityExportProtocol>

- (void)lua_setImageWith:(NSString *)imageName;
- (void)lua_setImageWith:(NSString *)imageName placeHolderImage:(NSString *)placeHolder;
- (void)lua_setImageWith:(NSString *)imageName placeHolderImage:(NSString *)placeHolder callback:(MLNUIBlock *)callback;

@end

@interface MLNUIOverlayImageView : MLNUIImageView

@end

NS_ASSUME_NONNULL_END
