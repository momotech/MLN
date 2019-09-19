//
//  MLNUIBundle.m
//  MLNDebugTool
//
//  Created by MoMo on 2019/9/11.
//

#import "MLNUIBundle.h"

@implementation MLNUIBundle

static MLNUIBundle *_UIBundle = nil;
+ (instancetype)UIBundle
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _UIBundle = [MLNUIBundle bundleWithClass:[self class] name:@"MLNDevTool_UI"];
    });
    return _UIBundle;
}

@end
