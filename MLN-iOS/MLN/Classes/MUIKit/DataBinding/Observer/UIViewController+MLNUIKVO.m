//
//  UIViewController+MLNUIKVO.m
//  MLNUI
//
//  Created by tamer on 2020/1/16.
//

#import "UIViewController+MLNUIKVO.h"
#import <objc/runtime.h>

@implementation UIViewController (MLNUIKVO)

+ (void)load
{
    Method origMethod = class_getInstanceMethod([self class], @selector(viewDidLoad));
    Method swizzledMethod = class_getInstanceMethod([self class], @selector(mln_viewDidLoad));
    method_exchangeImplementations(origMethod, swizzledMethod);
    
    origMethod = class_getInstanceMethod([self class], @selector(viewWillAppear:));
    swizzledMethod = class_getInstanceMethod([self class], @selector(mln_viewWillAppear:));
    method_exchangeImplementations(origMethod, swizzledMethod);
    
    origMethod = class_getInstanceMethod([self class], @selector(viewDidAppear:));
    swizzledMethod = class_getInstanceMethod([self class], @selector(mln_viewDidAppear:));
    method_exchangeImplementations(origMethod, swizzledMethod);
    
    origMethod = class_getInstanceMethod([self class], @selector(viewWillDisappear:));
    swizzledMethod = class_getInstanceMethod([self class], @selector(mln_viewWillDisappear:));
    method_exchangeImplementations(origMethod, swizzledMethod);
    
    origMethod = class_getInstanceMethod([self class], @selector(viewDidDisappear:));
    swizzledMethod = class_getInstanceMethod([self class], @selector(mln_viewDidDisappear:));
    method_exchangeImplementations(origMethod, swizzledMethod);
}

static const void *kMLNUILifeCycleObserverSet = &kMLNUILifeCycleObserverSet;
- (void)mln_addLifeCycleObserver:(MLNUIViewControllerLifeCycleObserver)observer
{
    if (!observer) {
        return;
    }
    NSMutableSet *set = objc_getAssociatedObject(self, kMLNUILifeCycleObserverSet);
    if (!set) {
        set = [NSMutableSet set];
        objc_setAssociatedObject(self, kMLNUILifeCycleObserverSet, set, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    [set addObject:observer];
}

- (void)mln_removeLifeCycleObserver:(MLNUIViewControllerLifeCycleObserver)observer
{
    if (!observer) {
        return;
    }
    NSMutableSet *set = objc_getAssociatedObject(self, kMLNUILifeCycleObserverSet);
    [set removeObject:observer];
}

- (void)mln_removeAllLifeCycleObserver
{
    NSMutableSet *set = objc_getAssociatedObject(self, kMLNUILifeCycleObserverSet);
    [set removeAllObjects];
}

- (void)__mln_notifyAllLifeCycleObserver:(MLNUIViewControllerLifeCycle)state
{
     NSMutableSet *set = objc_getAssociatedObject(self, kMLNUILifeCycleObserverSet);
    for (MLNUIViewControllerLifeCycleObserver observer in set) {
        observer(state);
    }
}

#pragma mark - Life Cycle

- (void)mln_viewDidLoad
{
    [self mln_viewDidLoad];
    [self __mln_notifyAllLifeCycleObserver:MLNUIViewControllerLifeCycleViewDidLoad];
}

- (void)mln_viewWillAppear:(BOOL)animated
{
    [self mln_viewWillAppear:animated];
    [self __mln_notifyAllLifeCycleObserver:MLNUIViewControllerLifeCycleViewWillAppear];
}

- (void)mln_viewDidAppear:(BOOL)animated
{
    [self mln_viewDidAppear:animated];
    [self __mln_notifyAllLifeCycleObserver:MLNUIViewControllerLifeCycleViewDidAppear];
}

- (void)mln_viewWillDisappear:(BOOL)animated
{
    [self mln_viewWillDisappear:animated];
    [self __mln_notifyAllLifeCycleObserver:MLNUIViewControllerLifeCycleViewWillAppear];
}

- (void)mln_viewDidDisappear:(BOOL)animated
{
    [self mln_viewDidDisappear:animated];
    [self __mln_notifyAllLifeCycleObserver:MLNUIViewControllerLifeCycleViewDidDisappear];
}

@end
