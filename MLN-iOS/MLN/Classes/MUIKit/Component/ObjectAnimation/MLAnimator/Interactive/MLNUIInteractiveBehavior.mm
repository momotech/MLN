//
//  MLNUIInteractiveBehavior.m
//  ArgoUI
//
//  Created by Dai Dongpeng on 2020/6/18.
//

#import "MLNUIInteractiveBehavior.h"
#import "UIView+MLNUIKit.h"
#import "MLAAnimation.h"
#import "MLAValueAnimation+Interactive.h"

#include "ObjectAnimation.h"
#include "MultiAnimation.h"
#import "MLADefines.h"
#import "MLAAnimatable.h"

@interface MLNUIInteractiveBehavior ()
@property (nonatomic, assign)InteractiveType type;
@property (nonatomic, strong) NSHashTable <MLAValueAnimation *> *valueAnimations;

@property (nonatomic, strong) MLNUITouchCallback touchCallback;

@property (nonatomic, assign) CGPoint beginPoint;
//@property (nonatomic, assign) CGPoint lastPoint;

//@property (nonatomic, assign) CGFloat previousTime;
//@property (nonatomic, assign) CGFloat newSpeed;
//@property (nonatomic, assign) CGFloat oldSpeed;

@end

@implementation MLNUIInteractiveBehavior

- (instancetype)initWithType:(InteractiveType)type {
    if (self = [super init]) {
        _type = type;
        _endDistance = 1999;
        _valueAnimations = [NSHashTable weakObjectsHashTable];
    }
    return self;
}

- (void)setTargetView:(UIView *)targetView {
    [self setupTouchBlock];
    
    [_targetView mlnui_removeTouchBlock:self.touchCallback];
    _targetView = targetView;
    [targetView mlnui_addTouchBlock:self.touchCallback];
}

- (void)setupTouchBlock {
    __block CGFloat newSpeed,oldSpeed = 0;
    __block NSTimeInterval previousTime = 0;
    
    __weak __typeof(self)weakSelf = self;
    self.touchCallback = ^(MLNUITouchType type, UITouch * _Nonnull touch, UIEvent * _Nonnull event) {
        __strong __typeof(weakSelf)self = weakSelf;
        if (!self.enable || !self.targetView.superview || self.endDistance == 0)  return ;
        
        CGPoint p = [touch locationInView:self.targetView.superview];
        CGPoint lastPoint = [touch previousLocationInView:self.targetView.superview];
        
        CGPoint diffLast = CGPointMake(p.x - lastPoint.x, p.y - lastPoint.y);
        CGPoint diffBegin = CGPointMake(p.x - self.beginPoint.x, p.y - self.beginPoint.y);
        CGFloat dis = self.direction == InteractiveDirection_X ? diffBegin.x : diffBegin.y;
        float factor = dis / self.endDistance;
        const float lambda = 0.8f; // the closer to 1 the higher weight to the next touch
        newSpeed = (1.0 - lambda) * oldSpeed + lambda* ((p.y - lastPoint.y)/(touch.timestamp - previousTime));
        oldSpeed = newSpeed;
        
        previousTime = touch.timestamp;
        if (MLNUITouchType_Begin == type) {
            self.beginPoint = p;
            newSpeed = oldSpeed = 0;
            if (self.touchBlock) {
                self.touchBlock(type,p.x, p.y, 0, newSpeed);
            }
            
            for (MLAValueAnimation *ani in self.valueAnimations) {
                [ani updateWithFactor:0 isBegan:YES];
            }
        } else if(MLNUITouchType_Move == type) {
            
            if (self.touchBlock) {
                self.touchBlock(type, p.x, p.y, dis, newSpeed);
            }
            
            if (self.followEnable) {
                CGPoint c = self.targetView.center;
                CGPoint newc = CGPointMake(c.x + diffLast.x, c.y + diffLast.y);
                self.targetView.center = newc;
                NSLog(@"old %@ new center %@",NSStringFromCGPoint(c),NSStringFromCGPoint(newc));
            }
            
            if (!self.overBoundary && (factor > 1 || factor < 0)) {
                self.beginPoint = p;
                return;
            }
            
            NSLog(@" factor %.2f ",factor);
            for (MLAValueAnimation *ani in self.valueAnimations) {
                [ani updateWithFactor:factor isBegan:NO];
            }
        } else {
            if (self.touchBlock) {
                self.touchBlock(type, p.x, p.y, dis, newSpeed);
            }
        }
    };
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
    }
}
- (void)removeAnimation:(MLAValueAnimation *)ani {
    if (ani) {
        [self.valueAnimations removeObject:ani];
    }
}
- (void)removeAllAnimations {
    [self.valueAnimations removeAllObjects];
}
@end
