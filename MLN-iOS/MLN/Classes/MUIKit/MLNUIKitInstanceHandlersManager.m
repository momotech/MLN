//
//  MLNUIKitInstanceHandlers.m
//  MLNUI
//
//  Created by MoMo on 2019/8/28.
//

#import "MLNUIKitInstanceHandlersManager.h"
#import "MLNUIApplication.h"
#import "MLNUINetworkReachability.h"
#import "MLNUIDefautImageloader.h"

@implementation MLNUIKitInstanceHandlersManager

- (instancetype)initWithUIInstance:(MLNUIKitInstance *)instance
{
    if (self = [super init]) {
        _instance = instance;
        _application = [[MLNUIApplication alloc] init];
        _networkReachability = [[MLNUINetworkReachability alloc] init];
    }
    return self;
}

static MLNUIKitInstanceHandlersManager *_defaultManager = nil;
+ (instancetype)defaultManager
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _defaultManager = [[MLNUIKitInstanceHandlersManager alloc] init];
        // 默认的handler
        [_defaultManager setImageLoader:[MLNUIDefautImageloader defaultIamgeLoader]];
    });
    return _defaultManager;
}

- (id<MLNUIKitInstanceErrorHandlerProtocol>)errorHandler
{
    if (!_errorHandler && self != [MLNUIKitInstanceHandlersManager defaultManager]) {
        return [MLNUIKitInstanceHandlersManager defaultManager].errorHandler;
    }
    return _errorHandler;
}

- (id<MLNUIHttpHandlerProtocol>)httpHandler
{
    if (!_httpHandler && self != [MLNUIKitInstanceHandlersManager defaultManager]) {
        return [MLNUIKitInstanceHandlersManager defaultManager].httpHandler;
    }
    return _httpHandler;
}

- (id<MLNUIImageLoaderProtocol>)imageLoader
{
    if (!_imageLoader && self != [MLNUIKitInstanceHandlersManager defaultManager]) {
        return [MLNUIKitInstanceHandlersManager defaultManager].imageLoader;
    }
    return _imageLoader;
}

- (id<MLNUIRefreshDelegate>)scrollRefreshHandler
{
    if (!_scrollRefreshHandler && self != [MLNUIKitInstanceHandlersManager defaultManager]) {
        return [MLNUIKitInstanceHandlersManager defaultManager].scrollRefreshHandler;
    }
    return _scrollRefreshHandler;
}

- (id<MLNUINavigatorHandlerProtocol>)navigatorHandler
{
    if (!_navigatorHandler && self != [MLNUIKitInstanceHandlersManager defaultManager]) {
        return [MLNUIKitInstanceHandlersManager defaultManager].navigatorHandler;
    }
    return _navigatorHandler;
}

@end
