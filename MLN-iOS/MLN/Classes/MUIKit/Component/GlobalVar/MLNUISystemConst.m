//
//  MLNUISystemConst.m
//  CocoaLumberjack
//
//  Created by MoMo on 2018/8/13.
//

#import "MLNUISystemConst.h"
#import "MLNUIGlobalVarExporterMacro.h"

@implementation MLNUISystemConst

#pragma mark - Setup For Lua
LUA_EXPORT_GLOBAL_VAR_BEGIN()
LUA_EXPORT_GLOBAL_VAR(NetworkState, (@{@"UNKNOWN": @(MLNUINetworkStatusUnknown),
                                       @"NO_NETWORK": @(MLNUINetworkStatusNoNetwork),
                                       @"CELLULAR": @(MLNUINetworkStatusWWAN),
                                       @"WIFI": @(MLNUINetworkStatusWifi)}))
LUA_EXPORT_GLOBAL_VAR_END()

@end
