//
//  NSObject+MLNUIKVO.m
//  MLNUI
//
//  Created by Dai Dongpeng on 2020/4/29.
//

#import "NSObject+MLNUIKVO.h"
#import "MLNUIKVOObserver.h"
#import "MLNUIExtScope.h"
#import "NSObject+MLNUIDealloctor.h"
#import "MLNUIArrayObserver.h"

#define kArrayKVOPlaceHolder @"kArrayKVOPlaceHolder"

@import ObjectiveC;

@implementation NSObject (MLNUIKVO)

#pragma mark - Public
- (NSObject * _Nonnull (^)(NSString * _Nonnull, MLNUIKVOBlock _Nonnull))mlnui_watch {
        @weakify(self);
        return ^(NSString *keyPath, MLNUIKVOBlock block){
            @strongify(self);
            if (self && block) {
                [self mlnui_observeProperty:keyPath withBlock:^(id  _Nonnull observer, id  _Nonnull object, id  _Nonnull oldValue, id  _Nonnull newValue, NSDictionary<NSKeyValueChangeKey,id> * _Nonnull change) {
                    block(oldValue, newValue, object);
                }];

            }
            return self;
        };
}

- (void)mlnui_observeProperty:(NSString *)keyPath withBlock:(MLNUIBlockChange)observationBlock {
    [self mlnui_observeObject:self property:keyPath withBlock:observationBlock];
}


- (void)mlnui_observeObject:(id)object property:(NSString *)keyPath withBlock:(MLNUIBlockChange)observationBlock {
    MLNUIObserver *observer = nil;
    @autoreleasepool {
        observer = [object mlnui_observerForKeyPath:keyPath owner:self];
    }
    __weak __typeof(self)weakSelf = self;
    [observer addObservationBlock:^(id  _Nonnull observer, id  _Nonnull object, id  _Nonnull oldValue, id  _Nonnull newValue, NSDictionary<NSKeyValueChangeKey,id> * _Nonnull change) {
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        observationBlock(strongSelf, object, oldValue, newValue, change);
    }];
}

- (void)mlnui_observeObject:(id)object properties:(NSArray <NSString *> *)keyPaths withBlock:(MLNUIBlockChangeMany)observationBlock {
    for (NSString *keyPath in keyPaths) {
        [self mlnui_observeObject:object property:keyPath withBlock:^(id  _Nonnull observer, id  _Nonnull object, id  _Nonnull oldValue, id  _Nonnull newValue, NSDictionary<NSKeyValueChangeKey,id> * _Nonnull change) {
            observationBlock(observer, object, keyPath, oldValue, newValue, change);
        }];
    }
}

- (MLNUIObserver *)mlnui_observerForKeyPath:(NSString *)keyPath owner:(id)owner {
    MLNUIObserver *observer = nil;
    NSMutableDictionary *observers = [self mlnui_keyPathBlockObserversCreateIfNeeded:YES];
    NSMutableSet *observersForKeyPath = [observers objectForKey:keyPath];
    if (!observersForKeyPath) {
        observersForKeyPath = [NSMutableSet set];
        [observers setObject:observersForKeyPath forKey:keyPath];
    } else {
        for (MLNUIObserver *existingObserver in observersForKeyPath) {
            if (existingObserver.owner == owner) {
                observer = existingObserver;
                break;
            }
        }
    }
    if (!observer) {
        if ([keyPath isEqualToString:kArrayKVOPlaceHolder] && [self isKindOfClass:[NSMutableArray class]]) {
            observer = [[MLNUIArrayObserver alloc] initWithTarget:(NSMutableArray *)self keyPath:kArrayKVOPlaceHolder owner:owner];
        } else {
            observer = [[MLNUIObserver alloc] initWithTarget:self keyPath:keyPath owner:owner];;
        }
        [observersForKeyPath addObject:observer];
        [observer attach];
        
        if (owner != self) {
            __weak MLNUIObserver *weakObserver = observer;
            [owner mlnui_addDeallocationCallback:^(id  _Nonnull receiver) {
                [weakObserver.target mlnui_removeObervationsForOwner:receiver keyPath:keyPath];
            }];
        }
    }
    return observer;
}

- (NSMutableDictionary *)mlnui_keyPathBlockObserversCreateIfNeeded:(BOOL)shouldCreate {
    @synchronized (self) {
        NSMutableDictionary *keyPathObservers = objc_getAssociatedObject(self, _cmd);
        if (!keyPathObservers && shouldCreate) {
            keyPathObservers = [NSMutableDictionary dictionary];
            objc_setAssociatedObject(self, _cmd, keyPathObservers, OBJC_ASSOCIATION_RETAIN);
            [self mlnui_addDeallocationCallback:^(id  _Nonnull receiver) {
                [receiver mlnui_removeAllObservations];
            }];
        }
        return keyPathObservers;
    }
}

- (void)mlnui_removeAllObservations {
    NSMutableDictionary *keyPathBlockObservers = [self mlnui_keyPathBlockObserversCreateIfNeeded:NO];
    for (NSMutableSet *observersForKeyPath in keyPathBlockObservers.allValues) {
        [observersForKeyPath makeObjectsPerformSelector:@selector(detach)];
        [observersForKeyPath removeAllObjects];
    }
    [keyPathBlockObservers removeAllObjects];
}

- (void)mlnui_removeObervationsForOwner:(id)owner keyPath:(NSString *)keyPath {
    [self _real_mlnui_removeObervationsForOwner:owner keyPath:keyPath];
}

- (void)mlnui_removeAllObervationsForkeyPath:(NSString *)keyPath {
    [self _real_mlnui_removeObervationsForOwner:nil keyPath:keyPath];
}

- (void)_real_mlnui_removeObervationsForOwner:(nullable id)owner keyPath:(NSString *)keyPath {
    NSMutableSet *observersForKeyPath = [self mlnui_keyPathBlockObserversCreateIfNeeded:NO][keyPath]
    ;
    
    NSMutableSet *observersForOwnerForKeyPath;
    if (owner) {
        observersForOwnerForKeyPath = [NSMutableSet set];
        for (MLNUIObserver *observer in observersForKeyPath) {
            if (observer.owner == owner) {
                [observersForOwnerForKeyPath addObject:observer];
            }
        }
    } else { // owner = nil,remove all observers for keypath
        observersForOwnerForKeyPath = observersForKeyPath;
    }
    
    for (MLNUIObserver *observer in observersForOwnerForKeyPath) {
        [observer detach];
        [observersForKeyPath removeObject:observer];
    }
}

@end

#import "MLNUIArrayObserver.h"
@implementation NSObject (MLNUIArrayKVO)

- (void)mlnui_observeArray:(NSMutableArray *)array withBlock:(MLNUIBlockChange)observationBlock {
    MLNUIObserver *observer = nil;
    @autoreleasepool {
        observer = [array mlnui_observerForKeyPath:kArrayKVOPlaceHolder owner:self];
    }
    __weak __typeof(self)weakSelf = self;
    [observer addObservationBlock:^(id  _Nonnull observer, id  _Nonnull object, id  _Nonnull oldValue, id  _Nonnull newValue, NSDictionary<NSKeyValueChangeKey,id> * _Nonnull change) {
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        observationBlock(strongSelf, object, oldValue, newValue, change);
    }];
}

- (void)mlnui_removeArrayObervationsForOwner:(id)owner {
    [self mlnui_removeObervationsForOwner:owner keyPath:kArrayKVOPlaceHolder];
}

- (void)mlnui_removeAllArrayObservations {
    [self mlnui_removeAllObervationsForkeyPath:kArrayKVOPlaceHolder];
}
@end

@implementation NSObject (MLNUIDeprecated)
- (NSObject * _Nonnull (^)(NSString * _Nonnull, MLNUIKVOBlock _Nonnull))mlnui_subscribe {
    return self.mlnui_watch;
}
@end
