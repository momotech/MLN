//
//  MLNDependence.m
//  MLN
//
//  Created by xue.yunqiang on 2022/5/5.
//

#import "MLNDependence.h"
#import "NSString+MLNDependence.h"
#import "MLNDependenceModel.h"
#import "MLNWidgetCacheManager.h"
#import "MLNDependenceTaskManager.h"
#import "MLNDependenceManager.h"

#define MLNDependenceFilePath [self.pRootPath stringByAppendingPathComponent:kDependenceFileName]

@interface MLNDependence()

@property (nonatomic, copy) NSString *pRootPath;
@property (nonatomic, strong) MLNDependenceModel *dependenceModel;
@property (nonatomic, strong) NSMutableDictionary *unzipTask;
@property (nonatomic, strong) NSMutableDictionary *downloadTask;
@property (nonatomic, strong) NSMutableDictionary<NSString *, NSDictionary *> *groupsConfig;
@property (nonatomic, copy) void (^searchWidgtBlock)(MLNDependenceWidget *);
@property (nonatomic, weak) MLNDependenceTaskManager *taskManager;
@end

@implementation MLNDependence

- (NSDictionary *)prepareDependenceWithLuaBundleRootPath:(NSString *)rootPath {
    self.pRootPath = rootPath;
    self.taskManager = [MLNDependenceTaskManager shareManager];
    self.taskManager.delegate = self.delegate;
    //cheack file
    if (![self hasDependenceFile]) {
        return nil;
    }
    //parase denpendence description file
    NSDictionary *dependenceDesDic = [MLNDependenceFilePath dictionaryWithContentFile];
    if (!dependenceDesDic.count) {
        return nil;
    }
    
    //transfrom denpendence model
    self.dependenceModel = [self.taskManager transfromDependenceModel:dependenceDesDic];
    
    //local has target group
    int resultCount = 0;
    for (MLNDependenceGroup *group in self.dependenceModel.group) {
        BOOL finded = [self.taskManager findedGroupPathWithGroup:group];
        if (!finded) {
            return nil;
        }
        resultCount += [[group allMap] count];
    }
    if (!resultCount) {
        return nil;
    }
    NSMutableDictionary *result = [NSMutableDictionary dictionaryWithCapacity:resultCount];
    for (MLNDependenceGroup *group in self.dependenceModel.group) {
        NSMutableDictionary *result = [NSMutableDictionary dictionaryWithCapacity:group.allMap.count];
        NSArray *widgets = [[group allMap] allKeys];
        for (NSString *widgetKey in widgets) {
            MLNDependenceWidget *widget = [group allMap][widgetKey];
            NSString *wp = [self findLocalWidgetWithGroup:group withWidget:widget];
            if (wp.length) {
                BOOL safe = [self checkWidgetFileWithWidget:widget withPath:wp];
                if (safe) {
                    result[widget.name] = wp;
                } else {
                    return nil;
                }
            } else {
                return nil;
            }
        }
    }
    if (result.count == resultCount) {
        return result;
    }
    return nil;
}

- (void)prepareDependenceWithLuaBundleRootPath:(NSString *)rootPath finished:(void (^)(NSDictionary *))finished {
    double start =  CFAbsoluteTimeGetCurrent()*1000;
    self.pRootPath = rootPath;
    self.taskManager = [MLNDependenceTaskManager shareManager];
    self.taskManager.delegate = self.delegate;
    //cheack file
    if (![self hasDependenceFile]) {
        finished ? finished(nil) : nil;
        return;
    }
    //parase denpendence description file
    NSDictionary *dependenceDesDic = [MLNDependenceFilePath dictionaryWithContentFile];
    if (!dependenceDesDic.count) {
        finished ? finished(nil) : nil;
        return;
    }
    
    //transfrom denpendence model
    self.dependenceModel = [self.taskManager transfromDependenceModel:dependenceDesDic];
    
    //collect all widget path
    int resultCount = 0;
    for (MLNDependenceGroup *group in self.dependenceModel.group) {
        resultCount += [[group allMap] count];
    }
    
    if (!resultCount) {
        finished ? finished(nil) : nil;
        return;
    }
    __block NSMutableDictionary *result = [NSMutableDictionary dictionaryWithCapacity:resultCount];
    __block int groupCallbackCount = 0;
    __block NSUInteger groupCount = self.dependenceModel.group.count;
    __weak typeof(self) weakSelf = self;
    for (MLNDependenceGroup *group in self.dependenceModel.group) {
        [self log:@"--MLN Dependence start--"];
        [self groupPrepareWith:group finish:^{
            [self groupScrPath:group];
            [weakSelf collectGroupAllWidgetPathWith:group lastWidget:nil finish:^(NSDictionary *res) {
                [self log:[NSString stringWithFormat:@"end check group: %@",group.gid]];
                groupCallbackCount += 1;
                [result addEntriesFromDictionary:res];
                if (groupCallbackCount == groupCount) {
                    weakSelf.searchWidgtBlock = nil;
                    if (result.count != resultCount) {
                        [weakSelf dependenceWithGroup:nil withWidget:nil error:[weakSelf defultError]];
                    } else {
                        double end = CFAbsoluteTimeGetCurrent()*1000;
                        NSString *allDoneLog = [NSString stringWithFormat:@"%@ load depen done:\n%f ms",weakSelf.projectTag ,(end-start)];
                        [weakSelf log:allDoneLog];
                        finished ? finished(result) : nil;
                    }
                    [weakSelf log:@"--MLN Dependence end--"];
                }
            }];
        }];
    }
}

- (NSString *)groupScrPath:(MLNDependenceGroup *)group {
    if (!self.groupsConfig) {
        self.groupsConfig = [NSMutableDictionary dictionary];
    }
    NSString *groupScrSource = self.groupsConfig[group.gid];
    if (!groupScrSource.length) {
        if ([self.delegate respondsToSelector:@selector(findGroupPathFileWith:withIdentifier:withVersion:)]) {
            NSString *groupPath = [self.delegate findGroupPathFileWith:group.name withIdentifier:group.identifier withVersion:group.version];
            if (groupPath.length) {
                NSString *configPath = [groupPath stringByAppendingPathComponent:@"config.json"];
                NSDictionary *config = [configPath dictionaryWithContentFile];
                NSString* middlePath = config[@"url"];
                if (middlePath.length) {
                    groupScrSource = [[groupPath stringByAppendingPathComponent:middlePath] stringByAppendingPathComponent:@"sources"];
                    self.groupsConfig[group.gid] = groupScrSource;
                }
            }
        }
    }
    return groupScrSource;
}

-(void)dealloc {
    NSLog(@"%s",__func__);
}

# pragma mark - Group
-(void)groupPrepareWith:(MLNDependenceGroup *)group
                 finish:(void (^)(void))finished {
    MLNDependenceTaskManager *taskManager = [MLNDependenceTaskManager shareManager];
    [self log:[NSString stringWithFormat:@"%@ group prepare",group.gid]];
    BOOL hasZip = [taskManager findZipWithGourp:group];
    if (hasZip) {//上次解压失败
        [self log:[NSString stringWithFormat:@"%@ hasZip",group.gid]];
        [self log:[NSString stringWithFormat:@"%@ unzip %s",group.gid,__func__]];
        [taskManager unzipWithGourp:group withFinish:^(BOOL suc) {
            group.status = MLNDependenceGroupStatusNone;
            if (suc) {
                [self log:[NSString stringWithFormat:@"%@ unzip suc %s",group.gid,__func__]];
                BOOL removeSuc = [taskManager removeGroupFileGourp:group];
                if (removeSuc) {
                    [self log:[NSString stringWithFormat:@"%@ remove group zip suc%s",group.gid,__func__]];
                } else {
                    [self warningLog:[NSString stringWithFormat:@"%@ remove group zip fail%s",group.gid,__func__]];
                }
                finished ? finished() : nil;
            } else {
                [self log:[NSString stringWithFormat:@"%@ unzip fail %s",group.gid,__func__]];
                BOOL removeSuc = [taskManager removeGroupFileGourp:group];
                [self log:[NSString stringWithFormat:@"%@ remove group %s",group.gid,__func__]];
                if (removeSuc) {
                    [self log:[NSString stringWithFormat:@"%@ remove suc %s",group.gid,__func__]];
                    [self log:[NSString stringWithFormat:@"%@ download %s",group.gid,__func__]];
                    [taskManager downloadWithGourp:group finished:^(BOOL downloadSuc) {
                        group.status = MLNDependenceGroupStatusNone;
                        if (downloadSuc) {
                            [self log:[NSString stringWithFormat:@"%@ download suc %s",group.gid,__func__]];
                            [self log:[NSString stringWithFormat:@"%@ unzip %s",group.gid,__func__]];
                            [taskManager unzipWithGourp:group withFinish:^(BOOL unzipSuc) {
                                group.status = MLNDependenceGroupStatusNone;
                                if (unzipSuc) {
                                    [self log:[NSString stringWithFormat:@"%@ unzip suc %s",group.gid,__func__]];
                                    BOOL removeSuc = [taskManager removeGroupFileGourp:group];
                                    if (removeSuc) {
                                        [self log:[NSString stringWithFormat:@"%@ remove group zip suc%s",group.gid,__func__]];
                                    } else {
                                        [self warningLog:[NSString stringWithFormat:@"%@ remove group zip fail%s",group.gid,__func__]];
                                    }
                                    finished ? finished() : nil;
                                } else {
                                    [self dependenceWithGroup:group withWidget:nil error:[self unzipError]];
                                }
                            }];
                        } else {
                            [self dependenceWithGroup:group withWidget:nil error:[self downloadError]];
                        }
                    }];
                } else {
                    [self dependenceWithGroup:group withWidget:nil error:[self removeFileError]];
                }
            }
        }];
    } else {
        BOOL finded = [taskManager findedGroupPathWithGroup:group];
        if (finded) {
            finished ? finished() : nil;
        } else {
            [self log:[NSString stringWithFormat:@"%@ dont find download %s",group.gid,__func__]];
            [taskManager downloadWithGourp:group finished:^(BOOL downloadSuc) {
                group.status = MLNDependenceGroupStatusNone;
                if (downloadSuc) {
                    [self log:[NSString stringWithFormat:@"%@ download suc %s",group.gid,__func__]];
                    [taskManager unzipWithGourp:group withFinish:^(BOOL unzipSuc) {
                        group.status = MLNDependenceGroupStatusNone;
                        if (unzipSuc) {
                            [self log:[NSString stringWithFormat:@"%@ unzip suc %s",group.gid,__func__]];
                            BOOL removeSuc = [taskManager removeGroupFileGourp:group];
                            if (removeSuc) {
                                [self log:[NSString stringWithFormat:@"%@ remove group zip suc %s",group.gid,__func__]];
                            } else {
                                [self warningLog:[NSString stringWithFormat:@"%@ remove group zip fail %s",group.gid,__func__]];
                            }
                            finished ? finished() : nil;
                        } else {
                            [self dependenceWithGroup:group withWidget:nil error:[self unzipError]];
                        }
                    }];
                } else {
                    [self dependenceWithGroup:group withWidget:nil error:[self downloadError]];
                }
            }];
        }
    }
}

-(void)collectGroupAllWidgetPathWith:(MLNDependenceGroup *)group
                          lastWidget:(MLNDependenceWidget *)lastWidget
                              finish:(void (^)(NSDictionary *))finished {
    [self log:[NSString stringWithFormat:@"start check group: %@",group.gid]];
    NSMutableDictionary *result = [NSMutableDictionary dictionaryWithCapacity:group.allMap.count];
    NSArray *widgets = [[group allMap] allKeys];
    __block int widgetCallBackCount = 0;
    if (group.retryCount > 0) {
        __block int cIndex= 0;
        __block MLNDependenceWidget *headWidget = [group allMap][widgets[cIndex]];;
        __weak __typeof(self) weakSelf = self;
        void (^searchWidgtBlock)(MLNDependenceWidget *) = ^void(MLNDependenceWidget * _Nullable widget) {
            if (cIndex < widgets.count && widget == nil) {
                widget = [group allMap][widgets[cIndex]];
            } else if (cIndex >= widgets.count){
                group.status = MLNDependenceGroupStatusFinished;
                finished ? finished(nil) : nil;
                return;
            }
            [self localWidgetSearchAndCheckWithGroup:group withWidget:widget needRetry:(group.retryCount > 0) finish:^(NSString *wp, BOOL needReload) {
                if (needReload && group.retryCount > 0) {
                    group.retryCount--;
                    [self collectGroupAllWidgetPathWith:group lastWidget:widget
                                                 finish:finished];
                    return;
                } else if (needReload && group.retryCount <= 0) {
                    group.status = MLNDependenceGroupStatusFinished;
                    finished ? finished(result) : nil;
                    return;
                } else {
                    widgetCallBackCount += 1;
                }
                result[widget.name] = wp;
                if (!wp.length) {
                    //异常
                    [self warningLog:[NSString stringWithFormat:@"文件路径为空异常, %@ %@",group.gid,widget.wid]];
                }
                if (widgetCallBackCount == widgets.count) {
                    group.status = MLNDependenceGroupStatusFinished;
                    finished ? finished(result) : nil;
                } else {
                    cIndex++;
                    if (cIndex < widgets.count) {
                        weakSelf.searchWidgtBlock ? weakSelf.searchWidgtBlock(nil) : nil;
                    }
                }
            }];
        };
        self.searchWidgtBlock = searchWidgtBlock;
        searchWidgtBlock(headWidget);
    } else {
        [self dependenceWithGroup:group withWidget:lastWidget error:[self checkFileTolimitedError]];
        group.status = MLNDependenceGroupStatusFinished;
        finished ? finished(result) : nil;
    }
}

#pragma mark - widget
-(void)localWidgetSearchAndCheckWithGroup:(MLNDependenceGroup *)group
                         withWidget:(MLNDependenceWidget *)widget
                          needRetry:(BOOL) needRetry
                             finish:(void(^)(NSString *, BOOL)) finied{
    if (group.status != MLNDependenceGroupStatusNone) {
        return;
    }
    [self log:[NSString stringWithFormat:@"开始查找 %@ %@",group.gid,widget.wid]];
    __block NSString *wp = [self findLocalWidgetWithGroup:group withWidget:widget];
    MLNDependenceTaskManager *taskManager = [MLNDependenceTaskManager shareManager];
    if (wp.length) {
        BOOL safe = [self checkWidgetFileWithWidget:widget withPath:wp];
        if (!safe) {
            wp = nil;
            //校验失败 - 报错
            [self dependenceWithGroup:group withWidget:widget error:[self checkFileError]];
            if (needRetry) {
                //校验失败
                BOOL removeSuc = [taskManager removeGroupFileGourp:group];
                if (removeSuc) {
                    [taskManager downloadWithGourp:group finished:^(BOOL downloadSuc) {
                        group.status = MLNDependenceGroupStatusNone;
                            if (downloadSuc) {
                                [taskManager unzipWithGourp:group withFinish:^(BOOL unzipSuc) {
                                        group.status = MLNDependenceGroupStatusNone;
                                    if (unzipSuc) {
                                        BOOL removeSuc = [taskManager removeGroupFileGourp:group];
                                        if (removeSuc) {
                                            [self log:[NSString stringWithFormat:@"%@ remove group zip suc %s",group.gid,__func__]];
                                        } else {
                                            [self warningLog:[NSString stringWithFormat:@"%@ remove group zip fail %s",group.gid,__func__]];
                                        }
                                        finied ? finied(nil,YES): nil;
                                        return;
                                    } else {
                                        //解压失败 - 报错
                                        [self dependenceWithGroup:group withWidget:widget error:[self unzipError]];
                                    }
                                }];
                            } else {
                                //下载失败- 报错
                                [self dependenceWithGroup:group withWidget:widget error:[self downloadError]];
                            }
                    }];
                } else {
                    //校验失败 - 报错
                    [self dependenceWithGroup:group withWidget:widget error:[self removeFileError]];
                }
            } else {
                //校验失败 - 报错
                [self dependenceWithGroup:group withWidget:widget error:[self checkFileError]];
            }
        } else {
            finied ? finied(wp,NO) : nil;
            return;
        }
    } else {
        if (!needRetry) {
            //解压失败 - 报错
            [self dependenceWithGroup:group withWidget:widget error:[self checkFileTolimitedError]];
            return;
        }
        [taskManager downloadWithGourp:group finished:^(BOOL downloadSuc) {
            group.status = MLNDependenceGroupStatusNone;
                if (downloadSuc) {
                    [taskManager unzipWithGourp:group withFinish:^(BOOL unzipSuc) {
                        group.status = MLNDependenceGroupStatusNone;
                        if (unzipSuc) {
                            BOOL removeSuc = [taskManager removeGroupFileGourp:group];
                            if (removeSuc) {
                                [self log:[NSString stringWithFormat:@"%@ remove group zip suc %s",group.gid,__func__]];
                            } else {
                                [self warningLog:[NSString stringWithFormat:@"%@ remove group zip fail %s",group.gid,__func__]];
                            }
                            finied ? finied(nil,YES): nil;
                            return;
                        } else {
                            //解压失败 - 报错
                            [self dependenceWithGroup:group withWidget:widget error:[self unzipError]];
                        }
                    }];
                } else {
                    //下载失败- 报错
                    [self dependenceWithGroup:group withWidget:widget error:[self downloadError]];
                }
        }];
    }
}

#pragma mark - Error
- (void)dependenceWithGroup:(MLNDependenceGroup *)group
                 withWidget:(MLNDependenceWidget *)widget
                      error:(NSError *)error {
    NSString *errorLog = [NSString stringWithFormat:@"MLN Dependence Error: group - %@ widget - %@ error - %@",group.gid,widget.wid,[error description]];
    [self log:errorLog];
    [self throwErrorWithGroup:group withWidget:widget error:error];
}

-(void)throwErrorWithGroup:(MLNDependenceGroup *)group
      withWidget:(MLNDependenceWidget *)widget
                     error:(NSError *)error {
    if ([self.errorHandle respondsToSelector:@selector(mlnDependenceErrorWithProjectTag:withGroup:withWidget:withError:)]) {
        [self.errorHandle mlnDependenceErrorWithProjectTag:self.projectTag
                                                 withGroup:group.gid
                                                withWidget:widget.wid
                                                 withError:error];
    }
}

#pragma mark - Check
-(BOOL)checkWidgetFileWithWidget:(MLNDependenceWidget *)widget withPath:(NSString *)path {
    BOOL suc = NO;
    NSData *file = [NSData dataWithContentsOfFile:path];
    if (file.length == [widget.size unsignedIntegerValue]) {
        [self updateChacheWithWid:widget.wid withPath:path];
        [self log:[NSString stringWithFormat:@"检验成功 %@ \n 路径:%@",widget.wid,path]];
        suc = YES;
    } else {
        [self warningLog:[NSString stringWithFormat:@"校验失败 %@",widget.wid]];
        [self warningLog:[NSString stringWithFormat:@"%@ 校验失败 target size: %ld current size: %ld",widget.wid,[widget.size unsignedIntegerValue], file.length]];
        [self removeChacheWithWid:widget.wid];
        suc = NO;
    }
    return suc;
}

#pragma mark - Find
- (NSString *)findLocalWidgetWithGroup:(MLNDependenceGroup *)group withWidget:(MLNDependenceWidget *)widget {
    //find cache
    NSString *wp = [self findCacheWithWid:widget.wid];
    if (!wp.length) {
        //find local
        wp = [self findLocalWithgroup:group withWidget:widget];
    }
    return wp;
}

-(NSString *)findLocalWithgroup:(MLNDependenceGroup *) group withWidget:(MLNDependenceWidget *) widget {
    NSString *targetPath = [self groupScrPath:group];
    NSString *wp = nil;
    if (targetPath.length) {
        targetPath = [targetPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.lua",widget.name]];
        if ([[NSFileManager defaultManager] fileExistsAtPath:targetPath]) {
            wp = targetPath;
        }
    }
    return wp;
}

-(NSString *)findCacheWithWid:(NSString *) wid {
    MLNWidgetCacheManager *cacheManager = [MLNWidgetCacheManager shareManager];
    NSString *wp = [cacheManager queryWith:wid];
    if (!wp.length) {
        if ([self.delegate respondsToSelector:@selector(queryPathWith:)]) {
            wp = [self.delegate queryPathWith:wid];
            if (wp.length) {
                [cacheManager updateWith:wid withPath:wp];
            }
        }
    }
    return wp;
}

#pragma mark - update cache
- (void)updateChacheWithWid:(NSString *)wid withPath:(NSString *)path {
    MLNWidgetCacheManager *cacheManager = [MLNWidgetCacheManager shareManager];
    [cacheManager updateWith:wid withPath:path];
    if ([self.delegate respondsToSelector:@selector(updatePathWith:withPath:)]) {
        [self.delegate updatePathWith:wid withPath:path];
    }
}

- (void)removeChacheWithWid:(NSString *)wid {
    MLNWidgetCacheManager *cacheManager = [MLNWidgetCacheManager shareManager];
    [cacheManager removeWith:wid];
    if ([self.delegate respondsToSelector:@selector(removePathWith:)]) {
        [self.delegate removePathWith:wid];
    }
}

#pragma mark - Tool
-(BOOL)hasDependenceFile {
    if ([[NSFileManager defaultManager] fileExistsAtPath:MLNDependenceFilePath]) {
        return YES;
    }
    return NO;
}

-(void)log:(NSString *) log {
#if DEBUG
    if (log.length) {
        NSString *reLog = [@"[MLNDependence] " stringByAppendingString:log];
        if ([self.logHandle respondsToSelector:@selector(recorderLog:)]) {
            NSString *logFormat = [NSString stringWithFormat:@"\n%@\n",reLog];
            NSLog(@"%@",logFormat);
            [self.logHandle recorderLog:logFormat];
        }
    }
#endif
}

-(void)warningLog:(NSString *) log {
#if DEBUG
    if (log.length) {
        NSString *warning = [@"[Warning]:" stringByAppendingString:log];
        [self log:warning];
    }
#endif
}

#pragma mark - Error
-(NSError *)downloadError {
    return [[NSError alloc] initWithDomain:@"com.mln.dependence" code:MLNDependenceErrorDownload userInfo:@{ NSLocalizedDescriptionKey: NSLocalizedString(@"download group file fail, please check out MLNDependenceDownloadDelegate downloadSourceWithGourp:withVersion:withFinish: implement", nil)}];
}

-(NSError *)unzipError {
    return [[NSError alloc] initWithDomain:@"com.mln.dependence" code:MLNDependenceErrorUnzip userInfo:@{ NSLocalizedDescriptionKey: NSLocalizedString(@"unzip group file fail, please check out MLNDependenceZipDelegate unzipWithGourp:withVersion:withFinish: implement", nil)}];
}

-(NSError *)removeFileError {
    return [[NSError alloc] initWithDomain:@"com.mln.dependence" code:MLNDependenceErrorRemoveFile userInfo:@{ NSLocalizedDescriptionKey: NSLocalizedString(@"remove group file fail, please check out MLNDependenceGroupFileDelegate removeGroupFileWith:withVersion: implement", nil)}];
}

-(NSError *)checkFileError {
    return [[NSError alloc] initWithDomain:@"com.mln.dependence" code:MLNDependenceErrorCheckFile userInfo:@{ NSLocalizedDescriptionKey: NSLocalizedString(@"check file error", nil)}];
}

-(NSError *)checkFileTolimitedError {
    return [[NSError alloc] initWithDomain:@"com.mln.dependence" code:MLNDependenceErrorCheckToLimited userInfo:@{ NSLocalizedDescriptionKey: NSLocalizedString(@"check file error to limited", nil)}];
}

-(NSError *)defultError {
    return [[NSError alloc] initWithDomain:@"com.mln.dependence" code:MLNDependenceErrorDefult userInfo:@{ NSLocalizedDescriptionKey: NSLocalizedString(@"defult error", nil)}];
}
@end
