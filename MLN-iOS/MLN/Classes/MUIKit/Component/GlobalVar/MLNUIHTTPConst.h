//
//  MLNUIHTTPCachePolicy.h
//  CocoaLumberjack
//
//  Created by MoMo on 2018/8/13.
//

#import <Foundation/Foundation.h>
#import "MLNUIGlobalVarExportProtocol.h"

typedef enum : NSUInteger {
    MLNUIHTTPCachePolicyRemoteOnly = 0, // 不使用缓存,只从网络更新数据
    MLNUIHTTPCachePolicyCacheThenRemote = 1, // 先使用缓存，随后请求网络更新请求
    MLNUIHTTPCachePolicyCacheOrRemote = 2, // 优先使用缓存，无法找到缓存时才连网更新
    MLNUIHTTPCachePolicyCacheOnly = 3, // 只读缓存
    MLNUIHTTPCachePolicyRefreshCache = 4, // 刷新网络后数据加入缓存
} MLNUIHTTPCachePolicy;

typedef enum : NSUInteger {
    MLNUIHTTPEncrptyTypeNORMAL = 0, // 加密，默认
    MLNUIHTTPEncrptyTypeNO = 1, //不加密
} MLNUIHTTPEncrptyType;

@interface MLNUIHTTPConst : NSObject <MLNUIGlobalVarExportProtocol>

@end
