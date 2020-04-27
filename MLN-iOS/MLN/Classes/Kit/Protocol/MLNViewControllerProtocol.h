//
//  MLNViewControllerProtocol.h
//  MLN
//
//  Created by MoMo on 2019/8/30.
//

#ifndef MLNViewControllerProtocol_h
#define MLNViewControllerProtocol_h

@class MLNKitInstance;
@protocol MLNViewControllerProtocol <NSObject>

- (MLNKitInstance *)kitInstance;

@end

@class MLNUIViewController;
@protocol MLNUIViewControllerDelegatee <NSObject>
@optional
/**
 模块执行完成
 
 @param viewController KitViewController
 @param entryFileName 被执行模块的入口文件
 */
- (void)viewController:(MLNUIViewController *)viewController didFinishRun:(NSString *)entryFileName;

/**
 模块执行失败
 
 @param viewController KitViewController
 @param entryFileName 被执行模块的入口文件
 @param error 失败的信息
 */
- (void)viewController:(MLNUIViewController *)viewController didFailRun:(NSString *)entryFileName error:(NSError *)error;
@end

#endif /* MLNViewControllerProtocol_h */
