//
//  MLNUIKitEnvironment.m
//  MLNUI
//
//  Created by MoMo on 2019/11/22.
//

#import "MLNUIKitEnvironment.h"
#import "MLNUIKitInstanceHandlersManager.h"
#import "MLNUIKitInstanceFactory.h"
#import "MLNUIKit.h"

@implementation MLNUIKitEnvironment

+ (void)instancePreload
{
    [[MLNUIKitInstanceFactory defaultFactory] preloadWithCapacity:1];
}

+ (void)instancePreloadWithCapacity:(NSUInteger)capacity
{
    [[MLNUIKitInstanceFactory defaultFactory] preloadWithCapacity:capacity];
}

+ (void)setDefaultErrorHandler:(id<MLNUIKitInstanceErrorHandlerProtocol>)errorHandler
{
    [MLNUIKitInstanceHandlersManager defaultManager].errorHandler = errorHandler;
}

+ (void)setDefaultHttpHandler:(id<MLNUIHttpHandlerProtocol>)httpHandler
{
    [MLNUIKitInstanceHandlersManager defaultManager].httpHandler = httpHandler;
}

+ (void)setDefaultImageLoader:(id<MLNUIImageLoaderProtocol>)imageLoader
{
    [MLNUIKitInstanceHandlersManager defaultManager].imageLoader = imageLoader;
}

+ (void)setDefaultScrollRefreshHandler:(id<MLNUIRefreshDelegate>)scrollRefreshHandler
{
    [MLNUIKitInstanceHandlersManager defaultManager].scrollRefreshHandler = scrollRefreshHandler;
}

+ (void)setDefaultNavigatorHandler:(id<MLNUINavigatorHandlerProtocol>)navigatorHandler
{
    [MLNUIKitInstanceHandlersManager defaultManager].navigatorHandler = navigatorHandler;
}

static __weak UIWindow *_mainWindow = nil;
+ (void)setMainWindow:(UIWindow *)mainWindow
{
    _mainWindow = mainWindow;
}

+ (UIWindow *)mainWindow
{
    if (!_mainWindow) {
        _mainWindow = [UIApplication sharedApplication].keyWindow;
    }
    return _mainWindow;
}

+ (void)setPerformanceMonitor:(id<MLNUIPerformanceMonitor>)pMonitor {
    [MLNUIKitInstanceHandlersManager defaultManager].performanceMonitor = pMonitor;
}
@end
