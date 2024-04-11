//
//  MLNDevice.m
//  MLN
//
//  Created by MoMo on 2019/8/5.
//

#import "MLNDevice.h"
#include <sys/socket.h>
#include <sys/sysctl.h>
#include <net/if.h>
#include <net/if_dl.h>

@implementation MLNDevice

+ (NSString *)getSysInfoByName:(char *)typeSpecifier
{
    size_t size;
    sysctlbyname(typeSpecifier, NULL, &size, NULL, 0);
    
    char *answer = malloc(size);
    sysctlbyname(typeSpecifier, answer, &size, NULL, 0);
    
    NSString *results = [NSString stringWithCString:answer encoding: NSUTF8StringEncoding];
    
    free(answer);
    return results;
}

+ (NSString *)platform
{
    return [self getSysInfoByName:"hw.machine"];
}

+ (NSString *)hwmodel
{
    return [self getSysInfoByName:"hw.model"];
}

+ (BOOL)isIPHX
{
    static BOOL isX = YES;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        CGFloat height = [UIApplication sharedApplication].statusBarFrame.size.height;
        if (height <= 20) {
            UIWindow *win = [UIApplication sharedApplication].keyWindow;
            isX = win.safeAreaInsets.bottom > 0;
        } else {
            isX = YES;
        }
        
    });
    return isX;
}

+ (BOOL)isiPhoneSimulator
{
    NSString *platform = [self platform];
    if ([platform hasSuffix:@"86"] || [platform isEqual:@"x86_64"])
    {
        BOOL smallerScreen = [[UIScreen mainScreen] bounds].size.width < 768;
        return smallerScreen;
    }
    return NO;
}

+ (BOOL)isiPadSimulator
{
    NSString *platform = [self platform];
    if ([platform hasSuffix:@"86"] || [platform isEqual:@"x86_64"])
    {
        BOOL smallerScreen = [[UIScreen mainScreen] bounds].size.width < 768;
        return !smallerScreen;
    }
    return NO;
}
@end
