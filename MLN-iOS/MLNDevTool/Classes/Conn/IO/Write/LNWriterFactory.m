//
//  MLNWriterFactory.m
//  MLNDebugger
//
//  Created by MoMo on 2019/7/2.
//

#import "LNWriterFactory.h"
#import "LNWirterImpl.h"
#import "LNUSBWriterImpl.h"

@implementation LNWriterFactory

+ (id<LNWriterProtocol>)getWriter
{
    return [[LNWirterImpl alloc] init];
}

+ (id<LNWriterProtocol>)getUSBWriter
{
    return [[LNUSBWriterImpl alloc] init];
}

@end
