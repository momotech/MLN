//
//  MLNSnapshotManager.h
//
//
//  Created by MoMo on 2019/3/9.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MLNSnapshotManager : NSObject

+ (UIImage *)mln_captureNormalView:(UIView *)view;

+ (UIImage *)mln_captureScrollView:(UIScrollView *)scrollView;


// 文件保存
+ (NSString *)mln_image:(UIImage *)image saveWithFileName:(NSString *)fileName;

@end

NS_ASSUME_NONNULL_END
