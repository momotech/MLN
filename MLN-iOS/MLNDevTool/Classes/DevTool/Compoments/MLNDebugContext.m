//
//  MLNDebugContext.m
//  MLNDevTool
//
//  Created by MOMO on 2020/1/6.
//

#import "MLNDebugContext.h"
#import "NSBundle+MLNDebugTool.h"
#import <ArgoUI/MLNUIKit.h>

#define MLNDEBUG_IP_KEY   @"MLNDebugContextDebugIPAddressKey"
#define MLNDEBUG_PORT_KEY @"MLNDebugContextDebugPortKey"

@interface MLNDebugContext ()

@end

@implementation MLNDebugContext

#pragma mark - Public

+ (MLNDebugContext *)sharedContext {
    static MLNDebugContext *context = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        context = [[MLNDebugContext alloc] init];
    });
    return context;
}

+ (NSBundle *)debugBundle {
    static NSBundle *bundle = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        bundle = [NSBundle bundleWithClass:[self class] name:@"MLNDevTool_Util"];
    });
    return bundle;
}

#pragma mark - Private

- (instancetype)init {
    if (self = [super init]) {
        _ipAddress = [[NSUserDefaults standardUserDefaults] stringForKey:MLNDEBUG_IP_KEY];
        _port = [[NSUserDefaults standardUserDefaults] integerForKey:MLNDEBUG_PORT_KEY];
        if (_port == 0) {
            _port = 8172;
        }
    }
    return self;
}

- (void)setIpAddress:(NSString *)ipAddress {
    _ipAddress = ipAddress;
    if (ipAddress.length) {
        [[NSUserDefaults standardUserDefaults] setObject:ipAddress forKey:MLNDEBUG_IP_KEY];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

- (void)setPort:(NSInteger)port {
    _port = port;
    if (port > 0) {
        [[NSUserDefaults standardUserDefaults] setInteger:port forKey:MLNDEBUG_PORT_KEY];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

#pragma mark - Lua

+ (NSString *)mln_debugIp {
    return [MLNDebugContext sharedContext].ipAddress;
}

+ (NSInteger)mln_debugPort {
    return [MLNDebugContext sharedContext].port;
}

LUA_EXPORT_STATIC_BEGIN(MLNDebugContext)
LUA_EXPORT_STATIC_METHOD(debugIp, "mln_debugIp", MLNDebugContext)
LUA_EXPORT_STATIC_METHOD(debugPort, "mln_debugPort", MLNDebugContext)
LUA_EXPORT_STATIC_END(MLNDebugContext, DebugContext, NO, NULL)

LUAUI_EXPORT_STATIC_BEGIN(MLNDebugContext)
LUAUI_EXPORT_STATIC_METHOD(debugIp, "mln_debugIp", MLNDebugContext)
LUAUI_EXPORT_STATIC_METHOD(debugPort, "mln_debugPort", MLNDebugContext)
LUAUI_EXPORT_STATIC_END(MLNDebugContext, DebugContext, NO, NULL)

@end
