//
//  MLNNetworkReachability.m
//  MLN
//
//  Created by MoMo on 2018/9/28.
//

#import "MLNNetworkReachability.h"
#import "MLNKitHeader.h"
#import "MLNKitInstance.h"
#import "MLNStaticExporterMacro.h"
#import "MLNKitInstanceHandlersManager.h"
#import "MLNBlock.h"
#import "MLNNetworkReachabilityManager.h"

@interface MLNNetworkReachability ()

@property (nonatomic, copy) MLNNetworkReachabilityStatusBlock reachabilityStatusBlock;

@end
@implementation MLNNetworkReachability

+ (void)lua_open
{
    [[MLNNetworkReachabilityManager sharedManager] startMonitoring];
}

+ (void)lua_cloze
{
    [[MLNNetworkReachabilityManager sharedManager] stopMonitoring];
}

+ (MLNNetworkStatus)lua_netWorkType
{
    return [[MLNNetworkReachabilityManager sharedManager] networkStatus];
}

+ (void)lua_setOnNetworkStateChange:(MLNBlock *)callback
{
    MLNStaticCheckTypeAndNilValue(callback, @"callback", MLNBlock);
    MLNNetworkReachability *networkReachability = MLN_KIT_INSTANCE(self.mln_currentLuaCore).instanceHandlersManager.networkReachability;
    // clear
    if (networkReachability.reachabilityStatusBlock) {
        [[MLNNetworkReachabilityManager sharedManager] removeNetworkChangedCallback:networkReachability.reachabilityStatusBlock];
    }
    // new
    networkReachability.reachabilityStatusBlock = ^(MLNNetworkStatus status) {
        if (callback) {
            [callback addIntArgument:status];
            [callback callIfCan];
        }
    };
    [[MLNNetworkReachabilityManager sharedManager] addNetworkChangedCallback:networkReachability.reachabilityStatusBlock];
}

- (void)dealloc
{
    if (self.reachabilityStatusBlock) {
        // clear
        [[MLNNetworkReachabilityManager sharedManager] removeNetworkChangedCallback:self.reachabilityStatusBlock];
        self.reachabilityStatusBlock = nil;
    }
}

#pragma mark - Setup For Lua
LUA_EXPORT_STATIC_BEGIN(MLNNetworkReachability)
LUA_EXPORT_STATIC_METHOD(open, "lua_open", MLNNetworkReachability)
LUA_EXPORT_STATIC_METHOD(close, "lua_cloze", MLNNetworkReachability)
LUA_EXPORT_STATIC_METHOD(networkState, "lua_netWorkType", MLNNetworkReachability)
LUA_EXPORT_STATIC_METHOD(setOnNetworkStateChange, "lua_setOnNetworkStateChange:", MLNNetworkReachability)
LUA_EXPORT_STATIC_END(MLNNetworkReachability, NetworkReachability, NO, NULL)

@end
