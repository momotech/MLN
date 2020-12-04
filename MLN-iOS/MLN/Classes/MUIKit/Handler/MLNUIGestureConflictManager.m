//
//  MLNUIGestureConflictManager.m
//  ArgoUI
//
//  Created by MOMO on 2020/10/26.
//

#import "MLNUIGestureConflictManager.h"
#import "NSObject+MLNUISwizzle.h"
#import <objc/runtime.h>
#import "MLNUIWindow.h"
#import "MLNUIView.h"
#import "UIView+MLNUIKit.h"
#import "MLNUIGestureRecognizer.h"

#define IS_ARGOUI_WINDOW(view) [view isMemberOfClass:[MLNUIWindow class]]

static __weak __kindof UIView *_responder = nil;
static __weak __kindof UIGestureRecognizer *_gesture = nil;

@interface UIGestureRecognizer (MLNUIGesture)

/// 在<MLNUIGestureRecogizerDelegate>中声明，用于替代`state`.
@property (nonatomic, assign) UIGestureRecognizerState argoui_state;

@end

@implementation UIGestureRecognizer (MLNUIGesture)

- (void)setArgoui_state:(UIGestureRecognizerState)state {
    objc_setAssociatedObject(self, @selector(argoui_state), @(state), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIGestureRecognizerState)argoui_state {
    UIGestureRecognizerState newState = [objc_getAssociatedObject(self, _cmd) boolValue];
    if (newState == UIGestureRecognizerStatePossible) {
        return self.state; // return origin state if doesn't set newState.
    }
    return newState;
}

@end

#pragma mark -

@implementation MLNUIGestureConflictManager

static inline BOOL ARGOUICanAcceptGesture(UIView *view) {
    UIView *current = view;
    do {
        current = current.superview;
        if (current.argo_notDispatch ||
            (current.superview.actualView == current && current.superview.argo_notDispatch)) {
            return NO;
        }
    } while (current != nil && current != _responder && !IS_ARGOUI_WINDOW(current));
    return YES;
}

#pragma mark - Public

+ (__kindof UIView *)currentGestureResponder {
    return _responder;
}

+ (void)setCurrentGesture:(UIGestureRecognizer *)gesture {
    _gesture = gesture;
    if (!gesture) {
        _responder = nil;
        return;
    }
    if (_responder == gesture.view) {
        return;
    }
    
    if (!_responder || [gesture.view isDescendantOfView:_responder]) {
        if (ARGOUICanAcceptGesture(gesture.view)) {
            _responder = gesture.view;
        }
    } else {
        // do nothing
    }
    
    if (!_responder) { // give it one more chance
        UIView *superView = gesture.view.superview;
        if (superView.actualView == gesture.view) { // 此情况为：superView=MLNUITableView，gesture.view=MLNUIInnerTableView.
            superView = superView.superview;
        }
        _responder = [self hitTop:superView currentGesture:gesture];
    }
}

+ (void)disableSubviewsInteraction:(BOOL)disable forView:(UIView *)view {
    if (!_gesture) return;
    if (disable) {
        if (_responder && ![view.actualView isDescendantOfView:_responder]) { // 从view开始向上找符合currentGesture的手势
            UIView *hit = [self hitTop:view currentGesture:_gesture];
            if (hit) _responder = hit;
        }
    } else {
        if (_responder && [view.actualView isDescendantOfView:_responder]) { // 从view开始向下找符合currentGesture的手势
            CGPoint touchPoint = [_gesture locationInView:nil];
            UIView *hit = [self hitTest:touchPoint withView:view currentGesture:_gesture];
            if (hit) _responder = hit;
        } else if (!_responder) {
            if (ARGOUICanAcceptGesture(_gesture.view)) {
                _responder = _gesture.view;
            }
        }
    }
}

+ (void)handleResponderGestureActionsWithCurrentGesture:(UIGestureRecognizer *)gesture {
    NSParameterAssert(gesture);
    if (!gesture || !_responder) return;
    __block UIGestureRecognizer<MLNUIGestureRecogizerDelegate> *responderGesture = nil;
    [_responder.gestureRecognizers enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(__kindof UIGestureRecognizer *_Nonnull obj, NSUInteger idx, BOOL *_Nonnull stop) {
        if ([obj isKindOfClass:gesture.class]) { // 如果有多个同类型的手势，应该先响应最后添加的，故倒序遍历
            responderGesture = obj;
            *stop = YES;
        }
    }];
    NSParameterAssert(responderGesture);
    if ([responderGesture respondsToSelector:@selector(argoui_handleTargetActions)]) {
        responderGesture.argoui_state = gesture.state; // 手势冲突时，系统认为应该响应gesture，responderGesture状态为failed，故使用argoui_state
        [responderGesture argoui_handleTargetActions];
        responderGesture.argoui_state = UIGestureRecognizerStatePossible; // reset
    }
}

#pragma mark - Private

// 向上找
+ (UIView *_Nullable)hitTop:(UIView *)view currentGesture:(UIGestureRecognizer *)currentGesture {
    if (IS_ARGOUI_WINDOW(view) || !view || !currentGesture) {
        return nil;
    }
    
    // 当前连续手势为滑动 scrollView 的手势
    if ([currentGesture isKindOfClass:NSClassFromString(@"UIScrollViewPanGestureRecognizer")]) {
        if ([view.actualView isKindOfClass:[UIScrollView class]]) {
            return view.actualView;
        }
        return [self hitTop:view.superview currentGesture:currentGesture];
    }
    
    __block BOOL matchGesture = NO;
    [view.gestureRecognizers enumerateObjectsUsingBlock:^(__kindof UIGestureRecognizer *_Nonnull obj, NSUInteger idx, BOOL *_Nonnull stop) {
        if ([obj isKindOfClass:currentGesture.class]) {
            matchGesture = YES;
            *stop = YES;
        }
    }];
    
    if (matchGesture) {
        return view;
    }
    return [self hitTop:view.superview currentGesture:currentGesture];
}

// 向下找
+ (UIView *_Nullable)hitTest:(CGPoint)point withView:(UIView *)view currentGesture:(UIGestureRecognizer *)currentGesture {
    if (!view || !currentGesture) return nil;
    
    CGRect bounds = [view convertRect:view.bounds toView:nil];
    if (!CGRectContainsPoint(bounds, point)) {
        return nil;
    }
    
    // 当前连续手势为滑动 scrollView 的手势
    if ([currentGesture isKindOfClass:NSClassFromString(@"UIScrollViewPanGestureRecognizer")]) {
        __block UIView *hit = [view.actualView isKindOfClass:[UIScrollView class]] ? view.actualView : nil;
        if (view.argo_notDispatch) {
            return hit;
        }
        [view.subviews enumerateObjectsUsingBlock:^(__kindof UIView *_Nonnull obj, NSUInteger idx, BOOL *_Nonnull stop) {
            UIView *ret = [self hitTest:point withView:obj currentGesture:currentGesture];
            if (!ret) return;
            hit = ret; *stop = YES; // 返回符合条件的叶子视图
        }];
        return hit;
    }
    
    __block BOOL matchGesture = NO;
    [view.gestureRecognizers enumerateObjectsUsingBlock:^(__kindof UIGestureRecognizer *_Nonnull obj, NSUInteger idx, BOOL *_Nonnull stop) {
        if ([obj isKindOfClass:currentGesture.class]) {
            matchGesture = YES;
            *stop = YES;
        }
    }];
    
    __block UIView *hit = matchGesture ? view : nil;
    if (view.argo_notDispatch) {
        return hit;
    }
    [view.subviews enumerateObjectsUsingBlock:^(__kindof UIView *_Nonnull obj, NSUInteger idx, BOOL *_Nonnull stop) {
        UIView *ret = [self hitTest:point withView:obj currentGesture:currentGesture];
        if (!ret) return;
        hit = ret; *stop = YES; // 返回符合条件的叶子视图
    }];
    return hit;
}

@end
