//
//  MLNOfflineBundle.m
//  MLNDevTool
//
//  Created by MoMo on 2019/9/13.
//

#import "MLNOfflineBundle.h"

@implementation MLNOfflineBundle

static MLNOfflineBundle *_offlineBundle = nil;
+ (instancetype)offlineBundle
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _offlineBundle = [MLNOfflineBundle bundleWithClass:[self class] name:@"MLNDevTool_Offline"];
    });
    return _offlineBundle;
}

@end
