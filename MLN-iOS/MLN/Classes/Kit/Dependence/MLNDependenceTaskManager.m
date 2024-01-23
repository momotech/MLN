//
//  MLNDependenceTaskManager.m
//  MLN
//
//  Created by xue.yunqiang on 2022/5/10.
//

#import "MLNDependenceTaskManager.h"
#import "MLNDependenceProtocol.h"
#import "MLNDependenceModel.h"
#import "NSString+MLNDependence.h"
#import "MLNKitInstanceHandlersManager.h"

static const void * const kDispatchQueueSpecificKey = &kDispatchQueueSpecificKey;

@interface MLNDependenceTaskManager()

@property(nonatomic, strong) NSMutableDictionary<NSString *, NSArray<MLNDependenceWidgetTask> *> *downloadTaskMap;
@property(nonatomic, strong) NSMutableDictionary<NSString *, NSArray<MLNDependenceWidgetTask> *> *unzipTaskMap;

@end

@implementation MLNDependenceTaskManager
+ (instancetype)shareManager
{
    static MLNDependenceTaskManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[self alloc] init];
    });
    return manager;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _unzipTaskMap = [NSMutableDictionary dictionary];
        _downloadTaskMap = [NSMutableDictionary dictionary];
    }
    return self;
}

-(void)unzipWithGourp:(MLNDependenceGroup *)group withFinish:(void(^)(BOOL)) finished {
    //同个 Project 相同版本的 Group 只有在 MLNDependenceGroupStatusNone 才可解压
    //不同 Project 相同版本的 Group 只会产生一个解压,然后进行回调
    if ([self.delegate respondsToSelector:@selector(unzipWithGourp:withIdentifier:withVersion:withFinish:)]) {
        NSMutableArray<MLNDependenceWidgetTask> *taskMArray = _unzipTaskMap[group.gid];
        if (!taskMArray) {
            taskMArray = [NSMutableArray array];
            _unzipTaskMap[group.gid] = taskMArray;
        }
        if (finished) {
            [taskMArray addObject:finished];
        }
        if (group.status == MLNDependenceGroupStatusNone) {
            group.status = MLNDependenceGroupStatusUnzip;
            [MLNDependenceTaskManager runAsynchronouslyOnQueue:^{
                [self.delegate unzipWithGourp:group.name withIdentifier:group.identifier withVersion:group.version withFinish:^(BOOL finish) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        NSMutableArray<MLNDependenceWidgetTask> *taskMArray = _unzipTaskMap[group.gid];
                        if (taskMArray.count) {
                            for (MLNDependenceWidgetTask task in taskMArray) {
                                task ? task(finish) : nil;
                            }
                        }
                        [_unzipTaskMap removeObjectForKey:group.gid];
                    });
                }];
            }];
        }
    }
}

-(void)downloadWithGourp:(MLNDependenceGroup *)group finished:(void(^)(BOOL)) finished{
    //download group
    //同个 Project 相同版本的 Group 只有在 MLNDependenceGroupStatusNone 才可下载
    //不同 Project 相同版本的 Group 只会产生一个下载,然后进行回调
    if ([self.delegate respondsToSelector:@selector(downloadSourceWithGourp:withIdentifier:withVersion:withFinish:)]) {
        NSMutableArray<MLNDependenceWidgetTask> *taskMArray = _downloadTaskMap[group.gid];
        if (!taskMArray) {
            taskMArray = [NSMutableArray array];
            _downloadTaskMap[group.gid] = taskMArray;
        }
        if (finished) {
            [taskMArray addObject:finished];
        }
        if (group.status == MLNDependenceGroupStatusNone) {
            group.status = MLNDependenceGroupStatusDownloading;
            [self.delegate downloadSourceWithGourp:group.name withIdentifier:group.identifier withVersion:group.version withFinish:^(BOOL finish) {
                NSMutableArray<MLNDependenceWidgetTask> *taskMArray = _downloadTaskMap[group.gid];
                if (taskMArray.count) {
                    for (MLNDependenceWidgetTask task in taskMArray) {
                        task ? task(finish) : nil;
                    }
                }
                [_downloadTaskMap removeObjectForKey:group.gid];
            }];
        }
    }
}

-(BOOL)removeGroupFileGourp:(MLNDependenceGroup *)group {
    BOOL suc = NO;
    if ([self.delegate respondsToSelector:@selector(removeGroupFileWith:withIdentifier:withVersion:)]) {
        suc = [self.delegate removeZipWithGourp:group.name withIdentifier:group.identifier withVersion:group.version];
    }
    return suc;
}

-(BOOL)findedGroupPathWithGroup:(MLNDependenceGroup *)group {
    BOOL suc = NO;
    if ([self.delegate respondsToSelector:@selector(findGroupPathFileWith:withIdentifier:withVersion:)]) {
        suc = [self.delegate findGroupPathFileWith:group.name withIdentifier:group.identifier withVersion:group.version];
    }
    return suc;
}

-(BOOL)findZipWithGourp:(MLNDependenceGroup *)group {
    BOOL finded = NO;
    if ([self.delegate respondsToSelector:@selector(findZipWithGourp:withIdentifier:withVersion:)]) {
        finded = [self.delegate findZipWithGourp:group.name withIdentifier:group.identifier withVersion:group.version];
    }
    return finded;
}

- (MLNDependenceModel *)transfromDependenceModel:(NSDictionary *)dependenceDesDic {
    MLNDependenceModel *model = [[MLNDependenceModel alloc] init];
    [model transfromDicToModel:dependenceDesDic];
    return model;
}

- (void)projectPrePareDependenceWithConfigPath:(NSString *) dependenceConfigPath {
    if ([[NSFileManager defaultManager] fileExistsAtPath:dependenceConfigPath]) {
        NSDictionary *dependenceDic = [dependenceConfigPath dictionaryWithContentFile];
        if (dependenceDic.count) {
            if (!self.delegate) {
                self.delegate = [MLNKitInstanceHandlersManager defaultManager].dependenceHandler;
            }
            MLNDependenceModel *model = [self transfromDependenceModel:dependenceDic];
            if (model.group.count) {
                void (^prePareDependenceBlock)(void) = ^void(void) {
                    __weak __typeof(self) weakSelf = self;
                    for (MLNDependenceGroup *group in model.group) {
                        BOOL hasGroupFile = [self findedGroupPathWithGroup:group];
                        if (hasGroupFile) {
                            break;
                        }
                        BOOL hasGroupFileZip = [self findZipWithGourp:group];
                        if (hasGroupFileZip) {
                            [self unzipWithGourp:group withFinish:^(BOOL) {
                                if ([weakSelf findZipWithGourp:group]) {
                                    [weakSelf removeGroupFileGourp:group];
                                }
                                group.status = MLNDependenceGroupStatusNone;
                            }];
                            break;
                        }
                        [self downloadWithGourp:group finished:^(BOOL suc) {
                            group.status = MLNDependenceGroupStatusNone;
                            if (suc) {
                                [weakSelf unzipWithGourp:group withFinish:^(BOOL) {
                                    if ([weakSelf findZipWithGourp:group]) {
                                        [weakSelf removeGroupFileGourp:group];
                                    }
                                    group.status = MLNDependenceGroupStatusNone;
                                }];
                            }
                        }];
                    }
                };
                if (strcmp(dispatch_queue_get_label(DISPATCH_CURRENT_QUEUE_LABEL), dispatch_queue_get_label(dispatch_get_main_queue())) == 0) {
                    prePareDependenceBlock ? prePareDependenceBlock() : nil;
                } else {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        prePareDependenceBlock ? prePareDependenceBlock() : nil;
                    });
                }
            }
        }
    }
}

#pragma mark - Content
+ (void)runAsynchronouslyOnQueue:(void (^)(void))block {
    if (dispatch_get_specific(kDispatchQueueSpecificKey)) {
        block();
    } else {
        dispatch_async([self contextQueue], block);
    }
}

+ (dispatch_queue_t)contextQueue {
    static dispatch_queue_t _contextQueue = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _contextQueue = dispatch_queue_create("com.mln.dependence.context", DISPATCH_QUEUE_SERIAL);
        dispatch_queue_set_specific(_contextQueue, kDispatchQueueSpecificKey, (__bridge void *)self, NULL);
    });
    return _contextQueue;
}
@end
