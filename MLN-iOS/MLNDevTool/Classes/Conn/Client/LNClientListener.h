//
//  MLNClientListener.h
//  MLNDebugger
//
//  Created by MoMo on 2019/7/22.
//

#ifndef LNClientListener_h
#define LNClientListener_h
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol LNClientProtocol;
@protocol LNClientListener <NSObject>

- (void)clientOnConnected:(id<LNClientProtocol>)client;
- (void)clientRequestForCertification:(id<LNClientProtocol>)client;
- (void)client:(id<LNClientProtocol>)client disconnectedWithError:(NSError *)error;

@end

NS_ASSUME_NONNULL_END

#endif /* LNClientListener_h */
