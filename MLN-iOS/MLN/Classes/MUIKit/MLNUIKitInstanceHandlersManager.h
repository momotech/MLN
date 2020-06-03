//
//  MLNUIKitInstanceHandlers.h
//  MLNUI
//
//  Created by MoMo on 2019/8/28.
//

#import <Foundation/Foundation.h>
#import "MLNUIImageLoaderProtocol.h"
#import "MLNUIRefreshDelegate.h"
#import "MLNUIKitInstanceErrorHandlerProtocol.h"
#import "MLNUIHttpHandlerProtocol.h"
#import "MLNUIKitInstance.h"
#import "MLNUINavigatorHandlerProtocol.h"

NS_ASSUME_NONNULL_BEGIN
@class MLNUIApplication;
@class MLNUINetworkReachability;
@interface MLNUIKitInstanceHandlersManager : NSObject

/**
 承载Kit库bridge和LuaCore实例
 */
@property (nonatomic, weak, readonly) MLNUIKitInstance *instance;

/**
 错误处理句柄
 */
@property (nonatomic, weak) id<MLNUIKitInstanceErrorHandlerProtocol> errorHandler;

/**
 网络处理句柄
 */
@property (nonatomic, weak) id<MLNUIHttpHandlerProtocol> httpHandler;

/**
 图片加载器
 */
@property (nonatomic, weak) id<MLNUIImageLoaderProtocol> imageLoader;

/**
 可滚动视图上拉下拉操作处理句柄
 */
@property (nonatomic, weak) id<MLNUIRefreshDelegate> scrollRefreshHandler;

/**
 页面跳转处理句柄
 */
@property (nonatomic, weak) id<MLNUINavigatorHandlerProtocol> navigatorHandler;

/**
 应用级别事务处理工具
 */
@property (nonatomic, strong, readonly) MLNUIApplication *application;

/**
 网络连通检测工具
 */
@property (nonatomic, strong, readonly) MLNUINetworkReachability *networkReachability;

/**
 创建Handler管理器

 @param instance 对应的KitInstance
 @return Handler管理器
 */
- (instancetype)initWithUIInstance:(MLNUIKitInstance *)instance;

/**
 创建默认的Handler管理器，如果某个KitInstance未设置相应的处理句柄，则使用默认管理器中的处理句柄

 @return Handler管理器
 */
+ (instancetype)defaultManager;

@end

NS_ASSUME_NONNULL_END
