//
//  MLNUIAnimationHandler.h
//  MLNUI
//
//  Created by MoMo on 2019/5/21.
//

#import <UIKit/UIKit.h>
#import "MLNUIAnimationHandlerCallbackProtocol.h"

NS_ASSUME_NONNULL_BEGIN

/**
 动画处理句柄，主要接受屏幕刷新频率事件
 */
@interface MLNUIAnimationHandler : NSObject

/**
 共享的处理句柄对象
 
 @note 所有的动画执行器，默认使用该共享处理句柄
 */
+ (instancetype)sharedHandler;

/**
 暂停接受屏幕刷新频率事件
 */
- (void)pause;

/**
 开始接受屏幕刷新频率事件
 */
- (void)resume;

/**
 添加一个屏幕刷新频率事件的监听者
 */
- (void)addCallback:(id<MLNUIAnimationHandlerCallbackProtocol>)callback;

/**
 移除一个屏幕刷新频率事件的监听者
 */
- (void)removeCallback:(id<MLNUIAnimationHandlerCallbackProtocol>)callback;

/**
 移除所有屏幕刷新频率事件的监听者
 */
- (void)removeAllCallbacks;

@end

NS_ASSUME_NONNULL_END
