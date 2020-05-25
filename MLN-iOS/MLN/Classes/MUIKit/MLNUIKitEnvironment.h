//
//  MLNKitEnvironment.h
//  MLN
//
//  Created by MoMo on 2019/11/22.
//

#import <Foundation/Foundation.h>
#import "MLNImageLoaderProtocol.h"
#import "MLNRefreshDelegate.h"
#import "MLNKitInstanceErrorHandlerProtocol.h"
#import "MLNHttpHandlerProtocol.h"
#import "MLNKitInstance.h"
#import "MLNNavigatorHandlerProtocol.h"

NS_ASSUME_NONNULL_BEGIN

/// MLNKit的环境变量
@interface MLNKitEnvironment : NSObject

/// 开启虚拟机的预加载, 会提前加载一个
+ (void)instancePreload;

/// 开启虚拟机的预加载
/// @param capacity 预加载的虚拟机个数
+ (void)instancePreloadWithCapacity:(NSUInteger)capacity;

/// 设置默认的错误处理句柄  ⚠️弱引用
/// @param errorHandler 错误处理句柄
+ (void)setDefaultErrorHandler:(id<MLNKitInstanceErrorHandlerProtocol>)errorHandler;

/// 设置默认的网络处理句柄  ⚠️弱引用
/// @param httpHandler 网络处理句柄
+ (void)setDefaultHttpHandler:(id<MLNHttpHandlerProtocol>)httpHandler;

/// 设置默认的图片加载器 ⚠️弱引用
/// @param imageLoader 图片加载器
+ (void)setDefaultImageLoader:(id<MLNImageLoaderProtocol>)imageLoader;

/// 设置默认的可滚动视图上拉下拉操作处理句柄 ⚠️弱引用
/// @param scrollRefreshHandler  可滚动视图上拉下拉操作处理句柄
+ (void)setDefaultScrollRefreshHandler:(id<MLNRefreshDelegate>)scrollRefreshHandler;

/// 设置默认的页面跳转处理句柄 ⚠️弱引用
/// @param navigatorHandler 页面跳转处理句柄
+ (void)setDefaultNavigatorHandler:(id<MLNNavigatorHandlerProtocol>)navigatorHandler;

/// 设置应用的主window
/// @param mainWindow 应用的主window
+ (void)setMainWindow:(UIWindow *)mainWindow;

/// 获取应用的主window
+ (UIWindow *)mainWindow;

@end

NS_ASSUME_NONNULL_END
