//
//  UIView+MLNPinchGesture.m
//  ArgoUI
//
//  Created by MOMO on 2020/9/29.
//

#import "UIView+MLNUIPinchGesture.h"
#import "UIView+MLNUIKit.h"
#import "MLNUIBLock.h"
#import <objc/runtime.h>

@implementation UIView (MLNUIPinchGesture)

- (void)argo_in_pinchAction:(UIPinchGestureRecognizer *)gesture {
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
        switch (gesture.state) {
            case UIGestureRecognizerStateBegan:
                [self runScaleCallback:self.argo_scaleBeginBlock gestureRecognizer:gesture];
                break;

            case UIGestureRecognizerStateChanged:
                [self runScaleCallback:self.argo_scalingBlock gestureRecognizer:gesture];
                break;

            case UIGestureRecognizerStateEnded:
            case UIGestureRecognizerStateCancelled:
                [self setPinchGestureTouchNumber:0];
                [self runScaleEndCallback:gesture];
                break;
            default:
                break;
        }
    }
}

- (void)runScaleCallback:(MLNUIBlock *)callback gestureRecognizer:(UIPinchGestureRecognizer *)recognizer {
    [self runScaleCallback:callback gestureRecognizer:recognizer params:[self pinchResultWithGestureRecognizer:recognizer]];
}

// 仿照Android,当手势的手指数为1时,执行 scaleEndCallback.
// 返回的坐标就是当前手指的坐标. scaleFactor 为 1
- (void)runScaleEndCallback:(UIPinchGestureRecognizer *)recognizer {
    NSMutableDictionary *params = [[self pinchGestureParams] mutableCopy];
    params[@"factor"] = @(1.0);
    [self runScaleCallback:self.argo_scaleEndBlock gestureRecognizer:recognizer params:params];
}

- (void)runScaleCallback:(MLNUIBlock *)callback gestureRecognizer:(UIPinchGestureRecognizer *)recognizer params:(NSDictionary *)params {
    if (!callback) {
        return;
    }
    [self setPinchGestureParams:params];
    for (id obj in params.allValues) {
        [callback addFloatArgument:[obj floatValue]];
    }
    [callback callIfCan];
}

- (NSDictionary *)pinchResultWithGestureRecognizer:(UIPinchGestureRecognizer *)recognizer {
    CGPoint location = [recognizer locationInView:recognizer.view];
    CGPoint location0 = [recognizer locationOfTouch:0 inView:recognizer.view];
    CGPoint location1 = [recognizer locationOfTouch:1 inView:recognizer.view];
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
