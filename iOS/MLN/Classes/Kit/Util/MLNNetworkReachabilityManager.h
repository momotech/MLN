//
//  MLNNetwork.h
//  CocoaLumberjack
//
//  Created by MoMo on 2018/8/13.
//

#import <Foundation/Foundation.h>
#import "MLNSystemConst.h"

typedef void(^MLNNetworkReachabilityStatusBlock)(MLNNetworkStatus status);

@interface MLNNetworkReachabilityManager : NSObject

@property (nonatomic, assign, readonly) MLNNetworkStatus networkStatus;

+ (instancetype)managerForAddress:(const void *)address;
+ (instancetype)manager;
+ (instancetype)sharedManager;
- (void)startMonitoring;
- (void)stopMonitoring;
- (void)addNetworkChangedCallback:(MLNNetworkReachabilityStatusBlock)callback;
- (void)removeNetworkChangedCallback:(MLNNetworkReachabilityStatusBlock)callback;

@end
