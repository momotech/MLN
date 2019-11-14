//
//  MLNLoadTimeStatistics.m
//  MLN
//
//  Created by MoMo on 2019/11/4.
//

#import "MLNLoadTimeStatistics.h"

@interface MLNLoadTimeStatistics()
@property (nonatomic, strong) NSMutableDictionary *loadScriptTimeDict;
@end

@implementation MLNLoadTimeStatistics
{
    CFTimeInterval _startTime;
    CFTimeInterval _endTime;
    CFTimeInterval _luaCoreCreateStartTime;
    CFTimeInterval _luaCoreCreateEndTime;
    CFTimeInterval _loadScriptStartTime;
    CFTimeInterval _loadScriptEndTime;
}

static MLNLoadTimeStatistics *_instance = nil;

+ (instancetype)sharedInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[MLNLoadTimeStatistics alloc] init];
    });
    return _instance;
}

- (NSString *)description
{
    NSString *descriptMessage = [NSString stringWithFormat:@"/********** MLN LoadTime Statistics ******/\n%@\n%@\n%@\n", \
                                 [NSString stringWithFormat:@"LuaCoreCreateTime:%.0f", [self luaCoreCreateTime] * 1000], \
                                 [NSString stringWithFormat:@"LuaScriptLoadTime:%.5f", [self loadScriptTime] * 1000], \
                                 [NSString stringWithFormat:@"RegisterThirdBridgeTime:%.0f", [self luaCoreCreateTime] * 1000]];
    return descriptMessage;
}

- (void)resetAllTimeRecord
{
    _startTime = 0.0;
    _endTime = 0.0;
    [self resetLuaCoreCreateTime];
    [self resetLuaScriptLoadTime];
}

- (void)recordStartTime
{
    [self resetAllTimeRecord];
    
    _startTime = CACurrentMediaTime();
}

- (void)recordEndTime
{
    _endTime = CACurrentMediaTime();
}

- (NSTimeInterval)allLoadTime
{
    return _endTime - _startTime;
}

- (void)resetLuaCoreCreateTime
{
    _luaCoreCreateStartTime = 0.0;
    _luaCoreCreateEndTime = 0.0;
}

- (void)recordLuaCoreCreateStartTime
{
    [self resetLuaCoreCreateTime];
    _luaCoreCreateStartTime = CACurrentMediaTime();
}

- (void)recordLuaCoreCreateEndTime
{
    _luaCoreCreateEndTime = CACurrentMediaTime();
}

- (NSTimeInterval)luaCoreCreateTime
{
    return _luaCoreCreateEndTime - _luaCoreCreateStartTime;
}

- (void)resetLuaScriptLoadTime
{
    if (self.loadScriptTimeDict.allKeys.count > 0) {
        [self.loadScriptTimeDict removeAllObjects];
    }
    self.loadScriptTimeDict = nil;
}

- (void)recordLoadScriptStartTimeWithFileName:(NSString *)fileName
{
    [self resetLuaScriptLoadTime];
    _loadScriptStartTime = CACurrentMediaTime();
    NSMutableDictionary *timeDict = [self scriptLoadTimeDictForFileName:fileName];
    [timeDict setObject:@(_loadScriptStartTime) forKey:@"startTime"];
}

- (void)recordLoadScriptEndTimeWithFileName:(NSString *)fileName
{
    _loadScriptEndTime = CACurrentMediaTime();
    NSMutableDictionary *timeDict = [self scriptLoadTimeDictForFileName:fileName];
    [timeDict setObject:@(_loadScriptEndTime) forKey:@"endTime"];
    [timeDict setObject:@(_loadScriptEndTime - _loadScriptStartTime) forKey:@"loadTime"];
}

- (NSTimeInterval)loadScriptTime
{
    NSTimeInterval totalLoadScriptTime = 0.0f;
    for (NSString *fileKey in self.loadScriptTimeDict.allKeys) {
        totalLoadScriptTime += [[[self.loadScriptTimeDict valueForKey:fileKey] valueForKey:@"loadTime"] doubleValue];
    }
    return totalLoadScriptTime;
}


- (NSTimeInterval)registerThirdBridgeTime
{
    return 0.0f;
}


#pragma mark - Private method

- (NSMutableDictionary *)scriptLoadTimeDictForFileName:(NSString *)fileName
{
    NSMutableDictionary *dict = [self.loadScriptTimeDict valueForKey:fileName];
    if (!dict) {
        dict = [NSMutableDictionary new];
        [self.loadScriptTimeDict setObject:dict forKey:fileName];
    }
    return dict;
}

- (NSMutableDictionary *)loadScriptTimeDict
{
    if (!_loadScriptTimeDict) {
        _loadScriptTimeDict = [NSMutableDictionary new];
    }
    return _loadScriptTimeDict;
}




@end
