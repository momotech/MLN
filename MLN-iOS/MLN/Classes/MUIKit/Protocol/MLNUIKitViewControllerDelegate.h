//
//  MLNUIKitViewControllerDelegate.h
//  MLNUI
//
//  Created by MoMo on 2019/9/2.
//

#ifndef MLNUIKitViewControllerDelegate_h
#define MLNUIKitViewControllerDelegate_h

@class MLNUIKitViewController;

/**
 KitViewController的代理协议
 */
@protocol MLNUIKitViewControllerDelegate <NSObject>

@optional
/**
 模块执行完成
 
 @param viewController KitViewController
 @param entryFileName 被执行模块的入口文件
 */
- (void)kitViewController:(MLNUIKitViewController *)viewController didFinishRun:(NSString *)entryFileName;

/**
 模块执行失败
 
 @param viewController KitViewController
 @param entryFileName 被执行模块的入口文件
 @param error 失败的信息
 */
- (void)kitViewController:(MLNUIKitViewController *)viewController didFailRun:(NSString *)entryFileName error:(NSError *)error;

// 系统生命周期回调
- (void)kitViewDidLoad:(MLNUIKitViewController *)viewController;
- (void)kitViewController:(MLNUIKitViewController *)viewController viewWillAppear:(BOOL)animated;
- (void)kitViewController:(MLNUIKitViewController *)viewController viewDidAppear:(BOOL)animated;
- (void)kitViewController:(MLNUIKitViewController *)viewController viewWillDisappear:(BOOL)animated;
- (void)kitViewController:(MLNUIKitViewController *)viewController viewDidDisappear:(BOOL)animated;

@end

#endif /* MLNUIKitViewControllerDelegate_h */
