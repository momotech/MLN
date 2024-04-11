//
//  MLNHotReloadBundle.m
//  MLNDebugTool
//
//  Created by MoMo on 2019/9/11.
//

#import "MLNHotReloadBundle.h"

@implementation MLNHotReloadBundle

static MLNHotReloadBundle *_hotReloadBundle = nil;
+ (instancetype)hotReloadBundle
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _hotReloadBundle = [MLNHotReloadBundle bundleWithClass:[self class] name:@"MLNDevTool_HotReload"];
    });
    return _hotReloadBundle;
}

@end
