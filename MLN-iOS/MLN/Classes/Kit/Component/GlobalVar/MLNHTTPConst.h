//
//  MLNHTTPCachePolicy.h
//  CocoaLumberjack
//
//  Created by MoMo on 2018/8/13.
//

#import <Foundation/Foundation.h>
#import "MLNGlobalVarExportProtocol.h"

typedef enum : NSUInteger {
    MLNHTTPCachePolicyRemoteOnly = 0, // 不使用缓存,只从网络更新数据
    MLNHTTPCachePolicyCacheThenRemote = 1, // 先使用缓存，随后请求网络更新请求
    MLNHTTPCachePolicyCacheOrRemote = 2, // 优先使用缓存，无法找到缓存时才连网更新
    MLNHTTPCachePolicyCacheOnly = 3, // 只读缓存
    MLNHTTPCachePolicyRefreshCache = 4, // 刷新网络后数据加入缓存
} MLNHTTPCachePolicy;

typedef enum : NSUInteger {
    MLNHTTPEncrptyTypeNORMAL = 0, // 加密，默认
    MLNHTTPEncrptyTypeNO = 1, //不加密
} MLNHTTPEncrptyType;

@interface MLNHTTPConst : NSObject <MLNGlobalVarExportProtocol>

@end
