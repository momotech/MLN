//
//  MLNUIHTTPCachePolicy.m
//  CocoaLumberjack
//
//  Created by MoMo on 2018/8/13.
//

#import "MLNUIHTTPConst.h"
#import "MLNUIGlobalVarExporterMacro.h"

@implementation MLNUIHTTPConst

#pragma mark - Setup For Lua
LUAUI_EXPORT_GLOBAL_VAR_BEGIN()
LUAUI_EXPORT_GLOBAL_VAR(CachePolicy, (@{@"API_ONLY": @(MLNUIHTTPCachePolicyRemoteOnly),
                                      @"CACHE_THEN_API": @(MLNUIHTTPCachePolicyCacheThenRemote),
                                      @"CACHE_OR_API": @(MLNUIHTTPCachePolicyCacheOrRemote),
                                      @"CACHE_ONLY": @(MLNUIHTTPCachePolicyCacheOnly),
                                      @"REFRESH_CACHE_BY_API": @(MLNUIHTTPCachePolicyRefreshCache)}))
LUAUI_EXPORT_GLOBAL_VAR(ResponseKey, (@{@"Cache": @"__isCache",
                                      @"Path" : @"__path"}))
LUAUI_EXPORT_GLOBAL_VAR(ErrorKey, (@{@"MSG": @"errmsg",
                                   @"CODE": @"errcode"}))
LUAUI_EXPORT_GLOBAL_VAR(EncType, (@{@"NORMAL": @(MLNUIHTTPEncrptyTypeNORMAL),
                                  @"NO": @(MLNUIHTTPEncrptyTypeNO)}))
LUAUI_EXPORT_GLOBAL_VAR_END()

@end
