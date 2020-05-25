//
//  MLNSizeCahceManager.m
//
//
//  Created by MoMo on 2018/11/12.
//

#import "MLNSizeCahceManager.h"
#import "MLNKitInstance.h"
#import "NSDictionary+MLNSafety.h"

@interface MLNSizeCahceManager ()

@property (nonatomic, strong) NSMutableDictionary *memCache;

@end
@implementation MLNSizeCahceManager

- (instancetype)initWithInstance:(MLNKitInstance *)instance
{
    if (self = [super init]) {
        _instance = instance;
    }
    return self;
}

- (instancetype)init
{
    if (self = [super init]) {
        _countLimit = 150;
    }
    return self;
}

- (nullable id)objectForKey:(id)key
{
    return [self.memCache mln_objectForKey:key];
}
- (void)setObject:(id)obj forKey:(id)key
{
    [self.memCache mln_setObject:obj forKey:key];
}

- (void)removeObjectForKey:(id)key
{
    [self.memCache mln_removeObjectForKey:key];
}

- (void)removeAllObjects
{
    [self.memCache removeAllObjects];
}

#pragma mark - Getter
- (NSMutableDictionary *)memCache
{
    if (!_memCache) {
        _memCache = [NSMutableDictionary dictionaryWithCapacity:150];
    }
    return _memCache;
}

@end
