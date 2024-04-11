//
//  MLNHotReloadPresenter.h
//  MLNDebugTool
//
//  Created by MoMo on 2019/9/11.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class MLNHotReloadPresenter;
@protocol MLNHotReloadPresenterDelegate <NSObject>

@optional
/**
 解析到二维码信息

 @param hotReloadPresenter 热重载的Presenter
 @param ip 解析到的ip地址
 @param port 解析到的端口号
 */
- (void)hotReloadPresenter:(MLNHotReloadPresenter *)hotReloadPresenter readDataFromQRCode:(NSString *)ip port:(int)port;

/**
 二维码解析错误

 @param hotReloadPresenter 热重载的Presenter
 @param error 错误信息
 */
- (void)hotReloadPresenter:(MLNHotReloadPresenter *)hotReloadPresenter QRCodeOnError:(NSError *)error;

/**
 变更端口号

 @param hotReloadPresenter 热重载的Presenter
 @param port 端口号
 */
- (void)hotReloadPresenter:(MLNHotReloadPresenter *)hotReloadPresenter changePort:(int)port;

/**
 获取当前端口号

 @param hotReloadPresenter 热重载的Presenter
 @return 当前端口号
 */
- (int)currentPortHotReloadPresenter:(MLNHotReloadPresenter *)hotReloadPresenter;

/**
 展示或隐藏导航栏

 @param hotReloadPresenter 热重载的Presenter
 @param hidden 展示、隐藏
 */
- (void)hotReloadPresenter:(MLNHotReloadPresenter *)hotReloadPresenter hiddenNavBar:(BOOL)hidden;

@end

@interface MLNHotReloadPresenter : NSObject

@property (nonatomic, weak) id<MLNHotReloadPresenterDelegate> delegate;
@property (nonatomic, assign, readonly) BOOL isUtilViewControllerShow;

- (void)openUI;
- (void)closeUI;
- (void)show:(NSString *)msg duration:(NSTimeInterval)duration;
- (void)hidden:(NSString *)msg duration:(NSTimeInterval)duration delay:(NSTimeInterval)delay;
- (void)tip:(NSString *)msg duration:(NSTimeInterval)duration delay:(NSTimeInterval)delay;

@end

NS_ASSUME_NONNULL_END
