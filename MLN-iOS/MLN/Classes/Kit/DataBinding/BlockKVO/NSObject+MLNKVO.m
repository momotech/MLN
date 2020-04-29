//
//  NSObject+MLNKVO.m
//  MLN
//
//  Created by Dai Dongpeng on 2020/4/29.
//

#import "NSObject+MLNKVO.h"
#import "KVOController.h"
#import "MLNKVOObserver.h"
#import "MLNExtScope.h"

@import ObjectiveC;

@interface MLNDeallocator : NSObject
@property (readonly, unsafe_unretained) NSObject *owner;
@property (readonly, strong) NSMutableArray<MLNDeallocatorCallback> *callbacks;
@end

@implementation MLNDeallocator

- (instancetype)initWithOwner:(NSObject*)owner {
    self = [super init];
    if (self) {
        _owner = owner;
        _callbacks = [NSMutableArray new];
    }
    return self;
}

- (void)addCallback:(MLNDeallocatorCallback)block {
    if (block)
        [_callbacks addObject:block];
}

- (void)invokeCallbacks {
    NSArray<MLNDeallocatorCallback> *blocks = _callbacks;
    _callbacks = nil;
    
    __unsafe_unretained NSObject *owner = _owner;
    for (MLNDeallocatorCallback block in blocks) {
        block(owner);
    }
}

- (void)dealloc {
    [self invokeCallbacks];
}
@end

@implementation NSObject (MLNKVO)

#pragma mark - Public
- (NSObject * _Nonnull (^)(NSString * _Nonnull, MLNBlockChange _Nonnull))mln_watch {
        @weakify(self);
        return ^(NSString *keyPath, MLNKVOBlock block){
            @strongify(self);
            if (self && block) {
                
//                MLNKVOObserver *ob = [[MLNKVOObserver alloc] initWithViewController:nil callback:^(NSString * _Nonnull keyPath, id  _Nonnull object, NSDictionary<NSKeyValueChangeKey,id> * _Nonnull change) {
//                    id oldValue = [change objectForKey:NSKeyValueChangeOldKey];
//                    id newValue = [change objectForKey:NSKeyValueChangeNewKey];
//                    block(oldValue, newValue);
//                } keyPath:keyPath];
//
//                [self.KVOControllerNonRetaining observe:self keyPath:keyPath options:NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew block:^(id  _Nullable observer, id  _Nonnull object, NSDictionary<NSString *,id> * _Nonnull change) {
//                    [ob mln_observeValueForKeyPath:keyPath ofObject:object change:change];
//                }];
                [self mln_observeProperty:keyPath withBlock:^(id  _Nonnull oldValue, id  _Nonnull newValue) {
                    block(oldValue, newValue);
                }];

            }
            return self;
        };
}

static const void *MLNDeallocatorAssociationKey = &MLNDeallocatorAssociationKey;
- (void)mln_addDeallocationCallback:(MLNDeallocatorCallback)block {
    @synchronized (self) {
        @autoreleasepool {
            MLNDeallocator *dealloctor = objc_getAssociatedObject(self, MLNDeallocatorAssociationKey);
            if (!dealloctor) {
                dealloctor = [[MLNDeallocator alloc] initWithOwner:self];
                objc_setAssociatedObject(self, MLNDeallocatorAssociationKey, dealloctor, OBJC_ASSOCIATION_RETAIN);
            }
            [self.class mln_swizzleDeallocIfNeeded];
            [dealloctor addCallback:block];
        }
    }
}

- (void)mln_observeProperty:(NSString *)keyPath withBlock:(MLNBlockChange)observationBlock {
    [self mln_observeObject:self property:keyPath withBlock:observationBlock];
}

#pragma mark - Private
+ (BOOL)mln_swizzleDeallocIfNeeded {
    static NSMutableSet *swizzledClasses = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        swizzledClasses = [NSMutableSet new];
    });
    
    @synchronized (self) {
        if ([swizzledClasses containsObject:self]) {
            return NO;
        }
        
        SEL deallocSelector = NSSelectorFromString(@"dealloc");
        Method dealloc = class_getInstanceMethod(self, deallocSelector);
        
        void(*oldIMP)(id, SEL) = (typeof(oldIMP))method_getImplementation(dealloc);
        void(^newIMPBlock)(id) = ^(__unsafe_unretained NSObject *self_deallocating) {
            MLNDeallocator *deallocator = objc_getAssociatedObject(self_deallocating, MLNDeallocatorAssociationKey);
            [deallocator invokeCallbacks];
            oldIMP(self_deallocating, deallocSelector);
        };
        
        IMP newIMP = imp_implementationWithBlock(newIMPBlock);
        class_replaceMethod(self, deallocSelector, newIMP, method_getTypeEncoding(dealloc));
        [swizzledClasses addObject:self];
        return YES;
    }
}

- (void)mln_observeObject:(id)object property:(NSString *)keyPath withBlock:(MLNBlockChange)observationBlock {
    MLNObserver *observer = nil;
    @autoreleasepool {
        observer = [object mln_observerForKeyPath:keyPath owner:self];
    }
    __weak __typeof(self)weakSelf = self;
    [observer addSettingObservationBlock:^(id  _Nonnull oldValue, id  _Nonnull newValue) {
        __unused __strong __typeof(weakSelf)strongSelf = weakSelf;
        observationBlock(oldValue, newValue);
    }];
}

- (MLNObserver *)mln_observerForKeyPath:(NSString *)keyPath owner:(id)owner {
    MLNObserver *observer = nil;
    NSMutableDictionary *observers = [self mln_keyPathBlockObserversCreateIfNeeded:YES];
    NSMutableSet *observersForKeyPath = [observers objectForKey:keyPath];
    if (!observersForKeyPath) {
        observersForKeyPath = [NSMutableSet set];
        [observers setObject:observersForKeyPath forKey:keyPath];
    } else {
        for (MLNObserver *existingObserver in observersForKeyPath) {
            if (existingObserver.owner == owner) {
                observer = existingObserver;
                break;
            }
        }
    }
    if (!observer) {
        observer = [[MLNObserver alloc] initWithTarget:self keyPath:keyPath owner:owner];
        [observersForKeyPath addObject:observer];
        [observer attach];
        
        if (owner != self) {
            __weak MLNObserver *weakObserver = observer;
            [owner mln_addDeallocationCallback:^(id  _Nonnull receiver) {
                [weakObserver.target mln_removeObervationsForOwner:receiver keyPath:keyPath];
            }];
        }
    }
    return observer;
}

- (NSMutableDictionary *)mln_keyPathBlockObserversCreateIfNeeded:(BOOL)shouldCreate {
    @synchronized (self) {
        NSMutableDictionary *keyPathObservers = objc_getAssociatedObject(self, _cmd);
        if (!keyPathObservers && shouldCreate) {
            keyPathObservers = [NSMutableDictionary dictionary];
            objc_setAssociatedObject(self, _cmd, keyPathObservers, OBJC_ASSOCIATION_RETAIN);
            [self mln_addDeallocationCallback:^(id  _Nonnull receiver) {
                [receiver mln_removeAllObservations];
            }];
        }
        return keyPathObservers;
    }
}

- (void)mln_removeAllObservations {
    NSMutableDictionary *keyPathBlockObservers = [self mln_keyPathBlockObserversCreateIfNeeded:NO];
    for (NSMutableSet *observersForKeyPath in keyPathBlockObservers.allValues) {
        [observersForKeyPath makeObjectsPerformSelector:@selector(detach)];
        [observersForKeyPath removeAllObjects];
    }
    [keyPathBlockObservers removeAllObjects];
}

- (void)mln_removeObervationsForOwner:(id)owner keyPath:(NSString *)keyPath {
    NSMutableSet *observersForKeyPath = [self mln_keyPathBlockObserversCreateIfNeeded:NO][keyPath]
    ;
    
    NSMutableSet *observersForOwnerForKeyPath = [NSMutableSet set];
    for (MLNObserver *observer in observersForKeyPath) {
        if (observer.owner == owner) {
            [observersForOwnerForKeyPath addObject:observer];
        }
    }
    
    for (MLNObserver *observer in observersForOwnerForKeyPath) {
        [observer detach];
        [observersForKeyPath removeObject:observer];
    }
}
@end

@implementation NSObject (MLNDeprecated)
- (NSObject * _Nonnull (^)(NSString * _Nonnull, MLNKVOBlock _Nonnull))mln_subscribe {
    @weakify(self);
    return ^(NSString *keyPath, MLNKVOBlock block){
        @strongify(self);
        if (self && block) {
//            [self.KVOControllerNonRetaining observe:self keyPath:keyPath options:NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew block:^(id  _Nullable observer, id  _Nonnull object, NSDictionary<NSString *,id> * _Nonnull change) {
//                id oldValue = [change objectForKey:NSKeyValueChangeOldKey];
//                id newValue = [change objectForKey:NSKeyValueChangeNewKey];
//                block(oldValue, newValue);
//            }];
            
            MLNKVOObserver *ob = [[MLNKVOObserver alloc] initWithViewController:nil callback:^(NSString * _Nonnull keyPath, id  _Nonnull object, NSDictionary<NSKeyValueChangeKey,id> * _Nonnull change) {
                id oldValue = [change objectForKey:NSKeyValueChangeOldKey];
                id newValue = [change objectForKey:NSKeyValueChangeNewKey];
                block(oldValue, newValue);
            } keyPath:keyPath];
            
            [self.KVOControllerNonRetaining observe:self keyPath:keyPath options:NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew block:^(id  _Nullable observer, id  _Nonnull object, NSDictionary<NSString *,id> * _Nonnull change) {
                [ob mln_observeValueForKeyPath:keyPath ofObject:object change:change];
            }];

        }
        return self;
    };
}
@end
