//
//  UIViewController+MLNUIKVO.h
//  MLNUI
//
//  Created by tamer on 2020/1/16.
//

#import <UIKit/UIKit.h>

typedef enum : NSUInteger {
    MLNUIViewControllerLifeCycleViewDidLoad,
    MLNUIViewControllerLifeCycleViewWillAppear,
    MLNUIViewControllerLifeCycleViewDidAppear,
    MLNUIViewControllerLifeCycleViewWillDisappear,
    MLNUIViewControllerLifeCycleViewDidDisappear,
} MLNUIViewControllerLifeCycle;

NS_ASSUME_NONNULL_BEGIN

typedef void(^MLNUIViewControllerLifeCycleObserver)(MLNUIViewControllerLifeCycle state);

@interface UIViewController (MLNUIKVO)

- (void)mlnui_addLifeCycleObserver:(MLNUIViewControllerLifeCycleObserver)observer;
- (void)mlnui_removeLifeCycleObserver:(MLNUIViewControllerLifeCycleObserver)observer;
- (void)mlnui_removeAllLifeCycleObserver;

@end

NS_ASSUME_NONNULL_END
