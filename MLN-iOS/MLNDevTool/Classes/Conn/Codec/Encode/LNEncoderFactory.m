//
//  MLNEncoderFActory.m
//  MLNDebugger
//
//  Created by MoMo on 2019/7/2.
//

#import "LNEncoderFactory.h"
#import "LNEncoderImpl.h"

@implementation LNEncoderFactory

+ (id<LNEncoderProtocol>)getEncoder
{
    return [[LNEncoderImpl alloc] init];
}

@end
