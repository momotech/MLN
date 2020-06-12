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

- (void)luaui_setImageWith:(NSString *)imageName;
- (void)luaui_setImageWith:(NSString *)imageName placeHolderImage:(NSString *)placeHolder;
- (void)luaui_setImageWith:(NSString *)imageName placeHolderImage:(NSString *)placeHolder callback:(MLNUIBlock *)callback;

@end

NS_ASSUME_NONNULL_END
