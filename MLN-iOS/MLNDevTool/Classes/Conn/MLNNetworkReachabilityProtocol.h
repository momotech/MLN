//
//  MLNNetworkReachabilityProtocol.h
//  MLN
//
//  Created by MoMo on 2019/9/6.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol MLNNetworkReachabilityProtocol <NSObject>

- (BOOL)isWifi;
- (void)addListener:(void(^)(BOOL isWifi))callback;

@end

NS_ASSUME_NONNULL_END
