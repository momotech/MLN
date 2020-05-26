//
//  MLNUINetwork.h
//  CocoaLumberjack
//
//  Created by MoMo on 2018/8/13.
//

#import <Foundation/Foundation.h>
#import "MLNUISystemConst.h"

typedef void(^MLNUINetworkReachabilityStatusBlock)(MLNUINetworkStatus status);

@interface MLNUINetworkReachabilityManager : NSObject

@property (nonatomic, assign, readonly) MLNUINetworkStatus networkStatus;

+ (instancetype)managerForAddress:(const void *)address;
+ (instancetype)manager;
+ (instancetype)sharedManager;
- (void)startMonitoring;
- (void)stopMonitoring;
- (void)addNetworkChangedCallback:(MLNUINetworkReachabilityStatusBlock)callback;
- (void)removeNetworkChangedCallback:(MLNUINetworkReachabilityStatusBlock)callback;

@end
