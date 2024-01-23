//
//  MLNWidgetCacheManager.m
//  MLN
//
//  Created by xue.yunqiang on 2022/5/7.
//

#import "MLNWidgetCacheManager.h"

@interface MLNWidgetCacheManager()

@property (nonatomic, strong) NSMutableDictionary<NSString*, NSString*> *cacheMap;

@end

@implementation MLNWidgetCacheManager

+ (instancetype)shareManager
{
    static MLNWidgetCacheManager *manager = nil;
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
        _cacheMap = [NSMutableDictionary dictionary];
    }
    return self;
}

-(void)updateWith:(NSString *) wid withPath:(NSString *) path {
    if (wid.length && path.length) {
        _cacheMap[wid] = path;
    }
}

-(void)removeWith:(NSString *) wid {
    if (wid.length) {
        [_cacheMap removeObjectForKey:wid];
    }
}

-(NSString *)queryWith:(NSString *) wid {
    if (wid.length) {
        return _cacheMap[wid];
    }
    return nil;
}

@end
