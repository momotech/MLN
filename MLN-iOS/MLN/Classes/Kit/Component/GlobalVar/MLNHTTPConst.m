//
//  MLNHTTPCachePolicy.m
//  CocoaLumberjack
//
//  Created by MoMo on 2018/8/13.
//

#import "MLNHTTPConst.h"
#import "MLNGlobalVarExporterMacro.h"

@implementation MLNHTTPConst

#pragma mark - Setup For Lua
LUA_EXPORT_GLOBAL_VAR_BEGIN()
LUA_EXPORT_GLOBAL_VAR(CachePolicy, (@{@"API_ONLY": @(MLNHTTPCachePolicyRemoteOnly),
                                      @"CACHE_THEN_API": @(MLNHTTPCachePolicyCacheThenRemote),
                                      @"CACHE_OR_API": @(MLNHTTPCachePolicyCacheOrRemote),
                                      @"CACHE_ONLY": @(MLNHTTPCachePolicyCacheOnly),
                                      @"REFRESH_CACHE_BY_API": @(MLNHTTPCachePolicyRefreshCache)}))
LUA_EXPORT_GLOBAL_VAR(ResponseKey, (@{@"Cache": @"__isCache",
                                      @"Path" : @"__path"}))
LUA_EXPORT_GLOBAL_VAR(ErrorKey, (@{@"MSG": @"errmsg",
                                   @"CODE": @"errcode"}))
LUA_EXPORT_GLOBAL_VAR(EncType, (@{@"NORMAL": @(MLNHTTPEncrptyTypeNORMAL),
                                  @"NO": @(MLNHTTPEncrptyTypeNO)}))
LUA_EXPORT_GLOBAL_VAR_END(MLNHTTPConst)

@end
