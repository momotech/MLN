//
//  NSMutableData+LuaNative.m
//  MLNDebugger_Example
//
//  Created by MoMo on 2019/6/30.
//  Copyright © 2019 MoMo.xiaoning. All rights reserved.
//

#import "NSMutableData+LuaNative.h"

@implementation NSMutableData (LuaNative)

- (void)appendInt16:(int16_t)val
{
    val = CFSwapInt16HostToBig(val);
    [self appendBytes:&val length:sizeof(int16_t)];
}

- (void)appendUInt16:(uint16_t)val
{
    val = CFSwapInt16HostToBig(val);
    [self appendBytes:&val length:sizeof(uint16_t)];
}

- (void)appendInt32:(int32_t)val
{
    val = CFSwapInt32HostToBig(val);
    [self appendBytes:&val length:sizeof(int32_t)];
}

- (void)appendUInt32:(uint32_t)val
{
    val = CFSwapInt32HostToBig(val);
    [self appendBytes:&val length:sizeof(uint32_t)];
}

- (void)appendByte:(Byte)val
{
    [self appendBytes:&val length:sizeof(Byte)];
}

- (void)appendChar:(char)val
{
    [self appendBytes:&val length:sizeof(char)];
}

@end
