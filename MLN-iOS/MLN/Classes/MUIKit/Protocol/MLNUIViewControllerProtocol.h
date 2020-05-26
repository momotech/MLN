//
//  MLNUIViewControllerProtocol.h
//  MLNUI
//
//  Created by MoMo on 2019/8/30.
//

#ifndef MLNUIViewControllerProtocol_h
#define MLNUIViewControllerProtocol_h

@class MLNUIKitInstance;
@protocol MLNUIViewControllerProtocol <NSObject>

- (MLNUIKitInstance *)kitInstance;

@end

@protocol MLNUIViewControllerDelegate <NSObject>
@optional
/**
 模块执行完成
 
 @param viewController UIViewController
 @param entryFileName 被执行模块的入口文件
 */
- (void)viewController:(UIViewController *)viewController didFinishRun:(NSString *)entryFileName;

/**
 模块执行失败
 
 @param viewController UIViewController
 @param entryFileName 被执行模块的入口文件
 @param error 失败的信息
 */
- (void)viewController:(UIViewController *)viewController didFailRun:(NSString *)entryFileName error:(NSError *)error;
@end

#endif /* MLNUIViewControllerProtocol_h */
