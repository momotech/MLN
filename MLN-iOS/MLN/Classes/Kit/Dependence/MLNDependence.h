//
//  MLNDependence.h
//  MLN
//
//  Created by xue.yunqiang on 2022/5/5.
//

#import <Foundation/Foundation.h>
#import "MLNDependenceProtocol.h"
#import "MLNRecordLogProtocol.h"

typedef enum : NSUInteger {
    MLNDependenceErrorDefult = 3000, // By default
    MLNDependenceErrorRemoveFile,
    MLNDependenceErrorUnzip,
    MLNDependenceErrorDownload,
    MLNDependenceErrorCheckFile,
    MLNDependenceErrorCheckToLimited
} MLNDependenceError;

NS_ASSUME_NONNULL_BEGIN

@interface MLNDependence : NSObject

@property(nonatomic, strong) id<MLNDependenceProtocol> delegate;

@property(nonatomic, strong) id<MLNRecordLogProtocol> logHandle;

@property(nonatomic, strong) id<MLNDependenceErrorDelegate> errorHandle;

@property(nonatomic, copy)   NSString * projectTag;

/// 获取依赖信息,如果不涉及下载,解压则同步返回结果,如果涉及下载,解压异步返回.
/// @param rootPath Lua 工程根路径
/// @param finished 查询结果回调
- (void)prepareDependenceWithLuaBundleRootPath:(NSString *)rootPath finished:(void (^)(NSDictionary *))finished;

/// 同步获取依赖,不会进行下载解压等操作
/// @param rootPath Lua 工程根路径
- (NSDictionary *)prepareDependenceWithLuaBundleRootPath:(NSString *)rootPath;

@end

NS_ASSUME_NONNULL_END
