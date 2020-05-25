//
//  MLNUINetwork.m
//  CocoaLumberjack
//
//  Created by MoMo on 2018/8/13.
//

#import "MLNUINetworkReachabilityManager.h"
#import <netinet/in.h>
#import <netinet6/in6.h>
#import <arpa/inet.h>
#import <ifaddrs.h>
#import <netdb.h>
#import <SystemConfiguration/SystemConfiguration.h>
#import "MLNUIHeader.h"

static const void * MLNUINetworkReachabilityRetainCallback(const void *info) {
    return Block_copy(info);
}

static void MLNUINetworkReachabilityReleaseCallback(const void *info) {
    if (info) {
        Block_release(info);
    }
}

static MLNUINetworkStatus MLNUINetworkReachabilityStatusForFlags(SCNetworkReachabilityFlags flags) {
    BOOL isReachable = ((flags & kSCNetworkReachabilityFlagsReachable) != 0);
    BOOL needsConnection = ((flags & kSCNetworkReachabilityFlagsConnectionRequired) != 0);
    BOOL canConnectionAutomatically = (((flags & kSCNetworkReachabilityFlagsConnectionOnDemand ) != 0) || ((flags & kSCNetworkReachabilityFlagsConnectionOnTraffic) != 0));
    BOOL canConnectWithoutUserInteraction = (canConnectionAutomatically && (flags & kSCNetworkReachabilityFlagsInterventionRequired) == 0);
    BOOL isNetworkReachable = (isReachable && (!needsConnection || canConnectWithoutUserInteraction));
    MLNUINetworkStatus status = MLNUINetworkStatusUnknown;
    if (isNetworkReachable == NO) {
        status = MLNUINetworkStatusNoNetwork;
    }
#if    TARGET_OS_IPHONE
    else if ((flags & kSCNetworkReachabilityFlagsIsWWAN) != 0) {
        status = MLNUINetworkStatusWWAN;
    }
#endif
    else {
        status = MLNUINetworkStatusWifi;
    }
    return status;
}

static void MLNUIPostReachabilityStatusChange(SCNetworkReachabilityFlags flags, MLNUINetworkReachabilityStatusBlock block) {
    MLNUINetworkStatus status = MLNUINetworkReachabilityStatusForFlags(flags);
    dispatch_async(dispatch_get_main_queue(), ^{
        if (block) {
            block(status);
        }
    });
}

static void MLNUINetworkReachabilityCallback(SCNetworkReachabilityRef __unused target, SCNetworkReachabilityFlags flags, void *info) {
    MLNUIPostReachabilityStatusChange(flags, (__bridge MLNUINetworkReachabilityStatusBlock)info);
}

@interface MLNUINetworkReachabilityManager ()

@property (readonly, nonatomic, assign) SCNetworkReachabilityRef networkReachability;
@property (nonatomic, strong) NSMutableArray<MLNUINetworkReachabilityStatusBlock> *callbacks;

@end
@implementation MLNUINetworkReachabilityManager

+ (instancetype)sharedManager
{
    static MLNUINetworkReachabilityManager *_sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedManager = [self manager];
    });
    
    return _sharedManager;
}

+ (instancetype)managerForAddress:(const void *)address
{
    SCNetworkReachabilityRef reachability = SCNetworkReachabilityCreateWithAddress(kCFAllocatorDefault, (const struct sockaddr *)address);
    MLNUINetworkReachabilityManager *manager = [[self alloc] initWithReachability:reachability];
    CFRelease(reachability);
    return manager;
}

+ (instancetype)manager
{
#if (defined(__IPHONE_OS_VERSION_MIN_REQUIRED) && __IPHONE_OS_VERSION_MIN_REQUIRED >= 90000) || (defined(__MAC_OS_X_VERSION_MIN_REQUIRED) && __MAC_OS_X_VERSION_MIN_REQUIRED >= 101100)
    struct sockaddr_in6 address;
    bzero(&address, sizeof(address));
    address.sin6_len = sizeof(address);
    address.sin6_family = AF_INET6;
#else
    struct sockaddr_in address;
    bzero(&address, sizeof(address));
    address.sin_len = sizeof(address);
    address.sin_family = AF_INET;
#endif
    return [self managerForAddress:&address];
}

- (instancetype)initWithReachability:(SCNetworkReachabilityRef)reachability
{
    self = [super init];
    if (!self) {
        return nil;
    }
    _networkReachability = CFRetain(reachability);
    _networkStatus = MLNUINetworkStatusUnknown;
    return self;
}

- (void)startMonitoring {
    [self stopMonitoring];
    
    if (!self.networkReachability) {
        return;
    }
    
    __weak __typeof(self)weakSelf = self;
    MLNUINetworkReachabilityStatusBlock callback = ^(MLNUINetworkStatus status) {
        doInMainQueue( __strong __typeof(weakSelf)strongSelf = weakSelf;
                      [strongSelf changeNetworkStatusAndCallback:status];)
    };
    
    SCNetworkReachabilityContext context = {0, (__bridge void *)callback, MLNUINetworkReachabilityRetainCallback, MLNUINetworkReachabilityReleaseCallback, NULL};
    SCNetworkReachabilitySetCallback(self.networkReachability, MLNUINetworkReachabilityCallback, &context);
    SCNetworkReachabilityScheduleWithRunLoop(self.networkReachability, CFRunLoopGetMain(), kCFRunLoopCommonModes);
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0),^{
        SCNetworkReachabilityFlags flags;
        if (SCNetworkReachabilityGetFlags(self.networkReachability, &flags)) {
            MLNUIPostReachabilityStatusChange(flags, callback);
        }
    });
}

- (void)changeNetworkStatusAndCallback:(MLNUINetworkStatus)status
{
    _networkStatus = status;
    for (MLNUINetworkReachabilityStatusBlock callback in self.callbacks) {
        callback(status);
    }
}

- (void)stopMonitoring
{
    if (!self.networkReachability) {
        return;
    }
    SCNetworkReachabilityUnscheduleFromRunLoop(self.networkReachability, CFRunLoopGetMain(), kCFRunLoopCommonModes);
}

- (void)dealloc
{
    [self stopMonitoring];
    if (_networkReachability != NULL) {
        CFRelease(_networkReachability);
    }
}

- (void)addNetworkChangedCallback:(MLNUINetworkReachabilityStatusBlock)callback
{
    if (!callback) {
        return;
    }
    if (!self.callbacks) {
        self.callbacks = [NSMutableArray array];
    }
    [self.callbacks addObject:callback];
}

- (void)removeNetworkChangedCallback:(MLNUINetworkReachabilityStatusBlock)callback
{
    if (!callback) {
        return;
    }
    [self.callbacks removeObject:callback];
}

@end
