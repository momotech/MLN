//
//  MLNUISnapshotManager.h
//
//
//  Created by MoMo on 2019/3/9.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MLNUISnapshotManager : NSObject

+ (UIImage *)mlnui_captureNormalView:(UIView *)view;

+ (UIImage *)mlnui_captureScrollView:(UIScrollView *)scrollView;


// 文件保存
+ (NSString *)mlnui_image:(UIImage *)image saveWithFileName:(NSString *)fileName;

@end

NS_ASSUME_NONNULL_END
