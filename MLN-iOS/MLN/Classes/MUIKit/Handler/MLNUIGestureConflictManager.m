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

#define IS_ARGOUI_WINDOW(view) [view isMemberOfClass:[MLNUIWindow class]]

static __weak __kindof UIView *_responder = nil;
static __weak __kindof UIGestureRecognizer *_gesture = nil;

@implementation MLNUIGestureConflictManager

static inline BOOL ARGOUICanAcceptGesture(UIView *view) {
    UIView *current = view;
    do {
        current = current.superview;
        if (current.argo_notDispatch) {
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
        _responder = [self hitTop:gesture.view.superview currentGesture:gesture];
    }
}

+ (void)disableSubviewsInteraction:(BOOL)disable forView:(UIView *)view {
    if (!_gesture) return;
    if (disable) {
        if (_responder && ![view isDescendantOfView:_responder]) { // 从view开始向上找符合currentGesture的手势
            UIView *hit = [self hitTop:view currentGesture:_gesture];
            if (hit) _responder = hit;
        }
    } else {
        if (_responder && [view isDescendantOfView:_responder]) { // 从view开始向下找符合currentGesture的手势
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

#pragma mark - Private

// 向上找
+ (UIView *_Nullable)hitTop:(UIView *)view currentGesture:(UIGestureRecognizer *)currentGesture {
    if (!view || !currentGesture) {
        return nil;
    }
    
    // 当前连续手势为滑动 scrollView 的手势
    if ([currentGesture isKindOfClass:NSClassFromString(@"UIScrollViewPanGestureRecognizer")]) {
        if ([view.actualView isKindOfClass:[UIScrollView class]]) {
            return view.actualView;
        }
        return [self hitTop:view.superview currentGesture:currentGesture];
    }
    
    // 只处理 MLNUIView 及其子类的连续手势
    if ([view isKindOfClass:[MLNUIView class]] == NO) {
        return nil;
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
    
    // 只处理 MLNUIView 及其子类的连续手势
    if ([view isKindOfClass:[MLNUIView class]] == NO) {
        return nil;
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
