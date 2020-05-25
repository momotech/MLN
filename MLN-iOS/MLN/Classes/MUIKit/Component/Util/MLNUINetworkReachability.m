//
//  MLNUINetworkReachability.m
//  MLNUI
//
//  Created by MoMo on 2018/9/28.
//

#import "MLNUINetworkReachability.h"
#import "MLNUIKitHeader.h"
#import "MLNUIKitInstance.h"
#import "MLNUIStaticExporterMacro.h"
#import "MLNUIKitInstanceHandlersManager.h"
#import "MLNUIBlock.h"
#import "MLNUINetworkReachabilityManager.h"

@interface MLNUINetworkReachability ()

@property (nonatomic, copy) MLNUINetworkReachabilityStatusBlock reachabilityStatusBlock;

@end
@implementation MLNUINetworkReachability

+ (void)lua_open
{
    [[MLNUINetworkReachabilityManager sharedManager] startMonitoring];
}

+ (void)lua_cloze
{
    [[MLNUINetworkReachabilityManager sharedManager] stopMonitoring];
}

+ (MLNUINetworkStatus)lua_netWorkType
{
    return [[MLNUINetworkReachabilityManager sharedManager] networkStatus];
}

+ (void)lua_setOnNetworkStateChange:(MLNUIBlock *)callback
{
    MLNUIStaticCheckTypeAndNilValue(callback, @"callback", MLNUIBlock);
    MLNUINetworkReachability *networkReachability = MLNUI_KIT_INSTANCE(self.mln_currentLuaCore).instanceHandlersManager.networkReachability;
    // clear
    if (networkReachability.reachabilityStatusBlock) {
        [[MLNUINetworkReachabilityManager sharedManager] removeNetworkChangedCallback:networkReachability.reachabilityStatusBlock];
    }
    // new
    networkReachability.reachabilityStatusBlock = ^(MLNUINetworkStatus status) {
        if (callback) {
            [callback addIntArgument:(int)status];
            [callback callIfCan];
        }
    };
    [[MLNUINetworkReachabilityManager sharedManager] addNetworkChangedCallback:networkReachability.reachabilityStatusBlock];
}

- (void)dealloc
{
    if (self.reachabilityStatusBlock) {
        // clear
        [[MLNUINetworkReachabilityManager sharedManager] removeNetworkChangedCallback:self.reachabilityStatusBlock];
        self.reachabilityStatusBlock = nil;
    }
}

#pragma mark - Setup For Lua
LUA_EXPORT_STATIC_BEGIN(MLNUINetworkReachability)
LUA_EXPORT_STATIC_METHOD(open, "lua_open", MLNUINetworkReachability)
LUA_EXPORT_STATIC_METHOD(close, "lua_cloze", MLNUINetworkReachability)
LUA_EXPORT_STATIC_METHOD(networkState, "lua_netWorkType", MLNUINetworkReachability)
LUA_EXPORT_STATIC_METHOD(setOnNetworkStateChange, "lua_setOnNetworkStateChange:", MLNUINetworkReachability)
LUA_EXPORT_STATIC_END(MLNUINetworkReachability, NetworkReachability, NO, NULL)

@end
