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
LUA_EXPORT_GLOBAL_VAR_BEGIN()
LUA_EXPORT_GLOBAL_VAR(CachePolicy, (@{@"API_ONLY": @(MLNUIHTTPCachePolicyRemoteOnly),
                                      @"CACHE_THEN_API": @(MLNUIHTTPCachePolicyCacheThenRemote),
                                      @"CACHE_OR_API": @(MLNUIHTTPCachePolicyCacheOrRemote),
                                      @"CACHE_ONLY": @(MLNUIHTTPCachePolicyCacheOnly),
                                      @"REFRESH_CACHE_BY_API": @(MLNUIHTTPCachePolicyRefreshCache)}))
LUA_EXPORT_GLOBAL_VAR(ResponseKey, (@{@"Cache": @"__isCache",
                                      @"Path" : @"__path"}))
LUA_EXPORT_GLOBAL_VAR(ErrorKey, (@{@"MSG": @"errmsg",
                                   @"CODE": @"errcode"}))
LUA_EXPORT_GLOBAL_VAR(EncType, (@{@"NORMAL": @(MLNUIHTTPEncrptyTypeNORMAL),
                                  @"NO": @(MLNUIHTTPEncrptyTypeNO)}))
LUA_EXPORT_GLOBAL_VAR_END()

@end
