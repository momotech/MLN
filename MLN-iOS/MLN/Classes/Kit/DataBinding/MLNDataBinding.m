//
//  MLNDataBinding.m
// MLN
//
//  Created by Dai Dongpeng on 2020/3/3.
//

#import "MLNDataBinding.h"
#import <pthread.h>
#import "NSMutableArray+MLNKVO.h"
#import "NSArray+MLNKVO.h"
#import "MLNExtScope.h"
#import "NSObject+MLNKVO.h"
#import "NSObject+MLNDealloctor.h"
#import "MLNExtScope.h"

@interface MLNDataBinding() {
    pthread_mutex_t _lock;
}
@property (nonatomic, strong) NSMutableDictionary *dataMap;
@property (nonatomic, strong) NSMapTable *observerMap;
@property (nonatomic, strong) NSMapTable *observerIDsMap;
@end

@implementation MLNDataBinding

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.dataMap = [NSMutableDictionary dictionary];
        self.observerMap =  [NSMapTable strongToStrongObjectsMapTable];
        self.observerIDsMap = [NSMapTable strongToWeakObjectsMapTable];
        LOCK_RECURSIVE_INIT();
    }
    return self;
}

#pragma mark - Public

- (void)bindData:(NSObject *)data forKey:(NSString *)key {
    NSParameterAssert(key);
    if (key) {
        LOCK();
        [self.dataMap setValue:data forKey:key];
        UNLOCK();
    }
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

- (NSString *)addMLNObserver:(NSObject<MLNKVOObserverProtol> *)observer forKeyPath:(NSString *)keyPath {
    NSParameterAssert(observer && keyPath);
    if (!observer || !keyPath) return nil;
    
    NSArray *keys = [keyPath componentsSeparatedByString:@"."];
    return [self addMLNObserver:observer forKeys:keys];
}

- (void)removeMLNObserver:(NSObject<MLNKVOObserverProtol> *)observer forKeyPath:(NSString *)keyPath {
    NSParameterAssert(observer && keyPath);
    if (!observer || !keyPath) return;
    
    NSArray *keys = [keyPath componentsSeparatedByString:@"."];
    [self removeMLNObserver:observer forKeys:keys];
}

- (void)removeMLNObserverByID:(NSString *)observerID {
    NSParameterAssert(observerID);
    if(!observerID) return;
    
    LOCK();
    id<MLNKVOObserverProtol> observer = [self.observerIDsMap objectForKey:observerID];
    UNLOCK();
    if (observer && [observer respondsToSelector:@selector(keyPath)]) {
        [self removeMLNObserver:observer forKeyPath:[observer keyPath]];
    }
}

#pragma mark - Array
- (void)bindArray:(NSArray *)array forKey:(NSString *)key {
    [self bindData:array forKey:key];
}

#pragma mark - Lua KeyPath
- (id)dataForKeyPath:(NSString *)keyPath {
    NSParameterAssert(keyPath);
    if(!keyPath) return nil;
    NSArray *keys = [keyPath componentsSeparatedByString:@"."];
    return [self dataForKeys:keys];
}

- (void)updateDataForKeyPath:(NSString *)keyPath value:(id)value {
    NSParameterAssert(keyPath);
    if(!keyPath) return;
    
    NSArray *keys = [keyPath componentsSeparatedByString:@"."];
    [self updateDataForKeys:keys value:value];
}

#pragma mark - Lua Keys

- (id __nullable)dataForKeys:(NSArray *)keys {
    NSParameterAssert(keys);
    if(!keys) return nil;
    return [self dataForKeysArray:keys frontObject:NULL];
}

- (void)updateDataForKeys:(NSArray *)keys value:(id)value {
    NSParameterAssert(keys);
    NSString *firstKey = keys.firstObject;
    if(![firstKey isKindOfClass:[NSString class]]) return;
    NSString *lastKey = keys.lastObject;
    
    if (keys.count == 1) {
        LOCK();
        [self.dataMap setObject:value forKey:firstKey];
        UNLOCK();
    } else {
        NSObject *frontObject;
        [self dataForKeysArray:keys frontObject:&frontObject];
        int index = 0;
        BOOL isNum = [self scanInt:&index forStringOrNumber:lastKey];
        BOOL isMArray = [frontObject isKindOfClass:[NSMutableArray class]];
        if (isNum != isMArray) {
            NSLog(@"key %@ and  value %@ are incompatible",lastKey,frontObject);
            return;
        }
        @try {
            if (isMArray) {
                NSMutableArray *arr = (NSMutableArray *)frontObject;
                if (index >= arr.count) {
                    NSLog(@"index %d exceed range of array %zd",index,arr.count);
                    return;
                }
                value ? arr[index] = value : [arr removeObjectAtIndex:index];
            } else {
                [frontObject setValue:value forKeyPath:lastKey];
            }
        } @catch (NSException *exception) {
            NSLog(@"%@ %s",exception, __func__);
        }
    }
}

- (NSString *)addMLNObserver:(NSObject<MLNKVOObserverProtol> *)observer forKeys:(NSArray *)keys {
    NSParameterAssert(observer && [keys isKindOfClass:[NSArray class]]);
    if(!observer || ![keys isKindOfClass:[NSArray class]] || keys.count == 0) return nil;
    
    NSString *observerKey = [keys componentsJoinedByString:@"."];
    NSObject *frontObject;
    NSObject *object = [self dataForKeysArray:keys frontObject:&frontObject];
    NSString *path = keys.lastObject;
    NSString *uuid;
    if (keys.count == 1) {
        // TODO:监听dataMap.
    }
    /*
     ['source']:array, object != nil ,frontObject = nil
     ['userData']:object, object != nil, frontObject = nil
     ['userData','name'], object = nil, frontObject != nil
     */
    if (![frontObject isKindOfClass:[NSArray class]]) {
        uuid = [self _realAddDataObserver:observer forObject:frontObject keys:keys path:path];
    }
    
    if ([object isKindOfClass:[NSMutableArray class]]) {
        NSString *uuid2 = [self _realAddArrayObserver:observer forObject:object keys:keys];
        uuid = uuid2 ? uuid2 : uuid;
    }
    return uuid;
}

- (void)removeMLNObserver:(NSObject<MLNKVOObserverProtol> *)observer forKeys:(NSArray *)keys {
    NSParameterAssert(observer && keys);
    if(!observer || ![keys isKindOfClass:[NSArray class]] || keys.count == 0) return;

    NSString *observerKey = [keys componentsJoinedByString:@"."];
    NSObject *frontObject;
    NSObject *object = [self dataForKeysArray:keys frontObject:&frontObject];
    NSString *path = keys.lastObject;
    if (keys.count == 1) {
        //TODO:移除监听dataMap
    }
    // not array, then path not number
    if (![frontObject isKindOfClass:[NSArray class]]) {
        [self _realRemoveDataObserver:observer forObject:frontObject observerKey:observerKey path:path];
    }
    if ([object isKindOfClass:[NSMutableArray class]]) {
        [self _realRemoveArrayObserver:observer forObject:(NSMutableArray *)object observerKey:observerKey];
    }
}

#pragma mark - Observer Private

- (NSString *)_realAddDataObserver:(NSObject<MLNKVOObserverProtol> *)observer forObject:(id)object keys:(NSArray *)keys  path:(NSString *)path {
    if (!object || !observer) return nil;
    NSString *uuid;
//    NSObject *object = [self _dataForKey:key path:nil];
    NSString *observerKey = [keys componentsJoinedByString:@"."];
    LOCK();
    NSMutableArray *observerArray = [self.observerMap objectForKey:observerKey];
    if (!observerArray) {
        observerArray = [NSMutableArray array];
        [self.observerMap setObject:observerArray forKey:observerKey];
    }
    
    @weakify(self);
    @weakify(observer);
    void(^obBlock)(NSString*,NSObject*,NSDictionary*) = ^(NSString *kp, NSObject *object, NSDictionary *change) {
        @strongify(self);
        @strongify(observer);
        if (self && observer) {
            [observer mln_observeValueForKeyPath:kp ofObject:object change:change];
        }
    };
    
    [observer mln_observeObject:object property:path withBlock:^(id  _Nonnull observer, id  _Nonnull object, id  _Nonnull oldValue, id  _Nonnull newValue, NSDictionary<NSKeyValueChangeKey,id> * _Nonnull change) {
        obBlock(path,object, change);
    }];
    
    [object mln_addDeallocationCallback:^(id  _Nonnull receiver) {
        @strongify(self);
        @strongify(observer);
        if (self && observer) {
            [self removeMLNObserver:observer forKeys:keys];
        }
    }];
    
    if (![observerArray containsObject:observer]) {
        [observerArray addObject:observer];
        uuid = [[NSUUID UUID] UUIDString];
        [self.observerIDsMap setObject:observer forKey:uuid];
    }
    UNLOCK();
    return uuid;
}

- (NSString *)_realAddArrayObserver:(NSObject<MLNKVOObserverProtol> *)observer forObject:(NSObject *)object keys:(NSArray *)keys {
    NSString *uuid;
//    NSObject *object = [self _dataForKey:key path:path];
    // 只有NSMutableArray才有必要添加observer
    if (![object isKindOfClass:[NSMutableArray class]]) {
        NSLog(@"binded object %@, is not KindOf NSMutableArray",object);
        return nil;
    }
    NSString *observerKey = [keys componentsJoinedByString:@"."];
    LOCK();
    NSMutableArray *observerArray = [self.observerMap objectForKey:observer];
    if (!observerArray) {
        observerArray = [NSMutableArray array];
        [self.observerMap setObject:observerArray forKey:observerKey];
    }
    
    @weakify(self);
    @weakify(observer);
    void(^obBlock)(NSString*,NSObject*,NSDictionary*) = ^(NSString *kp, NSObject *object, NSDictionary *change) {
        @strongify(self);
        @strongify(observer);
        if (self && observer) {
            [observer mln_observeValueForKeyPath:kp ofObject:object change:change];
        }
    };
    
    NSMutableArray *bindArray = (NSMutableArray *)object;
//        [bindArray mln_startKVOIfMutable];
    [observer mln_observeArray:bindArray withBlock:^(id  _Nonnull observer, id  _Nonnull object, id  _Nonnull oldValue, id  _Nonnull newValue, NSDictionary<NSKeyValueChangeKey,id> * _Nonnull change) {
        obBlock(nil, object, change);
    }];
    
    if ([bindArray mln_is2D]) {
        @weakify(bindArray);
        [bindArray enumerateObjectsUsingBlock:^(NSMutableArray*  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj isKindOfClass:[NSMutableArray class]]) {
                [observer mln_observeArray:obj withBlock:^(id  _Nonnull observer, id  _Nonnull object, id  _Nonnull oldValue, id  _Nonnull newValue, NSDictionary<NSKeyValueChangeKey,id> * _Nonnull change) {
                    @strongify(bindArray);
                    NSMutableDictionary *newChange = change.mutableCopy;
                    [newChange setValue:bindArray forKey:MLNKVOOrigin2DArrayKey];
                    obBlock(nil, object, newChange);
                }];
            }
        }];
    }
    
    if (![observerArray containsObject:observer]) {
        [observerArray addObject:observer];
        uuid = [[NSUUID UUID] UUIDString];
        [self.observerIDsMap setObject:observer forKey:uuid];
    }
    UNLOCK();
    return uuid;
}

- (void)_realRemoveDataObserver:(NSObject<MLNKVOObserverProtol> *)observer forObject:(NSObject *)object observerKey:(NSString *)observerKey path:(NSString *)path {
    if(!observer) return;
    
    if (observerKey && observer) {
        LOCK();
        NSMutableArray *observers = [self.observerMap objectForKey:observerKey];
        [observers removeObject:observer];
        UNLOCK();
    }
    
    if (path) {
        [object mln_removeObervationsForOwner:observer keyPath:path];
    }
}

- (void)_realRemoveArrayObserver:(NSObject<MLNKVOObserverProtol> *)observer forObject:(NSMutableArray *)object observerKey:(NSString *)observerKey {
    if(!observer) return;
    
    if (observerKey) {
        LOCK();
        NSMutableArray *observers = [self.observerMap objectForKey:observerKey];
        [observers removeObject:observer];
        UNLOCK();
    }
    
    if (![object isKindOfClass:[NSMutableArray class]]) {
        return;
    }
    [object mln_removeArrayObervationsForOwner:observer];

    if ([object mln_is2D]) { //处理二维数组
        @weakify(observer);
        [object enumerateObjectsUsingBlock:^(NSMutableArray *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            @strongify(observer);
            if ([obj isKindOfClass:[NSMutableArray class]]) {
                [obj mln_removeArrayObervationsForOwner:observer];
            }
        }];
    }
}

#pragma mark - GetData Private

- (id)dataForKeysArray:(NSArray *)keys frontObject:(NSObject **)frontObject {
    NSString *firstKey = keys.firstObject;
    if(!firstKey) return nil;
    
    LOCK();
    NSObject *obj = [self.dataMap objectForKey:firstKey];
    UNLOCK();
    NSObject *res = obj;
    // 从第二个位置开始遍历
    for (int i = 1; i < keys.count; i++) {
        if (i == keys.count - 1 && frontObject) {
            *frontObject = res;
        }
        NSString *k = keys[i];
        int index = 0;
        BOOL isNum = [self scanInt:&index forStringOrNumber:k];
        BOOL isArray = [res isKindOfClass:[NSArray class]];
        if (isNum != isArray) {
            if(frontObject) *frontObject = nil;
            NSLog(@"key %@ and  value %@ are incompatible",k,res);
            return nil;
        }
        if (isArray) {
            if (index >= [(NSArray *)res count]) {
                if(frontObject) *frontObject = nil;
                NSLog(@"index %d exceed rang of array %zd",index,[(NSArray *)res count]);
                return nil;
            }
            res = ((NSArray *)res)[index];
        } else {
            @try {
                res = [res valueForKeyPath:k];
            } @catch (NSException *exception) {
                NSLog(@"%@ %s",exception,__FUNCTION__);
                if(frontObject) *frontObject = nil;
                return nil;
            }
        }
    }
    return res;
}

#pragma mark - Utils
- (BOOL)scanInt:(int *)number forStringOrNumber:(NSString *)obj {
    if(!obj) return NO;
    
    if ([obj isKindOfClass:[NSNumber class]]) {
        *number = [(NSNumber *)obj intValue];
        return YES;
    }
#if 0 //兼容key是string类型
    NSScanner *scanner = [NSScanner scannerWithString:obj];
    return [scanner scanInt:number] && [scanner isAtEnd];
#endif
    return NO;
}

/*
 - (id)_dataForKey:(NSString *)key path:(NSString *)path {
     if (!key) return nil;
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
 
 - (NSString *)addDataObserver:(NSObject<MLNKVOObserverProtol> *)observer forKeyPath:(NSString *)keyPath {
 //    [self _realAddObserver:observer forKeyPath:keyPath isArray:NO];
     NSParameterAssert(observer && keyPath);
     if (!observer || !keyPath) return nil;
     
     NSString *key, *path;
     [self extractFirstKey:&key path:&path from:keyPath];
     if (!key || !path) {
         NSLog(@"key: %@ and path: %@ should not be nil",key,path);
         return nil;
     }
     NSObject *obj = [self _dataForKey:key path:nil];
     return [self _realAddDataObserver:observer forObject:obj observerKey:keyPath path:path];
 }

 - (void)removeDataObserver:(NSObject<MLNKVOObserverProtol> *)observer forKeyPath:(NSString *)keyPath {
 //    [self _realRemoveObserver:observer forKeyPath:keyPath forArray:NO];
     NSParameterAssert(observer && keyPath);
     if(!observer || !keyPath) return;
     
     LOCK();
     NSMutableArray *observers = [self.observerMap objectForKey:keyPath];
     [observers removeObject:observer];
     UNLOCK();

     NSString *key, *path;
     [self extractFirstKey:&key path:&path from:keyPath];
     if (!key || !path) {
         NSLog(@"key: %@ and path: %@ should not be nil",key,path);
         return;
     }
     id obj = [self _dataForKey:key path:path];
     [obj mln_removeObervationsForOwner:observer keyPath:path];
 }
 
// eg: form="userdata.a.b" -> key = "userdata", path = "a.b"
- (void)extractFirstKey:(NSString **)firstKey path:(NSString **)path from:(NSString *)from {
    NSMutableArray *coms = [from componentsSeparatedByString:@"."].mutableCopy;
    *firstKey = coms.firstObject;
    if (coms.count >= 2 && ![[coms lastObject] isEqualToString:@""]) {
        [coms removeObjectAtIndex:0];
        *path = [coms componentsJoinedByString:@"."];
    }
}

 - (NSString *)addArrayObserver:(NSObject<MLNKVOObserverProtol> *)observer forKey:(NSString *)keyPath {
 //    [self _realAddObserver:observer forKeyPath:key isArray:YES];
     NSString *uuid;
     NSParameterAssert(observer && keyPath);
     if (!observer || !keyPath) return nil;
     
     NSString *key, *path;
     [self extractFirstKey:&key path:&path from:keyPath];
     if (key && path) {
         // add data observer
         NSObject *object = [self _dataForKey:key path:nil];
         uuid = [self _realAddDataObserver:observer forObject:object observerKey:keyPath path:path];
     }
     NSObject *object = [self _dataForKey:key path:path];
     NSString *uuid2 = [self _realAddArrayObserver:observer forObject:object observerKey:keyPath];
     return uuid2 ? uuid2 : uuid;
 }

 - (void)removeArrayObserver:(NSObject<MLNKVOObserverProtol> *)observer forKey:(NSString *)keyPath {
 //    [self _realRemoveObserver:observer forKeyPath:key forArray:YES];
     NSParameterAssert(observer && keyPath);
     if(!observer || !keyPath) return;
     
     LOCK();
     NSMutableArray *observers = [self.observerMap objectForKey:keyPath];
     [observers removeObject:observer];
     UNLOCK();

     NSString *key, *path;
     [self extractFirstKey:&key path:&path from:keyPath];
     if (key && path) {
         // remove data observer
 //        [self removeDataObserver:observer forKeyPath:keyPath];
         id obj = [self _dataForKey:key path:nil];
         [obj mln_removeObervationsForOwner:observer keyPath:path];
     }
     id obj = [self _dataForKey:key path:path];
     [obj mln_removeArrayObervationsForOwner:observer];
 }
 */

//- (void)_realAddObserver:(NSObject<MLNKVOObserverProtol> *)observer forKeyPath:(NSString *)keyPath isArray:(BOOL)isArray {
//    NSParameterAssert(observer && keyPath);
//    if (!observer || !keyPath) return;
//
//    NSString *key, *path;
//    if (!isArray) {
//        [self extractFirstKey:&key path:&path from:keyPath];
//        if (!key || !path) {
//            NSLog(@"key: %@ and path: %@ should not be nil",key,path);
//            return;
//        }
//    } else {
//        key = keyPath;
//    }
//
//    NSObject *object = [self dataForKeyPath:key];
//    // 只有NSMutableArray才有必要添加observer
//    if (isArray && ![object isKindOfClass:[NSMutableArray class]]) {
//        NSLog(@"binded object %@, is not KindOf NSMutableArray",object);
//        return;
//    }
//
//    LOCK();
//    NSMutableArray *observerArray = [self.observerMap objectForKey:keyPath];
//    if (!observerArray) {
//        observerArray = [NSMutableArray array];
//        [self.observerMap setObject:observerArray forKey:keyPath];
//    }
//
//    @weakify(self);
//    @weakify(observer);
//    void(^obBlock)(NSString*,NSObject*,NSDictionary*) = ^(NSString *kp, NSObject *object, NSDictionary *change) {
//        @strongify(self);
//        @strongify(observer);
//        if (self && observer) {
////            pthread_mutex_lock(&self->_lock);
////            NSArray *obsCopy = observerArray.copy;
////            pthread_mutex_unlock(&self->_lock);
////            for (NSObject<MLNKVOObserverProtol> *ob in obsCopy) {
////                [ob mln_observeValueForKeyPath:kp ofObject:object change:change];
////            }
//            [observer mln_observeValueForKeyPath:kp ofObject:object change:change];
//        }
//    };
//
//    if (!isArray) {
//        [observer mln_observeObject:object property:path withBlock:^(id  _Nonnull observer, id  _Nonnull object, id  _Nonnull oldValue, id  _Nonnull newValue, NSDictionary<NSKeyValueChangeKey,id> * _Nonnull change) {
//            obBlock(path,object, change);
//        }];
//    } else {
//        NSMutableArray *bindArray = (NSMutableArray *)object;
////        [bindArray mln_startKVOIfMutable];
//
//        [observer mln_observeArray:bindArray withBlock:^(id  _Nonnull observer, id  _Nonnull object, id  _Nonnull oldValue, id  _Nonnull newValue, NSDictionary<NSKeyValueChangeKey,id> * _Nonnull change) {
//            obBlock(nil, object, change);
//        }];
//
//        if ([bindArray mln_is2D]) {
//            [bindArray enumerateObjectsUsingBlock:^(NSMutableArray*  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
//                if ([obj isKindOfClass:[NSMutableArray class]]) {
//                    [observer mln_observeArray:obj withBlock:^(id  _Nonnull observer, id  _Nonnull object, id  _Nonnull oldValue, id  _Nonnull newValue, NSDictionary<NSKeyValueChangeKey,id> * _Nonnull change) {
//                        obBlock(nil, object, change);
//                    }];
//                }
//            }];
//        }
//    }
//
//    if (![observerArray containsObject:observer]) {
//        [observerArray addObject:observer];
//    }
//    UNLOCK();
//}

/*
- (void)_realRemoveObserver:(NSObject<MLNKVOObserverProtol> *)observer forKeyPath:(NSString *)keyPath forArray:(BOOL)forArray {
    NSParameterAssert(observer && keyPath);
    if(!observer || !keyPath) return;
    
    LOCK();
    NSMutableArray *observers = [self.observerMap objectForKey:keyPath];
    [observers removeObject:observer];
    UNLOCK();

    NSString *key, *path;
    if (!forArray) {
        [self extractFirstKey:&key path:&path from:keyPath];
        if (!key || !path) {
            NSLog(@"key: %@ and path: %@ should not be nil",key,path);
            return;
        }
    } else {
        key = keyPath;
    }

    if (key) {
        id obj = [self dataForKeyPath:key];
        if (forArray) {
            [obj mln_removeArrayObervationsForOwner:observer];
        } else {
            [obj mln_removeObervationsForOwner:observer keyPath:path];
        }
    }
}
 */

// ex:keyPath=userData.source, key=userData, path=source
//- (NSString *)_realAddDataObserver:(NSObject<MLNKVOObserverProtol> *)observer forKeyPath:(NSString *)keyPath key:(NSString *)key path:(NSString *)path {
//    NSString *uuid;
//    NSObject *object = [self _dataForKey:key path:nil];
//    LOCK();
//    NSMutableArray *observerArray = [self.observerMap objectForKey:keyPath];
//    if (!observerArray) {
//        observerArray = [NSMutableArray array];
//        [self.observerMap setObject:observerArray forKey:keyPath];
//    }
//
//    @weakify(self);
//    @weakify(observer);
//    void(^obBlock)(NSString*,NSObject*,NSDictionary*) = ^(NSString *kp, NSObject *object, NSDictionary *change) {
//        @strongify(self);
//        @strongify(observer);
//        if (self && observer) {
//            [observer mln_observeValueForKeyPath:kp ofObject:object change:change];
//        }
//    };
//
//    [observer mln_observeObject:object property:path withBlock:^(id  _Nonnull observer, id  _Nonnull object, id  _Nonnull oldValue, id  _Nonnull newValue, NSDictionary<NSKeyValueChangeKey,id> * _Nonnull change) {
//        obBlock(path,object, change);
//    }];
//
//    [object mln_addDeallocationCallback:^(id  _Nonnull receiver) {
//        @strongify(self);
//        @strongify(observer);
//        if (self && observer) {
//            [self removeMLNObserver:observer forKeyPath:keyPath];
//        }
//    }];
//
//    if (![observerArray containsObject:observer]) {
//        [observerArray addObject:observer];
//        uuid = [[NSUUID UUID] UUIDString];
//        [self.observerIDsMap setObject:observer forKey:uuid];
//    }
//    UNLOCK();
//    return uuid;
//}
@end
