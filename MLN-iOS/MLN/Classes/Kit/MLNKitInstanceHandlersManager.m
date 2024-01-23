//
//  MLNKitInstanceHandlers.m
//  MLN
//
//  Created by MoMo on 2019/8/28.
//

#import "MLNKitInstanceHandlersManager.h"
#import "MLNApplication.h"
#import "MLNNetworkReachability.h"

@implementation MLNKitInstanceHandlersManager

- (instancetype)initWithUIInstance:(MLNKitInstance *)instance
{
    if (self = [super init]) {
        _instance = instance;
        _application = [[MLNApplication alloc] init];
        _networkReachability = [[MLNNetworkReachability alloc] init];
    }
    return self;
}

static MLNKitInstanceHandlersManager *_defaultManager = nil;
+ (instancetype)defaultManager
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _defaultManager = [[MLNKitInstanceHandlersManager alloc] init];
    });
    return _defaultManager;
}

- (id<MLNKitInstanceErrorHandlerProtocol>)errorHandler
{
    if (!_errorHandler && self != [MLNKitInstanceHandlersManager defaultManager]) {
        return [MLNKitInstanceHandlersManager defaultManager].errorHandler;
    }
    return _errorHandler;
}

- (id<MLNHttpHandlerProtocol>)httpHandler
{
    if (!_httpHandler && self != [MLNKitInstanceHandlersManager defaultManager]) {
        return [MLNKitInstanceHandlersManager defaultManager].httpHandler;
    }
    return _httpHandler;
}

- (id<MLNImageLoaderProtocol>)imageLoader
{
    if (!_imageLoader && self != [MLNKitInstanceHandlersManager defaultManager]) {
        return [MLNKitInstanceHandlersManager defaultManager].imageLoader;
    }
    return _imageLoader;
}

- (id<MLNRefreshDelegate>)scrollRefreshHandler
{
    if (!_scrollRefreshHandler && self != [MLNKitInstanceHandlersManager defaultManager]) {
        return [MLNKitInstanceHandlersManager defaultManager].scrollRefreshHandler;
    }
    return _scrollRefreshHandler;
}

- (id<MLNNavigatorHandlerProtocol>)navigatorHandler
{
    if (!_navigatorHandler && self != [MLNKitInstanceHandlersManager defaultManager]) {
        return [MLNKitInstanceHandlersManager defaultManager].navigatorHandler;
    }
    return _navigatorHandler;
}

-(id<MLNDependenceProtocol>)dependenceHandler {
    if (!_dependenceHandler && self != [MLNKitInstanceHandlersManager defaultManager]) {
        return [MLNKitInstanceHandlersManager defaultManager].dependenceHandler;
    }
    return _dependenceHandler;
}
@end
