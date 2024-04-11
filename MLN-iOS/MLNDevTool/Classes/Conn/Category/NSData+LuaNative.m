//
//  NSData+LuaNative.m
//  MLNDebugger
//
//  Created by MoMo on 2019/7/2.
//

#import "NSData+LuaNative.h"

@implementation NSData (LuaNative)

- (Byte)getByte:(int)loc
{
    Byte value = 0;
    [self getBytes:&value range:NSMakeRange(loc,1)];
    return value;
}

- (int)getInt32:(int)loc
{
    NSData *typeData = [self subdataWithRange:NSMakeRange(loc, 4)];
    int32_t value = CFSwapInt32BigToHost(*(int*)([typeData bytes]));
    return value;
}

- (int16_t)getInt16:(int)loc
{
    NSData *typeData = [self subdataWithRange:NSMakeRange(loc, 2)];
    int16_t value = CFSwapInt16BigToHost(*(int*)([typeData bytes]));
    return value;
}

@end
