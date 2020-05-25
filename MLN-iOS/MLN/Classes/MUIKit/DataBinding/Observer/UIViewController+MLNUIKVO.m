//
//  UIViewController+MLNKVO.m
//  MLN
//
//  Created by tamer on 2020/1/16.
//

#import "UIViewController+MLNKVO.h"
#import <objc/runtime.h>

@implementation UIViewController (MLNKVO)

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

static const void *kMLNLifeCycleObserverSet = &kMLNLifeCycleObserverSet;
- (void)mln_addLifeCycleObserver:(MLNViewControllerLifeCycleObserver)observer
{
    if (!observer) {
        return;
    }
    NSMutableSet *set = objc_getAssociatedObject(self, kMLNLifeCycleObserverSet);
    if (!set) {
        set = [NSMutableSet set];
        objc_setAssociatedObject(self, kMLNLifeCycleObserverSet, set, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    [set addObject:observer];
}

- (void)mln_removeLifeCycleObserver:(MLNViewControllerLifeCycleObserver)observer
{
    if (!observer) {
        return;
    }
    NSMutableSet *set = objc_getAssociatedObject(self, kMLNLifeCycleObserverSet);
    [set removeObject:observer];
}

- (void)mln_removeAllLifeCycleObserver
{
    NSMutableSet *set = objc_getAssociatedObject(self, kMLNLifeCycleObserverSet);
    [set removeAllObjects];
}

- (void)__mln_notifyAllLifeCycleObserver:(MLNViewControllerLifeCycle)state
{
     NSMutableSet *set = objc_getAssociatedObject(self, kMLNLifeCycleObserverSet);
    for (MLNViewControllerLifeCycleObserver observer in set) {
        observer(state);
    }
}

#pragma mark - Life Cycle

- (void)mln_viewDidLoad
{
    [self mln_viewDidLoad];
    [self __mln_notifyAllLifeCycleObserver:MLNViewControllerLifeCycleViewDidLoad];
}

- (void)mln_viewWillAppear:(BOOL)animated
{
    [self mln_viewWillAppear:animated];
    [self __mln_notifyAllLifeCycleObserver:MLNViewControllerLifeCycleViewWillAppear];
}

- (void)mln_viewDidAppear:(BOOL)animated
{
    [self mln_viewDidAppear:animated];
    [self __mln_notifyAllLifeCycleObserver:MLNViewControllerLifeCycleViewDidAppear];
}

- (void)mln_viewWillDisappear:(BOOL)animated
{
    [self mln_viewWillDisappear:animated];
    [self __mln_notifyAllLifeCycleObserver:MLNViewControllerLifeCycleViewWillAppear];
}

- (void)mln_viewDidDisappear:(BOOL)animated
{
    [self mln_viewDidDisappear:animated];
    [self __mln_notifyAllLifeCycleObserver:MLNViewControllerLifeCycleViewDidDisappear];
}

@end
