//
//  MLNControlContext.m
//  MMLNua_Example
//
//  Created by MOMO on 2019/11/2.
//  Copyright © 2019年 MOMO. All rights reserved.
//

#import "MLNControlContext.h"

@implementation MLNControlContext

+ (UIViewController *)mln_topViewController {
    //获取根控制器
    UIViewController *rootVC = [[UIApplication sharedApplication].delegate window].rootViewController;
    UIViewController *resultVC;
    resultVC = [self mln_in_topViewController:rootVC];
    while (resultVC.presentedViewController) {
        resultVC = [self mln_in_topViewController:resultVC.presentedViewController];
    }
    return resultVC;
}

+ (UIViewController *)mln_in_topViewController:(UIViewController *)vc {
    if ([vc isKindOfClass:[UINavigationController class]]) {
        return [self mln_in_topViewController:[(UINavigationController *)vc topViewController]];
    } else if ([vc isKindOfClass:[UITabBarController class]]) {
        return [self mln_in_topViewController:[(UITabBarController *)vc selectedViewController]];
    } else {
        return vc;
    }
    return nil;
}

@end
