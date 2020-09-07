//
//  MLNUIModelKeyPathComparator.h
//  AFNetworking
//
//  Created by MOMO on 2020/9/2.
//

#import <Foundation/Foundation.h>
@class MLNUILuaCore;
@protocol MLNUIModelHandlerProtocol;
NS_ASSUME_NONNULL_BEGIN

@interface MLNUIModelKeyPathComparator : NSObject
#if DEBUG

/// 根据 getCompareSwitchWithModel 的返回值为YES，拼接 luaTableKeyTrackCode，反之不拼接
/// @param functionChunk autoWired 函数字符串
/// @param model ArgoUI 生成的 viewModel
+ (const char *)luaTableKeyTrackCodeAppendFunction:(const char *)functionChunk model:(nonnull NSObject <MLNUIModelHandlerProtocol>*)model;


/// viewModel和服务器返回数据进行 keyPath 校验
/// @param luaCore lua状态机
/// @param model ArgoUI导出的viewModel
+ (void)keyPathCompare:(MLNUILuaCore *)luaCore model:(nonnull NSObject <MLNUIModelHandlerProtocol>*)model;
#endif
@end

NS_ASSUME_NONNULL_END
