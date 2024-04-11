//
//  MLNUsbTransporter.h
//  MLNDebugger
//
//  Created by MoMo on 2019/7/11.
//

#import <Foundation/Foundation.h>
#import "LNTransporterProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface LNUsbTransporter : NSObject <LNTransporterProtocol>

- (instancetype)initWithPort:(int)port;

@end

NS_ASSUME_NONNULL_END
