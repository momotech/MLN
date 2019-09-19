//
//  MLNNetTransporter.h
//  MLNDebugger
//
//  Created by MoMo on 2019/7/11.
//

#import <UIKit/UIKit.h>
#import "LNTransporterProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface LNNetTransporter : NSObject <LNTransporterProtocol>

- (instancetype)initWithIp:(NSString *)ip port:(int)port;

@end

NS_ASSUME_NONNULL_END
