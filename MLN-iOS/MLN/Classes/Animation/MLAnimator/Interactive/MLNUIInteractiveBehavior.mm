//
//  MLNUIInteractiveBehavior.m
//  ArgoUI
//
//  Created by MOMO on 2020/6/18.
//

#import "MLNUIInteractiveBehavior.h"
#import "UIView+MLNUIKit.h"
#import "MLAAnimation.h"
#import "MLAValueAnimation+Interactive.h"

#include "ObjectAnimation.h"
#include "MultiAnimation.h"
#import "MLADefines.h"
#import "MLAAnimatable.h"

#import "MLNUIViewExporterMacro.h"
#import "UIView+MLNUIKit.h"
#import "MLNUIMetamacros.h"

#define MLNUIAnimationPosition  (1 << 0)
#define MLNUIAnimationPositionX (1 << 1)
#define MLNUIAnimationPositionY (1 << 2)
#define MLNUIPositionXMask (MLNUIAnimationPosition | MLNUIAnimationPositionX)
#define MLNUIPositionYMask (MLNUIAnimationPosition | MLNUIAnimationPositionY)

union MLNUIAnimationTypes {
    uintptr_t bits;
    struct {
        uintptr_t position  : 1;
        uintptr_t positionX : 1;
        uintptr_t pssitionY : 1;
    };
};

@interface MLNUIInteractiveBehavior ()

@property (nonatomic, assign)InteractiveType type;
@property (nonatomic, strong) NSHashTable <MLAValueAnimation *> *valueAnimations;
@property (nonatomic, strong) MLNUITouchCallback touchCallback;
@property (nonatomic, assign) CGPoint beginPoint;
@property (nonatomic, assign) CGPoint endPoint;
@property (nonatomic, assign) CGPoint tolerant;
@property (nonatomic, assign) CGFloat lastDistance;
@property (nonatomic, strong) MLNUIBlock *luaTouchBlock;
@property (nonatomic, assign) MLNUIAnimationTypes animationTypes;

@end

@implementation MLNUIInteractiveBehavior

- (instancetype)initWithType:(InteractiveType)type {
    if (self = [super init]) {
        [self setupWithType:type];
    }
    return self;
}

- (void)setupWithType:(InteractiveType)type {
    _type = type;
    _endDistance = 1999;
    _valueAnimations = [NSHashTable weakObjectsHashTable];
}

- (void)setTargetView:(UIView *)targetView {
    [self setupTouchBlock];
    
    [_targetView mlnui_removeTouchBlock:self.touchCallback];
    _targetView = targetView;
    [targetView mlnui_addTouchBlock:self.touchCallback];
}

// 若 position 动画方向和手势驱动方向不同，则禁用手势跟随效果
static inline BOOL MLNUIFollowEnable(MLNUIInteractiveBehavior *self) {
    BOOL disallow = NO;
    if (self.direction == InteractiveDirection_X) {
        disallow = self->_animationTypes.bits & MLNUIPositionYMask;
    } else {
        disallow = self->_animationTypes.bits & MLNUIPositionXMask;
    }
    return (self.followEnable && !disallow);
}

- (void)setupTouchBlock {
    __block CGFloat newSpeed,oldSpeed = 0;
    __block NSTimeInterval previousTime = 0;
    __block CGFloat lastSpeed = 0;
    
    __weak __typeof(self)weakSelf = self;
    self.touchCallback = ^(MLNUITouchType type, UITouch * _Nonnull touch, UIEvent * _Nonnull event) {
        __strong __typeof(weakSelf)self = weakSelf;
        if (!self.enable || !self.targetView.superview || self.endDistance == 0)  return ;
        
        if (previousTime == touch.timestamp) {
            return;
        }
        CGPoint point = [touch locationInView:self.targetView.superview];
        CGPoint lastPoint = [touch previousLocationInView:self.targetView.superview];
        point = CGPointMake(point.x + self.tolerant.x, point.y + self.tolerant.y);
        lastPoint = CGPointMake(lastPoint.x + self.tolerant.x, lastPoint.y + self.tolerant.y);

        CGPoint diffLast = CGPointMake(point.x - lastPoint.x, point.y - lastPoint.y);
        CGPoint diffBegin = CGPointMake(point.x - self.beginPoint.x, point.y - self.beginPoint.y);
        CGFloat dis = self.direction == InteractiveDirection_X ? diffBegin.x : diffBegin.y;
        float factor = dis / self.endDistance;
        const float lambda = 0.8f; // the closer to 1 the higher weight to the next touch
        newSpeed = (1.0 - lambda) * oldSpeed + lambda* ((point.y - lastPoint.y)/(touch.timestamp - previousTime));
        oldSpeed = newSpeed;
        previousTime = touch.timestamp;
        
        switch (type) {
            case MLNUITouchType_Begin: {
                if (CGPointEqualToPoint(self.beginPoint, CGPointZero)) {
                    self.beginPoint = point;
                }
                if (CGPointEqualToPoint(self.endPoint, CGPointZero)) {
                    self.tolerant = CGPointZero;
                } else {
                    self.tolerant = CGPointMake(self.endPoint.x - point.x, self.endPoint.y - point.y);
                }
                newSpeed = oldSpeed = lastSpeed = 00;
                [self onTouch:type dx:point.x dy:point.y distance:0 velocity:newSpeed];
            }
                break;
                
            case MLNUITouchType_Move: {
                BOOL shouldReturn = !self.overBoundary && (factor > 1 || factor < 0);
                if (!shouldReturn) {
                    [self onTouch:type dx:point.x dy:point.y distance:dis velocity:newSpeed];
                }
                dispatch_block_t followBlock = ^{
                    CGPoint c = self.targetView.center;
                    CGPoint newc = CGPointMake(c.x + diffLast.x, c.y + diffLast.y);
                    self.targetView.center = newc;
                };
                if (MLNUIFollowEnable(self)) {
                    followBlock();
                }
                if (shouldReturn) {
                    if ((newSpeed > 0) ^ (lastSpeed > 0)) {
                        lastSpeed = newSpeed;
                        if (factor > 1) {
                            self.beginPoint = CGPointMake(point.x - self.endDistance, point.y - self.endDistance);
                        } else {
                            self.beginPoint = point;
                        }
                    }
                    return;
                }
                for (MLAValueAnimation *ani in self.valueAnimations) {
                    [ani updateWithFactor:factor isBegan:NO];
                }
            }
                break;
                
            case MLNUITouchType_End:
                self.endPoint = point;
                self.tolerant = CGPointZero;
                [self onTouch:type dx:point.x dy:point.y distance:dis velocity:newSpeed];
                break;
                
            default:
                break;
        }
        
        lastSpeed = newSpeed;
    };
}

- (void)onTouch:(MLNUITouchType)type dx:(float)dx dy:(float)dy distance:(float)distance velocity:(float)velocity {
    if (self.touchBlock) {
        self.touchBlock(type, dx, dy, distance, velocity);
    }

    if (self.luaTouchBlock) {
        [self.luaTouchBlock addUIntegerArgument:type];
        [self.luaTouchBlock addFloatArgument:distance];
        [self.luaTouchBlock addFloatArgument:velocity];
        [self.luaTouchBlock callIfCan];
    }
    self.lastDistance = distance;
}

- (id)copyWithZone:(nullable NSZone *)zone {
    MLNUIInteractiveBehavior *beh = [[MLNUIInteractiveBehavior alloc] initWithType:self.type];
    beh.type = self.type;
    beh.direction = self.direction;
    beh.endDistance = self.endDistance;
    beh.overBoundary = self.overBoundary;
    beh.enable = self.enable;
    beh.followEnable = self.followEnable;
    
    beh.targetView = self.targetView;
    beh.valueAnimations = self.valueAnimations.copy;
    beh.touchBlock = self.touchBlock;
    
    return beh;
}

- (void)addAnimation:(MLAValueAnimation *)ani {
    if (ani) {
        [self.valueAnimations addObject:ani];
        if ([ani.valueName isEqualToString:kMLAViewPosition]) {
            _animationTypes.bits |= MLNUIAnimationPosition;
        } else if ([ani.valueName isEqualToString:kMLAViewPositionX]) {
            _animationTypes.bits |= MLNUIAnimationPositionX;
        } else if ([ani.valueName isEqualToString:kMLAViewPositionY]) {
            _animationTypes.bits |= MLNUIAnimationPositionY;
        }
    }
}
- (void)removeAnimation:(MLAValueAnimation *)ani {
    if (ani) {
        [self.valueAnimations removeObject:ani];
        if ([ani.valueName isEqualToString:kMLAViewPosition]) {
            _animationTypes.bits &= ~MLNUIAnimationPosition;
        } else if ([ani.valueName isEqualToString:kMLAViewPositionX]) {
            _animationTypes.bits &= ~MLNUIAnimationPositionX;
        } else if ([ani.valueName isEqualToString:kMLAViewPositionY]) {
            _animationTypes.bits &= ~MLNUIAnimationPositionY;
        }
    }
}

- (void)removeAllAnimations {
    [self.valueAnimations removeAllObjects];
    _animationTypes.bits = 0;
}

- (instancetype)initWithMLNUILuaCore:(MLNUILuaCore *)luaCore type:(InteractiveType)type {
    if (self = [self initWithMLNUILuaCore:luaCore]) {
        [self setupWithType:type];
    }
    return self;
}

- (void)lua_setTouchBlock:(MLNUIBlock *)block {
    self.luaTouchBlock = block;
}

- (MLNUIBlock *)lua_touchBlock {
    return self.luaTouchBlock;
}

@end
