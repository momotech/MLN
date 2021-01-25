//
//  MLNUILoadTimeStatistics.m
//  MLNDevTool
//
//  Created by Dongpeng Dai on 2020/7/9.
//

#import "MLNUILoadTimeStatistics.h"
#import "MLNUILogViewer.h"
#import <ArgoUI/MLNUIExtScope.h>

@interface _MLNUILOadTimeModel : NSObject
@property (nonatomic, strong) NSString *key;
@property (nonatomic, assign) double cost;
@property (nonatomic, assign) double totalCost;
@property (nonatomic, assign) int totalCount;
@property (nonatomic, assign) BOOL afterLoaded;
@end

@implementation _MLNUILOadTimeModel
- (BOOL)isEqual:(_MLNUILOadTimeModel *)object {
    if (![object isKindOfClass:[self class]]) {
        return NO;
    }
    if ([self.key isEqualToString:object.key]) {
        return YES;
    }
    return NO;
}
@end

@interface MLNUILoadTimeStatistics () {
    NSUInteger _oc_cnt;
    NSUInteger _c_cnt;
    NSUInteger _db_cnt;
    NSTimer *_timer;
    
    CFAbsoluteTime _oc_start_time;
    CFAbsoluteTime _oc_end_time;
    BOOL _hasLoaded;
}

@property (nonatomic, strong) NSDictionary *typeTags;
@property (nonatomic, strong) NSMutableDictionary *startMaps;
//@property (nonatomic, strong) NSMutableDictionary *endMaps;
@property (nonatomic, strong) NSMutableArray *keys;
@property (nonatomic, strong) NSMutableDictionary *infos;
@property (nonatomic, strong) NSArray *spacers;

@property (nonatomic, strong) NSMutableDictionary *startTimes;
@property (nonatomic, strong) NSMutableArray *singleCosts;
@property (nonatomic, strong) NSMutableArray *dataBindingCosts;

@property (nonatomic, strong) NSRecursiveLock *lock;
@property (nonatomic, strong) dispatch_queue_t workQ;

@end

@implementation MLNUILoadTimeStatistics

+ (instancetype)sharedStatistics {
    static MLNUILoadTimeStatistics *s;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        s = [MLNUILoadTimeStatistics new];
        [s setup];
    });
    return s;
}

- (void)onStart:(MLNUILoadTimeStatisticsType)type {
    [self onStart:type tag:nil];
}

- (void)onStart:(MLNUILoadTimeStatisticsType)type tag:(NSString *)tag {
    if (!NSThread.isMainThread) {
        return;
    }
    if (type == MLNUILoadTimeStatisticsType_Total) {
        _hasLoaded = NO;
    }
    if (!tag) {
        tag = [self.typeTags objectForKey:@(type)];
    }
    NSString *key = [NSString stringWithFormat:@"%zd_%@",type,tag];
    self.startMaps[key] = @(CFAbsoluteTimeGetCurrent());
}

- (void)onEnd:(MLNUILoadTimeStatisticsType)type {
    [self onEnd:type tag:nil info:nil];
}

- (void)onEnd:(MLNUILoadTimeStatisticsType)type tag:(NSString *)tag {
    [self onEnd:type tag:tag info:nil];
}

- (void)onEnd:(MLNUILoadTimeStatisticsType)type tag:(NSString *)tag info:(NSString *)info {
    if (!NSThread.isMainThread) {
        return;
    }
    if (type == MLNUILoadTimeStatisticsType_Total) {
        _hasLoaded = YES;
    }
    
    dispatch_block_t block = ^{
        NSString *tagStr = tag;
        if (!tagStr) {
            tagStr = [self.typeTags objectForKey:@(type)];
        }
        NSString *key = [NSString stringWithFormat:@"%zd_%@",type,tagStr];
        if (self.startMaps[key] == nil) {
            return;
        }
        if (key) {
            float f = (CFAbsoluteTimeGetCurrent() - [self.startMaps[key] doubleValue]) * 1000;
            [self.startMaps removeObjectForKey:key];
            
            NSString *typeStr = self.typeTags[@(type)];
            NSString *m = [NSString stringWithFormat:@"%@%@%@",self.spacers[MIN(self.spacers.count - 1, self.startMaps.count)],typeStr, info ?: @""];
            NSString *msg = [NSString stringWithFormat:@"%@%*.2f ms",m,(int)(35 - m.length),f];
            
            [self.keys addObject:key];
            self.infos[key] = msg;
        }
    };
    block();
}

- (void)display {
    dispatch_block_t block = ^{
        [self _addBridgeLog:@"\n"];
        for (NSString *key in self.keys.copy) {
    //        NSString *log = tag;
    //        float f = [self.endMaps[tag] floatValue];
            NSString *log = self.infos[key];
    //        NSString *msg = [NSString stringWithFormat:@"%@ %.2f ms", log, f];
            [self _addBridgeLog:log];
        }
        [self reset];
    };
    block();
}

- (void)reset {
    [self.startMaps removeAllObjects];
//    [self.endMaps removeAllObjects];
    [self.keys removeAllObjects];
    [self.infos removeAllObjects];
    _hasLoaded = NO;
}

- (void)setup {
    self.startMaps = [NSMutableDictionary dictionary];
//    self.endMaps = [NSMutableDictionary dictionary];
    self.keys = [NSMutableArray array];
    self.infos = [NSMutableDictionary dictionary];
    
    NSString *all = @"【总加载时间】";
    NSString *read = @"【读取文件】";
    NSString *luaCore = @"【创建LuaCore】";
    NSString *compile = @"【编译】";
    NSString *exe = @"【执行】";
    NSString *cus = @"";
//    self.typeTags = @{
//        @(MLNUILoadTimeStatisticsType_StartALL): all,
//        @(MLNUILoadTimeStatisticsType_StartALL): all,
//
//        @(MLNUILoadTimeStatisticsType_StartLuaCore): luaCore,
//        @(MLNUILoadTimeStatisticsType_EndLuaCore): luaCore,
//
//        @(MLNUILoadTimeStatisticsType_StartReadFile): read,
//        @(MLNUILoadTimeStatisticsType_EndReadFile): read,
//
//        @(MLNUILoadTimeStatisticsType_StartCompile): compile,
//        @(MLNUILoadTimeStatisticsType_EndCompile): compile,
//
//        @(MLNUILoadTimeStatisticsType_StartExecute):exe,
//        @(MLNUILoadTimeStatisticsType_EndExeCute): exe,
//    };
    
    self.typeTags = @{
        @(MLNUILoadTimeStatisticsType_Total): all,
        @(MLNUILoadTimeStatisticsType_LuaCore): luaCore,
        @(MLNUILoadTimeStatisticsType_ReadFile): read,
        @(MLNUILoadTimeStatisticsType_Compile): compile,
        @(MLNUILoadTimeStatisticsType_Execute):exe,
        @(MLNUILoadTimeStatisticsType_Custom) :cus
    };
//    self.spacers = @[@"",@"-",@"--",@"---",@"----",@"-----",@"------"];
    self.spacers = @[@"",@" ",@"  ",@"   ",@"    ",@"     ",@"      "];
    self.startTimes = [NSMutableDictionary dictionary];
//    self.endTimes = [NSMutableDictionary dictionary];
    self.singleCosts = [NSMutableArray array];
    self.dataBindingCosts = [NSMutableArray array];
    
    self.lock = [NSRecursiveLock new];
    self.workQ = dispatch_queue_create("debug.work.queue", DISPATCH_QUEUE_SERIAL);
}

- (void)callOCBridge:(Class)cls selector:(SEL)sel {
    if (_oc_cnt == 0) {
        _oc_start_time = CFAbsoluteTimeGetCurrent();
    }
    _oc_cnt++;
    _oc_end_time = CFAbsoluteTimeGetCurrent();
    [self startTimeIfneeded];
}

- (void)callDBBridge:(const char *)func {
    _db_cnt++;
    [self startTimeIfneeded];
}

- (void)callCBridge:(const char *)func {
    _c_cnt++;
}

- (void)startTimeIfneeded {
//    [self.class cancelPreviousPerformRequestsWithTarget:self];
//    [self performSelector:@selector(_startTimer) withObject:nil afterDelay:2];
    [self _startTimer];
}

- (void)_startTimer {
    if (!_timer || !_timer.isValid) {
        if (@available(iOS 10.0, *)) {
            @weakify(self);
            _timer = [NSTimer timerWithTimeInterval:3 repeats:NO block:^(NSTimer * _Nonnull timer) {
                @strongify(self);
                if(!self) return;
                dispatch_async(self.workQ, ^{
                    NSString *log = [NSString stringWithFormat:@"调用OC方法次数：%zd",self->_oc_cnt];
                    self-> _oc_cnt = 0;
                    [self _addBridgeLog:log];
                    
                    log = [NSString stringWithFormat:@"调用数据绑定次数：%zd",self->_db_cnt];
                    self->_db_cnt = 0;
                    [self _addBridgeLog:log];

    //                NSString *cost = [NSString stringWithFormat:@"调用OC方法耗时： %.2f ms", (self->_oc_end_time - self->_oc_start_time) * 1000];
    //                [self _addBridgeLog:cost];
                    
                    [self printSortedCost];
                    
                    [timer invalidate];
                });
            }];
            [[NSRunLoop currentRunLoop] addTimer:_timer forMode: NSRunLoopCommonModes];
        } else {
            // Fallback on earlier versions
        }
    }
}

- (void)printSortedCost {
    [self.lock lock];
//    NSDictionary *starts = self.startTimes.copy;
    NSMutableArray *singles = self.singleCosts.mutableCopy;
    NSMutableArray *dataBindings = self.dataBindingCosts.mutableCopy;
    
    [self.startTimes removeAllObjects];
    [self.singleCosts removeAllObjects];
    [self.dataBindingCosts removeAllObjects];
    
    [self.lock unlock];
    
    NSMutableArray *totalCosts = @[].mutableCopy;
    NSMutableArray *totalCounts = @[].mutableCopy;
//    NSMutableArray *afterLaodedCosts = @[].mutableCopy;
    __block CGFloat cost_after_load = 0.f;
    
    void (^block)(_MLNUILOadTimeModel *m) = ^(_MLNUILOadTimeModel *m) {
        
        NSInteger idx = [totalCosts indexOfObject:m];
        if (idx != NSNotFound) {
            _MLNUILOadTimeModel *m2 = [totalCosts objectAtIndex:idx];
            m2.totalCost += m.cost;
            m2.totalCount += 1;
        } else {
            [totalCosts addObject:m];
        }
        if (m.afterLoaded) {
            cost_after_load += m.cost;
        }
    };
    
    for (_MLNUILOadTimeModel *m in singles) {
        block(m);
    }
    totalCounts = totalCosts.mutableCopy;
    
    int count = 20;
    [singles sortUsingComparator:^NSComparisonResult(_MLNUILOadTimeModel *  _Nonnull obj1, _MLNUILOadTimeModel *  _Nonnull obj2) {
        if (obj1.cost < obj2.cost) {
            return NSOrderedDescending;
        }
        return NSOrderedAscending;
    }];
    
    [totalCosts sortUsingComparator:^NSComparisonResult(_MLNUILOadTimeModel *  _Nonnull obj1, _MLNUILOadTimeModel *  _Nonnull obj2) {
        if (obj1.totalCost < obj2.totalCost) {
            return NSOrderedDescending;
        }
        return NSOrderedAscending;
    }];
    
    [totalCounts sortUsingComparator:^NSComparisonResult(_MLNUILOadTimeModel *  _Nonnull obj1, _MLNUILOadTimeModel *  _Nonnull obj2) {
        if (obj1.totalCount < obj2.totalCount) {
            return NSOrderedDescending;
        }
        return NSOrderedAscending;
    }];

    double total_cost = 0;
    for (_MLNUILOadTimeModel *m in totalCosts) {
        total_cost += m.totalCost;
    }
    
    double db_cost = 0;
    double db_cost_after_load = 0;
    for (_MLNUILOadTimeModel *m in dataBindings) {
        db_cost += m.cost;
        if (m.afterLoaded) {
            db_cost_after_load += m.cost;
        }
    }
    
    NSString *log = [NSString stringWithFormat:@"调用Bridge总耗时：%.2f ms",total_cost];
    [self _addBridgeLog: log];
    
    log = [NSString stringWithFormat:@"调用DataBinding总耗时：%.2f ms",db_cost];
    [self _addBridgeLog: log];
    
    log = [NSString stringWithFormat:@"Load之后的Bridge耗时： %.2f ms", cost_after_load];
    [self _addBridgeLog:log];
    
    log = [NSString stringWithFormat:@"Load之后的DataBinding耗时： %.2f ms", db_cost_after_load];
    [self _addBridgeLog:log];
    
    [self _addBridgeLog:@" \n\n单次Bridge调用耗时排序："];
    [singles enumerateObjectsUsingBlock:^(_MLNUILOadTimeModel *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (idx >= count) {
            *stop = YES;
        }
        NSString *log = [NSString stringWithFormat:@"%@ cost %.2f ms", obj.key, obj.cost];
        [self _addBridgeLog:log];
    }];
    
    [self _addBridgeLog:@"\n\nBridge调用总耗时排序："];
    [totalCosts enumerateObjectsUsingBlock:^(_MLNUILOadTimeModel *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (idx >= count) {
            *stop = YES;
        }
        NSString *log = [NSString stringWithFormat:@"%@ total cost: %.2f ms, total count: %d", obj.key, obj.totalCost, obj.totalCount];
        [self _addBridgeLog:log];
    }];
    
    [self _addBridgeLog:@"\n\nBridge调用总次数排序："];
    [totalCounts enumerateObjectsUsingBlock:^(_MLNUILOadTimeModel *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (idx >= count) {
            *stop = YES;
        }
        NSString *log = [NSString stringWithFormat:@"%@ total cost: %.2f ms, total count: %d", obj.key, obj.totalCost, obj.totalCount];
        [self _addBridgeLog:log];
    }];
}

- (void)_addBridgeLog:(NSString *)log {
//    [MLNUILogViewer addLog:log];
    NSLog(@">>>> %@",log);
}

- (void)onStartCallOCBridge:(Class)cls selector:(SEL)sel {
    [self startTimeIfneeded];
    
    if (!cls || !sel)  return;
    CFAbsoluteTime t = CFAbsoluteTimeGetCurrent();
    dispatch_async(self.workQ, ^{
                
        NSString *classStr = NSStringFromClass(cls);
        NSString *selStr = NSStringFromSelector(sel);
        NSMutableDictionary *dic = [self.startTimes objectForKey:classStr];
        [self.lock lock];
        if (!dic) {
            dic = [NSMutableDictionary dictionary];
            [self.startTimes setObject:dic forKey:classStr];
        }
        [dic setObject:@(t) forKey:selStr];
        [self.lock unlock];
    });
}

- (void)onEndCallOCBridge:(Class)cls selector:(SEL)sel {
    if (!cls || !sel)  return;
    CFAbsoluteTime t = CFAbsoluteTimeGetCurrent();
    BOOL afterLoaded = _hasLoaded;
    
    dispatch_async(self.workQ, ^{
        NSString *classStr = NSStringFromClass(cls);
        NSString *selStr = NSStringFromSelector(sel);
        [self.lock lock];
        NSMutableDictionary *dic = [self.startTimes objectForKey:classStr];
        if (!dic) {
            return;
        }
        double start = [[dic objectForKey:selStr] doubleValue];
        NSString *key = [NSString stringWithFormat:@"%@_%@",classStr,selStr];
        
        _MLNUILOadTimeModel *m = [_MLNUILOadTimeModel new];
        m.key = key;
        m.cost = (t - start) * 1000;
        m.totalCost = m.cost;
        m.totalCount = 1;
        m.afterLoaded = afterLoaded;
        
        [self.singleCosts addObject:m];
        
        [self.lock unlock];
    });
    [self callOCBridge:cls selector:sel];
}

- (void)onStartCallCBridge:(const char *)func {
    [self startTimeIfneeded];
    if (!func) return;
    CFAbsoluteTime t = CFAbsoluteTimeGetCurrent();
    dispatch_async(self.workQ, ^{
        NSString *str = [NSString stringWithUTF8String:func];
        [self.lock lock];
        [self.startTimes setObject:@(t) forKey:str];
        [self.lock unlock];
    });
}

- (void)onEndCallCBridge:(const char *)func {
    if (!func) return;
    CFAbsoluteTime t = CFAbsoluteTimeGetCurrent();
    BOOL afterLoaded = _hasLoaded;
    
    dispatch_async(self.workQ, ^{
        NSString *str = [NSString stringWithUTF8String:func];
        [self.lock lock];
        double start = [[self.startTimes objectForKey:str] doubleValue];
        NSString *key = [NSString stringWithUTF8String:func];
        
        _MLNUILOadTimeModel *m = [_MLNUILOadTimeModel new];
        m.key = key;
        m.cost = (t - start) * 1000;
        m.totalCost = m.cost;
        m.totalCount = 1;
        m.afterLoaded = afterLoaded;
        
        [self.singleCosts addObject:m];
        [self.dataBindingCosts addObject:m];
        [self.lock unlock];
    });
}

- (void)onStartCallDBBridge:(const char *)func {
    [self onStartCallCBridge:func];
}

- (void)onEndCallDBBridge:(const char *)func {
    [self onEndCallCBridge:func];
    [self callDBBridge:func];
}

@end
