//
//  MLNUISizeCahceManager.m
//
//
//  Created by MoMo on 2018/11/12.
//

#import "MLNUISizeCahceManager.h"
#import "MLNUIKitInstance.h"
#import "NSDictionary+MLNUISafety.h"

@interface MLNUISizeCahceManager ()

@property (nonatomic, strong) NSMutableDictionary *memCache;

@end
@implementation MLNUISizeCahceManager

- (instancetype)initWithInstance:(MLNUIKitInstance *)instance
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
    return [self.memCache mlnui_objectForKey:key];
}
- (void)setObject:(id)obj forKey:(id)key
{
    [self.memCache mlnui_setObject:obj forKey:key];
}

- (void)removeObjectForKey:(id)key
{
    [self.memCache mlnui_removeObjectForKey:key];
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
