//
//  MLNUtilBundle.m
//  MLNDebugTool
//
//  Created by MoMo on 2019/9/11.
//

#import "MLNUtilBundle.h"

@implementation MLNUtilBundle

static MLNUtilBundle *_utilBundle = nil;
+ (instancetype)utilBundle
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _utilBundle = [MLNUtilBundle bundleWithClass:[self class] name:@"MLNDevTool_Util"];
    });
    return _utilBundle;
}

@end
