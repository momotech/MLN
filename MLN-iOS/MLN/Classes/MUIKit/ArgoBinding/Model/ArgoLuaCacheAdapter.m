//
//  ArgoLuaCacheAdapter.m
//  ArgoUI
//
//  Created by Dongpeng Dai on 2020/9/1.
//

#import "ArgoLuaCacheAdapter.h"
#import "MLNUILuaTable.h"
#import "MLNUILuaCore.h"

#define DoWhenNotInMainThread(ret)     if ([NSThread isMainThread] == false) {\
ret;\
}\

@interface ArgoLuaCacheAdapter ()
@property (nonatomic, unsafe_unretained) id<ArgoListenerProtocol> object;
@property (nonatomic, strong) NSMutableDictionary <id<NSCopying> , MLNUILuaTable *> *cache;
@end

@implementation ArgoLuaCacheAdapter

#pragma mark -
- (void)addLuaTabe:(MLNUILuaTable *)table {
    DoWhenNotInMainThread(return;)
    MLNUILuaCore *core = table.luaCore;
    if (core) {
        [self.cache setObject:table forKey:core];
    }
}

- (MLNUILuaTable *)getLuaTable:(id<NSCopying>)key {
    DoWhenNotInMainThread(return nil;)
    if (key) {
        MLNUILuaTable *t = [self.cache objectForKey:key];
//        if (t) {
//            NSLog(@">>>>>> lua table hit cache %p",self.object);
//        } else {
//            NSLog(@">>>>>> lua table miss cache %p",self.object);
//        }
        return t;
    }
    return nil;
}

#pragma mark -

- (instancetype)initWithObject:(id<ArgoListenerProtocol>)object {
    DoWhenNotInMainThread(return nil;)
    if (self = [super init]) {
        _object = object;
    }
    return self;
}

- (void)dealloc {
    DoWhenNotInMainThread(
        __block id cache = _cache;
        dispatch_async(dispatch_get_main_queue(), ^{
          cache = nil;
    }))
}

- (NSMutableDictionary <id<NSCopying>, MLNUILuaTable *> *)cache {
    if (!_cache) {
        _cache = [NSMutableDictionary dictionary];
    }
    return _cache;
}

#pragma mark - Map

- (void)putValue:(NSObject *)value forKey:(NSString *)key {
    DoWhenNotInMainThread(return;)
    if(!key) return;
    for (MLNUILuaTable *table in self.cache.allValues) {
//        if (value) {
//            [table setObject:value key:key];
//        } else {
//            [table removeObject:key];
//        }
        //table兼容value=nil的情况
//        [table setObject:value key:key];
        [table rawsetObject:value key:key];
    }
}

- (void)removeAll {
    if (_cache) {
        if ([NSThread isMainThread]) {
            _cache = nil;
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                self->_cache = nil;
            });
        }
    }
}

#pragma mark - Array

- (void)putValue:(NSObject *)value forIndex:(int)index {
    DoWhenNotInMainThread(return;)
    for (MLNUILuaTable *table in self.cache.allValues) {
        //table兼容value=nil的情况
        [table rawsetObject:value index:index];
    }
}

- (void)insertValue:(NSObject *)value forIndex:(int)index {
    DoWhenNotInMainThread(return;)
    for (MLNUILuaTable *table in self.cache.allValues) {
        [table inseretObject:value index:index];
    }
}

- (void)notifyChange:(NSDictionary *)change {
    //TODO: 实现lua table的inert...
    [self.cache removeAllObjects];
    return;
    DoWhenNotInMainThread(return;)
    NSKeyValueChange type = [[change objectForKey:NSKeyValueChangeKindKey] unsignedIntegerValue];
    NSIndexSet *indexSet = [change objectForKey:NSKeyValueChangeIndexesKey];
    NSObject *newValue = [change objectForKey:NSKeyValueChangeNewKey];
    
    if (type == NSKeyValueChangeInsertion) {
        [self _handleInsertOrReplacement:YES WithIndexSet:indexSet newValue:newValue];
    } else if (type == NSKeyValueChangeRemoval) {
        [indexSet enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL * _Nonnull stop) {
            [self putValue:nil forIndex:(int)idx + 1];
        }];
    } else if (type == NSKeyValueChangeReplacement) {
        [self _handleInsertOrReplacement:NO WithIndexSet:indexSet newValue:newValue];
    } else {
        NSLog(@"error, should not reach here! ");
    }
}

- (void)_handleInsertOrReplacement:(BOOL)isInsert WithIndexSet:(NSIndexSet *)indexSet newValue:(NSObject *)newValue {
    NSUInteger count = [indexSet count];
    [indexSet enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL * _Nonnull stop) {
        if (count == 1) {
            if (isInsert) {
                [self insertValue:newValue forIndex:(int)(idx + 1)];
            } else {
                [self putValue:newValue forIndex:(int)(idx + 1)];
            }
        } else {
            NSArray *array = (NSArray *)newValue;
            if ([array isKindOfClass:[NSArray class]]) {
                NSUInteger array_index = idx - indexSet.firstIndex;
                if (array_index > array.count) {
                    NSLog(@"error, index incompatible");
                    *stop = YES;
                } else {
                    if (isInsert) {
                        [self insertValue:array[array_index] forIndex:(int)idx + 1];
                    } else {
                        [self putValue:array[array_index] forIndex:(int)idx + 1];
                    }
                }
            } else {
                NSLog(@"error, should be array");
            }
        }
    }];
}

@end

