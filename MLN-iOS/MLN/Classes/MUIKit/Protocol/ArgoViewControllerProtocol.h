//
//  ArgoViewControllerProtocol.h
//  Pods
//
//  Created by Dongpeng Dai on 2020/8/28.
//

#ifndef ArgoViewControllerProtocol_h
#define ArgoViewControllerProtocol_h
#import "ArgoKitDefinitions.h"
#import "MLNUIViewControllerProtocol.h"

typedef enum : NSUInteger {
    ArgoViewControllerLifeCycleViewDidLoad,
    ArgoViewControllerLifeCycleViewWillAppear,
    ArgoViewControllerLifeCycleViewDidAppear,
    ArgoViewControllerLifeCycleViewWillDisappear,
    ArgoViewControllerLifeCycleViewDidDisappear,
} ArgoViewControllerLifeCycleState;

typedef void(^ArgoViewControllerLifeCycle)(ArgoViewControllerLifeCycleState state);


@class ArgoKitInstance;
@protocol ArgoViewControllerProtocol <MLNUIViewControllerProtocol>

- (void)addLifeCycleListener:(ArgoViewControllerLifeCycle)block;

@end

@protocol ArgoViewControllerDelegate <MLNUIViewControllerDelegate>
@end

#endif /* ArgoViewControllerProtocol_h */
