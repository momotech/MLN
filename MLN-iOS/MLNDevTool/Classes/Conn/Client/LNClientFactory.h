//
//  MLNClientFactory.h
//  MLNDebugger
//
//  Created by MoMo on 2019/7/2.
//

#import <UIKit/UIKit.h>
#import "LNClientProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface LNClientFactory : NSObject

+ (id<LNClientProtocol>)getClientWithPort:(int)port listener:(id<LNClientListener>)listener;
+ (id<LNClientProtocol>)getClientWithIP:(NSString *)ip port:(int)port listener:(id<LNClientListener>)listener;

@end

NS_ASSUME_NONNULL_END
