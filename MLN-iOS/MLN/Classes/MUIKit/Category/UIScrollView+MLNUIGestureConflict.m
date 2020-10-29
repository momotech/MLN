//
//  UIScrollView+MLNUIGestureConflict.m
//  ArgoUI
//
//  Created by MOMO on 2020/10/26.
//

#import "UIScrollView+MLNUIGestureConflict.h"
#import "NSObject+MLNUISwizzle.h"
#import <objc/runtime.h>
#import "MLNUIGestureConflictManager.h"

static inline IMP ARGOUI_GetIMP(NSObject *receiver, SEL selector) {
    Class cls = object_getClass(receiver);
    Method method = class_getInstanceMethod(cls, selector);
    return method_getImplementation(method);
}

static BOOL _should_scroll = YES;
static inline void ARGOUI_SetContentOffsetSafely(UIScrollView *scrollView, CGPoint offset) {
    _should_scroll = NO;
    [scrollView setContentOffset:offset];
    _should_scroll = YES;
}

@interface UIScrollView ()
@property (nonatomic, assign) CGPoint argoui_previousContentOffset;
@end

@implementation UIScrollView (MLNUIGestureConflict)

#pragma mark - Public

+ (void)argoui_installScrollViewPanGestureConflictHandler {
   BOOL validClass = [self isSubclassOfClass:[UIScrollView class]];
    NSParameterAssert(validClass);
    if (!validClass) return;

    SEL origin = @selector(setDelegate:);
    SEL swizzle = sel_getUid("argoui_setDelegate:");
    [self mlnui_swizzleInstanceSelector:origin withNewSelector:swizzle newImpBlock:^(__kindof UIScrollView *receiver, id<UIScrollViewDelegate> delegate) {
        [self argoui_hookScrollViewDelegateMethodWithClass:object_getClass(delegate)];
        IMP imp = ARGOUI_GetIMP(receiver, swizzle);
        if (!imp) return;
        ((void(*)(id, SEL, id))imp)(receiver, swizzle, delegate);
    } addOriginImpBlockIfNeeded:^{}];
}

#pragma mark - Private

+ (void)argoui_hookScrollViewDelegateMethodWithClass:(Class)delegateClass {
    SEL origin = @selector(scrollViewDidScroll:);
    SEL swizzle = sel_getUid("argoui_scrollViewDidScroll:");
    [delegateClass mlnui_swizzleInstanceSelector:origin withNewSelector:swizzle newImpBlock:^(id<UIScrollViewDelegate> receiver, __kindof UIScrollView *scrollView) {
        if (!_should_scroll) return;
        IMP imp = ARGOUI_GetIMP(receiver, swizzle);
        ((void(*)(id, SEL, id))imp)(receiver, swizzle, scrollView);
        
        UIScrollView *responder = [MLNUIGestureConflictManager currentGestureResponder];
        if (responder && scrollView != responder) {
            ARGOUI_SetContentOffsetSafely(scrollView, scrollView.argoui_previousContentOffset); // 禁止滚动
        }
        scrollView.argoui_previousContentOffset = scrollView.contentOffset;
        
    } forceAddOriginImpBlock:^{}];
    
    origin = @selector(scrollViewWillBeginDragging:);
    swizzle = sel_getUid("argoui_scrollViewWillBeginDragging:");
    [delegateClass mlnui_swizzleInstanceSelector:origin withNewSelector:swizzle newImpBlock:^(id<UIScrollViewDelegate>receiver, UIScrollView *scrollView) {
        IMP imp = ARGOUI_GetIMP(receiver, swizzle);
        ((void(*)(id, SEL, id))imp)(receiver, swizzle, scrollView);
        [MLNUIGestureConflictManager setCurrentGesture:scrollView.panGestureRecognizer];
    } forceAddOriginImpBlock:^{}];
    
    origin = @selector(scrollViewDidEndDragging:willDecelerate:);
    swizzle = sel_getUid("argoui_scrollViewDidEndDragging:willDecelerate:");
    [delegateClass mlnui_swizzleInstanceSelector:origin withNewSelector:swizzle newImpBlock:^(id<UIScrollViewDelegate>receiver, UIScrollView *scrollView, BOOL decelerate) {
        IMP imp = ARGOUI_GetIMP(receiver, swizzle);
        ((void(*)(id, SEL, id, BOOL))imp)(receiver, swizzle, scrollView, decelerate);
        if (decelerate) return;
        UIScrollView *responder = [MLNUIGestureConflictManager currentGestureResponder];
        if (responder && scrollView == responder) {
            [MLNUIGestureConflictManager setCurrentGesture:nil]; // scrolling end
        }
    } forceAddOriginImpBlock:^{}];
    
    origin = @selector(scrollViewDidEndDecelerating:);
    swizzle = sel_getUid("argoui_scrollViewDidEndDecelerating:");
    [delegateClass mlnui_swizzleInstanceSelector:origin withNewSelector:swizzle newImpBlock:^(id<UIScrollViewDelegate>receiver, UIScrollView *scrollView) {
        IMP imp = ARGOUI_GetIMP(receiver, swizzle);
        ((void(*)(id, SEL, id))imp)(receiver, swizzle, scrollView);
        UIScrollView *responder = [MLNUIGestureConflictManager currentGestureResponder];
        if (responder && scrollView == responder) {
            [MLNUIGestureConflictManager setCurrentGesture:nil]; // scrolling end
        }
    } forceAddOriginImpBlock:^{}];
}

- (void)setArgoui_previousContentOffset:(CGPoint)argoui_previousContentOffset {
    objc_setAssociatedObject(self, @selector(argoui_previousContentOffset), @(argoui_previousContentOffset), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (CGPoint)argoui_previousContentOffset {
    return [objc_getAssociatedObject(self, _cmd) CGPointValue];
}

@end
