//
//  MLNDataBinding.m
// MLN
//
//  Created by Dai Dongpeng on 2020/3/3.
//

#import "MLNDataBinding.h"
#import <pthread.h>
#import "KVOController.h"
#import "NSMutableArray+MLNKVO.h"
#import "NSArray+MLNKVO.h"

@interface MLNDataBinding() {
    pthread_mutex_t _lock;
}
@property (nonatomic, strong) NSMutableDictionary *dataMap;
@property (nonatomic, strong) NSMapTable *observerMap;
@end

@implementation MLNDataBinding

#pragma mark - Data
- (instancetype)init
{
    self = [super init];
    if (self) {
        self.dataMap = [NSMutableDictionary dictionary];
        self.observerMap =  [NSMapTable strongToWeakObjectsMapTable];
        LOCK_INIT();
        NSLog(@"---- init : %s %p",__FUNCTION__, self);
    }
    return self;
}

- (void)bindData:(NSObject *)data forKey:(NSString *)key {
    NSParameterAssert(key);
    if (key) {
        LOCK();
        [self.dataMap setValue:data forKey:key];
        UNLOCK();
    }
}

- (void)updateDataForKeyPath:(NSString *)keyPath value:(id)value {
    NSParameterAssert(keyPath);
    NSString *key, *path;
    [self extractFirstKey:&key path:&path from:keyPath];
    if (!key) {
        return;
    }
    LOCK();
    if (!path) {
        [self.dataMap setValue:value forKey:key];
        UNLOCK();
        return;
    }
    NSObject *object = [self.dataMap objectForKey:key];
    UNLOCK();
    @try {
        [object setValue:value forKeyPath:path];
    } @catch (NSException *exception) {
        NSLog(@"exception: %s %@",__func__, exception);
    }
}

- (id)dataForKeyPath:(NSString *)keyPath {
    NSParameterAssert(keyPath);
    NSString *key, *path;
    [self extractFirstKey:&key path:&path from:keyPath];
    if (!key) {
        return nil;
    }
    LOCK();
    NSObject *object = [self.dataMap objectForKey:key];
    UNLOCK();
    if (!path) {
        return object;
    }
    NSObject *res;
    @try {
        res = [object valueForKeyPath:path];
    } @catch (NSException *exception) {
        NSLog(@"exception: %s %@",__func__, exception);
    }
    return res;
}

- (void)addDataObserver:(NSObject<MLNKVOObserverProtol> *)observer forKeyPath:(NSString *)keyPath {
    [self _realAddObserver:observer forKeyPath:keyPath isArray:NO];
}

- (void)removeDataObserver:(NSObject<MLNKVOObserverProtol> *)observer forKeyPath:(NSString *)keyPath {
    NSParameterAssert(observer && keyPath);
    if(!observer || !keyPath) return;
    
    LOCK();
    NSMutableArray *observers = [self.observerMap objectForKey:keyPath];
    [observers removeObject:observer];
    UNLOCK();
}

- (NSArray<NSObject<MLNKVOObserverProtol> *> *)observersForKeyPath:(NSString *)keyPath {
    NSParameterAssert(keyPath);
    if (!keyPath) {
        return nil;
    }
    LOCK();
    NSMutableArray *observers = [self.observerMap objectForKey:keyPath];
    UNLOCK();
    return observers;
}

#pragma mark - Array

- (void)bindArray:(NSArray *)array forKey:(NSString *)key {
    [array mln_startKVOIfMutableble];
    [self bindData:array forKey:key];
}

- (void)addArrayObserver:(NSObject<MLNKVOObserverProtol> *)observer forKey:(NSString *)key {
    [self _realAddObserver:observer forKeyPath:key isArray:YES];
}

- (void)removeArrayObserver:(NSObject<MLNKVOObserverProtol> *)observer forKey:(NSString *)key {
    [self removeDataObserver:observer forKeyPath:key];
}

#pragma mark - Util
// eg: form="userdata.a.b" -> key = "userdata", path = "a.b"
- (void)extractFirstKey:(NSString **)firstKey path:(NSString **)path from:(NSString *)from {
    NSMutableArray *coms = [from componentsSeparatedByString:@"."].mutableCopy;
    *firstKey = coms.firstObject;
    if (coms.count >= 2) {
        [coms removeObjectAtIndex:0];
        *path = [coms componentsJoinedByString:@"."];
    }
}

- (void)_realAddObserver:(NSObject<MLNKVOObserverProtol> *)observer forKeyPath:(NSString *)keyPath isArray:(BOOL)isArray {
    NSParameterAssert(observer && keyPath);
    if (!observer || !keyPath) return;
    
    NSString *key, *path;
    if (!isArray) {
        [self extractFirstKey:&key path:&path from:keyPath];
        if (!key || !path) {
            NSLog(@"key: %@ and path: %@ should not be nil",key,path);
            return;
        }
    } else {
        key = keyPath;
    }

    NSObject *object = [self dataForKeyPath:key];
    // 只有NSMutableArray才有必要添加observer
    if (isArray && ![object isKindOfClass:[NSMutableArray class]]) {
        NSLog(@"binded object %@, is not KindOf NSMutableArray",object);
        return;
    }

    LOCK();
    NSMutableArray *observerArray = [self.observerMap objectForKey:keyPath];
    if (!observerArray) {
        observerArray = [NSMutableArray array];
        [self.observerMap setObject:observerArray forKey:keyPath];
    }
    
    __weak __typeof(self)weakSelf = self;
    void(^obBlock)(NSString*,NSObject*,NSDictionary*) = ^(NSString *kp, NSObject *object, NSDictionary *change) {
        __strong __typeof(weakSelf)self = weakSelf;
        if (self) {
            pthread_mutex_lock(&self->_lock);
            NSArray *obsCopy = observerArray.copy;
            pthread_mutex_unlock(&self->_lock);
            for (NSObject<MLNKVOObserverProtol> *ob in obsCopy) {
                [ob mln_observeValueForKeyPath:kp ofObject:object change:change];
            }
        }
    };
    
    if (!isArray) {
        [self.KVOController observe:object keyPath:path options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld block:^(id  _Nullable obs, id  _Nonnull object, NSDictionary<NSKeyValueChangeKey,id> * _Nonnull change) {
            obBlock(path, object, change);
        }];
    } else {
        NSMutableArray *bindArray = (NSMutableArray *)object;
        [bindArray mln_startKVOIfMutableble];
        
        [bindArray mln_addObserverHandler:^(NSMutableArray * _Nonnull array, NSDictionary<NSKeyValueChangeKey,id> * _Nonnull change) {
            obBlock(nil, array, change);
        }];
        
        if ([bindArray mln_is2D]) {
            [bindArray enumerateObjectsUsingBlock:^(NSMutableArray* _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if ([obj isKindOfClass:[NSMutableArray class]]) {
                    [obj mln_addObserverHandler:^(NSMutableArray * _Nonnull array, NSDictionary<NSKeyValueChangeKey,id> * _Nonnull change) {
                        obBlock(nil, obj, change);
                    }];
                }
            }];
        }
    }
    
    if (![observerArray containsObject:observer]) {
        [observerArray addObject:observer];
    }
    UNLOCK();
}

- (void)dealloc {
    NSLog(@"---- dealloc : %s %p",__FUNCTION__, self);
}

@end
