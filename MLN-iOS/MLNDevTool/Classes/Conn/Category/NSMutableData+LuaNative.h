//
//  NSMutableData+LuaNative.h
//  MLNDebugger_Example
//
//  Created by MoMo on 2019/6/30.
//  Copyright © 2019 MoMo.xiaoning. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSMutableData (LuaNative)

- (void)appendInt16:(int16_t)val;
- (void)appendInt32:(int32_t)val;
- (void)appendUInt32:(uint32_t)val;
- (void)appendByte:(Byte)val;
- (void)appendChar:(char)val;

@end

NS_ASSUME_NONNULL_END
