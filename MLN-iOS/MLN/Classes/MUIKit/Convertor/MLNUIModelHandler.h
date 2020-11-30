//
//  MLNUIModelHandler.h
//  ArgoUI
//
//  Created by MOMO on 2020/8/17.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol MLNUIModelHandlerProtocol <NSObject>
@optional
/// @return YES 启用 viewModel 和 服务器返回数据的 key-path 校验功能
- (BOOL)isCompareKeyPath;
/// @return 返回 viewModel 的 key-path 字典功能，ArgoUI 自动生成。
- (NSMutableDictionary *_Nonnull)keyPaths;
@end

typedef void(^MLNUIModelHandleComplete)(__kindof NSObject *model, NSError *error);

@interface MLNUIModelHandler : NSObject

/// 业务方可根据需要，通过`dataObject`修改`model`中的属性值，从而满足UI显示需求。
/// @Note 在当前线程同步执行。
/// @param dataObject 数据源 (字典或数组)
/// @param model 绑定到视图上的viewModel
/// @param extra 额外的数据信息
/// @param functionChunk lua函数代码块
/// @param error 错误信息
/// @return 处理后的viewModel，若出现错误，则返回nil。
+ (__kindof NSObject *)buildModelWithDataObject:(id)dataObject model:(NSObject <MLNUIModelHandlerProtocol>*)model extra:(id _Nullable)extra functionChunk:(const char *)functionChunk error:(NSError **)error;

/// 业务方可根据需要，通过`dataObject`修改`model`中的属性值，从而满足UI显示需求。
/// @Note 在后台线程异步执行。
/// @param dataObject 数据源 (字典或数组)
/// @param model 绑定到视图上的viewModel
/// @param extra 额外的数据信息
/// @param functionChunk lua函数代码块
/// @param complete 结果回调。
+ (void)buildModelWithDataObject:(id)dataObject model:(NSObject <MLNUIModelHandlerProtocol>*)model extra:(id _Nullable)extra functionChunk:(const char *)functionChunk complete:(MLNUIModelHandleComplete)complete;

/// 将字典转为viewModel
/// @param model 绑定到视图上的viewModel
/// @param dic 待转换的字典
/// @return 即转换后的参数`model`
+ (NSObject *)convertViewModel:(NSObject <MLNUIModelHandlerProtocol> *)model fromDictionary:(NSDictionary *)dic;

@end

NS_ASSUME_NONNULL_END

