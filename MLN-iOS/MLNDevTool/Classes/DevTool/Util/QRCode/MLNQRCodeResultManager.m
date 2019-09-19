//
//  MLNQRCodeResultManager.m
//  MLNDevTool
//
//  Created by MoMo on 2019/9/14.
//

#import "MLNQRCodeResultManager.h"
#import "MLNQRCodeDefaultInfo.h"

#define kMLNQRCodeResultList @"kMLNQRCodeResultList"
#define kMLNQRCodeResultDictionary @"kMLNQRCodeResultDictionary"

@interface MLNQRCodeResultManager ()

@property (nonatomic, strong) NSMutableArray<id<MLNQRCodeHistoryInfoProtocol>> *infoList;
@property (nonatomic, strong) NSMutableDictionary<NSString *, id<MLNQRCodeHistoryInfoProtocol>> *infoDict;
@property (nonatomic, strong) NSDateFormatter *dateFormatter;

@end

@implementation MLNQRCodeResultManager

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self initInfos];
        _dateFormatter = [[NSDateFormatter alloc] init];
        [_dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss zzz"];
    }
    return self;
}

- (void)initInfos
{
    NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:kMLNQRCodeResultList];
    if (data) {
      _infoList = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    }
    if (!_infoList) {
        _infoList = [NSMutableArray array];
    }
    data = [[NSUserDefaults standardUserDefaults] objectForKey:kMLNQRCodeResultDictionary];
    if (data) {
        _infoDict = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    }
    if (!_infoDict) {
        _infoDict = [NSMutableDictionary dictionary];
    }
}

- (id<MLNQRCodeHistoryInfoProtocol>)resultAtIndex:(NSUInteger)index
{
    if (index >= self.infoList.count) {
        return nil;
    }
    return [self.infoList objectAtIndex:index];
}

- (void)addResult:(NSString *)result
{
    if (!result || result.length <= 0) {
        return;
    }
    NSDate *date = [NSDate date];
    NSString *dateTxt = [self.dateFormatter stringFromDate:date];
    id<MLNQRCodeHistoryInfoProtocol> info = [self.infoDict objectForKey:result];
    if (!info) {
        info = [self createInfo];
    }
    info.link = result;
    info.date = dateTxt;
    [self.infoList removeObject:info];
    [self.infoList insertObject:info atIndex:0];
    [self.infoDict setObject:info forKey:result];
    // synchronize to sandbox
    [self synchronize];
}

- (void)removeResult:(NSString *)result
{
    if (!result || result.length <= 0) {
        return;
    }
    id<MLNQRCodeHistoryInfoProtocol> info = [self.infoDict objectForKey:result];
    if (!info) {
        return;
    }
    [self.infoList removeObject:info];
    [self.infoDict removeObjectForKey:result];
    // synchronize to sandbox
    [self synchronize];
}

- (void)removeAll
{
    [self.infoDict removeAllObjects];
    [self.infoList removeAllObjects];
    // synchronize to sandbox
    [self synchronize];
}

- (NSUInteger)resultsCount
{
    return self.infoList.count;
}

- (void)synchronize
{
    NSData *listData = [NSKeyedArchiver archivedDataWithRootObject:self.infoList];
    NSData *dictData = [NSKeyedArchiver archivedDataWithRootObject:self.infoDict];
    [[NSUserDefaults standardUserDefaults] setObject:listData forKey:kMLNQRCodeResultList];
    [[NSUserDefaults standardUserDefaults] setObject:dictData forKey:kMLNQRCodeResultDictionary];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (id<MLNQRCodeHistoryInfoProtocol>)createInfo
{
    return [[MLNQRCodeDefaultInfo alloc] init];
}

@end
