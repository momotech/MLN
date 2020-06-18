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
//#include "SpringAnimation.h"
#include "MultiAnimation.h"
//#include "CustomAnimation.h"
//#include "MLAActionEnabler.h"
#import "MLADefines.h"
#import "MLAAnimatable.h"

@interface MLNUIInteractiveBehavior ()
@property (nonatomic, assign)InteractiveType type;

@property (nonatomic, strong) MLNUITouchCallback touchCallback;

@property (nonatomic, assign) CGPoint beginPoint;
@property (nonatomic, assign) CGPoint lastPoint;

@end

@implementation MLNUIInteractiveBehavior

- (instancetype)initWithType:(InteractiveType)type {
    if (self = [super init]) {
        _type = type;
        _endDistance = 1999;
        [self setupTouchBlock];
    }
    return self;
}

- (void)setTargetView:(UIView *)targetView {
    [_targetView mlnui_removeTouchBlock:self.touchCallback];
    _targetView = targetView;
    [targetView mlnui_addTouchBlock:self.touchCallback];
}

- (void)setupTouchBlock {
    __weak __typeof(self)weakSelf = self;
    self.touchCallback = ^(MLNUITouchType type, UITouch * _Nonnull touch, UIEvent * _Nonnull event) {
        __strong __typeof(weakSelf)self = weakSelf;
        if (!self.enable || !self.targetView.superview || self.endDistance == 0)  return ;
        
        if (MLNUITouchType_Begin == type) {
            CGPoint p = [touch locationInView:self.targetView.superview];
            self.beginPoint = p;
            self.lastPoint = p;
            if (self.startBlock) {
                self.startBlock();
            }
            if (self.touchBlock) {
                self.touchBlock(p.x, p.y, 0, 0);
            }
        } else if(MLNUITouchType_Move == type) {
            CGPoint p = [touch locationInView:self.targetView.superview];
            CGPoint diffLast = CGPointMake(p.x - self.lastPoint.x, p.y - self.lastPoint.y);
            CGPoint diffBegin = CGPointMake(p.x - self.beginPoint.x, p.y - self.beginPoint.y);
            CGFloat dis = self.direction == InteractiveDirection_X ? diffBegin.x : diffBegin.y;
            float factor = dis / self.endDistance;
            
            if (self.touchBlock) {
                self.touchBlock(p.x, p.y, dis, 0);
            }
            
            if (!self.overBoundary && (factor > 1 || factor < 0)) {
                return;
            }
            
            if (self.followEnable) {
                CGPoint c = self.targetView.center;
                self.targetView.center = CGPointMake(c.x + diffLast.x, c.y + diffLast.y);
            }
            [self.touchAnimation updateWithFactor:factor];
            self.lastPoint = p;
        } else {
            if (self.finishBlock) {
                self.finishBlock();
            }
        }
    };
}

 
@end
