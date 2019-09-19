//
//  MLNLayoutEngine.h
//
//
//  Created by MoMo on 2018/10/24.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class MLNKitInstance;
@class MLNLayoutContainerNode;
@class MLNSizeCahceManager;

/**
 自动布局引擎
 
 @note 该引擎主要监听MainRunLoop的BeforeWaiting事件，在视图渲染之前计算所有需要处理的视图布局。
        该引擎会持有所有需要布局视图的Layout Node 构建成的布局树，从Root节点，递归向下计算。
 */
@interface MLNLayoutEngine : NSObject

/**
 当前引擎所在的Lua 实例
 */
@property (nonatomic, weak, readonly) MLNKitInstance *luaInstance;

/**
 当前布局引擎的Size缓存
 */
@property (nonatomic, strong, readonly) MLNSizeCahceManager *sizeCacheManager;

/**
 创建布局引擎

 @param luaInstance 引擎所在的Lua 实例
 @return 布局引擎
 */
- (instancetype)initWithLuaInstance:(MLNKitInstance *)luaInstance;

/**
 开启布局引擎
 */
- (void)start;

/**
 关闭布局引擎
 */
- (void)end;

/**
 添加一个布局树

 @param rootnode 布局树的根节点
 */
- (void)addRootnode:(MLNLayoutContainerNode *)rootnode;

/**
 移除一个布局树

 @param rootnode 布局树的根节点
 */
- (void)removeRootNode:(MLNLayoutContainerNode *)rootnode;

/**
 手动触发一个布局计算。
 
 @note 这里会计算当前引擎中的所有布局树
 */
- (void)requestLayout;

@end

NS_ASSUME_NONNULL_END
