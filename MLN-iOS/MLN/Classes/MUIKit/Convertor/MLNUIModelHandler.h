//
//  MLNUIModelHandler.h
//  ArgoUI
//
//  Created by MOMO on 2020/8/17.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MLNUIModelHandler : NSObject

/// 业务方可根据需要，通过`dataObject`修改`model`中的属性值，从而满足UI显示需求。
/// @param dataObject 数据源 (字典或数组)
/// @param model 绑定到视图上的viewModel
/// @param extra 额外的数据信息
/// @param functionChunk lua函数代码块
/// @return 处理后的viewModel，若出现错误，则返回nil。
+ (__kindof NSObject *)buildModelWithDataObject:(id)dataObject model:(NSObject *)model extra:(id _Nullable)extra functionChunk:(const char *)functionChunk;

@end

NS_ASSUME_NONNULL_END
