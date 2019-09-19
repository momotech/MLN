//
//  MLNSimulatorTransporter.h
//  MLNDebugger
//
//  Created by MoMo on 2019/8/16.
//

#import <Foundation/Foundation.h>
#import "LNTransporterProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface LNSimulatorTransporter : NSObject <LNTransporterProtocol>

- (instancetype)initWithPort:(int)port;

@end

NS_ASSUME_NONNULL_END
