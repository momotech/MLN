//
//  MLNStaticTest.m
//  MLNCore_Example
//
//  Created by MoMo on 2019/8/1.
//  Copyright © 2019 MoMo. All rights reserved.
//

#import "MLNStaticTest.h"

@implementation MLNStaticTest

+ (NSString *)test:(NSString *)msg
{
    return [NSString stringWithFormat:@"Native_%@", msg];
}

+ (void)hiddenStatusBar:(BOOL)hidden
{
    [[UIApplication sharedApplication] setStatusBarHidden:hidden];
}

+ (void)hiddenNavBar:(BOOL)hidden
{
    UINavigationController *navigationController = [[UIApplication sharedApplication] keyWindow].rootViewController;
    [navigationController setNavigationBarHidden:hidden animated:YES];
}

+ (void)navBarAlpha:(CGFloat)alpha
{
    UINavigationController *navigationController = [[UIApplication sharedApplication] keyWindow].rootViewController;
    navigationController.navigationBar.alpha = alpha;
}

LUA_EXPORT_STATIC_BEGIN(MLNStaticTest)
LUA_EXPORT_STATIC_METHOD(test, "test:", MLNStaticTest)
LUA_EXPORT_STATIC_METHOD(hiddenStatusBar, "hiddenStatusBar:", MLNStaticTest)
LUA_EXPORT_STATIC_METHOD(hiddenNavBar, "hiddenNavBar:", MLNStaticTest)
LUA_EXPORT_STATIC_METHOD(navBarAlpha, "navBarAlpha:", MLNStaticTest)
LUA_EXPORT_STATIC_END(MLNStaticTest, StaticTest, NO, NULL)

@end
