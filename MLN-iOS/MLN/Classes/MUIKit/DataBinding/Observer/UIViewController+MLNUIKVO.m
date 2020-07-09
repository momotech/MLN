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
    Method swizzledMethod = class_getInstanceMethod([self class], @selector(mlnui_viewDidLoad));
    method_exchangeImplementations(origMethod, swizzledMethod);
    
    origMethod = class_getInstanceMethod([self class], @selector(viewWillAppear:));
    swizzledMethod = class_getInstanceMethod([self class], @selector(mlnui_viewWillAppear:));
    method_exchangeImplementations(origMethod, swizzledMethod);
    
    origMethod = class_getInstanceMethod([self class], @selector(viewDidAppear:));
    swizzledMethod = class_getInstanceMethod([self class], @selector(mlnui_viewDidAppear:));
    method_exchangeImplementations(origMethod, swizzledMethod);
    
    origMethod = class_getInstanceMethod([self class], @selector(viewWillDisappear:));
    swizzledMethod = class_getInstanceMethod([self class], @selector(mlnui_viewWillDisappear:));
    method_exchangeImplementations(origMethod, swizzledMethod);
    
    origMethod = class_getInstanceMethod([self class], @selector(viewDidDisappear:));
    swizzledMethod = class_getInstanceMethod([self class], @selector(mlnui_viewDidDisappear:));
    method_exchangeImplementations(origMethod, swizzledMethod);
}

static const void *kMLNUILifeCycleObserverSet = &kMLNUILifeCycleObserverSet;
- (void)mlnui_addLifeCycleObserver:(MLNUIViewControllerLifeCycleObserver)observer
{
    if (!observer) {
        return;
    }
    NSHashTable *set = objc_getAssociatedObject(self, kMLNUILifeCycleObserverSet);
    if (!set) {
        set = [NSHashTable weakObjectsHashTable];
        objc_setAssociatedObject(self, kMLNUILifeCycleObserverSet, set, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    [set addObject:observer];
}

- (void)mlnui_removeLifeCycleObserver:(MLNUIViewControllerLifeCycleObserver)observer
{
    if (!observer) {
        return;
    }
    NSHashTable *set = objc_getAssociatedObject(self, kMLNUILifeCycleObserverSet);
    [set removeObject:observer];
}

- (void)mlnui_removeAllLifeCycleObserver
{
    NSHashTable *set = objc_getAssociatedObject(self, kMLNUILifeCycleObserverSet);
    [set removeAllObjects];
}

- (void)__mlnui_notifyAllLifeCycleObserver:(MLNUIViewControllerLifeCycle)state
{
     NSHashTable *set = objc_getAssociatedObject(self, kMLNUILifeCycleObserverSet);
    for (MLNUIViewControllerLifeCycleObserver observer in set.allObjects) {
        observer(state);
    }
}

#pragma mark - Life Cycle

- (void)mlnui_viewDidLoad
{
    [self mlnui_viewDidLoad];
    [self __mlnui_notifyAllLifeCycleObserver:MLNUIViewControllerLifeCycleViewDidLoad];
}

- (void)mlnui_viewWillAppear:(BOOL)animated
{
    [self mlnui_viewWillAppear:animated];
    [self __mlnui_notifyAllLifeCycleObserver:MLNUIViewControllerLifeCycleViewWillAppear];
}

- (void)mlnui_viewDidAppear:(BOOL)animated
{
    [self mlnui_viewDidAppear:animated];
    [self __mlnui_notifyAllLifeCycleObserver:MLNUIViewControllerLifeCycleViewDidAppear];
}

- (void)mlnui_viewWillDisappear:(BOOL)animated
{
    [self mlnui_viewWillDisappear:animated];
    [self __mlnui_notifyAllLifeCycleObserver:MLNUIViewControllerLifeCycleViewWillAppear];
}

- (void)mlnui_viewDidDisappear:(BOOL)animated
{
    [self mlnui_viewDidDisappear:animated];
    [self __mlnui_notifyAllLifeCycleObserver:MLNUIViewControllerLifeCycleViewDidDisappear];
}

@end
