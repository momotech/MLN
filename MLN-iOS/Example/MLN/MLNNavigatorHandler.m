//
//  MLNNavigatorHandler.m
//  MLN_Example
//
//  Created by MoMo on 2019/9/9.
//  Copyright © 2019 liu.xu_1586. All rights reserved.
//

#import "MLNNavigatorHandler.h"
#import "MLNControlContext.h"
#import "MLNActionManager.h"
#import "MLNActionDefine.h"
#import "MLNActionItem.h"
#import "MLNKitInstanceHandlersManager.h"

@implementation MLNNavigatorHandler

- (void)viewController:(UIViewController<MLNViewControllerProtocol> *)viewController closeSelf:(MLNAnimationAnimType)animType {
    if (viewController.presentingViewController) {
        [viewController dismissViewControllerAnimated:YES completion:nil];
    } else {
        UIViewController *topViewController = [MLNControlContext mln_topViewController];
        [topViewController.navigationController popViewControllerAnimated:YES];
    }
}

- (BOOL)viewController:(UIViewController<MLNViewControllerProtocol> *)viewController closeToLuaPage:(NSString *)pageName animateType:(MLNAnimationAnimType)animType {
    return YES;
}

- (void)viewController:(UIViewController<MLNViewControllerProtocol> *)viewController gotoAndCloseSelf:(NSString *)action params:(NSDictionary *)params animType:(MLNAnimationAnimType)animType {
    NSAssert([action isKindOfClass:[NSString class]], @"goto action type must be String!");
    if (![action isKindOfClass:[NSString class]] || action.length == 0) {
        return;
    }
    UIViewController *selfController = [MLNControlContext mln_topViewController];
    [self viewController:viewController gotoPage:action params:params animType:animType];
    if(selfController.navigationController){
        NSMutableArray *childControllers = [selfController.navigationController.childViewControllers mutableCopy];
        [childControllers removeObject:selfController];
        [selfController.navigationController setViewControllers:childControllers animated:NO];
    }
}

- (void)viewController:(UIViewController<MLNViewControllerProtocol> *)viewController gotoLuaCodePage:(NSDictionary *)param animType:(MLNAnimationAnimType)animType {
    
}

- (void)viewController:(UIViewController<MLNViewControllerProtocol> *)viewController gotoPage:(NSString *)action params:(NSDictionary *)params animType:(MLNAnimationAnimType)animType {
    if (![action isKindOfClass:[NSString class]] || action.length == 0) {
        return;
    }
    NSMutableDictionary *paramsM = [NSMutableDictionary dictionary];
    if ([params isKindOfClass:[NSDictionary class]]) {
        [paramsM addEntriesFromDictionary:params];
    }
    //    保持传参一致性，将动画类型按照key-value形式传递
    [paramsM setValue:@(animType) forKey:kMLNAnimateTypeKey];
    //    读取当前页面的根目录，以实现包内跳转
    NSString *currentBundlePath = viewController.kitInstance.currentBundle.bundlePath;
    if (currentBundlePath) {
        [paramsM setValue:currentBundlePath forKey:kMLNCurrentBundlePath];
    }
    MLNActionItem *actionItem = [[MLNActionItem alloc] initWithAction:action params:paramsM];
    if (actionItem.actionType == nil) {
        actionItem.actionType = kLuaPageAction;
    }
    
    [[MLNActionManager actionManager] handlerGotoWithActionItem:actionItem];
}

@end
