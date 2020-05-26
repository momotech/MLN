//
//  MLNUIDevice.m
//  MLNUI
//
//  Created by MoMo on 2019/8/5.
//

#import "MLNUIDevice.h"
#include <sys/socket.h>
#include <sys/sysctl.h>
#include <net/if.h>
#include <net/if_dl.h>

@implementation MLNUIDevice

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
    NSString *platform = [self platform];
    if ([platform isEqualToString:@"iPhone10,3"] ||
        [platform isEqualToString:@"iPhone10,6"] ||
        [platform isEqualToString:@"iPhone11,2"] ||
        [platform isEqualToString:@"iPhone11,4"] ||
        [platform isEqualToString:@"iPhone11,6"] ||
        [platform isEqualToString:@"iPhone11,8"] ||
        [platform isEqualToString:@"iPhone12,1"] ||
        [platform isEqualToString:@"iPhone12,3"] ||
        [platform isEqualToString:@"iPhone12,5"] ||
        ([self isiPhoneSimulator] && (CGSizeEqualToSize([[UIScreen mainScreen] bounds].size, CGSizeMake(375.f, 812.f))
                                      || CGSizeEqualToSize([[UIScreen mainScreen] bounds].size, CGSizeMake(414.f, 896.f)))))
        return YES;
    return NO;
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
