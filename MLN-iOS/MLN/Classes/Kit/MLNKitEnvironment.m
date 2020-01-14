//
//  MLNKitEnvironment.m
//  MLN
//
//  Created by MoMo on 2019/11/22.
//

#import "MLNKitEnvironment.h"
#import "MLNKitInstanceHandlersManager.h"
#import "MLNKitInstanceFactory.h"

@implementation MLNKitEnvironment

+ (void)instancePreload
{
    [[MLNKitInstanceFactory defaultFactory] preloadWithCapacity:1];
}

+ (void)instancePreloadWithCapacity:(NSUInteger)capacity
{
    [[MLNKitInstanceFactory defaultFactory] preloadWithCapacity:capacity];
}

+ (void)setDefaultErrorHandler:(id<MLNKitInstanceErrorHandlerProtocol>)errorHandler
{
    [MLNKitInstanceHandlersManager defaultManager].errorHandler = errorHandler;
}

+ (void)setDefaultHttpHandler:(id<MLNHttpHandlerProtocol>)httpHandler
{
    [MLNKitInstanceHandlersManager defaultManager].httpHandler = httpHandler;
}

+ (void)setDefaultImageLoader:(id<MLNImageLoaderProtocol>)imageLoader
{
    [MLNKitInstanceHandlersManager defaultManager].imageLoader = imageLoader;
}

+ (void)setDefaultScrollRefreshHandler:(id<MLNRefreshDelegate>)scrollRefreshHandler
{
    [MLNKitInstanceHandlersManager defaultManager].scrollRefreshHandler = scrollRefreshHandler;
}

+ (void)setDefaultNavigatorHandler:(id<MLNNavigatorHandlerProtocol>)navigatorHandler
{
    [MLNKitInstanceHandlersManager defaultManager].navigatorHandler = navigatorHandler;
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

@end
