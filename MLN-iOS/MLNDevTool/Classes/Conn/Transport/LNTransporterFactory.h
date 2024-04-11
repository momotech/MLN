//
//  MLNTransporterFactory.h
//  MLNDebugger
//
//  Created by MoMo on 2019/7/11.
//

#import <UIKit/UIKit.h>
#import "LNTransporterProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface LNTransporterFactory : NSObject

+ (id<LNTransporterProtocol>)getInstance:(NSString *)ip port:(int)port;
+ (id<LNTransporterProtocol>)getInstance:(int)port;

@end

NS_ASSUME_NONNULL_END
