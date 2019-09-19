//
//  MLNKitViewControllerDelegate.h
//  MLN
//
//  Created by MoMo on 2019/9/2.
//

#ifndef MLNKitViewControllerDelegate_h
#define MLNKitViewControllerDelegate_h

@class MLNKitViewController;

/**
 KitViewController的代理协议
 */
@protocol MLNKitViewControllerDelegate <NSObject>

@optional
/**
 模块执行完成
 
 @param viewController KitViewController
 @param entryFileName 被执行模块的入口文件
 */
- (void)kitViewController:(MLNKitViewController *)viewController didFinishRun:(NSString *)entryFileName;

/**
 模块执行失败
 
 @param viewController KitViewController
 @param entryFileName 被执行模块的入口文件
 @param error 失败的信息
 */
- (void)kitViewController:(MLNKitViewController *)viewController didFailRun:(NSString *)entryFileName error:(NSError *)error;

// 系统生命周期回调
- (void)kitViewDidLoad:(MLNKitViewController *)viewController;
- (void)kitViewController:(MLNKitViewController *)viewController viewWillAppear:(BOOL)animated;
- (void)kitViewController:(MLNKitViewController *)viewController viewDidAppear:(BOOL)animated;
- (void)kitViewController:(MLNKitViewController *)viewController viewWillDisappear:(BOOL)animated;
- (void)kitViewController:(MLNKitViewController *)viewController viewDidDisappear:(BOOL)animated;

@end

#endif /* MLNKitViewControllerDelegate_h */
