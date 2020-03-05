//
//  UIViewController+MLNKVO.h
//  MLN
//
//  Created by tamer on 2020/1/16.
//

#import <UIKit/UIKit.h>

typedef enum : NSUInteger {
    MLNViewControllerLifeCycleViewDidLoad,
    MLNViewControllerLifeCycleViewWillAppear,
    MLNViewControllerLifeCycleViewDidAppear,
    MLNViewControllerLifeCycleViewWillDisappear,
    MLNViewControllerLifeCycleViewDidDisappear,
} MLNViewControllerLifeCycle;

NS_ASSUME_NONNULL_BEGIN

typedef void(^MLNViewControllerLifeCycleObserver)(MLNViewControllerLifeCycle state);

@interface UIViewController (MLNKVO)

- (void)mln_addLifeCycleObserver:(MLNViewControllerLifeCycleObserver)observer;
- (void)mln_removeLifeCycleObserver:(MLNViewControllerLifeCycleObserver)observer;
- (void)mln_removeAllLifeCycleObserver;

@end

NS_ASSUME_NONNULL_END
