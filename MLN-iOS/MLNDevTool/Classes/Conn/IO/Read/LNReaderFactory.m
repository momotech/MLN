//
//  MLNREaderFactory.m
//  MLNDebugger
//
//  Created by MoMo on 2019/7/2.
//

#import "LNReaderFactory.h"
#import "LNReaderImpl.h"

@implementation LNReaderFactory

+ (id<LNReaderProtocol>)getReader
{
    return [[LNReaderImpl alloc] init];
}

@end
