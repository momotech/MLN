//
//  MLNUISystemConst.m
//  CocoaLumberjack
//
//  Created by MoMo on 2018/8/13.
//

#import "MLNUISystemConst.h"
#import "MLNUIGlobalVarExporterMacro.h"
#import "ArgoKitDefinitions.h"

@implementation MLNUISystemConst

#pragma mark - Setup For Lua
LUAUI_EXPORT_GLOBAL_VAR_BEGIN()
LUAUI_EXPORT_GLOBAL_VAR(NetworkState, (@{@"UNKNOWN": @(MLNUINetworkStatusUnknown),
                                       @"NO_NETWORK": @(MLNUINetworkStatusNoNetwork),
                                       @"CELLULAR": @(MLNUINetworkStatusWWAN),
                                       @"WIFI": @(MLNUINetworkStatusWifi)}))

LUAUI_EXPORT_GLOBAL_VAR(WatchContext, (@{@"NATIVE": @(ArgoWatchContext_Native),
                                        @"LUA": @(ArgoWatchContext_Lua)}))

LUAUI_EXPORT_GLOBAL_VAR_END()

@end
