//
//  MLNUIInteractiveBehavior.h
//  ArgoUI
//
//  Created by MOMO on 2020/6/18.
//

#import <Foundation/Foundation.h>
#import "MLNUIViewConst.h"
#import <ArgoAnimation/MLAInteractiveBehaviorProtocol.h>

NS_ASSUME_NONNULL_BEGIN
@class MLAValueAnimation;
@class MLNUILuaCore, MLNUIBlock;

typedef void(^MLNUITouchBehaviorBlock)(MLNUITouchType type, CGFloat dx, CGFloat dy, CGFloat dis, CGFloat velocity);

@interface MLNUIInteractiveBehavior : NSObject <NSCopying, MLAInteractiveBehaviorProtocol>

/// 目标视图
@property (nonatomic, weak) UIView *targetView;

/// 交互行为方向
@property (nonatomic, assign) InteractiveDirection direction;

/// 是否越界
@property (nonatomic, assign) BOOL overBoundary;

/// 是否允许交互
@property (nonatomic, assign) BOOL enable;

/// 是否跟随手势
@property (nonatomic, assign) BOOL followEnable;

/// 驱动最大值，当移动、缩放或旋转手势超过最大值时，动画到达最大值
@property (nonatomic, assign) CGFloat max;

/// 触摸回调
@property (nonatomic, strong) MLNUITouchBehaviorBlock touchBlock;

- (void)addAnimation:(MLAValueAnimation *)ani;
- (void)removeAnimation:(MLAValueAnimation *)ani;
- (void)removeAllAnimations;

// bridge
- (instancetype)initWithMLNUILuaCore:(MLNUILuaCore *)luaCore type:(InteractiveType)type;
- (void)lua_setTouchBlock:(MLNUIBlock *)block;
- (MLNUIBlock *)lua_touchBlock;

@end

NS_ASSUME_NONNULL_END
