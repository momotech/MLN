//
//  UIView+MLNPinchGesture.m
//  ArgoUI
//
//  Created by MOMO on 2020/9/29.
//

#import "UIView+MLNUIPinchGesture.h"
#import "UIView+MLNUIKit.h"
#import "MLNUIBlock.h"
#import <objc/runtime.h>
#import "MLNUIGestureConflictManager.h"
#import "MLNUIPinchGestureRecognizer.h"

@interface UIView ()

@property (nonatomic, strong) MLNUIBlock *argo_scaleBeginBlock;
@property (nonatomic, strong) MLNUIBlock *argo_scalingBlock;
@property (nonatomic, strong) MLNUIBlock *argo_scaleEndBlock;
@property (nonatomic, strong) MLNUIPinchGestureRecognizer *argo_pinchGesture;

@end

@implementation UIView (MLNUIPinchGesture)

#pragma mark - Export To Lua

- (void)argo_addScaleBeginCallback:(MLNUIBlock *)argo_scaleBeginBlock {
    [self argo_in_addPinchGestureIfNeed];
    self.argo_scaleBeginBlock = argo_scaleBeginBlock;
}

- (void)argo_addScalingCallback:(MLNUIBlock *)argo_scalingBlock {
    [self argo_in_addPinchGestureIfNeed];
    self.argo_scalingBlock = argo_scalingBlock;
}

- (void)argo_addScaleEndCallback:(MLNUIBlock *)argo_scaleEndBlock {
    [self argo_in_addPinchGestureIfNeed];
    self.argo_scaleEndBlock = argo_scaleEndBlock;
}

#pragma mark - Private

- (void)argo_in_addPinchGestureIfNeed {
    MLNUIPinchGestureRecognizer *gesture = self.argo_pinchGesture;
    if (!gesture && [self luaui_canPinch]) {
        self.mlnui_needRender = YES;
        gesture = [[MLNUIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(argo_preparePinchGestureAction:)];
        [self addGestureRecognizer:gesture];
        gesture.cancelsTouchesInView = NO;
        self.argo_pinchGesture = gesture;
    }
}

- (void)argo_preparePinchGestureAction:(MLNUIPinchGestureRecognizer *)gesture {
    if (gesture.argoui_state == UIGestureRecognizerStateBegan) {
        [MLNUIGestureConflictManager setCurrentGesture:gesture];
    }
    UIView *responder = [MLNUIGestureConflictManager currentGestureResponder];
    if (!responder) return;
    [responder argo_handlePinchGestureAction:gesture]; // 直接处理responder的action
}

- (void)argo_handlePinchGestureAction:(MLNUIPinchGestureRecognizer *)gesture {
    if (!self.luaui_enable) {
        return;
    }
    NSInteger lastTouchNumber = [self pinchGestureTouchNumber];
    // lastTouchNumber != 0: 不是 realBegin 状态
    // gesture.numberOfTouches != lastTouchNumber: 手指个数发生了变化
    if (lastTouchNumber != 0 && gesture.numberOfTouches != lastTouchNumber) {
        if (lastTouchNumber == 1) {
            [self runScaleCallback:self.argo_scaleBeginBlock gestureRecognizer:gesture];
        } else {
            [self runScaleEndCallback:gesture];
        }
        [self setPinchGestureTouchNumber:gesture.numberOfTouches];
        
    } else if (gesture.numberOfTouches == 2) {
        [self setPinchGestureTouchNumber:gesture.numberOfTouches];
        switch (gesture.argoui_state) {
            case UIGestureRecognizerStateBegan:
                [self runScaleCallback:self.argo_scaleBeginBlock gestureRecognizer:gesture];
                break;

            case UIGestureRecognizerStateChanged:
                [self runScaleCallback:self.argo_scalingBlock gestureRecognizer:gesture];
                break;

            case UIGestureRecognizerStateEnded:
            case UIGestureRecognizerStateCancelled:
            case UIGestureRecognizerStateFailed:
                [MLNUIGestureConflictManager setCurrentGesture:nil];
                [self setPinchGestureTouchNumber:0];
                [self runScaleEndCallback:gesture];
                break;
            default:
                break;
        }
    }
}

- (void)runScaleCallback:(MLNUIBlock *)callback gestureRecognizer:(MLNUIPinchGestureRecognizer *)recognizer {
    [self runScaleCallback:callback gestureRecognizer:recognizer params:[self pinchResultWithGestureRecognizer:recognizer]];
}

// 仿照Android,当手势的手指数为1时,执行 scaleEndCallback.
// 返回的坐标就是当前手指的坐标. scaleFactor 为 1
- (void)runScaleEndCallback:(MLNUIPinchGestureRecognizer *)recognizer {
    NSMutableDictionary *params = [[self pinchGestureParams] mutableCopy];
    params[@"factor"] = @(1.0);
    [self runScaleCallback:self.argo_scaleEndBlock gestureRecognizer:recognizer params:params];
}

- (void)runScaleCallback:(MLNUIBlock *)callback gestureRecognizer:(MLNUIPinchGestureRecognizer *)recognizer params:(NSDictionary *)params {
    if (!callback) {
        return;
    }
    [self setPinchGestureParams:params];
    for (id obj in params.allValues) {
        [callback addFloatArgument:[obj floatValue]];
    }
    [callback callIfCan];
}

- (NSDictionary *)pinchResultWithGestureRecognizer:(MLNUIPinchGestureRecognizer *)recognizer {
    CGPoint location = [recognizer locationInView:self];
    CGPoint location0 = [recognizer locationOfTouch:0 inView:self];
    CGPoint location1 = [recognizer locationOfTouch:1 inView:self];
    CGFloat spanX = fabs(location0.x - location1.x);
    CGFloat spanY = fabs(location0.y - location1.y);
    CGFloat span = sqrt(pow(spanX, 2) + pow(spanY, 2));
    
    NSMutableDictionary *resultTouch = [[NSMutableDictionary alloc] initWithCapacity:6];
    resultTouch[@"focusX"] = @(location.x);
    resultTouch[@"focusY"] = @(location.y);
    resultTouch[@"span"] = @(span);
    resultTouch[@"spanX"] = @(spanX);
    resultTouch[@"spanY"] = @(spanY);
    resultTouch[@"factor"] = @(recognizer.scale);
    
    return resultTouch;
}

#pragma mark - Property

static const void *kLuaScaleBeginBlock = &kLuaScaleBeginBlock;
- (void)setArgo_scaleBeginBlock:(MLNUIBlock *)argo_scaleBeginBlock {
    objc_setAssociatedObject(self, kLuaScaleBeginBlock, argo_scaleBeginBlock, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (MLNUIBlock *)argo_scaleBeginBlock {
    return objc_getAssociatedObject(self, kLuaScaleBeginBlock);
}

static const void *kLuaScalingBlock = &kLuaScalingBlock;
- (void)setArgo_scalingBlock:(MLNUIBlock *)argo_scalingBlock {
    objc_setAssociatedObject(self, kLuaScalingBlock, argo_scalingBlock, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (MLNUIBlock *)argo_scalingBlock {
    return objc_getAssociatedObject(self, kLuaScalingBlock);
}

static const void *kLuaScaleEndBlock = &kLuaScaleEndBlock;
- (void)setArgo_scaleEndBlock:(MLNUIBlock *)argo_scaleEndBlock {
    objc_setAssociatedObject(self, kLuaScaleEndBlock, argo_scaleEndBlock, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (MLNUIBlock *)argo_scaleEndBlock {
    return objc_getAssociatedObject(self, kLuaScaleEndBlock);
}

- (void)setArgo_pinchGesture:(MLNUIPinchGestureRecognizer *)gesture {
    objc_setAssociatedObject(self, @selector(argo_pinchGesture), gesture, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (MLNUIPinchGestureRecognizer *)argo_pinchGesture {
    return objc_getAssociatedObject(self, _cmd);
}

static const void *kLuaPinchGestureParams = &kLuaPinchGestureParams;
- (void)setPinchGestureParams:(NSDictionary *)params {
    objc_setAssociatedObject(self, kLuaPinchGestureParams, params, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSDictionary *)pinchGestureParams {
    return objc_getAssociatedObject(self, kLuaPinchGestureParams);
}

static const void *kLuaPinchGestureLastTouchNumber = &kLuaPinchGestureLastTouchNumber;
- (void)setPinchGestureTouchNumber:(NSInteger)numberOfTouch {
    objc_setAssociatedObject(self, kLuaPinchGestureLastTouchNumber, @(numberOfTouch), OBJC_ASSOCIATION_ASSIGN);
}

- (NSInteger)pinchGestureTouchNumber {
    return [objc_getAssociatedObject(self, kLuaPinchGestureLastTouchNumber) integerValue];
}
@end
