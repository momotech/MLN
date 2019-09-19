//
//  MLNTransporterFactory.m
//  MLNDebugger
//
//  Created by MoMo on 2019/7/11.
//

#import "LNTransporterFactory.h"
#import "LNNetTransporter.h"
#import "LNUsbTransporter.h"
#import "LNSimulatorTransporter.h"

@implementation LNTransporterFactory

+ (id<LNTransporterProtocol>)getInstance:(NSString *)ip port:(int)port
{
    return [[LNNetTransporter alloc] initWithIp:ip port:port];
}

+ (id<LNTransporterProtocol>)getInstance:(int)port
{
#if TARGET_IPHONE_SIMULATOR//模拟器
    return [[LNSimulatorTransporter alloc] initWithPort:port];
#elif TARGET_OS_IPHONE//真机
    return [[LNUsbTransporter alloc] initWithPort:port];
#endif
}

@end
