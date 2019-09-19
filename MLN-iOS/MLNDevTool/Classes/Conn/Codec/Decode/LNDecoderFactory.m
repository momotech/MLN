//
//  MLNDecoderFactory.m
//  MLNDebugger
//
//  Created by MoMo on 2019/7/2.
//

#import "LNDecoderFactory.h"
#import "LNDecoderImpl.h"

@implementation LNDecoderFactory

+ (id<LNDecoderProtocol>)getDecoder
{
    return [[LNDecoderImpl alloc] init];
}

@end
