//
//  MLNDependenceManager.h
//  MLN
//
//  Created by xue.yunqiang on 2022/5/10.
//

#import <Foundation/Foundation.h>
@class MLNKitInstance;
@class MLNDependence;
@protocol MLNDependenceProtocol;
@protocol MLNRecordLogProtocol;
@protocol MLNDependenceErrorDelegate;

extern NSString *kDependenceGroupIdSplit;
extern NSString *kDependenceWidgetIdSplit;
extern NSString *kDependenceFileName;

NS_ASSUME_NONNULL_BEGIN

@interface MLNDependenceManager : NSObject

@property(nonatomic, copy) NSString *dependencePath;

@property(nonatomic, strong) id<MLNRecordLogProtocol> logHandle;

@property(nonatomic, strong) id<MLNDependenceProtocol> handle;

@property(nonatomic, strong) id<MLNDependenceErrorDelegate> errorHandle;

@property(nonatomic, copy)   NSString * projectTag;

+ (instancetype)shareManager;

- (MLNDependence *)loadDependenceWithLuaBundleRootPath:(NSString *)rootPath finished:(void (^)(NSDictionary *))finished;

- (MLNDependence *)loadDependenceWithLuaBundleRootPath:(NSString *)rootPath withHandle:(__nullable id<MLNDependenceProtocol>)handle finished:(void (^)(NSDictionary *))finished;

- (MLNDependence *)loadDependenceWithLuaBundleRootPath:(NSString *)rootPath withHandle:(id<MLNDependenceProtocol>)handle withInstance:(MLNKitInstance *) Instance finished:(void (^)(NSDictionary *))finished;

- (NSDictionary *)prepareDependenceWithLuaBundleRootPath:(NSString *)rootPath;

@end

NS_ASSUME_NONNULL_END
