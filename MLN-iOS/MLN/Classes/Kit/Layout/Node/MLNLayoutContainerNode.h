//
//  MLNLayoutContainerNode.h
//
//
//  Created by MoMo on 2018/10/29.
//

#import "MLNLayoutNode.h"

NS_ASSUME_NONNULL_BEGIN

/**
 容器类布局节点，可以拥有子视图
 */
@interface MLNLayoutContainerNode : MLNLayoutNode

/**
 获取所有子节点
 */
@property (nonatomic, strong, readonly) NSArray<MLNLayoutNode *> *subnodes;

/**
 是否需要对节点排序
 */
@property (nonatomic, assign) BOOL needSorting;

/**
 添加一个子节点

 @param subNode 子节点
 */
- (void)addSubnode:(MLNLayoutNode *)subNode;

/**
 插入一个子节点到指定位置

 @param subNode 子节点
 @param index 指定位置
 */
- (void)insertSubnode:(MLNLayoutNode *)subNode atIndex:(NSUInteger)index;

/**
 移除一个子节点

 @param subNode 子节点
 */
- (void)removeSubnode:(MLNLayoutNode *)subNode;

/**
 移除所有子节点
 */
- (void)removeAllSubnodes;

/**
 手动请求布局该节点所在的节点树
 */
- (void)requestLayout;

/**
 测量
 */
- (void)onMeasure;

/**
 计算布局
 */
- (void)onLayout;

/**
 布局子节点
 */
- (void)layoutSubnodes;

@end

NS_ASSUME_NONNULL_END
