//
//  MLNUIInteractiveBehavior.h
//  ArgoUI
//
//  Created by Dai Dongpeng on 2020/6/18.
//

#import <Foundation/Foundation.h>
#import "MLNUIViewConst.h"

NS_ASSUME_NONNULL_BEGIN
@class MLAValueAnimation;
@class MLNUILuaCore, MLNUIBlock;

@interface MLNUIInteractiveBehavior : NSObject <NSCopying>

@property (nonatomic, weak) UIView *targetView;
@property (nonatomic, assign) InteractiveDirection direction;
@property (nonatomic, assign) CGFloat endDistance;
@property (nonatomic, assign) BOOL overBoundary;
@property (nonatomic, assign) BOOL enable;
@property (nonatomic, assign) BOOL followEnable;

@property (nonatomic, strong) void(^touchBlock)(MLNUITouchType type,CGFloat dx, CGFloat dy, CGFloat dis, CGFloat velocity);

- (instancetype)initWithType:(InteractiveType)type;

- (void)addAnimation:(MLAValueAnimation *)ani;
- (void)removeAnimation:(MLAValueAnimation *)ani;
- (void)removeAllAnimations;

// bridge
- (instancetype)initWithMLNUILuaCore:(MLNUILuaCore *)luaCore type:(InteractiveType)type;
- (void)lua_setTouchBlock:(MLNUIBlock *)block;
- (MLNUIBlock *)lua_touchBlock;

@end

NS_ASSUME_NONNULL_END
