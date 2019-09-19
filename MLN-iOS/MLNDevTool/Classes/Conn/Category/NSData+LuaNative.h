//
//  NSData+LuaNative.h
//  MLNDebugger
//
//  Created by MoMo on 2019/7/2.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSData (LuaNative)

- (Byte)getByte:(int)loc;
- (int32_t)getInt32:(int)loc;
- (int16_t)getInt16:(int)loc;

@end

NS_ASSUME_NONNULL_END
