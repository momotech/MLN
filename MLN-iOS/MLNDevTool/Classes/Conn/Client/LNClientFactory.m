//
//  MLNClientFactory.m
//  MLNDebugger
//
//  Created by MoMo on 2019/7/2.
//

#import "LNClientFactory.h"
#import "LNClientImpl.h"
#import "LNUsbClientImpl.h"
#import "LNTransporterFactory.h"

@implementation LNClientFactory

+ (id<LNClientProtocol>)getClientWithIP:(NSString *)ip port:(int)port listener:(id<LNClientListener>)listener
{
    id<LNTransporterProtocol> netTransporter = [LNTransporterFactory getInstance:ip port:port];
    return [[LNClientImpl alloc] initWithTransporter:netTransporter listener:listener];
}

+ (id<LNClientProtocol>)getClientWithPort:(int)port listener:(id<LNClientListener>)listener
{
    id<LNTransporterProtocol> transporter = [LNTransporterFactory getInstance:port];
    return [[LNUsbClientImpl alloc] initWithTransporter:transporter listener:listener];
}

@end
