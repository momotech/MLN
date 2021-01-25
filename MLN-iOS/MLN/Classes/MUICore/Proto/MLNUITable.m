//
//  MLNUITable.m
//  ArgoUI
//
//  Created by xindong on 2020/11/27.
//

#import "MLNUITable.h"

@implementation MLNUITable {
    NSMutableArray *_array;
    NSMutableDictionary *_dic;
}

- (instancetype)initWithArray:(NSArray *)array {
    if (self = [super init]) {
        _array = [array mutableCopy];
    }
    return self;
}

- (instancetype)initWithDictionary:(NSDictionary *)dictionary {
    if (self = [super init]) {
        _dic = [dictionary mutableCopy];
    }
    return self;
}

+ (MLNUITable *)array {
    return [[MLNUITable alloc] initWithArray:@[]];
}

+ (MLNUITable *)dictionary {
    return [[MLNUITable alloc] initWithDictionary:@{}];
}

- (NSUInteger)count {
    if (_dic) {
        return _dic.count;
    }
    return _array.count;
}

- (BOOL)contains:(id)object {
    if (!object) return 0;
    if (_dic) {
        return [_dic.allValues containsObject:object];
    }
    return [_array containsObject:object];
}

// get
- (id)objectForKey:(id)key {
    if (_dic) {
        return [_dic objectForKey:key];
    }
    NSParameterAssert([key isKindOfClass:[NSNumber class]]);
    if ([key isKindOfClass:[NSNumber class]]) {
        NSUInteger index = [key unsignedIntegerValue];
        if (_array.count > index) {
            return [_array objectAtIndex:index];
        }
    }
    return nil;
}

- (id)firstObject {
    if (_dic) {
        return _dic.objectEnumerator.nextObject;
    }
    return _array.firstObject;
}

- (id)lastObject {
    if (_dic) {
        __block id last = nil;
        [_dic enumerateKeysAndObjectsWithOptions:NSEnumerationReverse usingBlock:^(id _Nonnull key, id _Nonnull obj, BOOL *_Nonnull stop) {
            last = obj; *stop = YES;
        }];
        return last;
    }
    if (_array.count > 0) {
        return [_array objectAtIndex:_array.count - 1];
    }
    return nil;
}

// update
- (void)setObject:(id)object forKey:(id)key {
    if (!object || !key) return;
    if (_dic) {
        [_dic setObject:object forKey:key];
        return;
    }
    if ([key isKindOfClass:[NSNumber class]]) {
        NSUInteger index = [key unsignedIntegerValue];
        if (index == _array.count) {
            [_array insertObject:object atIndex:index];
        } else if (_array.count > index) {
            [_array removeObjectAtIndex:index];
            [_array insertObject:object atIndex:index];
        }
    }
}

- (void)addObject:(id)object {
    if (!object) return;
    if (_array) {
        [_array addObject:object];
    }
}

// remove
- (void)removeObjectForKey:(id)key {
    if (!key) return;
    if (_dic) {
        [_dic removeObjectForKey:key];
        return;
    }
    if ([key isKindOfClass:[NSNumber class]]) {
        NSUInteger index = [key unsignedIntegerValue];
        if (_array.count > index) {
            [_array removeObjectAtIndex:index];
        }
    }
}

- (void)removeObject:(id)object {
    if (!object) return;
    if (_dic) {
        NSArray *keys = [_dic allKeysForObject:object];
        [_dic removeObjectsForKeys:keys];
    } else {
        [_array removeObject:object];
    }
}

- (void)removeAllObjects {
    if (_dic) {
        [_dic removeAllObjects];
    } else {
        [_array removeAllObjects];
    }
}

@end
