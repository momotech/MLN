//
//  MLNSystemConst.m
//  CocoaLumberjack
//
//  Created by MoMo on 2018/8/13.
//

#import "MLNSystemConst.h"
#import "MLNGlobalVarExporterMacro.h"

@implementation MLNSystemConst

#pragma mark - Setup For Lua
LUA_EXPORT_GLOBAL_VAR_BEGIN()
LUA_EXPORT_GLOBAL_VAR(NetworkState, (@{@"UNKNOWN": @(MLNNetworkStatusUnknown),
                                       @"NO_NETWORK": @(MLNNetworkStatusNoNetwork),
                                       @"CELLULAR": @(MLNNetworkStatusWWAN),
                                       @"WIFI": @(MLNNetworkStatusWifi)}))
LUA_EXPORT_GLOBAL_VAR_END()

@end
