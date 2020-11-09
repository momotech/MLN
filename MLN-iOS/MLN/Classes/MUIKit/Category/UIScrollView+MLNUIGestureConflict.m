//
//  UIScrollView+MLNUIGestureConflict.m
//  ArgoUI
//
//  Created by MOMO on 2020/10/26.
//

#import "UIScrollView+MLNUIGestureConflict.h"
#import "NSObject+MLNUISwizzle.h"
#import "MLNUIGestureConflictManager.h"
#import <objc/message.h>

static inline void ARGOUI_CallOriginMethod(Class cls, id receiver, SEL selector, id value) {
    if (cls == [receiver class]) {
        ((void(*)(id, SEL, id))objc_msgSend)(receiver, selector, value);
    } else if (cls == [receiver superclass]) {
        struct objc_super superReceiver = {receiver, cls};
        ((void(*)(struct objc_super *, SEL, id))objc_msgSendSuper)(&superReceiver, selector, value);
    } else {
        NSCParameterAssert(false);
    }
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
        ARGOUI_CallOriginMethod(self, receiver, swizzle, delegate);
    } addOriginImpBlockIfNeeded:^{}];
}

#pragma mark - Private

+ (void)argoui_hookScrollViewDelegateMethodWithClass:(Class)delegateClass {
    SEL origin = @selector(scrollViewDidScroll:);
    SEL swizzle = sel_getUid("argoui_scrollViewDidScroll:");
    [delegateClass mlnui_swizzleInstanceSelector:origin withNewSelector:swizzle newImpBlock:^(id<UIScrollViewDelegate> receiver, __kindof UIScrollView *scrollView) {
        if (!_should_scroll) return;
        ARGOUI_CallOriginMethod(delegateClass, receiver, swizzle, scrollView);
        UIScrollView *responder = [MLNUIGestureConflictManager currentGestureResponder];
        if (responder && scrollView != responder) {
            ARGOUI_SetContentOffsetSafely(scrollView, scrollView.argoui_previousContentOffset); // 禁止滚动
        }
        scrollView.argoui_previousContentOffset = scrollView.contentOffset;
    } addOriginImpBlockIfNeeded:^{}];
    
    origin = @selector(scrollViewWillBeginDragging:);
    swizzle = sel_getUid("argoui_scrollViewWillBeginDragging:");
    [delegateClass mlnui_swizzleInstanceSelector:origin withNewSelector:swizzle newImpBlock:^(id<UIScrollViewDelegate>receiver, UIScrollView *scrollView) {
        ARGOUI_CallOriginMethod(delegateClass, receiver, swizzle, scrollView);
        [MLNUIGestureConflictManager setCurrentGesture:nil];
        [MLNUIGestureConflictManager setCurrentGesture:scrollView.panGestureRecognizer];
    } addOriginImpBlockIfNeeded:^{}];
}

- (void)setArgoui_previousContentOffset:(CGPoint)argoui_previousContentOffset {
    objc_setAssociatedObject(self, @selector(argoui_previousContentOffset), @(argoui_previousContentOffset), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (CGPoint)argoui_previousContentOffset {
    return [objc_getAssociatedObject(self, _cmd) CGPointValue];
}

@end
