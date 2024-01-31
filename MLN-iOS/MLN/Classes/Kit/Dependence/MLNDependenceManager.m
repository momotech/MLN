//
//  MLNDependenceManager.m
//  MLN
//
//  Created by xue.yunqiang on 2022/5/10.
//

#import "MLNDependenceManager.h"
#import "MLNDependenceProtocol.h"
#import "MLNRecordLogProtocol.h"
#import "MLNKitInstanceHandlersManager.h"
#import "MLNDependence.h"
#import "MLNKitInstance.h"
#import "MLNDebugHeader.h"


NSString *kDependenceGroupIdSplit = @"##";
NSString *kDependenceWidgetIdSplit = @"##";
NSString *kDependenceFileName = @"dependenceConfig.json";

@interface MLNDependenceManager()

@end

@implementation MLNDependenceManager

+ (instancetype)shareManager
{
    static MLNDependenceManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[self alloc] init];
    });
    return manager;
}

- (MLNDependence *)loadDependenceWithLuaBundleRootPath:(NSString *)rootPath finished:(void (^)(NSDictionary *))finished {
    return [self loadDependenceWithLuaBundleRootPath:rootPath withHandle:nil finished:finished];
}

- (MLNDependence *)loadDependenceWithLuaBundleRootPath:(NSString *)rootPath withHandle:(id<MLNDependenceProtocol>)handle withInstance:(MLNKitInstance *) Instance finished:(void (^)(NSDictionary *))finished {
    NSAssert([rootPath length], @"please pass lua project root path!");
    if (!handle) {
        handle = [MLNKitInstanceHandlersManager defaultManager].dependenceHandler;
    }
    
    MLNDependence *dependance = [[MLNDependence alloc] init];
    NSString *debugFlag = Instance.windowExtra[kLuaDebugModeKey];
    if ([debugFlag isEqualToString:kLuaDebugModeHotReload] && handle == nil) {
        finished ? finished(nil) : nil;
        return dependance;
    }
    NSAssert(handle, @"please pass the handle!");
    dependance.delegate = handle;
    dependance.logHandle = self.logHandle;
    dependance.errorHandle = self.errorHandle;
    dependance.projectTag = self.projectTag;
    Instance.dependence = dependance;
    [dependance prepareDependenceWithLuaBundleRootPath:rootPath finished:finished];
    return dependance;
}

- (MLNDependence *)loadDependenceWithLuaBundleRootPath:(NSString *)rootPath withHandle:(id<MLNDependenceProtocol>)handle finished:(void (^)(NSDictionary *))finished {
    NSAssert([rootPath length], @"please pass lua project root path!");
    if (!handle) {
        handle = [MLNKitInstanceHandlersManager defaultManager].dependenceHandler;
    }
    NSAssert(handle, @"please pass the handle!");
    MLNDependence *dependance = [[MLNDependence alloc] init];
    dependance.delegate = handle;
    dependance.logHandle = self.logHandle;
    dependance.errorHandle = self.errorHandle;
    dependance.projectTag = self.projectTag;
    [dependance prepareDependenceWithLuaBundleRootPath:rootPath finished:finished];
    return dependance;
}

- (NSDictionary *)prepareDependenceWithLuaBundleRootPath:(NSString *)rootPath {
    NSAssert([rootPath length], @"please pass lua project root path!");
    MLNDependence *dependance = [[MLNDependence alloc] init];
    dependance.delegate = [MLNKitInstanceHandlersManager defaultManager].dependenceHandler;
    dependance.errorHandle = self.errorHandle;
    dependance.projectTag = self.projectTag;
    return [dependance prepareDependenceWithLuaBundleRootPath:rootPath];
}

@end
