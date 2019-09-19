//
//  MLNConvertorProtocol.h
//  MLN
//
//  Created by MoMo on 2019/8/2.
//

#ifndef MLNHttpHandlerProtocol_h
#define MLNHttpHandlerProtocol_h

#import <UIKit/UIkit.h>
#import "MLNHttp.h"

/**
 处理网络请求的协议
 */
@protocol MLNHttpHandlerProtocol <NSObject>

/**
 发起GET请求

 @param http 对应的Http请求类
 @param urlString 请求地址
 @param params 参数
 @param completionHandler 网络回调
 */
- (void)http:(MLNHttp *)http get:(NSString *)urlString params:(NSDictionary *)params completionHandler:(void(^)(BOOL success, NSDictionary *respInfo, NSDictionary *errorInfo))completionHandler;

/**
 发起POST请求

 @param http 对应的Http请求类
 @param urlString 请求地址
 @param params 参数
 @param completionHandler 网络回调
 */
- (void)http:(MLNHttp *)http post:(NSString *)urlString params:(NSDictionary *)params completionHandler:(void(^)(BOOL success, NSDictionary *respInfo, NSDictionary *errorInfo))completionHandler;

/**
 下载请求

 @param http 对应的Http请求类
 @param urlString 请求地址
 @param params 参数
 @param progressHandler 进度回调
 @param completionHandler 网络回调
 */
- (void)http:(MLNHttp *)http download:(NSString *)urlString params:(NSDictionary *)params progressHandler:(void(^)(float progress, float total))progressHandler completionHandler:(void(^)(BOOL success, NSDictionary *respInfo, id respData, NSDictionary *errorInfo))completionHandler;

/**
 上传

 @param http 对应的Http请求类
 @param urlString 请求地址
 @param params 参数
 @param filePaths 要上传的文件组
 @param fileNames 文件组对应的名称
 @param completionHandler 网络回调
 */
- (void)http:(MLNHttp *)http upload:(NSString *)urlString params:(NSDictionary *)params filePaths:(NSArray *)filePaths  fileNames:(NSArray *)fileNames completionHandler:(void(^)(BOOL success, NSDictionary *respInfo, NSDictionary *errorInfo))completionHandler;

@optional

/**
 设置网络请求的根地址，如果不为空的话，请求接口的url可以是相对地址

 @param http 对应的Http请求类
 @param baseUrlString 网络请求的根地址
 */
- (void)http:(MLNHttp *)http setBaseUrlString:(NSString *)baseUrlString;

/**
 添加缓存策略需要过滤的参数Key

 @param http 对应的Http请求类
 @param key 需要过滤的参数Key
 */
- (void)http:(MLNHttp *)http addCachePolicyFilterKey:(NSString *)key;

@end

#endif /* MLNHttpHandlerProtocol_h */
