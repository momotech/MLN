//
//  MLNUILoadTimeStatistics.m
//  MLNDevTool
//
//  Created by Dongpeng Dai on 2020/7/9.
//

#import "MLNUILoadTimeStatistics.h"
#import "MLNUILogViewer.h"

@interface MLNUILoadTimeStatistics ()

@property (nonatomic, strong) NSDictionary *typeTags;
@property (nonatomic, strong) NSMutableDictionary *startMaps;
@property (nonatomic, strong) NSMutableDictionary *endMaps;
@property (nonatomic, strong) NSMutableArray *tags;
@property (nonatomic, strong) NSMutableDictionary *tagInfos;

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
    if (type == MLNUILoadTimeStatisticsType_Custom) {
        NSLog(@"");
    }
}

- (void)onStart:(MLNUILoadTimeStatisticsType)type tag:(NSString *)tag {
    if (!tag) {
        tag = [self.typeTags objectForKey:@(type)];
    }
    if (tag) {
        self.startMaps[tag] = @(CFAbsoluteTimeGetCurrent());
    }
}

- (void)onEnd:(MLNUILoadTimeStatisticsType)type {
    [self onEnd:type tag:nil info:nil];
}

- (void)onEnd:(MLNUILoadTimeStatisticsType)type tag:(NSString *)tag {
    [self onEnd:type tag:tag info:nil];
}

- (void)onEnd:(MLNUILoadTimeStatisticsType)type tag:(NSString *)tag info:(NSString *)info {
    if (!tag) {
        tag = [self.typeTags objectForKey:@(type)];
    }
    if (tag) {
        NSNumber *cost = @((CFAbsoluteTimeGetCurrent() - [self.startMaps[tag] doubleValue]) * 1000);
        self.endMaps[tag] = cost;
        [self.tags addObject:tag];
        self.tagInfos[tag] = info;
    }
}

- (void)display {
    [MLNUILogViewer addLog:@"\n"];
    for (NSString *tag in self.tags.copy) {
        NSString *log = tag;
        float f = [self.endMaps[tag] floatValue];
        NSString *info = self.tagInfos[tag];
        if (info.length > 0) {
//            log = [tag stringByAppendingFormat:@" %@",info];
            log = info;
        }
        NSString *msg = [NSString stringWithFormat:@"%@ %.2f ms", log, f];
        [MLNUILogViewer addLog:msg];
    }
    [self reset];
}

- (void)reset {
    [self.startMaps removeAllObjects];
    [self.endMaps removeAllObjects];
    [self.tags removeAllObjects];
    [self.tagInfos removeAllObjects];
}

- (void)setup {
    self.startMaps = [NSMutableDictionary dictionary];
    self.endMaps = [NSMutableDictionary dictionary];
    self.tags = [NSMutableArray array];
    self.tagInfos = [NSMutableDictionary dictionary];
    
    NSString *all = @"【总加载时间】";
    NSString *read = @"【读取文件】";
    NSString *luaCore = @"【创建LuaCore】";
    NSString *compile = @"【编译】";
    NSString *exe = @"【执行】";
    NSString *cus = @"【自定义】";
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
}


@end
