//
//  MLNUILoadTimeStatistics.m
//  MLNDevTool
//
//  Created by Dongpeng Dai on 2020/7/9.
//

#import "MLNUILoadTimeStatistics.h"
#import "MLNUILogViewer.h"
#import "MLNUIExtScope.h"

@interface MLNUILoadTimeStatistics () {
    NSUInteger _oc_cnt;
    NSUInteger _c_cnt;
    NSUInteger _db_cnt;
    NSTimer *_timer;
}

@property (nonatomic, strong) NSDictionary *typeTags;
@property (nonatomic, strong) NSMutableDictionary *startMaps;
//@property (nonatomic, strong) NSMutableDictionary *endMaps;
@property (nonatomic, strong) NSMutableArray *keys;
@property (nonatomic, strong) NSMutableDictionary *infos;
@property (nonatomic, strong) NSArray *spacers;
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
    dispatch_block_t block = ^{
        NSString *tagStr = tag;
        if (!tagStr) {
            tagStr = [self.typeTags objectForKey:@(type)];
        }
        NSString *key = [NSString stringWithFormat:@"%zd_%@",type,tagStr];
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
        [MLNUILogViewer addLog:@"\n"];
        for (NSString *key in self.keys.copy) {
    //        NSString *log = tag;
    //        float f = [self.endMaps[tag] floatValue];
            NSString *log = self.infos[key];
    //        NSString *msg = [NSString stringWithFormat:@"%@ %.2f ms", log, f];
            [MLNUILogViewer addLog:log];
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
}

- (void)callOCBridge:(Class)cls selector:(SEL)sel {
    _oc_cnt++;
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
                NSString *log = [NSString stringWithFormat:@"调用OC方法次数：%zd",self->_oc_cnt];
                self-> _oc_cnt = 0;
                [MLNUILogViewer addLog:log];
                
                log = [NSString stringWithFormat:@"调用数据绑定次数：%zd",self->_db_cnt];
                self->_db_cnt = 0;
                [MLNUILogViewer addLog:log];

                [timer invalidate];
            }];
            [[NSRunLoop currentRunLoop] addTimer:_timer forMode: NSRunLoopCommonModes];
        } else {
            // Fallback on earlier versions
        }
    }
}
@end
