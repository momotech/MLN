//
//  MLNNavigatorHandler.m
//  MLN_Example
//
//  Created by MoMo on 2019/9/9.
//  Copyright © 2019 liu.xu_1586. All rights reserved.
//

#import "MLNNavigatorHandler.h"

@implementation MLNNavigatorHandler

- (void)viewController:(UIViewController<MLNViewControllerProtocol> *)viewController closeSelf:(MLNAnimationAnimType)animType {
    [viewController dismissViewControllerAnimated:YES completion:nil];
}

- (BOOL)viewController:(UIViewController<MLNViewControllerProtocol> *)viewController closeToLuaPage:(NSString *)pageName animateType:(MLNAnimationAnimType)animType {
    return NO;
}

- (void)viewController:(UIViewController<MLNViewControllerProtocol> *)viewController gotoAndCloseSelf:(NSString *)action params:(NSDictionary *)params animType:(MLNAnimationAnimType)animType {
    
}

- (void)viewController:(UIViewController<MLNViewControllerProtocol> *)viewController gotoLuaCodePage:(NSDictionary *)param animType:(MLNAnimationAnimType)animType {
    
}

- (void)viewController:(UIViewController<MLNViewControllerProtocol> *)viewController gotoPage:(NSString *)action params:(NSDictionary *)params animType:(MLNAnimationAnimType)animType {
    
}

@end
